package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.datamodel.Association;
import edu.mcw.rgd.datamodel.Strain2MarkerAssociation;
import edu.mcw.rgd.edit.association.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by hsnalabolu on 12/11/2018.
 */
public class VariantAssociationsEditObjectController extends AssociationEditObjectController {

    AssociationDAO adao = new AssociationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int rgdId = Integer.parseInt(request.getParameter("rgdId"));

        String markerClass = Utils.defaultString(request.getParameter("markerClass"));

        if (markerClass.equals("variant_to_gene")) {
            String[] geneRgdIds = request.getParameterValues("geneRgdId");
            String[] geneMarkerTypes = request.getParameterValues("geneMarkerType");
            updateGeneAssociations(rgdId, geneRgdIds, geneMarkerTypes, adao.getAssociationsForMasterRgdId(rgdId,"variant_to_gene"));
        }

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }

    void updateGeneAssociations(int variantRgdId, String[] rgdIds,String[] markerTypes,
                                  List<Association> inRgdAssocs) throws Exception {

        if (rgdIds != null) {
            for (int i = 0; i < rgdIds.length; i++) {
                String incomingRgdId = rgdIds[i];
                String markerType = markerTypes[i];

                // is the incoming rgd id already in rgd?
                boolean inRgd = false;
                Iterator<Association> it = inRgdAssocs.iterator();
                while (it.hasNext()) {
                   Association inRgdAssoc = it.next();
                    if (incomingRgdId.equals(Integer.toString(inRgdAssoc.getDetailRgdId()))) {
                        // yes, it is in rgd
                        inRgd = true;
                        it.remove();

                        // is update needed for marker type or region name?
                        if (!Utils.stringsAreEqualIgnoreCase(inRgdAssoc.getAssocSubType(), markerType) ) {
                            // update needed
                            inRgdAssoc.setAssocSubType(markerType);
                            adao.updateAssociation(inRgdAssoc);
                        }
                        break;
                    }
                }

                // if incoming data was not in rgd, insert it
                if (!inRgd) {
                    Association assoc = new Association();
                    assoc.setMasterRgdId(variantRgdId);
                    assoc.setDetailRgdId(Integer.parseInt(incomingRgdId));
                    assoc.setAssocType("variant_to_gene");
                    assoc.setAssocSubType(markerType);
                    adao.insertAssociation(assoc);
                }
            }
        }

        // incoming data processed -- whatever was left in 'inRgdAssocs' list is stale, and must be deleted
        for (Association a : inRgdAssocs) {
            adao.deleteAssociations(variantRgdId, a.getDetailRgdId(),"variant_to_gene");
        }
    }
}