package edu.mcw.rgd.ontology;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by mtutaj on 11/23/2015.
 */
public class CytoscapeController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        return new ModelAndView("/WEB-INF/jsp/ontology/cytoscape_iframe.jsp");
    }
}
