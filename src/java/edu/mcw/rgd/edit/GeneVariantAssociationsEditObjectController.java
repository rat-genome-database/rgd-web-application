package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.RgdVariantDAO;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.datamodel.Association;
import edu.mcw.rgd.datamodel.RgdVariant;
import edu.mcw.rgd.datamodel.Strain;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class GeneVariantAssociationsEditObjectController implements Controller {

    AssociationDAO dao = new AssociationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int geneRgdId = Integer.parseInt(request.getParameter("rgdId"));

        List<Integer> existingVariantRgdIds = getExistingVariantRgdIds(geneRgdId);
        List<Integer> incomingVariantRgdIds = parseParameters(request);


        // drop shared variant rgd ids
        dropSharedVariantRgdIds(incomingVariantRgdIds, existingVariantRgdIds);

        // add new variant rgd ids
        if(incomingVariantRgdIds != null) {
            for (Integer variantRgdId : incomingVariantRgdIds) {
                Association a = new Association();
                a.setAssocType("variant_to_gene");
                a.setAssocSubType("allele");
                a.setMasterRgdId(variantRgdId);
                a.setDetailRgdId(geneRgdId);
                dao.insertAssociation(a);
//                dao.insertStrainAssociation(strainRgdId, geneRgdId);
            }
        }

        // delete unused variant rgd ids
        for( Integer variantRgdId: existingVariantRgdIds ) {
            Association a = new Association();
            a.setAssocType("variant_to_gene");
            a.setAssocSubType("allele");
            a.setMasterRgdId(variantRgdId);
            a.setDetailRgdId(geneRgdId);
            dao.deleteAssociations(a.getMasterRgdId(),a.getDetailRgdId(),a.getAssocType());
//            dao.removeStrainAssociation(strainRgdId, geneRgdId);
        }

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");
    }

    List<Integer> parseParameters(HttpServletRequest request) {
        if(request.getParameterMap().containsKey("variantRgdId")) {
            String[] variantRgdIds = request.getParameterValues("variantRgdId");

                int recCount = variantRgdIds.length;

                List<Integer> records = new ArrayList<Integer>(recCount);
                for (int i = 0; i < recCount; i++) {
                    int variantRgdId = Integer.parseInt(variantRgdIds[i]);

                    // ensure the new id is unique
                    if (!records.contains(variantRgdId))
                        records.add(variantRgdId);
                }
                return records;
        } else return null;
    }

    List<Integer> getExistingVariantRgdIds(int geneRgdId) throws Exception {

        RgdVariantDAO rdao = new RgdVariantDAO();
        List<Integer> variantRgdIds = new ArrayList<Integer>();
        for (RgdVariant var : rdao.getVariantsFromGeneRgdId(geneRgdId)){
            variantRgdIds.add(var.getRgdId());
        }
        return variantRgdIds;
    }

    // return count of dropped variant rgd ids
    int dropSharedVariantRgdIds(List<Integer> incomingVariantRgdIds, List<Integer> existingVariantRgdIds) throws Exception {

        int droppedCount = 0;
        if(incomingVariantRgdIds!=null) {
            // find incoming annotation that matches existingAnnotation
            Iterator<Integer> it1 = incomingVariantRgdIds.iterator();
            while (it1.hasNext()) {
                Integer var1 = it1.next();

                Iterator<Integer> it2 = existingVariantRgdIds.iterator();
                while (it2.hasNext()) {
                    Integer var2 = it2.next();

                    if (var1.equals(var2)) {

                        droppedCount++;
                        it1.remove();
                        it2.remove();
                        break; // break inner loop
                    }
                }
            }
            return droppedCount;
        } else return existingVariantRgdIds.size();
    }

}
