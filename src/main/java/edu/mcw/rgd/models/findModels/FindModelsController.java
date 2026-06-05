package edu.mcw.rgd.models.findModels;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregate;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregation;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.DisMaxQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.EsBucket;
import edu.mcw.rgd.web.EsHit;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

public class FindModelsController implements Controller {
    Map<String, List<EsBucket>> aggregations = new HashMap<>();
    int hitsCount = 0;


    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(httpServletRequest);
        String aspect = req.getParameter("models-aspect");
        String qualifier = req.getParameter("qualifier");
        String term = req.getParameter("modelsSearchTerm");
        String searchType = req.getParameter("searchType");
        String strainType = req.getParameter("strainType");
        String condition = req.getParameter("condition");
        if (!Objects.equals(term, "")) {
            List<EsHit[]> searchHits = new ArrayList<>();
            if (aspect.equals("all")) aspect = "";
            searchHits = this.getSearchResults(term, aspect, qualifier, searchType, strainType, condition);
            httpServletRequest.setAttribute("term", term);
            httpServletRequest.setAttribute("aspect", aspect);
            httpServletRequest.setAttribute("qualifier", qualifier);
            httpServletRequest.setAttribute("aggregations", aggregations);
            httpServletRequest.setAttribute("searchHits", searchHits);
            httpServletRequest.setAttribute("hitsCount", hitsCount);
            httpServletRequest.setAttribute("strainType", strainType);
            httpServletRequest.setAttribute("condition", condition);
            if (!qualifier.equals("")) {
                return new ModelAndView("/WEB-INF/jsp/models/findModels/tableData.jsp");
            } else
                return new ModelAndView("/WEB-INF/jsp/models/findModels/results.jsp");
        } else

