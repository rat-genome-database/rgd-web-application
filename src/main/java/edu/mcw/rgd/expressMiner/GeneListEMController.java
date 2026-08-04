package edu.mcw.rgd.expressMiner;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.List;

public class GeneListEMController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int mapKey = 380;
        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        } catch (Exception ignore) {}

        try {
            List<String> selectedStudyIds = collectParam(request, "studyId");
            boolean studiesFirst = !selectedStudyIds.isEmpty();

            // Carry forward any strain/tissue selections made before this step so
            // the gene list can be added on top of them and posted on to the results.
            List<String> selectedStrainIds = collectParam(request, "strainId");
            List<String> selectedTissueIds = collectParam(request, "tissueId");
            boolean strainTissueFirst = !selectedStrainIds.isEmpty() || !selectedTissueIds.isEmpty();

            request.setAttribute("mapKey", mapKey);
            request.setAttribute("selectedStudyIds", selectedStudyIds);
            request.setAttribute("studiesFirst", studiesFirst);
            request.setAttribute("selectedStrainIds", selectedStrainIds);
            request.setAttribute("selectedTissueIds", selectedTissueIds);

            // Pure "Limit by Genes" entry: the page offers a choice -- add strains/tissues, or
            // go straight to the (genes-only) results.
            boolean genesEntry = !strainTissueFirst && !studiesFirst;
            request.setAttribute("genesEntry", genesEntry);

            // Decide where the gene list posts next:
            //  - arrived from the strain/tissue step -> the gene list completes that query, go to results
            //  - pure "Limit by Genes" entry -> default action is the results page (genes only); the page
            //    also offers an "Add Strains / Tissues" button that posts to the strain/tissue step
            //  - studies were picked first -> legacy studies path
            String nextAction;
            if (strainTissueFirst) {
                nextAction = "/rgdweb/expressMiner/result.html";
            } else if (studiesFirst) {
                nextAction = "/rgdweb/expressMiner/config.html";
            } else {
                nextAction = "/rgdweb/expressMiner/result.html";
            }
            request.setAttribute("nextAction", nextAction);

            return new ModelAndView("/WEB-INF/jsp/expressMiner/geneList.jsp");
        } catch (Exception e) {
            request.setAttribute("mapKey", mapKey);
            request.setAttribute("errorMessage",
                    "Could not load gene list page: " + (e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage()));
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
