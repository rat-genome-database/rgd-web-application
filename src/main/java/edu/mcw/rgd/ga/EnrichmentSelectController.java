package edu.mcw.rgd.ga;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by hsnalabolu on 1/2/2019.
 */
public class EnrichmentSelectController extends GAController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        if(request.getParameter("species") != null)
        return new ModelAndView("/WEB-INF/jsp/enrichment/start.jsp?species="+request.getParameter("species"), "hello", null);
        else return new ModelAndView("/WEB-INF/jsp/enrichment/start.jsp?species=3", "hello", null);
    }
}