package edu.mcw.rgd.models;

import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
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
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
        ModelMap model= new ModelMap();
        HttpRequestFacade req= new HttpRequestFacade(httpServletRequest);
        String aspect=req.getParameter("models-aspect");
        String qualifier=req.getParameter("qualifier");
        String term=req.getParameter("models-search-term");
        String searchType=req.getParameter("searchType");

        if(!Objects.equals(term, "")){
            List<SearchHit[]> searchHits=new ArrayList<>();
            if(aspect.equals("all")) aspect="";

            searchHits= this.getSearchResults(term, aspect,qualifier, searchType);
            model.put("term", term);
            model.put("aspect", aspect);
            model.put("qualifier", qualifier);
            model.put("aggregations", aggregations);
            model.put("searchHits", searchHits);
            model.put("hitsCount", hitsCount);
            if(!qualifier.equals("")){
                return new ModelAndView("/WEB-INF/jsp/models/findModels/tableData.jsp", "model", model);
            }else
            return new ModelAndView("/WEB-INF/jsp/models/findModels/results.jsp", "model", model);
        }else

        return new ModelAndView("/WEB-INF/jsp/models/findModels.jsp");
    }

    public List<SearchHit[]> getSearchResults(String term, String aspect, String qualifier, String searchType) throws IOException {
        System.out.println("ASPECT: "+ aspect+"\n"+"QUALIFIER: "+ qualifier+"\nSearchType: "+ searchType+"\tTERM: "+ term);
        List<SearchHit[]> hitsList= new ArrayList<>();
        SearchSourceBuilder srb=new SearchSourceBuilder();
        DisMaxQueryBuilder qb=new DisMaxQueryBuilder();
        if(aspect.equals("") && qualifier.equals("") && searchType.equals("") || qualifier.equals("all")){
            qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(1000));
            qb.add(QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term));
            qb.add(QueryBuilders.termQuery("term.keyword", term).boost(1000));
            qb.add(QueryBuilders.matchPhraseQuery("term", term).boost(100));
            qb.add(QueryBuilders.matchPhraseQuery("parentTerms.term", term));
        }else {
            if (aspect.equalsIgnoreCase("model") || searchType.equalsIgnoreCase("model")) {
                term = term.replaceAll("/", "\\/");
                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(1000));
                qb.add(QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term));
                if (searchType.equalsIgnoreCase("model")) {
                    qb.add(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("aspect", aspect)));
                }
            } else {

                qb.add(QueryBuilders.termQuery("term.keyword", term).boost(1000));
                qb.add(QueryBuilders.matchPhraseQuery("term", term).boost(100));
                qb.add(QueryBuilders.matchPhraseQuery("parentTerms.term", term));
                if(!qualifier.equals("")  && (aspect.equals("D") || aspect.equals("N"))){
                    qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(1000));
                    qb.add(QueryBuilders.matchPhraseQuery("annotatedObjectSymbol", term));
                }
            }
        }

        BoolQueryBuilder query= new BoolQueryBuilder();
        query.must(qb);
        if(!aspect.equals("") && !aspect.equalsIgnoreCase("model")){
           query.filter(QueryBuilders.termQuery("aspect.keyword", aspect));
        }
        if(!qualifier.equals("") && !qualifier.equals("all") && !aspect.equalsIgnoreCase("model")){
          //  System.out.print("QUALIFIER:"+ qualifier);
          query.filter(QueryBuilders.termQuery("qualifier.keyword", qualifier));
        }

       // srb.query(QueryBuilders.matchAllQuery());
        srb.query(query);
        srb.aggregation(getAggregations());
        srb.size(1000);
        SearchRequest searchRequest=new SearchRequest("models_index_test");
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
        if(sr!=null) {
            System.out.println(sr.getHits().getTotalHits());
            Terms aspectAgg;
            if(sr.getAggregations()!=null){
                aspectAgg=sr.getAggregations().get("aspect");
                aggregations.put("aspectAgg", aspectAgg.getBuckets());
                for( Terms.Bucket bkt: aspectAgg.getBuckets()){
                    Terms modelsAgg=   bkt.getAggregations().get("qualifier");
                    System.out.println("bkt.getKey().toString():"+ bkt.getKey().toString());
                    aggregations.put(bkt.getKey().toString(), modelsAgg.getBuckets());
                }
              /*  modelsAgg=sr.getAggregations().get("qualifier");
                aggregations.put("qualifiers", modelsAgg.getBuckets());*/
            }
            hitsCount= (int) sr.getHits().getTotalHits().value;
         //   System.out.println("SEARCH HITS:"+sr.getHits().getTotalHits());
            hitsList.add(sr.getHits().getHits());

        }
        return hitsList;
    }
    public AggregationBuilder getAggregations(){
      //  return AggregationBuilders.terms("qualifier").field("qualifier.keyword");

        return AggregationBuilders.terms("aspect").field("aspect.keyword")
                .subAggregation(AggregationBuilders.terms("qualifier").field("qualifier.keyword"));

    }
}
