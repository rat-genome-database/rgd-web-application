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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class VVService {
    private static String variantIndex;
    private final VariantSearchBean vsb;
    private final HttpRequestFacade req;

    public VVService(VariantSearchBean vsb, HttpRequestFacade req){
        this.vsb=vsb;
        this.req=req;
        String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey())).replace(" ","");
        variantIndex=RgdContext.getESVariantIndexName("variants_"+species.toLowerCase()+vsb.getMapKey());
    }

    public List<EsHit> getVariants() throws VVException {
        Query mainQuery = this.boolQuery();
        if (mainQuery == null) {
            return null;
        }
        List<EsHit> searchHits = new ArrayList<>();
        try {
            ElasticsearchClient client = ClientInit.getClient();
            if (req.getParameter("showDifferences").equals("true")) {
                SearchResponse<Map> sr = client.search(s -> s
                                .index(variantIndex)
                                .query(mainQuery)
                                .size(10000)
                                .scroll(Time.of(t -> t.time("1m"))),
                        Map.class);
                String scrollId = sr.scrollId();
                addHits(searchHits, sr.hits().hits());

                int lastPageSize = sr.hits().hits().size();
                while (lastPageSize > 0) {
                    final String sid = scrollId;
                    ScrollResponse<Map> scrollResp = client.scroll(sb -> sb
                                    .scrollId(sid)
                                    .scroll(Time.of(t -> t.time("60s"))),
                            Map.class);
                    scrollId = scrollResp.scrollId();
                    addHits(searchHits, scrollResp.hits().hits());
                    lastPageSize = scrollResp.hits().hits().size();
                }
                return this.excludeCommonVariants(searchHits);
            } else {
                SearchResponse<Map> sr = client.search(s -> s
                                .index(variantIndex)
                                .query(mainQuery)
                                .size(10000)
                                .scroll(Time.of(t -> t.time("1m"))),
                        Map.class);
                String scrollId = sr.scrollId();
                addHits(searchHits, sr.hits().hits());

                int lastPageSize = sr.hits().hits().size();
                while (lastPageSize > 0) {
                    final String sid = scrollId;
                    ScrollResponse<Map> scrollResp = client.scroll(sb -> sb
                                    .scrollId(sid)
                                    .scroll(Time.of(t -> t.time("100s"))),
                            Map.class);
                    scrollId = scrollResp.scrollId();
                    addHits(searchHits, scrollResp.hits().hits());
                    lastPageSize = scrollResp.hits().hits().size();
                }
                return searchHits;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new VVException(e.getMessage());
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
        String aggField = req.getParameter("showDifferences").equals("true") ? "regionName" : "sampleId";
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
        List<EsHit> nonSharedVariants = new ArrayList<>();
        List<Integer> verifiedPositions = new ArrayList<>();

        for (EsHit hit : searchHitList) {
            List<EsHit> tempList = new ArrayList<>();
            String chr = (String) hit.getSourceAsMap().get("chromosome");
            int startPos = (int) hit.getSourceAsMap().get("startPos");
            String varNuc = (String) hit.getSourceAsMap().get("varNuc");

            if (!verifiedPositions.contains(startPos)) {
                verifiedPositions.add(startPos);
                for (EsHit h : searchHitList) {
                    String chr1 = (String) h.getSourceAsMap().get("chromosome");
                    int startPos1 = (int) h.getSourceAsMap().get("startPos");
                    String varNuc1 = (String) h.getSourceAsMap().get("varNuc");
                    if (chr1 != null && chr1.equals(chr) && startPos1 == startPos && varNuc1 != null && varNuc1.equals(varNuc)) {
                        tempList.add(h);
                    }
                }
                if (tempList.size() > 0 && tempList.size() < vsb.sampleIds.size()) {
                    nonSharedVariants.addAll(tempList);
                }
            }
        }
        return nonSharedVariants;
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
