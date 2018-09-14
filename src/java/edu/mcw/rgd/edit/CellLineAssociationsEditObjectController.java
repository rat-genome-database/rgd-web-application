package edu.mcw.rgd.edit;

import edu.mcw.rgd.edit.association.ReferenceAssociationUpdate;
import edu.mcw.rgd.edit.association.RgdAssociationUpdate;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class CellLineAssociationsEditObjectController extends AssociationEditObjectController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        //HttpRequestFacade req = new HttpRequestFacade(request);

        int rgdId = Integer.parseInt(request.getParameter("rgdId"));

        this.updateAssociations(rgdId, request.getParameterValues("CellLineGeneAssociation"), new RgdAssociationUpdate("cellline_to_gene"));
        this.updateAssociations(rgdId,request.getParameterValues("CellLineStrainAssociation"), new RgdAssociationUpdate("cellline_to_strain"));
        this.updateAssociations(rgdId,request.getParameterValues("ReferenceAssociation"), new ReferenceAssociationUpdate());

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }
}