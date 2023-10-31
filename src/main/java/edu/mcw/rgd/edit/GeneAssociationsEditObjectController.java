package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.datamodel.Strain;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

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
public class GeneAssociationsEditObjectController implements Controller {

    AssociationDAO dao = new AssociationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int geneRgdId = Integer.parseInt(request.getParameter("rgdId"));

        List<Integer> existingStrainRgdIds = getExistingStrainRgdIds(geneRgdId);
        List<Integer> incomingStrainRgdIds = parseParameters(request);


        // drop shared strain rgd ids
        dropSharedStrainRgdIds(incomingStrainRgdIds, existingStrainRgdIds);

        // add new strain rgd ids
        if(incomingStrainRgdIds != null) {
            for (Integer strainRgdId : incomingStrainRgdIds) {
                dao.insertStrainAssociation(strainRgdId, geneRgdId);
            }
        }

        // delete unused strain rgd ids
        for( Integer strainRgdId: existingStrainRgdIds ) {
            dao.removeStrainAssociation(strainRgdId, geneRgdId);
        }

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");
    }

    List<Integer> parseParameters(HttpServletRequest request) {
if(request.getParameterMap().containsKey("strainRgdId")) {
        String[] strainRgdIds = request.getParameterValues("strainRgdId");

            int recCount = strainRgdIds.length;

            List<Integer> records = new ArrayList<Integer>(recCount);
            for (int i = 0; i < recCount; i++) {
                int strainRgdId = Integer.parseInt(strainRgdIds[i]);

                // ensure the new id is unique
                if (!records.contains(strainRgdId))
                    records.add(strainRgdId);
            }
            return records;
        } else return null;
    }

    List<Integer> getExistingStrainRgdIds(int geneRgdId) throws Exception {

        StrainDAO strainDAO = new StrainDAO();
        List<Integer> strainRgdIds = new ArrayList<Integer>();
        for(Strain strain: strainDAO.getAssociatedStrains(geneRgdId) ) {
            strainRgdIds.add(strain.getRgdId());
        }
        return strainRgdIds;
    }

    // return count of dropped strain rgd ids
    int dropSharedStrainRgdIds(List<Integer> incomingStrainRgdIds, List<Integer> existingStrainRgdIds) throws Exception {

        int droppedCount = 0;
        if(incomingStrainRgdIds!=null) {
            // find incoming annotation that matches existingAnnotation
            Iterator<Integer> it1 = incomingStrainRgdIds.iterator();
            while (it1.hasNext()) {
                Integer var1 = it1.next();

                Iterator<Integer> it2 = existingStrainRgdIds.iterator();
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
        } else return existingStrainRgdIds.size();
    }

}
