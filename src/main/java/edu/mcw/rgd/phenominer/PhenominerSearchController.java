package edu.mcw.rgd.phenominer;

import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class PhenominerSearchController extends PhenominerController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/phenominer/search.jsp");
    }

}