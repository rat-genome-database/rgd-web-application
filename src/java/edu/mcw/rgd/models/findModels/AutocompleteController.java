package edu.mcw.rgd.models.findModels;

import com.google.gson.Gson;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 3/18/2020.
 */
public class AutocompleteController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        HttpRequestFacade req=new HttpRequestFacade(httpServletRequest);
        List<String> autocompleteList=new ArrayList<>();
        String term=req.getParameter("term");
        term = term.replaceAll("/", "\\/");
        String aspect=req.getParameter("aspect");
        DisMaxQueryBuilder qb = new DisMaxQueryBuilder();
        BoolQueryBuilder query= new BoolQueryBuilder();
        query.must(qb);
        System.out.println("ASPECT: "+ aspect);
        switch(aspect){
            case "all":
                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(1000));
                qb.add(QueryBuilders.matchPhrasePrefixQuery("annotatedObjectSymbol", term));

          case "D":
            case "N":

                qb.add(QueryBuilders.matchPhrasePrefixQuery("term", term));
                qb.add(QueryBuilders.termQuery("term.keyword", term).boost(100));
              //  qb.add(QueryBuilders.matchQuery("parentTerms.term", term));
                break;
            case "MODEL":
                qb.add(QueryBuilders.termQuery("annotatedObjectSymbol.keyword", term).boost(1000));
                qb.add(QueryBuilders.matchPhrasePrefixQuery("annotatedObjectSymbol", term));
                break;
            default:
        }
        query.must(qb);
        if(aspect.equals("D") || aspect.equals("N")){
            query.filter(QueryBuilders.termQuery("aspect.keyword", aspect));
        }
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(query);
        srb.highlighter(this.buildHighlights());
        srb.size(1000);
        SearchRequest searchRequest=new SearchRequest("models_index_test");
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
    //    List<String> autocompleteList=new ArrayList<>(Arrays.asList("Hello", "Jyothi", "How", "are"));

        if(sr!=null){
            for(SearchHit h:sr.getHits().getHits()){
                if(!aspect.equals("MODEL") && !aspect.equals("all")) {
                    if(!autocompleteList.contains(h.getSourceAsMap().get("term").toString()))
                    autocompleteList.add(h.getSourceAsMap().get("term").toString());
                    //   autocompleteList.addAll((List<String>) h.getSourceAsMap().get("parentTerms"));
                }

                if(aspect.equals("MODEL")){

                    if(!autocompleteList.contains(h.getSourceAsMap().get("annotatedObjectSymbol").toString()))
                        autocompleteList.add(h.getSourceAsMap().get("annotatedObjectSymbol").toString());
                    }
                if(aspect.equals("all")){

                   for(Map.Entry e: h.getHighlightFields().entrySet()) {
                       System.out.println(e.getKey()+"\t"+e.getValue());
                       if(e.getKey().toString().equals("term") || e.getKey().toString().equals("term.keyword")){
                           if(!autocompleteList.contains(h.getSourceAsMap().get("term").toString()))
                           autocompleteList.add(h.getSourceAsMap().get("term").toString());

                       }
                       if(e.getKey().toString().equals("annotatedObjectSymbol") || e.getKey().toString().equals("annotatedObjectSymbol")){
                           if(!autocompleteList.contains(h.getSourceAsMap().get("annotatedObjectSymbol").toString()))
                               autocompleteList.add(h.getSourceAsMap().get("annotatedObjectSymbol").toString());

                       }

                   }
                }
            }
        }


        Gson gson = new Gson();
        String autoList = gson.toJson(autocompleteList);

        httpServletResponse.getWriter().write(autoList);
        return null;
    }
    public HighlightBuilder buildHighlights(){
        List<String> fields=new ArrayList<>(Arrays.asList(
                "term", "term.keyword",
                "annotatedObjectSymbol", "annotatedObjectSymbol.keyword"
        ));
        HighlightBuilder hb=new HighlightBuilder();
        for(String field:fields){
            hb.field(field);
        }
        return hb;
    }
}
