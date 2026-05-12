package edu.mcw.rgd.phenominer.elasticsearch.service;


import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregate;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregation;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.DisMaxQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.util.NamedValue;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.vv.VVException;
import edu.mcw.rgd.web.EsBucket;
import edu.mcw.rgd.web.HttpRequestFacade;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

public class PhenominerService {
    private static String phenominerIndex;
    private static int speciesTypeKey = 3;

    public static void setPhenominerIndex(String phenominerIndex) {
        PhenominerService.phenominerIndex = phenominerIndex;
    }


    public SearchResponse<Map> getSearchResponse(HttpRequestFacade req, Map<String, String> filterMap) throws VVException, IOException {

        if (req.getParameter("species") != null && !req.getParameter("species").equals(""))
            speciesTypeKey = Integer.parseInt(req.getParameter("species"));

        Query mainQuery = this.boolQuery(req, filterMap);
        Map<String, Aggregation> aggs = new LinkedHashMap<>();
        aggs.put("cmoTermWithUnits", this.buildAggregation("cmoTermWithUnits"));
        aggs.put("cmoTerm", this.buildAggregation("cmoTerm"));
        aggs.put("mmoTerm", this.buildAggregation("mmoTerm"));
        aggs.put("rsTerm", this.buildAggregation("rsTerm"));
        aggs.put("xcoTerm", this.buildAggregation("xcoTerm"));
        aggs.put("vtTerm", this.buildAggregation("vtTerm"));
        aggs.put("sex", this.buildAggregation("sex"));
        aggs.put("units", this.buildAggregation("units"));

        ElasticsearchClient client = ClientInit.getClient();
        return client.search(s -> s
                        .index(phenominerIndex)
                        .query(mainQuery)
                        .size(10000)
                        .aggregations(aggs),
                Map.class);
    }

    public Aggregation buildAggregation(String fieldName) {
        if (fieldName.equalsIgnoreCase("units")) {
            Map<String, Aggregation> expSubs = new LinkedHashMap<>();
            expSubs.put("cmoTerm", Aggregation.of(a -> a.terms(t -> t.field("cmoTerm.keyword"))));
            Map<String, Aggregation> unitsSubs = new LinkedHashMap<>();
            unitsSubs.put("experimentName", Aggregation.of(a -> a
                    .terms(t -> t.field("experimentName.keyword"))
                    .aggregations(expSubs)));
            return Aggregation.of(a -> a
                    .terms(t -> t.field(fieldName + ".keyword").size(1000)
                            .order(List.of(NamedValue.of("_key", SortOrder.Asc))))
                    .aggregations(unitsSubs));
        }
        if (fieldName.equalsIgnoreCase("rsTerm") && speciesTypeKey == 3) {
            Map<String, Aggregation> rsSubs = new LinkedHashMap<>();
            rsSubs.put(fieldName, Aggregation.of(a -> a.terms(t -> t.field(fieldName + ".keyword"))));
            return Aggregation.of(a -> a
                    .terms(t -> t.field("rsTopLevelTerm.keyword").size(1000)
                            .order(List.of(NamedValue.of("_key", SortOrder.Asc))))
                    .aggregations(rsSubs));
        }
        return Aggregation.of(a -> a
                .terms(t -> t.field(fieldName + ".keyword").size(1000)
                        .order(List.of(NamedValue.of("_key", SortOrder.Asc)))));
    }

