package edu.mcw.rgd.expressMiner;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.process.mapping.MapManager;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.List;

/**
 * Renders the Expression Miner result table.
 *
 * Collects the tissue / strain selections (plus an optional gene list and
 * expression-level filter) carried in from the earlier wizard steps and hands
 * them to result.jsp. The JSP fetches the matching expression records from the
 * /rgdws expression index REST endpoint and builds the table client-side, so this
 * controller only prepares the query parameters -- it does not proxy any data.
 *
 * The expression index filters genes by RGD id, but the wizard collects gene
 * symbols, so any supplied gene list is resolved to RGD ids here (mirroring
 * StudyListEMController), and unresolved symbols are surfaced for the user.
 */
public class ExpressMinerResultController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int mapKey = 380;
        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        } catch (Exception ignore) {}

        List<String> tissueIds = collectParam(request, "tissueId");
        List<String> strainAccIds = collectParam(request, "strainId");
        String expressionLevel = request.getParameter("expressionLevel");
        String geneListParam = request.getParameter("geneList");

        // Resolve gene symbols -> RGD ids for the expression index gene filter.
        List<Integer> rgdIds = new ArrayList<>();
        List<String> unresolvedSymbols = new ArrayList<>();
        if (geneListParam != null && !geneListParam.trim().isEmpty()) {
            int speciesTypeKey = MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey();
            GeneDAO geneDAO = new GeneDAO();
            for (String sym : parseSymbols(geneListParam)) {
                List<Gene> matches = geneDAO.getAllGenesBySymbol(sym, speciesTypeKey);
                if (matches == null || matches.isEmpty()) {
                    unresolvedSymbols.add(sym);
                } else {
                    rgdIds.add(matches.get(0).getRgdId());
                }
            }
        }

        request.setAttribute("mapKey", mapKey);
        request.setAttribute("tissueIds", tissueIds);
        request.setAttribute("strainAccIds", strainAccIds);
        request.setAttribute("expressionLevel", expressionLevel);
        request.setAttribute("geneList", geneListParam);
        request.setAttribute("rgdIds", rgdIds);
        request.setAttribute("unresolvedSymbols", unresolvedSymbols);

        return new ModelAndView("/WEB-INF/jsp/expressMiner/result.jsp");
    }

    private List<String> collectParam(HttpServletRequest request, String name) {
        List<String> out = new ArrayList<>();
        String[] values = request.getParameterValues(name);
        if (values != null) {
            for (String v : values) {
                if (v != null && !v.trim().isEmpty()) out.add(v.trim());
            }
        }
        return out;
    }

    private List<String> parseSymbols(String input) {
        List<String> out = new ArrayList<>();
        if (input == null) return out;
        for (String token : input.split("[,\\s]+")) {
            String t = token.trim();
            if (!t.isEmpty()) out.add(t);
        }
        return out;
    }
}
