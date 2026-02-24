package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.HgncDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.HgncFamily;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class GeneFamilyReportController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        HgncDAO hgncDAO = new HgncDAO();
        GeneDAO geneDAO = new GeneDAO();
        HttpRequestFacade req = new HttpRequestFacade(request);

        String idStr = req.getParameter("id");
        HgncFamily obj = null;
        List<Gene> familyGenes = Collections.emptyList();
        List<String> hgncIds = Collections.emptyList();

        if (idStr == null || idStr.isEmpty()) {
            error.add("No family ID was given!");
        } else {
            try {
                int familyId = Integer.parseInt(idStr);
                obj = hgncDAO.getFamilyById(familyId);
                if (obj == null) {
                    error.add("No gene family was found with ID " + familyId);
                } else {
                    hgncIds = hgncDAO.getHgncIdsForFamily(familyId);

                    List<Integer> rgdIds = hgncDAO.getGeneRgdIdsForFamily(familyId);
                    if (!rgdIds.isEmpty()) {
                        familyGenes = geneDAO.getGeneByRgdIds(rgdIds);
                        familyGenes.sort((g1, g2) -> g1.getSymbol().compareToIgnoreCase(g2.getSymbol()));
                    }
                }
            } catch (NumberFormatException e) {
                error.add("Invalid family ID: " + idStr);
            } catch (Exception e) {
                error.add(e.getMessage());
            }
        }

        request.setAttribute("reportObject", obj);
        request.setAttribute("familyGenes", familyGenes);
        request.setAttribute("hgncIds", hgncIds);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        if (!error.isEmpty()) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        }
        return new ModelAndView("/WEB-INF/jsp/report/geneFamily/main.jsp");
    }
}
