package edu.mcw.rgd.models.findModels;

import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.AggregationBuilder;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.sort.SortOrder;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * Created by jthota on 2/27/2020.
 */
public class FindModelsController implements Controller {
    Map<String,  List<? extends Terms.Bucket>> aggregations=new HashMap<>();
    int hitsCount=0;


    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        HttpRequestFacade req= new HttpRequestFacade(httpServletRequest);
        String aspect=req.getParameter("models-aspect");
        String qualifier=req.getParameter("qualifier");
        String term=req.getParameter("modelsSearchTerm");
        String searchType=req.getParameter("searchType");
        String strainType=req.getParameter("strainType");
        String condition=req.getParameter("condition");
        if(!Objects.equals(term, "")){
            List<SearchHit[]> searchHits=new ArrayList<>();
            if(aspect.equals("all")) aspect="";
            searchHits= this.getSearchResults(term, aspect,qualifier, searchType,strainType, condition);
            httpServletRequest.setAttribute("term", term);
            httpServletRequest.setAttribute("aspect", aspect);
            httpServletRequest.setAttribute("qualifier", qualifier);
            httpServletRequest.setAttribute("aggregations", aggregations);
            httpServletRequest.setAttribute("searchHits", searchHits);
            httpServletRequest.setAttribute("hitsCount", hitsCount);
            httpServletRequest.setAttribute("strainType", strainType);
            httpServletRequest.setAttribute("condition", condition);
            if(!qualifier.equals("")){
                return new ModelAndView("/WEB-INF/jsp/models/findModels/tableData.jsp");
            }else
                return new ModelAndView("/WEB-INF/jsp/models/findModels/results.jsp");
        }else

