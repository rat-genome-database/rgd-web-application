package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
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
public class PhenominerCurationController extends PhenominerController {


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("action");
        PhenominerDAO dao = new PhenominerDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        if (!req.getParameter("referenceId").equals("")) {
            status.add("Reference imported with RGD ID " + req.getParameter("referenceId"));
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/phenominer/home.jsp");
    }

}