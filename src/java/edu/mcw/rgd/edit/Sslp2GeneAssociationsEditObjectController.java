package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: April 23, 2015
 */
public class Sslp2GeneAssociationsEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int sslpKey = Integer.parseInt(request.getParameter("sslpKey"));
        int sslpRgdId = Integer.parseInt(request.getParameter("sslpRgdId"));
        String msg = updateSslp2GeneAssociations(sslpKey, sslpRgdId, new HttpRequestFacade(request));

        status.add("Update Successful! "+msg);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }

    String updateSslp2GeneAssociations(int sslpKey, int sslpRgdId, HttpRequestFacade req) throws Exception {

        // request parameters
        List<String> geneRgdIdList = req.getParameterValues("gene_rgd_id");

        AssociationDAO associationDAO = new AssociationDAO();
        List<Gene> genesInRgd = associationDAO.getGeneAssociationsBySslp(sslpKey);


        // convert req params into gene_keys
        GeneDAO geneDAO = new GeneDAO();

        List<Integer> geneKeysIncoming = new ArrayList<Integer>();
        for( int i=0; i<geneRgdIdList.size(); i++ ) {
            String geneRgdId = geneRgdIdList.get(i);
            if( geneRgdId.isEmpty() )
                continue;
            geneKeysIncoming.add(geneDAO.getGene(Integer.parseInt(geneRgdId)).getKey());
        }

        int rowsInserted = 0;
        int rowsDeleted = 0;

        // pair (sslp_key,gene_key) must be unique

        for( int geneKeyIncoming: geneKeysIncoming ) {
            // is the incoming gene in RGD?
            Gene geneInRgd = null;
            for (Gene gene: genesInRgd) {
                if (gene.getKey() == geneKeyIncoming) {
                    // we have a matching row in RGD
                    geneInRgd = gene;
                    break;
                }
            }

            if( geneInRgd!=null ) {
                // remove the gene from list of genes in rgd
                genesInRgd.remove(geneInRgd);
            } else {
                // sslp2gene assoc must be inserted into RGD
                associationDAO.associateGeneWithSslp(geneKeyIncoming, sslpKey, "RGD");
                rowsInserted++;
            }
        }

        // whatever was left from genesInRgd, is not matching the incoming data, so it must be deleted from RGD
        for( Gene geneInRgd: genesInRgd ) {
            associationDAO.removeGeneAssociationsBySslp(sslpRgdId, geneInRgd.getRgdId());
            rowsDeleted++;
        }

        // build final message
        String msg = "";
        if( rowsInserted>0 )
            msg += rowsInserted+" sslp2gene association(s) inserted; ";
        if( rowsDeleted>0 )
            msg += rowsDeleted+" sslp2gene association(s) deleted; ";
        return msg;
    }
}