    public Query boolQuery(HttpRequestFacade req, Map<String, String> filterMap) {
        BoolQuery.Builder b = new BoolQuery.Builder();
        b.must(this.getDisMaxQuery(req));
        Map<String, List<String>> termsMap = getSegregatedTerms(req);
        if (termsMap.get("CMO") != null) {
            b.filter(termsFilterStr("cmoTermAcc.keyword", termsMap.get("CMO")));
        }
        if (termsMap.get("MMO") != null) {
            b.filter(termsFilterStr("mmoTermAcc.keyword", termsMap.get("MMO")));
        }
        if (termsMap.get("RS") != null) {
            b.filter(termsFilterStr("rsTermAcc.keyword", termsMap.get("RS")));
        }
        if (termsMap.get("XCO") != null) {
            b.filter(termsFilterStr("xcoTermAcc.keyword", termsMap.get("XCO")));
        }
        if (termsMap.get("VT") != null) {
            List<String> vts = termsMap.get("VT");
            BoolQuery.Builder vt = new BoolQuery.Builder();
            vt.should(termsFilterStr("vtTermAcc.keyword", vts));
            vt.should(termsFilterStr("vtTerm2Acc.keyword", vts));
            vt.should(termsFilterStr("vtTerm3Acc.keyword", vts));
            b.filter(Query.of(q -> q.bool(vt.build())));
        }

        if (filterMap != null && filterMap.size() > 0) {
            for (String key : filterMap.keySet()) {
                List<String> vals = Arrays.asList(filterMap.get(key).split(","));
                b.filter(termsFilterStr(key + ".keyword", vals));
            }
        }

        if (speciesTypeKey > 0) {
            b.filter(Query.of(q -> q.term(t -> t.field("speciesTypeKey").value(FieldValue.of(speciesTypeKey)))));
        }
        return Query.of(q -> q.bool(b.build()));
    }

    public Map<String, List<String>> getSegregatedTerms(HttpRequestFacade req) {
        Map<String, List<String>> segregatedTermsMap = new HashMap<>();
        List<String> terms = Arrays.asList(req.getParameter("terms").split(","));
        for (String term : terms) {
            if (term.contains("CMO")) {
                segregatedTermsMap.computeIfAbsent("CMO", k -> new ArrayList<>()).add(term);
            }
            if (term.contains("XCO")) {
                segregatedTermsMap.computeIfAbsent("XCO", k -> new ArrayList<>()).add(term);
            }
            if (term.contains("MMO")) {
                segregatedTermsMap.computeIfAbsent("MMO", k -> new ArrayList<>()).add(term);
            }
            if (term.contains("VT")) {
                segregatedTermsMap.computeIfAbsent("VT", k -> new ArrayList<>()).add(term);
            }
            if (term.contains("RS") || term.contains("CS")) {
                segregatedTermsMap.computeIfAbsent("RS", k -> new ArrayList<>()).add(term);
            }
        }
        return segregatedTermsMap;
    }

