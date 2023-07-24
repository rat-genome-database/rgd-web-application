package edu.mcw.rgd.models;


import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.List;

/**
 * Created by jthota on 8/10/2016.
 */
public class AutocompleteController implements Controller {
GeneDAO geneDAO= new GeneDAO();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String q= request.getParameter("term");
        List<Gene> genes= geneDAO.getAllGenesBySubSymbol(q, 3);
        request.setAttribute("q", q);
        request.setAttribute("genes", genes);
        return new ModelAndView("/WEB-INF/jsp/models/getGenes.jsp");
    }
}
