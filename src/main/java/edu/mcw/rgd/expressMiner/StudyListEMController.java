package edu.mcw.rgd.expressMiner;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.GeneExpressionDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.mapping.MapManager;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class StudyListEMController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int mapKey = 380;
        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        } catch (Exception ignore) {}

        try {
            String geneListParam = request.getParameter("geneList");
            boolean genesFirst = geneListParam != null && !geneListParam.trim().isEmpty();

            List<Study> studies;
            List<String> unresolvedSymbols = new ArrayList<>();
            Integer resolvedSymbolCount = null;

            if (genesFirst) {
                int speciesTypeKey = MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey();
                List<String> symbols = parseSymbols(geneListParam);

                GeneDAO geneDAO = new GeneDAO();
                List<Integer> rgdIds = new ArrayList<>();
                for (String sym : symbols) {
                    List<Gene> matches = geneDAO.getAllGenesBySymbol(sym, speciesTypeKey);
                    if (matches == null || matches.isEmpty()) {
                        unresolvedSymbols.add(sym);
                    } else {
                        rgdIds.add(matches.get(0).getRgdId());
                    }
                }
                resolvedSymbolCount = symbols.size() - unresolvedSymbols.size();

                GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
                studies = rgdIds.isEmpty()
                        ? Collections.emptyList()
                        : geneExpressionDAO.getStudiesWithExpressionForObjects(rgdIds, mapKey);

                request.setAttribute("nextAction", "/rgdweb/expressMiner/config.html");
            } else {
                GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
                studies = geneExpressionDAO.getStudiesWithExpressionForMap(mapKey);
                request.setAttribute("nextAction", "/rgdweb/expressMiner/geneList.html");
            }

            request.setAttribute("mapKey", mapKey);
            request.setAttribute("geneList", geneListParam);
            request.setAttribute("genesFirst", genesFirst);
            request.setAttribute("resolvedSymbolCount", resolvedSymbolCount);
            request.setAttribute("unresolvedSymbols", unresolvedSymbols);
            request.setAttribute("studies", studies);

            return new ModelAndView("/WEB-INF/jsp/expressMiner/studyList.jsp");
        } catch (Exception e) {
            request.setAttribute("mapKey", mapKey);
            request.setAttribute("errorMessage",
                    "Could not load studies: " + (e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage()));
            return new ModelAndView("/WEB-INF/jsp/expressMiner/main.jsp");
        }
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