        return new ModelAndView("/WEB-INF/jsp/models/findModels.jsp");
    }

    public List<SearchHit[]> getSearchResults(String term1, String aspect, String qualifier, String searchType, String strainType, String condition) throws IOException {
     //   System.out.println("ASPECT: "+ aspect+"\n"+"QUALIFIER: "+ qualifier+"\nSearchType: "+ searchType+"\tTERM: "+ term);
        List<SearchHit[]> hitsList= new ArrayList<>();
        SearchSourceBuilder srb=new SearchSourceBuilder();
        DisMaxQueryBuilder qb=new DisMaxQueryBuilder();
        String term=term1.toLowerCase();
        if(aspect.equals("") && qualifier.equals("") && searchType.equals("") || qualifier.equals("all")){
            qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.lowercase", term).boost(500));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.termQuery("annotatedObjectSymbol.lowercase", term))
                            .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                    .boost(900)
                            );

           qb.add(QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                    .boost(10)
                    );

            //************************************************************************//
            qb.add(QueryBuilders.termQuery("term.keyword", term).boost(500));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.termQuery("term.keyword", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                    .boost(900)
            );
          qb.add(QueryBuilders.matchPhraseQuery("term", term));
           qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.matchPhraseQuery("term", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                    .boost(10)
            );

           /*******************Parent Terms***********************/
           qb.add(QueryBuilders.matchPhraseQuery("parentTerms.term", term));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.matchPhraseQuery("parentTerms.term", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                    .boost(10)
            );
            /*******************synonyms***********************/
            qb.add(QueryBuilders.termQuery("termSynonyms.keyword", term));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.termQuery("termSynonyms.keyword", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                    .boost(10)
            );
            /*******************aliases***********************/
           qb.add(QueryBuilders.matchPhraseQuery("aliases", term));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.matchPhraseQuery("aliases", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                    .boost(10)
            );
            /*******************associations***********************/
           qb.add(QueryBuilders.matchPhraseQuery("associations", term));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.matchPhraseQuery("associations", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                    .boost(10)
            );
            /********************Experimental Condition***********************/
            qb.add(QueryBuilders.termQuery("infoTerms.term.keyword", term).boost(500));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.termQuery("infoTerms.term.keyword", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                    .boost(900)
            );
            qb.add(QueryBuilders.matchPhraseQuery("infoTerms.term", term));
            qb.add(QueryBuilders.boolQuery().must(
                    QueryBuilders.matchPhraseQuery("infoTerms.term", term))
                    .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                    .boost(10)
            );



        }else {
            if (aspect.equalsIgnoreCase("model") || searchType.equalsIgnoreCase("model")) {
                term = term.replaceAll("/", "\\/");
                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(500));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                        .boost(900)
                );
                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.lowercase", term).boost(500));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("annotatedObjectSymbol.lowercase", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                        .boost(900)
                );

                qb.add(QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                        .boost(10)
                );


                if (searchType.equalsIgnoreCase("model")) {
                    qb.add(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("aspect", aspect)));
                }
            } else {
            //    term = term.replaceAll("/", "\\/");
                qb.add(QueryBuilders.termQuery("term.keyword", term).boost(500));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("term.keyword", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                        .boost(900)
                );
                qb.add(QueryBuilders.matchPhraseQuery("term", term));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.matchPhraseQuery("term", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                        .boost(10)
                );
                qb.add(QueryBuilders.matchPhraseQuery("parentTerms.term", term));

                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(500));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                        .boost(900)
                );
                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.lowercase", term).boost(500));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("annotatedObjectSymbol.lowercase", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                        .boost(900)
                );

                qb.add(QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL"))
                        .boost(10)
                );
                /*******************synonyms***********************/
                qb.add(QueryBuilders.termQuery("termSynonyms.keyword", term));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("termSynonyms.keyword", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                        .boost(10)
                );
                /*******************aliases***********************/
                qb.add(QueryBuilders.matchPhraseQuery("aliases", term));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.matchPhraseQuery("aliases", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                        .boost(10)
                );
                /*******************associations***********************/
                qb.add(QueryBuilders.matchPhraseQuery("associations", term));
                qb.add(QueryBuilders.boolQuery().must(
                        QueryBuilders.matchPhraseQuery("associations", term))
                        .must(QueryBuilders.matchPhraseQuery("qualifiers","MODEL*"))
                        .boost(10)
                );

            }
        }

        BoolQueryBuilder query= new BoolQueryBuilder();
        query.must(qb);
        if(!aspect.equals("") && !aspect.equalsIgnoreCase("model")){
           query.filter(QueryBuilders.termQuery("aspect.keyword", aspect));
        }
        if(!qualifier.equals("") && !qualifier.equals("all") && !aspect.equalsIgnoreCase("model")){
         query.filter(QueryBuilders.termQuery("qualifiers.keyword", qualifier.trim()));
        }
        if(!strainType.equals("")){
            query.filter(QueryBuilders.termQuery("annotatedObjectType.keyword", strainType));
        }
        if(!condition.equals("")){
            query.filter(QueryBuilders.termQuery("infoTerms.term.keyword", condition));
        }
       // srb.query(QueryBuilders.matchAllQuery());
        System.out.println("QUERY:"+ query);
        srb.query(query);
        srb.aggregation(getAggregations("aspect"));
        srb.aggregation(getAggregations("annotatedObjectType"));
        srb.aggregation(getAggregations("infoTerms.term"));
    //    srb.sort("annotatedObjectSymbol.keyword", SortOrder.ASC);
        srb.size(10000);
        SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("models"));
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
        if(sr!=null) {
        //    System.out.println(sr.getHits().getTotalHits());
            Terms aspectAgg;
            Terms typeAgg;
            Terms conditionsAgg;
            if(sr.getAggregations()!=null){
                aspectAgg=sr.getAggregations().get("aspect");
                aggregations.put("aspectAgg", aspectAgg.getBuckets());
                for( Terms.Bucket bkt: aspectAgg.getBuckets()){
                    Terms modelsAgg=   bkt.getAggregations().get("qualifiers");
                 //   System.out.println("bkt.getKey().toString():"+ bkt.getKey().toString());
                    aggregations.put(bkt.getKey().toString(), modelsAgg.getBuckets());
                }
            typeAgg=sr.getAggregations().get("annotatedObjectType");
                aggregations.put("typeAgg", typeAgg.getBuckets());
            conditionsAgg=sr.getAggregations().get("infoTerms");
            aggregations.put("conditionsAgg", conditionsAgg.getBuckets());
            }
            hitsCount= (int) sr.getHits().getTotalHits().value;
        //  System.out.println("SEARCH HITS:"+sr.getHits().getTotalHits());
            hitsList.add(sr.getHits().getHits());

        }
        return hitsList;
    }
    public AggregationBuilder getAggregations(String field){
      //  return AggregationBuilders.terms("qualifier").field("qualifier.keyword");

       if(field.equalsIgnoreCase("aspect"))
        return AggregationBuilders.terms("aspect").field("aspect.keyword")
                .subAggregation(AggregationBuilders.terms("qualifiers").field("qualifiers.keyword"));
       if(field.equalsIgnoreCase("annotatedObjectType")){
           return AggregationBuilders.terms("annotatedObjectType").field("annotatedObjectType.keyword");
                  // .subAggregation(AggregationBuilders.terms("qualifiers").field("qualifiers.keyword"));
       }
        if(field.equalsIgnoreCase("infoTerms.term")){
            return AggregationBuilders.terms("infoTerms").field("infoTerms.term.keyword");
            // .subAggregation(AggregationBuilders.terms("qualifiers").field("qualifiers.keyword"));
        }
        return null;
    }
}
