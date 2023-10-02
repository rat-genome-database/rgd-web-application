package edu.mcw.rgd.edit;

import edu.mcw.rgd.edit.association.ReferenceAssociationUpdate;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

public class ProjectAssociationEditObjectController extends AssociationEditObjectController{
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        HttpRequestFacade req = new HttpRequestFacade(request);

        int rgdId = Integer.parseInt(request.getParameter("rgdId"));
        this.updateAssociations(rgdId,request.getParameterValues("ReferenceAssociation"), new ReferenceAssociationUpdate());
        status.add("Update Successful");
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }
}
