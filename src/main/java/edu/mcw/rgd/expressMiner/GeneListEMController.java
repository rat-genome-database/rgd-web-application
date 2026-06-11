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

        String[] studyIds = request.getParameterValues("studyId");
        List<String> selectedStudyIds = new ArrayList<>();
        if (studyIds != null) {
            for (String id : studyIds) {
                if (id != null && !id.trim().isEmpty()) selectedStudyIds.add(id.trim());
            }
        }
        boolean studiesFirst = !selectedStudyIds.isEmpty();

        request.setAttribute("mapKey", mapKey);
        request.setAttribute("selectedStudyIds", selectedStudyIds);
        request.setAttribute("studiesFirst", studiesFirst);
        request.setAttribute("nextAction", studiesFirst
                ? "/rgdweb/expressMiner/config.html"
                : "/rgdweb/expressMiner/studyList.html");

        return new ModelAndView("/WEB-INF/jsp/expressMiner/geneList.jsp");
    }
}
