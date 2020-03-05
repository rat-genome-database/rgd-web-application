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
    //    System.out.println("ASPECT:"+aspect);
        if(!Objects.equals(term, "")){
            List<SearchHit[]> searchHits=new ArrayList<>();
            if(aspect.equals("all")) aspect="";
            searchHits= this.getModels(term, aspect,qualifier);
            model.put("term", term);
            model.put("aspect", aspect);
            model.put("qualfiier", qualifier);
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
    public List<SearchHit[]> getModels(String term, String aspect, String qualifier) throws IOException {
        List<SearchHit[]> hitsList= new ArrayList<>();
        SearchSourceBuilder srb=new SearchSourceBuilder();

        DisMaxQueryBuilder qb=new DisMaxQueryBuilder();
        qb.add(QueryBuilders.termQuery("term.keyword", term).boost(1000));
        qb.add(QueryBuilders.matchPhraseQuery("term", term).boost(100));
        qb.add(QueryBuilders.matchPhraseQuery("parentTerms.term", term));
        BoolQueryBuilder query= new BoolQueryBuilder();
        query.must(qb);
        if(!aspect.equals("")){
            query.filter(QueryBuilders.termQuery("aspect.keyword", aspect));
        }
        if(!qualifier.equals("") && !qualifier.equals("all")){
          //  System.out.print("QUALIFIER:"+ qualifier);
            query.filter(QueryBuilders.termQuery("qualifier.keyword", qualifier));
        }

       // srb.query(QueryBuilders.matchAllQuery());
        srb.query(query);
        srb.aggregation(getAggregations());
        srb.size(1000);
        SearchRequest searchRequest=new SearchRequest("models_index_dev");
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
        if(sr!=null) {
            Terms modelsAgg;
            if(sr.getAggregations()!=null){
                modelsAgg=sr.getAggregations().get("qualifier");
                aggregations.put("qualifiers", modelsAgg.getBuckets());
            }
            hitsCount= (int) sr.getHits().getTotalHits().value;
         //   System.out.println("SEARCH HITS:"+sr.getHits().getTotalHits());
            hitsList.add(sr.getHits().getHits());

        }
        return hitsList;
    }
    public AggregationBuilder getAggregations(){
        return AggregationBuilders.terms("qualifier").field("qualifier.keyword");

    }
}
