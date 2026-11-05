package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.datamodel.Strain2MarkerAssociation;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.edit.association.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class StrainAssociationEditObjectController extends AssociationEditObjectController {

    AssociationDAO adao = new AssociationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int rgdId = Integer.parseInt(request.getParameter("rgdId"));

        String markerClass = Utils.defaultString(request.getParameter("markerClass"));

        if (markerClass.equals("strain2var")) {
            String[] varRgdIds = request.getParameterValues("varRgdId");
            String[] varRegionNames = request.getParameterValues("varRegionName");
            String[] varMarkerTypes = request.getParameterValues("varMarkerType");
            updateStrainAssociations(rgdId, varRgdIds, varRegionNames, varMarkerTypes, adao.getStrain2VariantAssociations(rgdId));
        }

        if( markerClass.equals("strain2sslp") ) {
            String[] sslpRgdIds = request.getParameterValues("sslpRgdId");
            String[] sslpRegionNames = request.getParameterValues("sslpRegionName");
            String[] sslpMarkerTypes = request.getParameterValues("sslpMarkerType");
            updateStrainAssociations(rgdId, sslpRgdIds, sslpRegionNames, sslpMarkerTypes, adao.getStrain2SslpAssociations(rgdId));
        }

        if( markerClass.equals("strain2gene") ) {
            String[] geneRgdIds = request.getParameterValues("geneRgdId");
            String[] geneRegionNames = request.getParameterValues("geneRegionName");
            String[] geneMarkerTypes = request.getParameterValues("geneMarkerType");
            updateStrainAssociations(rgdId, geneRgdIds, geneRegionNames, geneMarkerTypes, adao.getStrain2GeneAssociations(rgdId));
        }

        if( markerClass.equals("strain2xxx") ) {
            this.updateAssociations(rgdId,request.getParameterValues("StrainQTLAssociation"), new StrainQTLAssociationUpdate());
            this.updateAssociations(rgdId,request.getParameterValues("StrainStrainAssociation"), new StrainStrainAssociationUpdate());
            this.updateAssociations(rgdId,request.getParameterValues("ReferenceAssociation"), new ReferenceAssociationUpdate());
        }

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }

    void updateStrainAssociations(int strainRgdId, String[] rgdIds, String[] regionNames, String[] markerTypes,
                                  List<Strain2MarkerAssociation> inRgdAssocs) throws Exception {

        if( rgdIds!=null ) {
            for( int i=0; i<rgdIds.length; i++ ) {
                String incomingRgdId = rgdIds[i];
                String regionName = regionNames[i];
                String markerType = markerTypes[i];

                // is the incoming rgd id already in rgd?
                boolean inRgd = false;
                Iterator<Strain2MarkerAssociation> it = inRgdAssocs.iterator();
                while( it.hasNext() ) {
                    Strain2MarkerAssociation inRgdAssoc = it.next();
                    if( incomingRgdId.equals(Integer.toString(inRgdAssoc.getMarkerRgdId())) ) {
                        // yes, it is in rgd
                        inRgd = true;
                        it.remove();

                        // is update needed for marker type or region name?
                        if(!Utils.stringsAreEqualIgnoreCase(inRgdAssoc.getMarkerType(), markerType) ||
                           !Utils.stringsAreEqualIgnoreCase(inRgdAssoc.getRegionName(), regionName) ) {
                            // update needed
                            inRgdAssoc.setMarkerType(markerType);
                            inRgdAssoc.setRegionName(regionName);
                            adao.updateStrainAssociation(inRgdAssoc);
                        }
                        break;
                    }
                }

                // if incoming data was not in rgd, insert it
                if( !inRgd ) {
                    Strain2MarkerAssociation assoc = new Strain2MarkerAssociation();
                    assoc.setStrainRgdId(strainRgdId);
                    assoc.setMarkerRgdId(Integer.parseInt(incomingRgdId));
                    assoc.setMarkerType(markerType);
                    assoc.setRegionName(regionName);
                    adao.insertStrainAssociation(assoc);
                }
            }
        }

        // incoming data processed -- whatever was left in 'inRgdAssocs' list is stale, and must be deleted
        for( Strain2MarkerAssociation a: inRgdAssocs ) {
            adao.removeStrainAssociation(strainRgdId, a.getMarkerRgdId());
        }
    }
}
