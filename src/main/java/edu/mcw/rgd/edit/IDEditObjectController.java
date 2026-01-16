package edu.mcw.rgd.edit;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class IDEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        if (request.getParameter("objectStatus") == null) {
            error.add("Object Status Not Received");
        }

        if (request.getParameter("speciesType") == null) {
            error.add("Species Not Received");
        }

        RGDManagementDAO rdao = new RGDManagementDAO();
        RgdId rid = rdao.getRgdId(Integer.parseInt(request.getParameter("rgdId")));
        rid.setObjectStatus(request.getParameter("objectStatus"));
        rid.setLastModifiedDate(new Date());

        rid.setSpeciesTypeKey(SpeciesType.parse(request.getParameter("speciesType").toLowerCase()));
        rdao.updateRgdId(rid);

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }

}