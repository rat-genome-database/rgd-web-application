package edu.mcw.rgd.gviewer;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.query_dsl.Operator;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * ES-backed lookup for the GViewer "Add Objects" panel. Replaces the
 * Oracle-backed /rgdweb/search/{type}s.html?fmt=6 path. Returns JSON in
 * the same shape as {@link AnnotationJSONController} so the existing
 * {@code loadAnnotationsGET} client path can consume it directly.
 */
public class AddObjectsController implements Controller {

    private static final List<String> FIELDS = Arrays.asList(
            "annotatedObjectRgdId", "objectSymbol", "objectType",
            "chromosome", "startPos", "stopPos"
    );

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        String type = request.getParameter("type");
        String term = request.getParameter("term");
        String mapKeyStr = request.getParameter("mapKey");

        if (type == null || term == null || mapKeyStr == null
                || type.isEmpty() || term.isEmpty() || mapKeyStr.isEmpty()) {
            out.print("{\"genome\":{\"feature\":[]}}");
            return null;
        }

        int mapKey;
        try {
            mapKey = Integer.parseInt(mapKeyStr);
        } catch (NumberFormatException e) {
            out.print("{\"genome\":{\"feature\":[]}}");
            return null;
        }

        final String typeFilter = type;
        final long mapKeyFilter = mapKey;
        final String termValue = term;

        // Symbol match: case-insensitive substring on the keyword field
        // OR analyzed match on the text field. minimumShouldMatch=1.
        Query symbolMatch = Query.of(q -> q.bool(b -> b
                .should(s -> s.wildcard(w -> w
                        .field("objectSymbol.keyword")
                        .value("*" + termValue + "*")
                        .caseInsensitive(true)))
                .should(s -> s.match(m -> m
                        .field("objectSymbol")
                        .query(termValue)
                        .operator(Operator.And)))
                .minimumShouldMatch("1")));

        Query query = Query.of(q -> q.bool(b -> b
                .filter(f -> f.term(t -> t.field("objectType").value(FieldValue.of(typeFilter))))
                .filter(f -> f.term(t -> t.field("mapKey").value(FieldValue.of(mapKeyFilter))))
                .must(symbolMatch)));

        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<Map> resp = client.search(s -> s
                        .index(RgdContext.getESIndexName("gviewer"))
                        .query(query)
                        .size(1000)
                        .source(src -> src.filter(sf -> sf.includes(FIELDS)))
                        .collapse(c -> c.field("annotatedObjectRgdId")),
                Map.class);

        out.print("{\"genome\":{\"feature\":[");
        boolean first = true;
        for (Hit<Map> hit : resp.hits().hits()) {
            Map<String, Object> src = hit.source();
            if (src == null) continue;

            int rgdId = src.get("annotatedObjectRgdId") instanceof Number
                    ? ((Number) src.get("annotatedObjectRgdId")).intValue() : 0;
            if (rgdId == 0) continue;

            String objectType = s(src.get("objectType"));
            String symbol = s(src.get("objectSymbol"));

            String link = "gene".equals(objectType) ? Link.gene(rgdId) :
                    "qtl".equals(objectType) ? Link.qtl(rgdId) :
                    "strain".equals(objectType) ? Link.strain(rgdId) : "";

            if (!first) out.print(",");
            first = false;

            out.print("{");
            out.print("\"chromosome\":\"" + s(src.get("chromosome")) + "\",");
            out.print("\"start\":\"" + s(src.get("startPos")) + "\",");
            out.print("\"end\":\"" + s(src.get("stopPos")) + "\",");
            out.print("\"type\":\"" + objectType + "\",");
            out.print("\"label\":\"" + escapeJson(symbol) + "\",");
            out.print("\"link\":\"" + escapeJson(link) + "\"");
            out.print("}");
        }
        out.print("]}}");
        return null;
    }

    private static String s(Object o) {
        return o == null ? "" : String.valueOf(o);
    }

    private static String escapeJson(String v) {
        return v == null ? "" : v.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