            return new ModelAndView("/WEB-INF/jsp/models/findModels.jsp");
    }

    public List<EsHit[]> getSearchResults(String term1, String aspect, String qualifier, String searchType, String strainType, String condition) throws IOException {
        List<EsHit[]> hitsList = new ArrayList<>();
        List<Query> dq = new ArrayList<>();
        final String term = term1.toLowerCase();

        if (aspect.equals("") && qualifier.equals("") && searchType.equals("") || qualifier.equals("all")) {
            dq.add(termBoosted("annotatedObjectSymbol.lowercase", term, 500f));
            dq.add(mustWithQualifier(termFilter("annotatedObjectSymbol.lowercase", term), "MODEL", 900f));

            dq.add(matchPhraseQ("annotatedObjectSymbol", term));
            dq.add(mustWithQualifier(matchPhraseQ("annotatedObjectSymbol", term), "MODEL", 10f));

            //************************************************************************//
            dq.add(termBoosted("term.keyword", term, 500f));
            dq.add(mustWithQualifier(termFilter("term.keyword", term), "MODEL", 900f));
            dq.add(matchPhraseQ("term", term));
            dq.add(mustWithQualifier(matchPhraseQ("term", term), "MODEL", 10f));

            /*******************Parent Terms***********************/
            dq.add(matchPhraseQ("parentTerms.term", term));
            dq.add(mustWithQualifier(matchPhraseQ("parentTerms.term", term), "MODEL*", 10f));
            /*******************synonyms***********************/
            dq.add(termFilter("termSynonyms.keyword", term));
            dq.add(mustWithQualifier(termFilter("termSynonyms.keyword", term), "MODEL*", 10f));
            /*******************aliases***********************/
            dq.add(matchPhraseQ("aliases", term));
            dq.add(mustWithQualifier(matchPhraseQ("aliases", term), "MODEL*", 10f));
            /*******************associations***********************/
            dq.add(matchPhraseQ("associations", term));
            dq.add(mustWithQualifier(matchPhraseQ("associations", term), "MODEL*", 10f));
            /********************Experimental Condition***********************/
            dq.add(termBoosted("infoTerms.term.keyword", term, 500f));
            dq.add(mustWithQualifier(termFilter("infoTerms.term.keyword", term), "MODEL", 900f));
            dq.add(matchPhraseQ("infoTerms.term", term));
            dq.add(mustWithQualifier(matchPhraseQ("infoTerms.term", term), "MODEL", 10f));


        } else {
            if (aspect.equalsIgnoreCase("model") || searchType.equalsIgnoreCase("model")) {
                final String t = term.replaceAll("/", "\\/");
                dq.add(termBoosted("annotatedObjectSymbol.keyword", t, 500f));
                dq.add(mustWithQualifier(termFilter("annotatedObjectSymbol.keyword", t), "MODEL*", 900f));
                dq.add(termBoosted("annotatedObjectSymbol.lowercase", t, 500f));
                dq.add(mustWithQualifier(termFilter("annotatedObjectSymbol.lowercase", t), "MODEL", 900f));

                dq.add(matchPhraseQ("annotatedObjectSymbol", t));
                dq.add(mustWithQualifier(matchPhraseQ("annotatedObjectSymbol", t), "MODEL", 10f));


                if (searchType.equalsIgnoreCase("model")) {
                    final String asp = aspect;
                    BoolQuery.Builder b = new BoolQuery.Builder();
                    b.filter(termFilter("aspect", asp));
                    dq.add(Query.of(q -> q.bool(b.build())));
                }
            } else {
                dq.add(termBoosted("term.keyword", term, 500f));
                dq.add(mustWithQualifier(termFilter("term.keyword", term), "MODEL*", 900f));
                dq.add(matchPhraseQ("term", term));
                dq.add(mustWithQualifier(matchPhraseQ("term", term), "MODEL", 10f));
                dq.add(matchPhraseQ("parentTerms.term", term));

                dq.add(termBoosted("annotatedObjectSymbol.keyword", term, 500f));
                dq.add(mustWithQualifier(termFilter("annotatedObjectSymbol.keyword", term), "MODEL*", 900f));
                dq.add(termBoosted("annotatedObjectSymbol.lowercase", term, 500f));
                dq.add(mustWithQualifier(termFilter("annotatedObjectSymbol.lowercase", term), "MODEL", 900f));

                dq.add(matchPhraseQ("annotatedObjectSymbol", term));
                dq.add(mustWithQualifier(matchPhraseQ("annotatedObjectSymbol", term), "MODEL", 10f));
                /*******************synonyms***********************/
                dq.add(termFilter("termSynonyms.keyword", term));
                dq.add(mustWithQualifier(termFilter("termSynonyms.keyword", term), "MODEL*", 10f));
                /*******************aliases***********************/
                dq.add(matchPhraseQ("aliases", term));
                dq.add(mustWithQualifier(matchPhraseQ("aliases", term), "MODEL*", 10f));
                /*******************associations***********************/
                dq.add(matchPhraseQ("associations", term));
                dq.add(mustWithQualifier(matchPhraseQ("associations", term), "MODEL*", 10f));
            }
        }

        Query disMax = Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(dq))));
        BoolQuery.Builder query = new BoolQuery.Builder();
        query.must(disMax);
        if (!aspect.equals("") && !aspect.equalsIgnoreCase("model")) {
            query.filter(termFilter("aspect.keyword", aspect));
        }
        if (!qualifier.equals("") && !qualifier.equals("all") && !aspect.equalsIgnoreCase("model")) {
            query.filter(termFilter("qualifiers.keyword", qualifier.trim()));
        }
        if (!strainType.equals("")) {
            query.filter(termFilter("annotatedObjectType.keyword", strainType));
        }
        if (!condition.equals("")) {
            query.filter(termFilter("infoTerms.term.keyword", condition));
        }
        Query mainQuery = Query.of(q -> q.bool(query.build()));

        Map<String, Aggregation> aggs = new LinkedHashMap<>();
        aggs.put("aspect", buildAggregation("aspect"));
        aggs.put("annotatedObjectType", buildAggregation("annotatedObjectType"));
        aggs.put("infoTerms", buildAggregation("infoTerms.term"));

        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<java.util.Map> sr = client.search(s -> s
                        .index(RgdContext.getESIndexName("models"))
                        .query(mainQuery)
                        .size(10000)
                        .aggregations(aggs),
                java.util.Map.class);

        if (sr != null) {
            if (sr.aggregations() != null) {
                Map<String, Aggregate> aggResults = sr.aggregations();
                StringTermsAggregate aspectAgg = optSterms(aggResults, "aspect");
                if (aspectAgg != null) {
                    aggregations.put("aspectAgg", toEsBuckets(aspectAgg.buckets().array()));
                    for (StringTermsBucket bkt : aspectAgg.buckets().array()) {
                        StringTermsAggregate modelsAgg = optSterms(bkt.aggregations(), "qualifiers");
                        if (modelsAgg != null) {
                            aggregations.put(bkt.key().stringValue(), toEsBuckets(modelsAgg.buckets().array()));
                        }
                    }
                }
                StringTermsAggregate typeAgg = optSterms(aggResults, "annotatedObjectType");
                if (typeAgg != null) {
                    aggregations.put("typeAgg", toEsBuckets(typeAgg.buckets().array()));
                }
                StringTermsAggregate conditionsAgg = optSterms(aggResults, "infoTerms");
                if (conditionsAgg != null) {
                    aggregations.put("conditionsAgg", toEsBuckets(conditionsAgg.buckets().array()));
                }
            }
            hitsCount = (sr.hits().total() != null) ? (int) sr.hits().total().value() : 0;
            List<Hit<java.util.Map>> rawHits = sr.hits().hits();
            EsHit[] hitArr = new EsHit[rawHits.size()];
            for (int i = 0; i < rawHits.size(); i++) {
                Hit<java.util.Map> h = rawHits.get(i);
                @SuppressWarnings("unchecked")
                java.util.Map<String, Object> src = (java.util.Map<String, Object>) h.source();
                hitArr[i] = new EsHit(h.id(), src);
            }
            hitsList.add(hitArr);
        }
        return hitsList;
    }

    public Aggregation buildAggregation(String field) {
        if (field.equalsIgnoreCase("aspect")) {
            Map<String, Aggregation> subs = new LinkedHashMap<>();
            subs.put("qualifiers", Aggregation.of(a -> a.terms(t -> t.field("qualifiers.keyword"))));
            return Aggregation.of(a -> a
                    .terms(t -> t.field("aspect.keyword"))
                    .aggregations(subs));
        }
        if (field.equalsIgnoreCase("annotatedObjectType")) {
            return Aggregation.of(a -> a.terms(t -> t.field("annotatedObjectType.keyword")));
        }
        if (field.equalsIgnoreCase("infoTerms.term")) {
            return Aggregation.of(a -> a.terms(t -> t.field("infoTerms.term.keyword")));
        }
        return null;
    }

    private static Query termFilter(String field, String value) {
        return Query.of(q -> q.term(t -> t.field(field).value(FieldValue.of(value))));
    }

    private static Query termBoosted(String field, String value, float boost) {
        return Query.of(q -> q.term(t -> t.field(field).value(FieldValue.of(value)).boost(boost)));
    }

    private static Query matchPhraseQ(String field, String value) {
        return Query.of(q -> q.matchPhrase(m -> m.field(field).query(value)));
    }

    private static Query mustWithQualifier(Query inner, String qualifierValue, float boost) {
        BoolQuery.Builder b = new BoolQuery.Builder();
        b.must(inner);
        b.must(matchPhraseQ("qualifiers", qualifierValue));
        b.boost(boost);
        return Query.of(q -> q.bool(b.build()));
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
