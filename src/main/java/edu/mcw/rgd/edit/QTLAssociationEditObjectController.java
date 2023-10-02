package edu.mcw.rgd.edit;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.edit.association.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class QTLAssociationEditObjectController extends AssociationEditObjectController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        HttpRequestFacade req = new HttpRequestFacade(request);

        int rgdId = Integer.parseInt(request.getParameter("rgdId"));

        this.updateAssociations(rgdId, request.getParameterValues("QTLGeneAssociation"), new QTLGeneAssociationUpdate());
        this.updateAssociations(rgdId,request.getParameterValues("QTLStrainAssociation"), new QTLStrainAssociationUpdate());
        //this.updateAssociations(rgdId,request.getParameterValues("QTLQTLAssociation"), new QTLQTLAssociationUpdate());

        this.updateAssociations(rgdId,request.getParameterValues("ReferenceAssociation"), new ReferenceAssociationUpdate());

        status.add("Update Successfull");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }
}