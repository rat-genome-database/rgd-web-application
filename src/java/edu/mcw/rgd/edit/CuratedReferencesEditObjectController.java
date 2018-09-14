package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.GeneVariation;
import edu.mcw.rgd.datamodel.Reference;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Mar 14, 2013
 */
public class CuratedReferencesEditObjectController implements Controller {

    AssociationDAO dao = new AssociationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        int geneRgdId = Integer.parseInt(request.getParameter("rgdId"));
        List<Integer> incomingRefRgdIds = parseParameters(request);
        List<Integer> existingRefRgdIds = getExistingRefRgdIds(geneRgdId);

        // drop all ref rgd ids shared between incoming and existing lists
        dropSharedRefRgdIds(incomingRefRgdIds, existingRefRgdIds);

        // add new ref rgd ids
        for( Integer refRgdId: incomingRefRgdIds ) {
            dao.insertReferenceeAssociation(geneRgdId, refRgdId);
        }

        // delete unused ref rgd ids
        for( Integer refRgdId: existingRefRgdIds ) {
            dao.removeReferenceAssociation(geneRgdId, refRgdId);
        }
        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");
    }

    List<Integer> parseParameters(HttpServletRequest request) throws Exception {

        String[] refRgdIdsParam = request.getParameterValues("refRgdId");

        List<Integer> refRgdIds = new ArrayList<Integer>();
        for( String refRgdIdStr: refRgdIdsParam ) {
            int refRgdId = Integer.parseInt(refRgdIdStr);
            if( !refRgdIds.contains(refRgdId) )
                refRgdIds.add(refRgdId);
        }
        return refRgdIds;
    }

    List<Integer> getExistingRefRgdIds(int geneRgdId) throws Exception {

        List<Integer> refRgdIds = new ArrayList<Integer>();
        for( Reference ref: dao.getReferenceAssociations(geneRgdId) ) {
            refRgdIds.add(ref.getRgdId());
        }
        return refRgdIds;
    }

    int dropSharedRefRgdIds(List<Integer> incomingRefRgdIds, List<Integer> existingRefRgdIds) throws Exception {

        int updatedCount = 0;

        Iterator<Integer> it1 = incomingRefRgdIds.iterator();
        while( it1.hasNext() ) {
            Integer var1 = it1.next();

            Iterator<Integer> it2 = existingRefRgdIds.iterator();
            while( it2.hasNext() ) {
                Integer var2 = it2.next();

                if( var1.equals(var2) ) {

                    updatedCount++;
                    it1.remove();
                    it2.remove();
                    break; // break inner loop
                }
            }
        }
        return updatedCount;
    }

}
