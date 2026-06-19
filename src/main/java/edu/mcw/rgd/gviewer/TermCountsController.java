package edu.mcw.rgd.gviewer;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * For a list of termAcc IDs, returns the unique-object (gene/QTL/strain)
 * count directly annotated to each in the gviewer index for the given
 * mapKey. Counts are *direct* — no ontology DAG expansion. The autocomplete
 * client treats all-zero responses as "greyed out, still shown" so the
 * dropdown isn't silently empty for ontologies (like HP) that the gviewer
 * index does not currently include.
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

        List<FieldValue> accValues = new ArrayList<>();
        for (String acc : accs) accValues.add(FieldValue.of(acc));
        List<FieldValue> typeValues = new ArrayList<>();
        for (String t : Arrays.asList("gene", "qtl", "strain")) typeValues.add(FieldValue.of(t));
        final long mapKeyFilter = mapKey;
        final int aggSize = accs.size();

        Query query = Query.of(qq -> qq.bool(b -> b
                .filter(f -> f.terms(t -> t.field("termAcc").terms(tt -> tt.value(accValues))))
                .filter(f -> f.term(t -> t.field("mapKey").value(FieldValue.of(mapKeyFilter))))
                .filter(f -> f.terms(t -> t.field("objectType").terms(tt -> tt.value(typeValues))))));

        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<Void> resp = client.search(s -> s
                        .index(RgdContext.getESIndexName("gviewer"))
                        .query(query)
                        .size(0)
                        .aggregations("by_term", a -> a
                                .terms(t -> t.field("termAcc").size(aggSize))
                                .aggregations("uniq", u -> u
                                        .cardinality(c -> c.field("annotatedObjectRgdId")))),
                Void.class);

        Map<String, Long> counts = new LinkedHashMap<>();
        for (String acc : accs) counts.put(acc, 0L);

        Aggregate byTerm = resp.aggregations().get("by_term");
        if (byTerm != null) {
            for (StringTermsBucket b : byTerm.sterms().buckets().array()) {
                Aggregate uniq = b.aggregations().get("uniq");
                long n = uniq == null ? b.docCount() : uniq.cardinality().value();
                counts.put(b.key().stringValue(), n);
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
