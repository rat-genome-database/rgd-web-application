package edu.mcw.rgd.models;


import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
        System.out.println("genes:" + genes.size());
        request.setAttribute("q", q);
        request.setAttribute("genes", genes);
        return new ModelAndView("/WEB-INF/jsp/models/getGenes.jsp");
    }
}
