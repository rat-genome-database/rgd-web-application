package edu.mcw.rgd.vv.vvservice;


import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.Script;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.Time;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregation;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.DisMaxQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.ScrollResponse;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.JsonData;
import co.elastic.clients.util.NamedValue;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.vv.VVException;
import edu.mcw.rgd.web.EsHit;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class VVService {

    // One page of the scroll. Kept at the ES default ceiling for index.max_result_window.
    private static final int SCROLL_PAGE_SIZE = 10000;

    // Hard ceiling on how many hits a single request will hold in memory. A region query is
    // user-supplied and the variant indexes are the largest in the cluster, so without a cap one
    // request can scroll millions of documents into heap and take the whole JVM down. Overridable
    // with -Dvv.maxHits=... so this can be tuned on a server without a rebuild.
    private static final int MAX_HITS = Integer.getInteger("vv.maxHits", 200000);

    private final String variantIndex;
    private final VariantSearchBean vsb;
    private final HttpRequestFacade req;

    public VVService(VariantSearchBean vsb, HttpRequestFacade req){
        this.vsb=vsb;
        this.req=req;
        String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey())).replace(" ","");
        this.variantIndex=RgdContext.getESVariantIndexName("variants_"+species.toLowerCase()+vsb.getMapKey());
    }

    public List<EsHit> getVariants() throws VVException {
        Query mainQuery = this.boolQuery();
        if (mainQuery == null) {
            return null;
        }
        boolean showDifferences = "true".equals(req.getParameter("showDifferences"));
        List<EsHit> searchHits = scrollAll(mainQuery);
        return showDifferences ? this.excludeCommonVariants(searchHits) : searchHits;
    }

    /**
     * Scrolls the whole result set for the given query into memory, refusing to go past
     * {@link #MAX_HITS} rather than exhausting the heap, and always releasing the scroll context
     * on the cluster when it is done with it.
     */
    private List<EsHit> scrollAll(Query mainQuery) throws VVException {
        List<EsHit> searchHits = new ArrayList<>();
        String scrollId = null;
        ElasticsearchClient client;
        try {
            client = ClientInit.getClient();
            SearchResponse<Map> sr = client.search(s -> s
                            .index(variantIndex)
                            .query(mainQuery)
                            .size(SCROLL_PAGE_SIZE)
                            .scroll(Time.of(t -> t.time("1m"))),
                    Map.class);
            scrollId = sr.scrollId();
            addHits(searchHits, sr.hits().hits());

            int lastPageSize = sr.hits().hits().size();
            while (lastPageSize > 0) {
                if (searchHits.size() > MAX_HITS) {
                    throw new VVException("This region matches more than " + MAX_HITS
                            + " variants, which is too many to display. Please narrow the region,"
                            + " or select fewer samples, and try again.");
                }
                final String sid = scrollId;
                ScrollResponse<Map> scrollResp = client.scroll(sb -> sb
                                .scrollId(sid)
                                .scroll(Time.of(t -> t.time("1m"))),
                        Map.class);
                scrollId = scrollResp.scrollId();
                addHits(searchHits, scrollResp.hits().hits());
                lastPageSize = scrollResp.hits().hits().size();
            }
            return searchHits;
        } catch (VVException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new VVException(e.getMessage());
        } finally {
            clearScroll(scrollId);
        }
    }

    /**
     * Releases a scroll context instead of leaving it to expire. Each open scroll pins segments on
     * the data nodes, so letting them lapse on their keep-alive is real memory held cluster-side.
     */
    private static void clearScroll(String scrollId) {
        if (scrollId == null) {
            return;
        }
        try {
            ClientInit.getClient().clearScroll(c -> c.scrollId(scrollId));
        } catch (Exception ignored) {
            // the context expires on its own; nothing useful to do on a failed cleanup
        }
    }

    private static void addHits(List<EsHit> out, List<Hit<Map>> hits) {
        for (Hit<Map> h : hits) {
            @SuppressWarnings("unchecked")
            java.util.Map<String, Object> src = (java.util.Map<String, Object>) h.source();
            out.add(new EsHit(h.id(), src));
        }
    }

    public SearchResponse<Map> getAggregations() throws VVException {
        Query mainQuery = this.boolQuery();
        if (mainQuery == null) {
            return null;
        }
        String aggField = "true".equals(req.getParameter("showDifferences")) ? "regionName" : "sampleId";
        Aggregation agg = this.buildAggregation(aggField);
        try {
            ElasticsearchClient client = ClientInit.getClient();
            return client.search(s -> s
                            .index(variantIndex)
                            .size(0)
                            .query(mainQuery)
                            .aggregations(aggField, agg),
                    Map.class);
        } catch (IOException e) {
            throw new VVException(e.getMessage());
        }
    }

    public List<EsHit> excludeCommonVariants(List<EsHit> searchHitList) {
        // Group the hits by (chromosome, startPos, varNuc) in a single pass, then walk the list
        // once. This used to be a nested loop over the full hit list, which is O(n*n) -- at a few
        // hundred thousand hits it pinned the entire list live for minutes while it ran.
        Map<String, List<EsHit>> hitsByVariant = new LinkedHashMap<>();
        for (EsHit h : searchHitList) {
            java.util.Map<String, Object> src = h.getSourceAsMap();
            String chr = (String) src.get("chromosome");
            String varNuc = (String) src.get("varNuc");
            // the original match required both of these to be non-null on the candidate
            if (chr == null || varNuc == null) {
                continue;
            }
            String key = variantKey(chr, (int) src.get("startPos"), varNuc);
            hitsByVariant.computeIfAbsent(key, k -> new ArrayList<>()).add(h);
        }

        List<EsHit> nonSharedVariants = new ArrayList<>();
        Set<Integer> verifiedPositions = new HashSet<>();

        for (EsHit hit : searchHitList) {
            java.util.Map<String, Object> src = hit.getSourceAsMap();
            int startPos = (int) src.get("startPos");

            // only the first hit seen at a given startPos is considered -- preserved from the
            // original, which tracked verified positions by startPos alone
            if (!verifiedPositions.add(startPos)) {
                continue;
            }
            String chr = (String) src.get("chromosome");
            String varNuc = (String) src.get("varNuc");
            if (chr == null || varNuc == null) {
                continue; // the original matched nothing in this case
            }
            List<EsHit> sharing = hitsByVariant.get(variantKey(chr, startPos, varNuc));
            if (sharing != null && !sharing.isEmpty() && sharing.size() < vsb.sampleIds.size()) {
                nonSharedVariants.addAll(sharing);
            }
        }
        return nonSharedVariants;
    }

    private static String variantKey(String chromosome, int startPos, String varNuc) {
        return chromosome + '|' + startPos + '|' + varNuc;
    }

    public Aggregation buildAggregation(String fieldName) {
        if (fieldName.equalsIgnoreCase("sampleId")) {
            Map<String, Aggregation> subs = new LinkedHashMap<>();
            subs.put("region", Aggregation.of(a -> a.terms(t -> t.field("regionName.keyword").size(1000))));
            return Aggregation.of(a -> a
                    .terms(t -> t.field("sampleId").size(1000)
                            .order(List.of(NamedValue.of("_key", SortOrder.Asc))))
                    .aggregations(subs));
        }

        if (fieldName.equalsIgnoreCase("regionName")) {
            Map<String, Aggregation> startPosSubs = new LinkedHashMap<>();
            startPosSubs.put("sample", Aggregation.of(a -> a.terms(t -> t.field("sampleId"))));
            startPosSubs.put("varNuc", Aggregation.of(a -> a.terms(t -> t.field("varNuc.keyword").size(100000))));

            Map<String, Aggregation> regionSubs = new LinkedHashMap<>();
            regionSubs.put("startPos", Aggregation.of(a -> a
                    .terms(t -> t.field("startPos").size(100000)
                            .order(List.of(NamedValue.of("_key", SortOrder.Asc))))
                    .aggregations(startPosSubs)));

            return Aggregation.of(a -> a
                    .terms(t -> t.field("regionName.keyword").size(100000))
                    .aggregations(regionSubs));
        }

        return null;
    }

    public Query boolQuery() {
        Query dqb = this.getDisMaxQuery();
        if (dqb == null) {
            return null;
        }
        BoolQuery.Builder b = new BoolQuery.Builder();
        b.must(dqb);

        List<String> synStats = new ArrayList<>();
        List<String> genicStats = new ArrayList<>();
        List<String> vTypes = new ArrayList<>();
        List<String> locs = new ArrayList<>();
        List<String> zygosity = new ArrayList<>();
        List<Integer> alleleCount = new ArrayList<>();
        int depthLowBound = 0;
        int depthHighBound = 0;
        if (req.getParameter("nonSynonymous").equals("true")) {
            synStats.add("nonsynonymous");
        }
        if (req.getParameter("synonymous").equals("true")) {
            synStats.add("synonymous");
        }
        if (synStats.size() > 0) {
            b.filter(termsFilter("variantTranscripts.synStatus", toFieldValuesStr(synStats)));
        }
        if (req.getParameter("genic").equals("true")) {
            genicStats.add("GENIC");
        }
        if (req.getParameter("intergenic").equals("true")) {
            genicStats.add("INTERGENIC");
        }
        if (genicStats.size() > 0) {
            b.filter(termsFilter("genicStatus.keyword", toFieldValuesStr(genicStats)));
        }
        if (req.getParameter("snv").equals("true")) {
            vTypes.add("snv");
        }
        if (req.getParameter("ins").equals("true")) {
            vTypes.add("ins");
            vTypes.add("insertion");
        }
        if (req.getParameter("del").equals("true")) {
            vTypes.add("del");
            vTypes.add("deletion");
        }
        if (vTypes.size() > 0) {
            b.filter(termsFilter("variantType.keyword", toFieldValuesStr(vTypes)));
        }
        if (req.getParameter("intron").equals("true")) {
            locs.add("INTRON");
        }
        if (req.getParameter("3prime").equals("true")) {
            locs.add("3UTRS");
        }
        if (req.getParameter("5prime").equals("true")) {
            locs.add("5UTRS");
        }
        if (locs.size() > 0) {
            BoolQuery.Builder qb = new BoolQuery.Builder();
            for (String l : locs) {
                final String lf = l;
                qb.should(Query.of(q -> q.match(m -> m.field("variantTranscripts.locationName").query(FieldValue.of(lf)))));
            }
            b.filter(Query.of(q -> q.bool(qb.build())));
        }
        if (req.getParameter("nearSpliceSite").equals("true")) {
            b.filter(termFilter("variantTranscripts.nearSpliceSite.keyword", "T"));
        }
        if (req.getParameter("proteinCoding").equals("true")) {
            b.filter(Query.of(q -> q.exists(e -> e.field("variantTranscripts.refAA.keyword"))));
        }
        if (req.getParameter("frameshift").equals("true")) {
            b.filter(termFilter("variantTranscripts.frameShift.keyword", "T"));
        }
        List<String> pPredictions = new ArrayList<>();
        if (req.getParameter("benign").equals("true")) {
            pPredictions.add("benign");
        }
        if (req.getParameter("possibly").equals("true")) {
            pPredictions.add("possibly damaging");
        }
        if (req.getParameter("probably").equals("true")) {
            pPredictions.add("probably damaging");
        }
        if (pPredictions.size() > 0) {
            b.filter(termsFilter("variantTranscripts.polyphenStatus.keyword", toFieldValuesStr(pPredictions)));
        }

        // clinicalSignificance is constructed in the original but only used to drive the matchPhrase filters below
        if (req.getParameter("cs_pathogenic").equals("true")) {
            b.filter(Query.of(q -> q.matchPhrase(m -> m.field("clinicalSignificance").query("pathogenic"))));
        }
        if (req.getParameter("cs_benign").equals("true")) {
            b.filter(Query.of(q -> q.matchPhrase(m -> m.field("clinicalSignificance").query("benign"))));
        }
        if (req.getParameter("cs_other").equals("true")) {
            b.filter(Query.of(q -> q.matchPhrase(m -> m.field("clinicalSignificance").query("uncertain significance"))));
        }

        /***************************zygosity************************************/
        if (req.getParameter("het").equals("true")) {
            zygosity.add("heterozygous");
        }
        if (req.getParameter("hom").equals("true")) {
            zygosity.add("homozygous");
        }
        if (req.getParameter("possiblyHom").equals("true")) {
            zygosity.add("possibly homozygous");
        }
        if (zygosity.size() > 0) {
            b.filter(termsFilter("zygosityStatus.keyword", toFieldValuesStr(zygosity)));
        }
        /**********************alleleCount********************************/
        if (req.getParameter("alleleCount1").equals("true"))
            alleleCount.add(1);
        if (req.getParameter("alleleCount2").equals("true"))
            alleleCount.add(2);
        if (req.getParameter("alleleCount3").equals("true"))
            alleleCount.add(3);
        if (req.getParameter("alleleCount4").equals("true"))
            alleleCount.add(4);
        if (alleleCount.size() > 0) {
            b.filter(termsFilter("zygosityNumAllele", toFieldValuesInt(alleleCount)));
        }
        /********exclude possible error not working because new table structure doesn't have this data in the DB******/
        if (req.getParameter("excludePossibleError").equals("true")) {
            b.filter(termFilter("zygosityPossError.keyword", "N"));
        }
        if (req.getParameter("hetDiffFromRef").equals("true")) {
            b.filter(termFilter("zygosityRefAllele.keyword", "N"));
        }
        /**************************************LIMIT TO**********************************************/

        if (req.getParameter("prematureStopCodon").equals("true")) {
            BoolQuery.Builder inner = new BoolQuery.Builder();
            inner.must(Query.of(q -> q.script(sq -> sq.script(Script.of(s -> s
                    .source(src -> src.scriptString("doc['variantTranscripts.refAA.keyword'].value != doc['variantTranscripts.varAA.keyword'].value")))))));
            inner.filter(termFilter("variantTranscripts.varAA.keyword", "*"));
            b.filter(Query.of(q -> q.bool(inner.build())));
        }

        if (req.getParameter("readthroughMutation").equals("true")) {
            BoolQuery.Builder inner = new BoolQuery.Builder();
            inner.must(Query.of(q -> q.script(sq -> sq.script(Script.of(s -> s
                    .source(src -> src.scriptString("doc['variantTranscripts.refAA.keyword'].value != doc['variantTranscripts.varAA.keyword'].value")))))));
            inner.filter(termFilter("variantTranscripts.refAA.keyword", "*"));
            b.filter(Query.of(q -> q.bool(inner.build())));
        }
        /***********************readDepth****************************************/
        if (!req.getParameter("depthLowBound").equals(""))
            depthLowBound = Integer.parseInt(req.getParameter("depthLowBound"));
        if (!req.getParameter("depthHighBound").equals(""))
            depthHighBound = Integer.parseInt(req.getParameter("depthHighBound"));
        final int low = depthLowBound;
        final int high = depthHighBound;
        if ((low > 0 && high > 0) || (low == 0 && high > 0)) {
            b.filter(Query.of(q -> q.range(r -> r.untyped(u -> u
                    .field("totalDepth").gte(JsonData.of(low)).lte(JsonData.of(high))))));
        } else if (low > 0) {
            b.filter(Query.of(q -> q.range(r -> r.untyped(u -> u
                    .field("totalDepth").gte(JsonData.of(low))))));
        }
        if ((vsb.getMinConservation() == 0.0F) && (vsb.getMaxConservation() == 0.0F)) {
            b.filter(Query.of(q -> q.term(t -> t.field("conScores").value(FieldValue.of(0)))));
        } else {
            if (vsb.getMinConservation() > 0 && vsb.getMaxConservation() > 0) {
                final float minC = vsb.getMinConservation();
                final float maxC = vsb.getMaxConservation();
                b.filter(Query.of(q -> q.range(r -> r.untyped(u -> u
                        .field("conScores").gte(JsonData.of(minC)).lte(JsonData.of(maxC))))));
            }
        }
        return Query.of(q -> q.bool(b.build()));
    }

    public Query getDisMaxQuery() {
        List<Query> queries = new ArrayList<>();
        if (vsb.getGenes() != null && vsb.getGenes().size() > 0) {
            List<FieldValue> geneVals = vsb.getGenes().stream()
                    .map(g -> FieldValue.of(g.toLowerCase()))
                    .collect(Collectors.toList());
            List<FieldValue> sampleVals = vsb.getSampleIds().stream()
                    .map(FieldValue::of)
                    .collect(Collectors.toList());
            BoolQuery.Builder qb = new BoolQuery.Builder();
            qb.must(termsFilter("regionNameLc.keyword", geneVals));
            qb.filter(termsFilter("sampleId", sampleVals));
            queries.add(Query.of(q -> q.bool(qb.build())));
        } else {
            if (vsb.getChromosome() != null && !vsb.getChromosome().equals("")) {
                BoolQuery.Builder qb = new BoolQuery.Builder();
                qb.must(termFilter("chromosome.keyword", vsb.getChromosome()));
                if (vsb.sampleIds.size() > 0) {
                    List<FieldValue> sampleVals = vsb.sampleIds.stream()
                            .map(FieldValue::of)
                            .collect(Collectors.toList());
                    qb.filter(termsFilter("sampleId", sampleVals));
                }
                if (vsb.getStartPosition() != null && vsb.getStartPosition() >= 0 && vsb.getStopPosition() != null && vsb.getStopPosition() > 0
                        && (vsb.getGenes() == null || vsb.getGenes().size() == 0)) {
                    final long start = vsb.getStartPosition();
                    final long stop = vsb.getStopPosition();
                    qb.filter(Query.of(q -> q.range(r -> r.untyped(u -> u
                            .field("startPos").lte(JsonData.of(stop))))));
                    qb.filter(Query.of(q -> q.range(r -> r.untyped(u -> u
                            .field("endPos").gte(JsonData.of(start))))));
                }
                if (vsb.getGenes().size() > 0) {
                    List<FieldValue> geneVals = vsb.getGenes().stream()
                            .map(FieldValue::of)
                            .collect(Collectors.toList());
                    qb.filter(termsFilter("regionNameLc.keyword", geneVals));
                }
                queries.add(Query.of(q -> q.bool(qb.build())));
            } else {
                if (vsb.getVariantId() > 0) {
                    BoolQuery.Builder qb = new BoolQuery.Builder();
                    qb.must(Query.of(q -> q.term(t -> t.field("variant_id").value(FieldValue.of(vsb.getVariantId())))));
                    if (vsb.getSampleIds().size() > 0) {
                        List<FieldValue> sampleVals = vsb.sampleIds.stream()
                                .map(FieldValue::of)
                                .collect(Collectors.toList());
                        qb.filter(termsFilter("sampleId", sampleVals));
                    }
                    queries.add(Query.of(q -> q.bool(qb.build())));
                }
            }
        }
        if (queries.size() > 0) {
            return Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(queries))));
        }
        return null;
    }

    private static Query termFilter(String field, String value) {
        return Query.of(q -> q.term(t -> t.field(field).value(FieldValue.of(value))));
    }

    private static Query termsFilter(String field, List<FieldValue> values) {
        return Query.of(q -> q.terms(t -> t.field(field).terms(tqf -> tqf.value(values))));
    }

    private static List<FieldValue> toFieldValuesStr(List<String> values) {
        return values.stream().map(FieldValue::of).collect(Collectors.toList());
    }

    private static List<FieldValue> toFieldValuesInt(List<Integer> values) {
        return values.stream().map(i -> FieldValue.of((long) i)).collect(Collectors.toList());
    }
}
