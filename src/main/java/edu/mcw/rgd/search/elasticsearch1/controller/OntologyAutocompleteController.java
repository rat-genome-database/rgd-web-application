package edu.mcw.rgd.search.elasticsearch1.controller;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.DisMaxQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Operator;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
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

        final String t = term.trim().toLowerCase();

        if (maxParam != null) {
            try {
                max = Integer.parseInt(maxParam);
            } catch (NumberFormatException ignored) {}
        }

        // Build DisMax query across ontology term fields
        List<Query> dmqQueries = new ArrayList<>();
        dmqQueries.add(Query.of(q -> q.match(m -> m.field("term.symbol").query(t).operator(Operator.And).boost(15f))));
        dmqQueries.add(Query.of(q -> q.match(m -> m.field("term").query(t).boost(10f))));
        dmqQueries.add(Query.of(q -> q.match(m -> m.field("name.symbol").query(t).operator(Operator.And).boost(5f))));
        dmqQueries.add(Query.of(q -> q.match(m -> m.field("synonyms.symbol").query(t).operator(Operator.And).boost(3f))));
        dmqQueries.add(Query.of(q -> q.match(m -> m.field("synonyms").query(t).boost(2f))));
        dmqQueries.add(Query.of(q -> q.prefix(p -> p.field("term.symbol").value(t).boost(8f))));
        Query disMax = Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(dmqQueries).tieBreaker(0.3))));

        // Build bool query with category + subcat filters
        BoolQuery.Builder boolQuery = new BoolQuery.Builder();
        boolQuery.must(disMax);
        boolQuery.filter(Query.of(q -> q.term(tq -> tq.field("category.keyword").value(FieldValue.of("Ontology")))));

        // Apply ontology filter — supports single prefix, comma-separated, or ALL/null for no filter
        if (ont != null && !ont.trim().isEmpty() && !ont.trim().equalsIgnoreCase("ALL")) {
            String[] parts = ont.split(",");
            if (parts.length == 1) {
                String subcat = mapOntPrefix(parts[0].trim());
                if (subcat != null && !subcat.isEmpty()) {
                    final String sc = subcat;
                    boolQuery.filter(Query.of(q -> q.prefix(p -> p.field("subcat.keyword").value(sc + ":"))));
                }
            } else {
                // Multiple ontology prefixes — use bool should (OR)
                BoolQuery.Builder subcatFilter = new BoolQuery.Builder();
                for (String part : parts) {
                    String subcat = mapOntPrefix(part.trim());
                    if (subcat != null && !subcat.isEmpty()) {
                        final String sc = subcat;
                        subcatFilter.should(Query.of(q -> q.prefix(p -> p.field("subcat.keyword").value(sc + ":"))));
                    }
                }
                subcatFilter.minimumShouldMatch("1");
                boolQuery.filter(Query.of(q -> q.bool(subcatFilter.build())));
            }
        }

        BoolQuery builtBool = boolQuery.build();
        Query finalQuery = Query.of(q -> q.bool(builtBool));
        final int maxResults = max;

        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<Map> sr = client.search(s -> s
                        .index(RgdContext.getESIndexName("search"))
                        .query(finalQuery)
                        .from(0)
                        .size(maxResults),
                Map.class);

        // Build pipe-delimited response: term_name|term_acc
        StringBuilder sb = new StringBuilder();
        for (Hit<Map> hit : sr.hits().hits()) {
            Map<String, Object> source = hit.source();
            if (source == null) continue;
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
