package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.reporting.Link;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
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
 * "gviewer" Elasticsearch index. Term resolution still uses the
 * ontology DAG in Oracle.
 */
public class XmlToolController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        GViewerBean bean = new GViewerBean();
        bean.loadParametersFromRequest(request);

        LinkedList<String[]> lines = new LinkedList<String[]>();
        bean.setLines(lines);

        // handle GViewer - AddObject - OntologyTerm (unchanged: ontology browse, no positions)
        String gviewer = request.getParameter("gviewer");
        if (gviewer != null && gviewer.equalsIgnoreCase("addObjTerm")) {
            return handleGViewerAddObjectTerm(bean);
        }

        int mapKey = bean.getEffectiveMapKey();
        String[] terms = bean.getTerms();
        String[] onts = bean.getOnts();
        String[] ops = bean.getOps();
        boolean withChildren = !"0".equals(request.getParameter("withChildren"));

        OntologyXDAO xdao = new OntologyXDAO();

        List<GViewerEsHelper.CriterionResult> criterionResults = new ArrayList<>();
        List<Set<Integer>> perCriterion = new ArrayList<>();
        Map<Integer, GViewerEsHelper.Row> firstPosition = new LinkedHashMap<>();

        for (int i = 0; i < terms.length; i++) {
            String ontList = (onts != null && i < onts.length) ? onts[i] : null;
            Set<String> expanded = GViewerEsHelper.expandToDescendants(xdao, terms[i], ontList, withChildren);
            GViewerEsHelper.CriterionResult cr = GViewerEsHelper.queryCriterion(expanded, mapKey);
            criterionResults.add(cr);
            perCriterion.add(cr.rgdIds);
            for (Map.Entry<Integer, List<GViewerEsHelper.Row>> e : cr.positions.entrySet()) {
                if (!firstPosition.containsKey(e.getKey()) && !e.getValue().isEmpty()) {
                    firstPosition.put(e.getKey(), e.getValue().get(0));
                }
            }
        }

        Set<Integer> finalRgds = GViewerEsHelper.combine(perCriterion, ops);

        // Build one row per rgdId (table view collapses multi-locus genes
        // to a single row, matching the original behavior).
        Map<Integer, String[]> linesMap = new HashMap<>();
        for (Integer rgdId : finalRgds) {
            GViewerEsHelper.Row r = firstPosition.get(rgdId);
            if (r == null) continue;

            String link = "gene".equals(r.objectType) ? Link.gene(rgdId) :
                    "qtl".equals(r.objectType) ? Link.qtl(rgdId) :
                    "strain".equals(r.objectType) ? Link.strain(rgdId) :
                    "";

            String[] line = new String[6 + terms.length];
            line[0] = String.valueOf(rgdId);
            line[1] = r.objectType;
            line[2] = r.objectSymbol;
            line[3] = link;
            line[4] = r.chromosome;
            String start = r.startPos == null ? "" : r.startPos;
            String stop = r.stopPos;
            line[5] = start + (stop != null && !stop.isEmpty() && !stop.equals(start) ? "-" + stop : "");

            lines.add(line);
            linesMap.put(rgdId, line);
        }

        // Per-term column: list each criterion's matched terms for the rgdId
        for (int termIndex = 0; termIndex < terms.length; termIndex++) {
            String selTerm = terms[termIndex] == null ? "" : terms[termIndex].toLowerCase();
            Map<Integer, List<GViewerEsHelper.TermHit>> termHits = criterionResults.get(termIndex).termHits;

            for (Integer rgdId : finalRgds) {
                String[] line = linesMap.get(rgdId);
                if (line == null) continue;
                List<GViewerEsHelper.TermHit> hits = termHits.get(rgdId);
                if (hits == null) continue;

                StringBuilder cell = new StringBuilder();
                for (GViewerEsHelper.TermHit th : hits) {
                    int pos = th.termAcc.indexOf(':');
                    String ontId = pos > 0 ? th.termAcc.substring(0, pos + 1) + ' ' : "";
                    String formatted = "<a href='" + Link.ontAnnot(th.termAcc) + "'>"
                            + ontId + GViewerBean.highlight(th.term, selTerm) + "</a>";
                    if (cell.length() > 0) cell.append("<br>");
                    cell.append(formatted);
                }
                line[6 + termIndex] = cell.toString();
            }
        }

        ModelAndView mv = new ModelAndView("/gTool/GViewerTerms.jsp");
        mv.addObject("bean", bean);
        return mv;
    }

    ModelAndView handleGViewerAddObjectTerm(GViewerBean bean) throws Exception {

        String sql = bean.buildSqlForAddObjectTerm();

        AnnotationDAO annotationDAO = new AnnotationDAO();

        //   0         1        2          3          4             5
        // TERM_ACC | TERM | ONTOLOGY | RAT_COUNT | MOUSE_COUNT | HUMAN_COUNT
        List<String[]> lines = bean.getLines();

        Connection conn = null;
        try {
            conn = DataSourceFactory.getInstance().getDataSource().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                String term = rs.getString("term");
                String termAcc = rs.getString("term_acc");
                String ontName = rs.getString("ont_name");

                int annotObjCountRat = annotationDAO.getAnnotatedObjectCount(termAcc, true, SpeciesType.RAT, 0);
                int annotObjCountMouse = annotationDAO.getAnnotatedObjectCount(termAcc, true, SpeciesType.MOUSE, 0);
                int annotObjCountHuman = annotationDAO.getAnnotatedObjectCount(termAcc, true, SpeciesType.HUMAN, 0);

                String[] line = new String[6];
                line[0] = termAcc;
                line[1] = term;
                line[2] = ontName;
                line[3] = Integer.toString(annotObjCountRat);
                line[4] = Integer.toString(annotObjCountMouse);
                line[5] = Integer.toString(annotObjCountHuman);

                lines.add(line);
            }

        } catch (SQLException se) {
            se.printStackTrace();
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception ignored) {
            }
        }

        ModelAndView mv = new ModelAndView("/gTool/GViewerAddObjectTerm.jsp");
        mv.addObject("bean", bean);
        return mv;
    }
}
