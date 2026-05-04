package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.collapse.CollapseBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.Map;

/**
 * ES-backed lookup for the GViewer "Add Objects" panel. Replaces the
 * Oracle-backed /rgdweb/search/{type}s.html?fmt=6 path. Returns JSON in
 * the same shape as {@link AnnotationJSONController} so the existing
 * {@code loadAnnotationsGET} client path can consume it directly.
 */
public class AddObjectsController implements Controller {

    private static final String[] FIELDS = new String[]{
            "annotatedObjectRgdId", "objectSymbol", "objectType",
            "chromosome", "startPos", "stopPos"
    };

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

        // Symbol match: case-insensitive substring on the keyword field
        // OR analyzed match on the text field. minimumShouldMatch=1.
        BoolQueryBuilder symbolMatch = QueryBuilders.boolQuery()
                .should(QueryBuilders.wildcardQuery("objectSymbol.keyword", "*" + term + "*").caseInsensitive(true))
                .should(QueryBuilders.matchQuery("objectSymbol", term).operator(Operator.AND))
                .minimumShouldMatch(1);

        BoolQueryBuilder query = QueryBuilders.boolQuery()
                .filter(QueryBuilders.termQuery("objectType", type))
                .filter(QueryBuilders.termQuery("mapKey", mapKey))
                .must(symbolMatch);

        SearchSourceBuilder ssb = new SearchSourceBuilder()
                .query(query)
                .fetchSource(FIELDS, null)
                .size(1000)
                .collapse(new CollapseBuilder("annotatedObjectRgdId"));

        SearchResponse resp = ClientInit.getClient().search(
                new SearchRequest(RgdContext.getESIndexName("gviewer")).source(ssb),
                RequestOptions.DEFAULT);

        out.print("{\"genome\":{\"feature\":[");
        boolean first = true;
        for (SearchHit hit : resp.getHits().getHits()) {
            Map<String, Object> src = hit.getSourceAsMap();
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
