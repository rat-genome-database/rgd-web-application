package edu.mcw.rgd.search.elasticsearch1.controller;


import com.google.gson.Gson;


import edu.mcw.rgd.search.elasticsearch.client.ClientInit;


;
import edu.mcw.rgd.search.elasticsearch1.model.RgdIndex;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.common.xcontent.ToXContent;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.suggest.SuggestBuilder;
import org.elasticsearch.search.suggest.SuggestBuilders;
import org.elasticsearch.search.suggest.completion.CompletionSuggestion;
import org.elasticsearch.search.suggest.completion.context.CategoryQueryContext;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 5/1/2017.
 */
public class AutocompleteController implements Controller {
 /*@Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        List<String> categories=new ArrayList<>(Arrays.asList("General", "Gene", "QTL", "SSLP", "Strain", "Reference","Ontology" ));
       String term = null;
        if (request != null) {
            String category= request.getParameter("category");
            if (request.getParameter("term") != null) {
                term = request.getParameter("term").toLowerCase();
            }
            if(term!=null){
                List<String> autocompleteSuggestions= new ArrayList<>();
                SearchResponse searchResponse=null;
                String catStr;
                if(!category.equalsIgnoreCase("general")) {
                    if(!categories.contains(category)){
                        catStr = category.toUpperCase();
                    }else{
                       catStr=category.toLowerCase();
                    }

                    Map<String, List<? extends ToXContent>> contextMap = new HashMap<>();
                    contextMap.put("category", Collections.singletonList(CategoryQueryContext.builder().setCategory(catStr).build()));
                    searchResponse = ClientInit.getClient().prepareSearch(RgdIndex.INDEX_NAME)
                            .suggest(new SuggestBuilder().addSuggestion("suggest", SuggestBuilders.completionSuggestion("suggest")
                                    .contexts(contextMap)
                                   .text(term)
                                 // .regex(".+"+term +".+")
                                    .size(20)
                            ))
                            .get();
                }else{
                    searchResponse = ClientInit.getClient().prepareSearch(RgdIndex.INDEX_NAME)
                            .suggest(new SuggestBuilder().addSuggestion("suggest", SuggestBuilders.completionSuggestion("suggest")
                                 .text(term)
                                   // .regex(".+"+term +".+")
                                    .size(20)
                            ))
                            .get();
                }
                CompletionSuggestion completionSuggestion= searchResponse.getSuggest().getSuggestion("suggest");
                List<CompletionSuggestion.Entry> entries=completionSuggestion.getEntries();




/*
                Iterator $i= entries.iterator();
                while ($i.hasNext()){
                    CompletionSuggestion.Entry entry= (CompletionSuggestion.Entry) $i.next();
                    List<CompletionSuggestion.Entry.Option> options=entry.getOptions();
                    Iterator i=options.iterator();
                    while(i.hasNext()){
                        CompletionSuggestion.Entry.Option option= (CompletionSuggestion.Entry.Option) i.next();

                        autocompleteSuggestions.add(option.getText().toString());
                    }
                }
                Set<String> autoStrs=new TreeSet<>(String.CASE_INSENSITIVE_ORDER);
                autoStrs.addAll(autocompleteSuggestions);

                Set<String> autoSet= new LinkedHashSet<>(autoStrs);
                autoSet.retainAll(new LinkedHashSet<>(autoStrs));
                autocompleteSuggestions=new ArrayList<>(autoSet);
              String autoList = new Gson().toJson(autocompleteSuggestions);
            /*   Gson gson = new Gson();
                String autoList = gson.toJson(autocompleteSuggestions);

                response.getWriter().write(autoList);
            }

        }

        return null;


    }*/
   @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {



        String term=null;
        if(request!=null) {
            if (request.getParameter("term") != null) {
                term = request.getParameter("term").toLowerCase();
            }
            String category = request.getParameter("category");

            DisMaxQueryBuilder dqb = new DisMaxQueryBuilder();
            if (term != null) {
                switch (category) {
                    case "General":

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
                    case "Reference":

                        dqb.add(QueryBuilders.termQuery("title.title", term).boost(10));
                        dqb.add(QueryBuilders.termQuery("title", term).boost(5));//.edgeNgram
                        dqb.add(QueryBuilders.matchQuery("title.title", term).operator(Operator.AND));
                        dqb.add(QueryBuilders.termQuery("author.author", term).boost(10));
                        break;
                    case "Ontology":

                        dqb.add(QueryBuilders.termQuery("term.symbol", term).boost(15)); // term Lowercase
                        dqb.add(QueryBuilders.termQuery("term", term).boost(10)); //edgeNgram
                        dqb.add(QueryBuilders.matchQuery("term.symbol", term).operator(Operator.AND).boost(5));
                        break;
                    case "Strain":
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
            SearchResponse sr=null;
            if(!category.equalsIgnoreCase("general") && !category.equalsIgnoreCase("reference") && !category.equalsIgnoreCase("ontology")){
                sr = ClientInit.getClient().prepareSearch(RgdIndex.INDEX_NAME)
                    .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                    .setQuery(dqb)
                        .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("category.keyword", category)))
                        .setFrom(0).setSize(20)
                    .get();
            }else {
                sr = ClientInit.getClient().prepareSearch(RgdIndex.INDEX_NAME)
                        .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                        .setQuery(dqb)
                        .setFrom(0).setSize(20)
                        .get();
            }

            for (SearchHit h : sr.getHits().getHits()) {
                    if (h.getSource().get("symbol") != null) {
                    Object o = h.getSource().get("symbol");
                    if(!isAdded(autocompleteList, o.toString())){
                        autocompleteList.add(o.toString());
                    }
                  //  System.out.println(h.getSource().get("symbol")+ "\t" + h.getSource().get("species") +"\t"+h.getSource().get("category"));
                    }

                    if (h.getSource().get("term") != null) {
                    if(h.getSource().get("term")!=null) {
                        Object o = h.getSource().get("term");
                        if (!isAdded(autocompleteList, o.toString())) {
                            autocompleteList.add(o.toString());
                    }
                        //      System.out.println(h.getSource().get("term")+ "\t" + h.getSource().get("subcat"));
                    }
                }
                if(h.getSource().get("title")!=null) {
                    if (h.getSource().get("title") != null) {
                        Object o = h.getSource().get("title");
                        if (!isAdded(autocompleteList, o.toString())) {
                            autocompleteList.add(o.toString());
                    }
                }
                    }
                if(h.getSource().get("author")!=null) {
                    if (h.getSource().get("author") != null) {
                        Object o = h.getSource().get("author");
                        if (!isAdded(autocompleteList, o.toString())) {
                            autocompleteList.add(o.toString());
                    }
                }
            }
            }

            Gson gson = new Gson();
            String autoList = gson.toJson(autocompleteList);

            response.getWriter().write(autoList);
        }

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
