package edu.mcw.rgd.search.elasticsearch1.controller;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Operator;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class OntologyAutocompleteController implements Controller {

    // Cache of descendant term acc IDs keyed by root term acc.
    // Lazy-loaded on first request per root; cleared only on Tomcat restart.
    private static final ConcurrentHashMap<String, Set<String>> DESCENDANT_CACHE = new ConcurrentHashMap<>();
    private static final OntologyXDAO ONTOLOGY_DAO = new OntologyXDAO();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String term = request.getParameter("term");
        String ont = request.getParameter("ont");
        String root = request.getParameter("root");
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

        // Match clauses in descending order of specificity, OR'ed together so recall is
        // their union while the boosts decide what reaches the top of the dropdown.
        //
        // A single OR'ed match on `term` is not enough on its own, for two reasons:
        //
        //   1. Ranking. `term` is edge-n-grammed, so an OR match over it hits thousands
        //      of terms and the 20 we can show get filled with near-misses. Searching
        //      "exposure to lipopolysaccharide" used to surface "X-ray exposure" and
        //      "air-jet exposure" above the terms that contain the whole phrase. The
        //      AND and phrase-prefix clauses below are what pull exact and in-order
        //      matches to the top; the bare OR clauses are kept at a low boost purely
        //      as a tail fallback.
        //
        //   2. Index skew. `term` is indexed with `autocomplete_analyzer`, whose edge
        //      n-grams stop at 15 characters, so a typed word of 16+ characters can
        //      analyze to a token that was never indexed. The search side now truncates
        //      to match (see autocomplete_search_analyzer in the elastic-search-indexer
        //      pipeline), but that only takes effect for indexes built after that change
        //      -- and only `term` is n-grammed, not `term.term`. Querying `term.term`
        //      (english_analyzer, no n-grams) and `term.symbol` (keyword tokenizer)
        //      keeps long words matching regardless of when the index was built.
        List<Query> shouldQueries = new ArrayList<>();
        // the whole term name, typed exactly
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("term.symbol").query(t).operator(Operator.And).boost(100f))));
        // term name begins with what was typed
        shouldQueries.add(Query.of(q -> q.prefix(p -> p.field("term.symbol").value(t).boost(60f))));
        // typed words in order with a partial last word -- the main as-you-type clause
        shouldQueries.add(Query.of(q -> q.matchPhrasePrefix(m -> m.field("term.term").query(t).maxExpansions(50).boost(40f))));
        // every typed word present in the name, any order, any length
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("term.term").query(t).operator(Operator.And).boost(30f))));
        // every typed word present as an n-gram prefix (partial words up to 15 chars)
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("term").query(t).operator(Operator.And).boost(20f))));
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("name.symbol").query(t).operator(Operator.And).boost(15f))));
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("synonyms.symbol").query(t).operator(Operator.And).boost(12f))));
        shouldQueries.add(Query.of(q -> q.matchPhrasePrefix(m -> m.field("synonyms").query(t).maxExpansions(50).boost(8f))));
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("synonyms").query(t).operator(Operator.And).boost(6f))));
        // Last-resort fallbacks: any one typed word matches. Kept at a low boost so they
        // only fill the tail of the dropdown rather than crowding out the clauses above.
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("term").query(t).boost(2f))));
        shouldQueries.add(Query.of(q -> q.match(m -> m.field("synonyms").query(t).boost(1f))));
        Query termMatch = Query.of(q -> q.bool(b -> b.should(shouldQueries).minimumShouldMatch("1")));

        // Build bool query with category + subcat filters
        BoolQuery.Builder boolQuery = new BoolQuery.Builder();
        boolQuery.must(termMatch);
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

        // When restricting to a portal subtree, over-fetch from ES so the
        // post-filter can still return up to `max` matches.
        boolean hasRootFilter = root != null && !root.trim().isEmpty();
        Set<String> descendantAccs = hasRootFilter ? getDescendantAccs(root.trim()) : null;
        final int maxResults = hasRootFilter ? Math.max(max * 10, 100) : max;

        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<Map> sr = client.search(s -> s
                        .index(RgdContext.getESIndexName("search"))
                        .query(finalQuery)
                        .from(0)
                        .size(maxResults),
                Map.class);

        // Build pipe-delimited response: term_name|term_acc
        StringBuilder sb = new StringBuilder();
        int emitted = 0;
        for (Hit<Map> hit : sr.hits().hits()) {
            if (emitted >= max) break;
            Map<String, Object> source = hit.source();
            if (source == null) continue;
            String termName = source.get("term") != null ? source.get("term").toString() : "";
            String termAcc = source.get("term_acc") != null ? source.get("term_acc").toString() : "";
            if (termName.isEmpty() || termAcc.isEmpty()) continue;
            if (descendantAccs != null && !descendantAccs.contains(termAcc)) continue;
            sb.append(termName).append("|").append(termAcc).append("\n");
            emitted++;
        }

        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().write(sb.toString());
        return null;
    }

    // Loads and caches the set of descendant term acc IDs for a root term.
    // Includes the root itself so a user can select it too.
    private Set<String> getDescendantAccs(String rootAcc) {
        Set<String> cached = DESCENDANT_CACHE.get(rootAcc);
        if (cached != null) return cached;
        try {
            List<String> descendants = ONTOLOGY_DAO.getAllActiveTermDescendantAccIds(rootAcc);
            Set<String> set = new HashSet<>(descendants);
            set.add(rootAcc);
            DESCENDANT_CACHE.put(rootAcc, set);
            return set;
        } catch (Exception e) {
            e.printStackTrace();
            // On failure, return an empty set — better to show no results than to
            // silently fall back to the full ontology and mislead the user.
            return new HashSet<>();
        }
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
