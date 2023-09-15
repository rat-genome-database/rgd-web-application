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
public class StatusUpdateController implements Controller {


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String path = "/WEB-INF/jsp/curation/edit/";

        HttpRequestFacade req = new HttpRequestFacade(request);

        String[] rgdIds = request.getParameterValues("rgdId");
        String objectStatus = request.getParameter("objectStatus");

        RGDManagementDAO dao = new RGDManagementDAO();

        if (rgdIds != null && objectStatus != null) {
            for (int i=0; i< rgdIds.length; i++) {
                RgdId rgdId = null;
                if (rgdIds[i] != null && !rgdIds[i].trim().equals("")) {
                    try {
                        int id = Integer.parseInt(rgdIds[i]);
                        rgdId = dao.getRgdId(id);
                        rgdId.setObjectStatus(objectStatus);

                        dao.updateRgdId(rgdId);
                        status.add("Updated " + rgdId);

                    } catch (Exception e) {
                        error.add("Update failed for RGD Id '" + rgdIds[i] + "'");

                    }
                }
            }
        }
        
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView(path + "statusUpdate.jsp");
    }

}