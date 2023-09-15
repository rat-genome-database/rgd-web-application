package edu.mcw.rgd.search.elasticsearch1.controller;


import com.google.gson.Gson;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;

import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;

import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 5/1/2017.
 */
public class AutocompleteController implements Controller {

   @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {



        String term=request.getParameter("term")!=null?request.getParameter("term").trim():null;
     //   if(request!=null) {

            String category = request.getParameter("category")!=null?request.getParameter("category").toLowerCase():"general";
            DisMaxQueryBuilder dqb = new DisMaxQueryBuilder();
            if (term != null ) {
                switch (category) {

                    case  "general":

                        dqb.add(QueryBuilders.termQuery("symbol.symbol", term).boost(100));
                      //  dqb.add(QueryBuilders.prefixQuery("symbol.symbol", term).boost(50));
                        dqb.add(QueryBuilders.termQuery("symbol", term).boost(10));
                        dqb.add(QueryBuilders.termQuery("symbol.ngram",term));

                        dqb.add(QueryBuilders.termQuery("term.symbol", term).boost(15)); // term Lowercase
                        dqb.add(QueryBuilders.termQuery("term", term).boost(10)); //edgeNgram
                        dqb.add(QueryBuilders.matchQuery("term.symbol", term).operator(Operator.AND).boost(5));


                        dqb.add(QueryBuilders.termQuery("title.title", term).boost(10));
                        dqb.add(QueryBuilders.termQuery("title", term).boost(5));//.edgeNgram
                        dqb.add(QueryBuilders.matchQuery("title.title", term).operator(Operator.AND));
                        dqb.add(QueryBuilders.termQuery("author.author", term).boost(10));
                        break;

                    case "reference":
                        dqb.add(QueryBuilders.termQuery("title.title", term).boost(10));
                        dqb.add(QueryBuilders.termQuery("title", term).boost(5));//.edgeNgram
                        dqb.add(QueryBuilders.matchQuery("title.title", term).operator(Operator.AND));
                        dqb.add(QueryBuilders.termQuery("author.author", term).boost(10));
                        break;

                    case "ontology":
                        dqb.add(QueryBuilders.termQuery("term.symbol", term).boost(15)); // term Lowercase
                        dqb.add(QueryBuilders.termQuery("term", term).boost(10)); //edgeNgram
                        dqb.add(QueryBuilders.matchQuery("term.symbol", term).operator(Operator.AND).boost(5));
                        break;

                    case "strain":
                        dqb.add(QueryBuilders.termQuery("symbol.symbol", term).boost(100));
                    //    dqb.add(QueryBuilders.prefixQuery("symbol.symbol", term).boost(50));
                        dqb.add(QueryBuilders.termQuery("symbol", term).boost(10));
                        dqb.add(QueryBuilders.termQuery("symbol.ngram",term));
                        break;
                    default:

                        dqb.add(QueryBuilders.termQuery("symbol.symbol", term).boost(100));
                    //    dqb.add(QueryBuilders.prefixQuery("symbol.symbol", term).boost(50));
                        dqb.add(QueryBuilders.termQuery("symbol", term).boost(10));
                        dqb.add(QueryBuilders.termQuery("symbol.ngram",term));
                        break;

                }
            }


            List<String> autocompleteList = new ArrayList<>();

       SearchSourceBuilder srb=new SearchSourceBuilder();
       srb.query(dqb);
       srb.from(0).size(20);



            if(!category.equalsIgnoreCase("general") && !category.equalsIgnoreCase("reference") && !category.equalsIgnoreCase("ontology")){
                srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("category.keyword", category)));
              /*  sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("search"))
                    .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                    .setQuery(dqb)
                        .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("category.keyword", category)))
                        .setFrom(0).setSize(20)
                    .get();*/
            }else {
              /*  sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("search"))
                        .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                        .setQuery(dqb)
                        .setFrom(0).setSize(20)
                        .get();*/
            }
       SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("search"));
       searchRequest.source(srb);
       SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

            for (SearchHit h : sr.getHits().getHits()) {
                if(h.getSourceAsMap().get("symbol")!=null){
                    if(!isAdded(autocompleteList, h.getSourceAsMap().get("symbol").toString())){
                        autocompleteList.add(h.getSourceAsMap().get("symbol").toString());
                    }
                }
            //   System.out.println("SYMBOL:"+h.getSourceAsMap().get("symbol"));
                if(h.getSourceAsMap().get("name")!=null){
                    if(!isAdded(autocompleteList, h.getSourceAsMap().get("name").toString())){
                        autocompleteList.add(h.getSourceAsMap().get("name").toString());
                    }
                }
             //   System.out.println("NAME:"+h.getSourceAsMap().get("name"));
                if(h.getSourceAsMap().get("term")!=null){
                    if(!isAdded(autocompleteList, h.getSourceAsMap().get("term").toString())){
                        autocompleteList.add(h.getSourceAsMap().get("term").toString());
                    }
                }
             //   System.out.println("TERM:"+h.getSourceAsMap().get("term"));
                if(h.getSourceAsMap().get("title")!=null){
                    if(!isAdded(autocompleteList, h.getSourceAsMap().get("title").toString())){
                        autocompleteList.add(h.getSourceAsMap().get("title").toString());
                    }
                }
                if(h.getSourceAsMap().get("author")!=null){
                    if(!isAdded(autocompleteList, h.getSourceAsMap().get("author").toString())){
                        autocompleteList.add(h.getSourceAsMap().get("author").toString());
                    }
                }

            }

            Gson gson = new Gson();
            String autoList = gson.toJson(autocompleteList);

            response.getWriter().write(autoList);
      //  }

        return null;
    }

    public boolean isAdded(List<String> autoCompleteList, String str) {
        boolean flag = false;
        for (String s : autoCompleteList) {
            if (s.equalsIgnoreCase(str)) {
                flag = true;
                break;

}
        }
        return flag;
    }
}
