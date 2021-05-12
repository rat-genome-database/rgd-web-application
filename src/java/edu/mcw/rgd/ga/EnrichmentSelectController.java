package edu.mcw.rgd.ga;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by hsnalabolu on 1/2/2019.
 */
public class EnrichmentSelectController extends GAController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        if(request.getParameter("species") != null)
        return new ModelAndView("/WEB-INF/jsp/enrichment/start.jsp?species="+request.getParameter("species"), "hello", null);
        else return new ModelAndView("/WEB-INF/jsp/enrichment/start.jsp?species=3", "hello", null);
    }
}