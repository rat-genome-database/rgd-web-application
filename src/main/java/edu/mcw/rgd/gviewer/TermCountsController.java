package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.aggregations.metrics.Cardinality;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

/**
 * For a list of termAcc IDs, returns the unique-object (gene/QTL/strain)
 * count directly annotated to each in the gviewer index for the given
 * mapKey. Counts are *direct* — no ontology DAG expansion.
 *
 * Used by the GViewer search autocomplete to grey out terms with zero
 * annotations and to show a "no annotations found" hint when all of the
 * autocomplete matches have zero counts.
 */
public class TermCountsController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        String accsParam = request.getParameter("accs");
        String mapKeyStr = request.getParameter("mapKey");
        if (accsParam == null || accsParam.isEmpty()
                || mapKeyStr == null || mapKeyStr.isEmpty()) {
            out.print("{}");
            return null;
        }

        int mapKey;
        try {
            mapKey = Integer.parseInt(mapKeyStr);
        } catch (NumberFormatException e) {
            out.print("{}");
            return null;
        }

        Set<String> accs = new LinkedHashSet<>();
        for (String a : accsParam.split(",")) {
            String s = a.trim();
            if (!s.isEmpty()) accs.add(s);
        }
        if (accs.isEmpty()) {
            out.print("{}");
            return null;
        }

        BoolQueryBuilder q = QueryBuilders.boolQuery()
                .filter(QueryBuilders.termsQuery("termAcc", accs))
                .filter(QueryBuilders.termQuery("mapKey", mapKey))
                .filter(QueryBuilders.termsQuery("objectType",
                        Arrays.asList("gene", "qtl", "strain")));

        SearchSourceBuilder ssb = new SearchSourceBuilder()
                .query(q)
                .size(0)
                .aggregation(AggregationBuilders.terms("by_term")
                        .field("termAcc")
                        .size(accs.size())
                        .subAggregation(AggregationBuilders.cardinality("uniq")
                                .field("annotatedObjectRgdId")));

        SearchResponse resp = ClientInit.getClient().search(
                new SearchRequest(RgdContext.getESIndexName("gviewer")).source(ssb),
                RequestOptions.DEFAULT);

        Map<String, Long> counts = new LinkedHashMap<>();
        for (String acc : accs) counts.put(acc, 0L);

        Terms agg = resp.getAggregations().get("by_term");
        if (agg != null) {
            for (Terms.Bucket b : agg.getBuckets()) {
                Cardinality uniq = b.getAggregations().get("uniq");
                long n = uniq == null ? b.getDocCount() : uniq.getValue();
                counts.put(b.getKeyAsString(), n);
            }
        }

        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Long> e : counts.entrySet()) {
            if (!first) sb.append(",");
            first = false;
            sb.append("\"").append(escapeJson(e.getKey())).append("\":").append(e.getValue());
        }
        sb.append("}");
        out.print(sb.toString());
        return null;
    }

    private static String escapeJson(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
