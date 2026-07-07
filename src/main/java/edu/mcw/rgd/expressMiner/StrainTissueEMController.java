package edu.mcw.rgd.expressMiner;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.List;

/**
 * Renders the Expression Miner "Limit by Strain / Tissue" step.
 *
 * The page lets the user build two lists of ontology terms through the shared
 * ontology popup browser: strains (RS ontology) and tissues (UBERON ontology).
 * Either, both, or neither may be chosen. Any selections (plus an optional gene
 * list carried forward) are posted on to the next step.
 */
public class StrainTissueEMController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int mapKey = 380;
        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        } catch (Exception ignore) {}

        try {
            // Carry forward anything already chosen in an earlier step so this
            // page can sit before or after the gene/study steps.
            String geneListParam = request.getParameter("geneList");

            List<String> selectedStrainIds = collectParam(request, "strainId");
            List<String> selectedTissueIds = collectParam(request, "tissueId");

            request.setAttribute("mapKey", mapKey);
            request.setAttribute("geneList", geneListParam);
            request.setAttribute("selectedStrainIds", selectedStrainIds);
            request.setAttribute("selectedTissueIds", selectedTissueIds);
            request.setAttribute("nextAction", "/rgdweb/expressMiner/config.html");

            return new ModelAndView("/WEB-INF/jsp/expressMiner/strainTissue.jsp");
        } catch (Exception e) {
            request.setAttribute("mapKey", mapKey);
            request.setAttribute("errorMessage",
                    "Could not load strain/tissue page: " + (e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage()));
            return new ModelAndView("/WEB-INF/jsp/expressMiner/main.jsp");
        }
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
}
