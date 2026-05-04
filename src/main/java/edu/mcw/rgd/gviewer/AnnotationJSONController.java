package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.reporting.Link;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 8/13/12
 * Time: 4:23 PM
 *
 * Position lookup migrated from Oracle (maps_data join) to the
 * "gviewer" Elasticsearch index. Term resolution still uses the Oracle
 * ontology DAG via {@link GViewerEsHelper#expandToDescendants}.
 */
public class AnnotationJSONController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        GViewerBean bean = new GViewerBean();
        bean.loadParametersFromRequest(request);

        int mapKey = bean.getEffectiveMapKey();
        String[] terms = bean.getTerms();
        String[] onts = bean.getOnts();
        String[] ops = bean.getOps();

        OntologyXDAO xdao = new OntologyXDAO();

        // One ES call per criterion. Position rows from every criterion
        // accumulate into a master map so OR/UNION-combined results still
        // have positions for every rgdId in the final set.
        Map<Integer, List<GViewerEsHelper.Row>> positions = new LinkedHashMap<>();
        List<Set<Integer>> perCriterion = new ArrayList<>();

        for (int i = 0; i < terms.length; i++) {
            String ontList = (onts != null && i < onts.length) ? onts[i] : null;
            java.util.Set<String> expanded = GViewerEsHelper.expandToDescendants(xdao, terms[i], ontList);
            GViewerEsHelper.CriterionResult cr = GViewerEsHelper.queryCriterion(expanded, mapKey);
            perCriterion.add(cr.rgdIds);
            mergePositions(positions, cr.positions);
        }

        Set<Integer> finalRgds = GViewerEsHelper.combine(perCriterion, ops);

        out.print("{\"genome\":{\"feature\":[");
        boolean first = true;
        for (Integer rgdId : finalRgds) {
            List<GViewerEsHelper.Row> rows = positions.get(rgdId);
            if (rows == null) continue;
            for (GViewerEsHelper.Row r : rows) {
                String link = "gene".equals(r.objectType) ? Link.gene(rgdId) :
                        "qtl".equals(r.objectType) ? Link.qtl(rgdId) :
                        "strain".equals(r.objectType) ? Link.strain(rgdId) :
                        "";
                // Okabe-Ito CVD-safe palette; mirrors gviewer.js colorScheme
                String color = "gene".equals(r.objectType) ? "#D55E00" :
                        "qtl".equals(r.objectType) ? "#0072B2" :
                        "strain".equals(r.objectType) ? "#009E73" :
                        "";
                String symbol = r.objectSymbol.replaceAll("\\<.*?>", "");

                if (!first) out.print(",");
                first = false;

                out.print("{");
                out.print("\"chromosome\":\"" + r.chromosome + "\",");
                out.print("\"start\":\"" + r.startPos + "\",");
                out.print("\"end\":\"" + r.stopPos + "\",");
                out.print("\"type\":\"" + r.objectType + "\",");
                out.print("\"label\":\"" + escapeJson(symbol) + "\",");
                out.print("\"link\":\"" + escapeJson(link) + "\",");
                out.print("\"color\":\"" + color + "\"");
                out.print("}");
            }
        }
        out.println("]}}");

        return null;
    }

    private static void mergePositions(Map<Integer, List<GViewerEsHelper.Row>> dest,
                                       Map<Integer, List<GViewerEsHelper.Row>> src) {
        for (Map.Entry<Integer, List<GViewerEsHelper.Row>> e : src.entrySet()) {
            List<GViewerEsHelper.Row> existing = dest.computeIfAbsent(e.getKey(), k -> new ArrayList<>());
            for (GViewerEsHelper.Row r : e.getValue()) {
                if (!existing.contains(r)) existing.add(r);
            }
        }
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
