package edu.mcw.rgd.allelestrain;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.GeneticModelsDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.models.GeneticModel;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AlleleStrainController implements Controller {

    private final GeneDAO geneDAO = new GeneDAO();
    private final GeneticModelsDAO geneticModelsDAO = new GeneticModelsDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String genesParam = request.getParameter("genes");
        int speciesKey = parseIntOrDefault(request.getParameter("species"), 0);
        int mapKey = parseIntOrDefault(request.getParameter("mapKey"), 0);

        List<String> submittedSymbols = new ArrayList<>();
        if (genesParam != null && !genesParam.trim().isEmpty()) {
            for (String s : genesParam.split(",")) {
                String trimmed = s.trim();
                if (!trimmed.isEmpty()) {
                    submittedSymbols.add(trimmed);
                }
            }
        }

        Map<String, List<GeneticModel>> geneStrainMap = new LinkedHashMap<>();
        for (String symbol : submittedSymbols) {
            geneStrainMap.putIfAbsent(symbol, new ArrayList<>());
        }

        if (!submittedSymbols.isEmpty() && speciesKey > 0) {
            List<Gene> genes = geneDAO.getActiveGenesBySymbols(submittedSymbols, speciesKey);
            if (genes != null) {
                for (Gene gene : genes) {
                    List<GeneticModel> models = geneticModelsDAO.getAllModelsByGeneRgdId(gene.getRgdId());
                    if (models != null && !models.isEmpty()) {
                        String key = resolveKey(geneStrainMap, gene.getSymbol());
                        geneStrainMap.get(key).addAll(models);
                    }
                }
            }
        }

        request.setAttribute("submittedSymbols", submittedSymbols);
        request.setAttribute("geneStrainMap", geneStrainMap);
        request.setAttribute("speciesKey", speciesKey);
        request.setAttribute("mapKey", mapKey);

        return new ModelAndView("/WEB-INF/jsp/AlleleStrain/main.jsp");
    }

    private static int parseIntOrDefault(String s, int def) {
        if (s == null || s.isEmpty()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static String resolveKey(Map<String, List<GeneticModel>> map, String symbol) {
        if (symbol == null) return null;
        if (map.containsKey(symbol)) return symbol;
        for (String k : map.keySet()) {
            if (k.equalsIgnoreCase(symbol)) return k;
        }
        map.put(symbol, new ArrayList<>());
        return symbol;
    }
}
