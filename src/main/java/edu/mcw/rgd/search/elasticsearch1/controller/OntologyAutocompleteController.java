package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Map;

public class OntologyAutocompleteController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String term = request.getParameter("term");
        String ont = request.getParameter("ont");
        String maxParam = request.getParameter("max");
        int max = 20;

        if (term == null || term.trim().isEmpty()) {
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("");
            return null;
        }

        term = term.trim().toLowerCase();

        if (maxParam != null) {
            try {
                max = Integer.parseInt(maxParam);
            } catch (NumberFormatException ignored) {}
        }

        // Build DisMax query across ontology term fields
        DisMaxQueryBuilder dmq = new DisMaxQueryBuilder();
        dmq.add(QueryBuilders.matchQuery("term.symbol", term).operator(Operator.AND).boost(15));
        dmq.add(QueryBuilders.matchQuery("term", term).boost(10));
        dmq.add(QueryBuilders.matchQuery("name.symbol", term).operator(Operator.AND).boost(5));
        dmq.add(QueryBuilders.matchQuery("synonyms.symbol", term).operator(Operator.AND).boost(3));
        dmq.add(QueryBuilders.matchQuery("synonyms", term).boost(2));
        dmq.add(QueryBuilders.prefixQuery("term.symbol", term).boost(8));
        dmq.tieBreaker(0.3f);

        // Build bool query with category + subcat filters
        BoolQueryBuilder boolQuery = QueryBuilders.boolQuery().must(dmq);
        boolQuery.filter(QueryBuilders.termQuery("category.keyword", "Ontology"));

        // Apply ontology filter — supports single prefix, comma-separated, or ALL/null for no filter
        if (ont != null && !ont.trim().isEmpty() && !ont.trim().equalsIgnoreCase("ALL")) {
            String[] parts = ont.split(",");
            if (parts.length == 1) {
                String subcat = mapOntPrefix(parts[0].trim());
                if (subcat != null && !subcat.isEmpty()) {
                    boolQuery.filter(QueryBuilders.prefixQuery("subcat.keyword", subcat + ":"));
                }
            } else {
                // Multiple ontology prefixes — use bool should (OR)
                BoolQueryBuilder subcatFilter = QueryBuilders.boolQuery();
                for (String part : parts) {
                    String subcat = mapOntPrefix(part.trim());
                    if (subcat != null && !subcat.isEmpty()) {
                        subcatFilter.should(QueryBuilders.prefixQuery("subcat.keyword", subcat + ":"));
                    }
                }
                subcatFilter.minimumShouldMatch(1);
                boolQuery.filter(subcatFilter);
            }
        }

        SearchSourceBuilder srb = new SearchSourceBuilder();
        srb.query(boolQuery);
        srb.from(0).size(max);

        SearchRequest searchRequest = new SearchRequest(RgdContext.getESIndexName("search"));
        searchRequest.source(srb);
        SearchResponse sr = ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

        // Build pipe-delimited response: term_name|term_acc
        StringBuilder sb = new StringBuilder();
        for (SearchHit hit : sr.getHits().getHits()) {
            Map<String, Object> source = hit.getSourceAsMap();
            String termName = source.get("term") != null ? source.get("term").toString() : "";
            String termAcc = source.get("term_acc") != null ? source.get("term_acc").toString() : "";
            if (!termName.isEmpty() && !termAcc.isEmpty()) {
                sb.append(termName).append("|").append(termAcc).append("\n");
            }
        }

        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().write(sb.toString());
        return null;
    }

    private String mapOntPrefix(String ont) {
        if (ont == null || ont.trim().isEmpty()) {
            return null;
        }
        String prefix = ont.trim().toUpperCase();
        switch (prefix) {
            case "BP":
            case "MF":
            case "CC":
                return "GO";
            case "DO":
                return "RDO";
            case "MA":
                return "UBERON";
            default:
                return prefix;
        }
    }
}
