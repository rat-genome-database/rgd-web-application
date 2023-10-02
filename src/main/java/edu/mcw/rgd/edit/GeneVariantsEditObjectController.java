package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.*;
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
public class GeneVariantsEditObjectController implements Controller {

    GeneDAO geneDAO = new GeneDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        int variantRgdId = Integer.parseInt(request.getParameter("rgdId"));
        Gene variantGene = geneDAO.getGene(variantRgdId);

        List<Gene> incomingParentGenes = parseParameters(request);
        List<Gene> existingParentGenes = geneDAO.getGeneFromVariant(variantRgdId);

        // drop all parent genes shared between incoming and existing lists
        updateParentGenes(incomingParentGenes, existingParentGenes);

        // add new parent genes
        for( Gene parentGene: incomingParentGenes ) {
            geneDAO.insertVariation(variantRgdId, parentGene.getRgdId(), variantGene.getType());
        }

        // delete unused parent genes
        for( Gene parentGene: existingParentGenes ) {
            GeneVariation var = new GeneVariation();
            var.setVariationKey(variantGene.getKey());
            var.setKey(parentGene.getKey());
            geneDAO.deleteGeneVariation(var);
        }

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");
    }

    List<Gene> parseParameters(HttpServletRequest request) throws Exception {

        String[] parentGeneRgdIds = request.getParameterValues("parentGeneRgdId");

        List<Gene> parentGenes = new ArrayList<Gene>();
        for( String parentGeneRgdId: parentGeneRgdIds ) {
            Gene parentGene = geneDAO.getGene(Integer.parseInt(parentGeneRgdId));
            if( !parentGenes.contains(parentGene) )
                parentGenes.add(parentGene);
        }
        return parentGenes;
    }

    int updateParentGenes(List<Gene> incomingParentGenes, List<Gene> existingParentGenes) throws Exception {

        int updatedCount = 0;

        Iterator<Gene> it1 = incomingParentGenes.iterator();
        while( it1.hasNext() ) {
            Gene var1 = it1.next();

            Iterator<Gene> it2 = existingParentGenes.iterator();
            while( it2.hasNext() ) {
                Gene var2 = it2.next();

                if( var1.getRgdId()==var2.getRgdId() ) {

                    it1.remove();
                    it2.remove();
                    break; // break inner loop
                }
            }
        }
        return updatedCount;
    }

}
