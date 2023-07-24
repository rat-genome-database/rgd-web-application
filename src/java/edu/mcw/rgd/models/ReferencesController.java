package edu.mcw.rgd.models;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.datamodel.Reference;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.List;

/**
 * Created by jthota on 10/25/2016.
 */
public class ReferencesController implements Controller{

    private AssociationDAO associationDAO= new AssociationDAO();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

                String strainRgdId= request.getParameter("rgdId");
                int rgdId= Integer.parseInt(strainRgdId);
               
                List<Reference> refs = associationDAO.getReferenceAssociations(rgdId);
                request.setAttribute("refs", refs);

                return new ModelAndView("/WEB-INF/jsp/models/references.jsp");
    }
}