    public Query getDisMaxQuery(HttpRequestFacade req) {
        List<Query> queries = new ArrayList<>();
        if (req.getParameter("refRgdId") != null && !req.getParameter("refRgdId").equals("")
                && Integer.parseInt(req.getParameter("refRgdId")) > 0) {
            final int refRgdId = Integer.parseInt(req.getParameter("refRgdId"));
            queries.add(Query.of(q -> q.term(t -> t.field("refRgdId").value(FieldValue.of(refRgdId)))));
        } else {
            List<String> terms = Arrays.asList(req.getParameter("terms").split(","));
            queries.add(termsFilterStr("cmoTermAcc.keyword", terms));
            queries.add(termsFilterStr("mmoTermAcc.keyword", terms));
            queries.add(termsFilterStr("rsTermAcc.keyword", terms));
            queries.add(termsFilterStr("xcoTermAcc.keyword", terms));
            queries.add(termsFilterStr("xcoTerm.keyword", terms));

            BoolQuery.Builder vt = new BoolQuery.Builder();
            vt.should(termsFilterStr("vtTermAcc.keyword", terms));
            vt.should(termsFilterStr("vtTerm2Acc.keyword", terms));
            vt.should(termsFilterStr("vtTerm3Acc.keyword", terms));
            queries.add(Query.of(q -> q.bool(vt.build())));
        }
        return Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(queries))));
    }

    public java.util.Map<String, List<EsBucket>> getAggregationsBeforeFilters(HttpRequestFacade req) throws IOException, VVException {
        SearchResponse<Map> sr = getSearchResponse(req, null);
        return getSearchAggregations(sr);
    }

    public java.util.Map<String, List<EsBucket>> getSearchAggregations(SearchResponse<Map> sr) {
        java.util.Map<String, List<EsBucket>> aggregations = new HashMap<>();
        if (sr != null && sr.aggregations() != null) {
            Map<String, Aggregate> aggs = sr.aggregations();
            StringTermsAggregate cmoAggs = optSterms(aggs, "cmoTerm");
            if (cmoAggs != null) {
                aggregations.put("cmoTermBkts", toEsBuckets(cmoAggs.buckets().array()));
            }
            StringTermsAggregate mmoAggs = optSterms(aggs, "mmoTerm");
            if (mmoAggs != null) {
                aggregations.put("mmoTermBkts", toEsBuckets(mmoAggs.buckets().array()));
            }
            StringTermsAggregate vtAggs = optSterms(aggs, "vtTerm");
            if (vtAggs != null) {
                aggregations.put("vtTermBkts", toEsBuckets(vtAggs.buckets().array()));
            }
            StringTermsAggregate xcoAggs = optSterms(aggs, "xcoTerm");
            if (xcoAggs != null) {
                aggregations.put("xcoTermBkts", toEsBuckets(xcoAggs.buckets().array()));
            }
            StringTermsAggregate rsTopLevelTerm = optSterms(aggs, "rsTopLevelTerm");
            if (rsTopLevelTerm != null) {
                aggregations.put("rsTermBkts", toEsBuckets(rsTopLevelTerm.buckets().array()));
            }
            if (speciesTypeKey == 4) {
                StringTermsAggregate rsTermAggs = optSterms(aggs, "rsTerm");
                if (rsTermAggs != null) {
                    aggregations.put("rsTerms", toEsBuckets(rsTermAggs.buckets().array()));
                }
            }
            StringTermsAggregate sexAggs = optSterms(aggs, "sex");
            if (sexAggs != null) {
                aggregations.put("sexBkts", toEsBuckets(sexAggs.buckets().array()));
            }
            StringTermsAggregate unitsAggs = optSterms(aggs, "units");
            if (unitsAggs != null) {
                aggregations.put("unitBkts", toEsBuckets(unitsAggs.buckets().array()));
                // The original code intentionally overwrites cmoTermBkts with an empty list here.
                aggregations.put("cmoTermBkts", new ArrayList<>());
            }
        }
        return aggregations;
    }

    public java.util.Map<String, List<EsBucket>> getFilteredAggregations(Map<String, String> filterMap, HttpRequestFacade req) throws IOException, VVException {
        SearchResponse<Map> sr = null;
        if (filterMap.size() == 1 || (filterMap.size() == 2 && filterMap.containsKey("experimentName"))) {
            Query mainQuery = this.boolQuery(req, null);
            String filterField = filterMap.entrySet().iterator().next().getKey();
            final String aggField = filterField.equalsIgnoreCase("cmoTerm") ? "units" : filterField;
            Aggregation agg = this.buildAggregation(aggField);
            ElasticsearchClient client = ClientInit.getClient();
            sr = client.search(s -> s
                            .index(phenominerIndex)
                            .size(0)
                            .query(mainQuery)
                            .aggregations(aggField, agg),
                    Map.class);
        } else {
            // Empty aggregations: original code only attached aggs in the single-filter branch.
            Query mainQuery = this.boolQuery(req, null);
            ElasticsearchClient client = ClientInit.getClient();
            sr = client.search(s -> s
                            .index(phenominerIndex)
                            .size(0)
                            .query(mainQuery),
                    Map.class);
        }
        return getSearchAggregations(sr);
    }

    private static Query termsFilterStr(String field, List<String> values) {
        List<FieldValue> fvs = values.stream().map(FieldValue::of).collect(Collectors.toList());
        return Query.of(q -> q.terms(t -> t.field(field).terms(tqf -> tqf.value(fvs))));
    }

    private static StringTermsAggregate optSterms(Map<String, Aggregate> aggs, String name) {
        Aggregate a = aggs.get(name);
        if (a == null) return null;
        if (!a.isSterms()) return null;
        return a.sterms();
    }

    private static List<EsBucket> toEsBuckets(List<StringTermsBucket> buckets) {
        List<EsBucket> out = new ArrayList<>(buckets.size());
        for (StringTermsBucket b : buckets) {
            out.add(new EsBucket(b.key().stringValue(), b.docCount()));
        }
        return out;
    }
}
