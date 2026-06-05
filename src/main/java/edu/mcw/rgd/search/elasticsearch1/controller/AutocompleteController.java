package edu.mcw.rgd.search.elasticsearch1.controller;


import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.query_dsl.Operator;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import com.google.gson.Gson;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

public class AutocompleteController implements Controller {

   @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String term=request.getParameter("term")!=null?request.getParameter("term").trim():null;

            String category = request.getParameter("category")!=null?request.getParameter("category").toLowerCase():"general";
            List<Query> dqQueries = new ArrayList<>();
            if (term != null ) {
                final String t = term;
                switch (category) {

                    case  "general":

                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol.symbol").value(FieldValue.of(t)).boost(100f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol").value(FieldValue.of(t)).boost(10f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol.ngram").value(FieldValue.of(t)))));

                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("term.symbol").value(FieldValue.of(t)).boost(15f)))); // term Lowercase
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("term").value(FieldValue.of(t)).boost(10f)))); //edgeNgram
                        dqQueries.add(Query.of(q -> q.match(mq -> mq.field("term.symbol").query(FieldValue.of(t)).operator(Operator.And).boost(5f))));


                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("title.title").value(FieldValue.of(t)).boost(10f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("title").value(FieldValue.of(t)).boost(5f))));//.edgeNgram
                        dqQueries.add(Query.of(q -> q.match(mq -> mq.field("title.title").query(FieldValue.of(t)).operator(Operator.And))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("author.author").value(FieldValue.of(t)).boost(10f))));
                        break;

                    case "reference":
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("title.title").value(FieldValue.of(t)).boost(10f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("title").value(FieldValue.of(t)).boost(5f))));//.edgeNgram
                        dqQueries.add(Query.of(q -> q.match(mq -> mq.field("title.title").query(FieldValue.of(t)).operator(Operator.And))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("author.author").value(FieldValue.of(t)).boost(10f))));
                        break;

                    case "ontology":
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("term.symbol").value(FieldValue.of(t)).boost(15f)))); // term Lowercase
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("term").value(FieldValue.of(t)).boost(10f)))); //edgeNgram
                        dqQueries.add(Query.of(q -> q.match(mq -> mq.field("term.symbol").query(FieldValue.of(t)).operator(Operator.And).boost(5f))));
                        break;

                    case "strain":
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol.symbol").value(FieldValue.of(t)).boost(100f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol").value(FieldValue.of(t)).boost(10f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol.ngram").value(FieldValue.of(t)))));
                        break;
                    default:

                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol.symbol").value(FieldValue.of(t)).boost(100f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol").value(FieldValue.of(t)).boost(10f))));
                        dqQueries.add(Query.of(q -> q.term(tq -> tq.field("symbol.ngram").value(FieldValue.of(t)))));
                        break;

                }
            }


            List<String> autocompleteList = new ArrayList<>();

            final String categoryF = category;
            ElasticsearchClient client = ClientInit.getClient();
            SearchResponse<java.util.Map> sr = client.search(s -> {
                s.index(RgdContext.getESIndexName("search"))
                        .from(0).size(20)
                        .query(q -> q.disMax(d -> d.queries(dqQueries)));
                if (!categoryF.equalsIgnoreCase("general") && !categoryF.equalsIgnoreCase("reference") && !categoryF.equalsIgnoreCase("ontology")) {
                    s.postFilter(pf -> pf.bool(b -> b
                            .filter(f -> f.term(tq -> tq.field("category.keyword").value(FieldValue.of(categoryF))))));
                }
                return s;
            }, java.util.Map.class);

            for (Hit<java.util.Map> h : sr.hits().hits()) {
                @SuppressWarnings("unchecked")
                java.util.Map<String, Object> src = (java.util.Map<String, Object>) h.source();
                if (src == null) continue;
                if(src.get("symbol")!=null){
                    if(!isAdded(autocompleteList, src.get("symbol").toString())){
                        autocompleteList.add(src.get("symbol").toString());
                    }
                }
                if(src.get("name")!=null){
                    if(!isAdded(autocompleteList, src.get("name").toString())){
                        autocompleteList.add(src.get("name").toString());
                    }
                }
                if(src.get("term")!=null){
                    if(!isAdded(autocompleteList, src.get("term").toString())){
                        autocompleteList.add(src.get("term").toString());
                    }
                }
                if(src.get("title")!=null){
                    if(!isAdded(autocompleteList, src.get("title").toString())){
                        autocompleteList.add(src.get("title").toString());
                    }
                }
                if(src.get("author")!=null){
                    if(!isAdded(autocompleteList, src.get("author").toString())){
                        autocompleteList.add(src.get("author").toString());
                    }
                }

            }

            Gson gson = new Gson();
            String autoList = gson.toJson(autocompleteList);

            response.getWriter().write(autoList);

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
