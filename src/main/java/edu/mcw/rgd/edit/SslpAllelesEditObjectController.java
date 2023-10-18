package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: April 23, 2015
 */
public class SslpAllelesEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int sslpKey = Integer.parseInt(request.getParameter("sslpKey"));
        String msg = updateSslpAlleles(sslpKey, new HttpRequestFacade(request));

        status.add("Update Successful! "+msg);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }

    String updateSslpAlleles(int sslpKey, HttpRequestFacade req) throws Exception {

        // request parameters
        List<String> strainRgdIdList = req.getParameterValues("strain_rgd_id");
        List<String> size1List = req.getParameterValues("size1");
        List<String> size2List = req.getParameterValues("size2");
        List<String> alleleNotesList = req.getParameterValues("allele_notes");

        // convert req params into SslpsAllele objects
        StrainDAO strainDAO = new StrainDAO();

        List<SslpsAllele> sslpsAllelesIncoming = new ArrayList<SslpsAllele>();
        for( int i=0; i<strainRgdIdList.size(); i++ ) {
            String strainRgdId = strainRgdIdList.get(i);
            if( strainRgdId.isEmpty() )
                continue;
            SslpsAllele sa = new SslpsAllele();
            sa.setSslpKey(sslpKey);
            sa.setStrainKey(strainDAO.getStrain(Integer.parseInt(strainRgdId)).getKey());
            String size = size1List.get(i);
            if( !size.isEmpty() )
                sa.setSize1(Integer.parseInt(size));
            size = size2List.get(i);
            if( !size.isEmpty() )
                sa.setSize2(Integer.parseInt(size));
            sa.setNotes(alleleNotesList.get(i));
            sslpsAllelesIncoming.add(sa);
        }

        SslpsAlleleDAO sslpsAlleleDAO = new SslpsAlleleDAO();
        List<SslpsAllele> sslpsAllelesInRgd = sslpsAlleleDAO.getSslpsAlleleByKey(sslpKey);

        int rowsUpdated = 0;
        int rowsInserted = 0;
        int rowsDeleted = 0;

        // pair (sslp_key,strain_key) must be unique

        for( SslpsAllele alleleIncoming: sslpsAllelesIncoming ) {
            // is the incoming allele in RGD?
            SslpsAllele alleleInRgd = null;
            for (SslpsAllele allele: sslpsAllelesInRgd) {
                if (allele.getSslpKey() == alleleIncoming.getSslpKey() &&
                        allele.getStrainKey() == alleleIncoming.getStrainKey()) {
                    // we have a matching row in RGD
                    alleleInRgd = allele;
                    break;
                }
            }

            if( alleleInRgd!=null ) {
                // matching allele in RGD -- determine if it needs to be updated
                if( alleleInRgd.getSize1()!=alleleIncoming.getSize1() ||
                    alleleInRgd.getSize2()!=alleleIncoming.getSize2() ||
                    !Utils.stringsAreEqual(alleleInRgd.getNotes(), alleleIncoming.getNotes()) ) {
                    // yes -- update fields
                    alleleIncoming.setKey(alleleInRgd.getKey());
                    sslpsAlleleDAO.updateAllele(alleleIncoming);
                    rowsUpdated++;
                }
                // remove the allele from list of alleles in rgd
                sslpsAllelesInRgd.remove(alleleInRgd);
            } else {
                // allele must be inserted into RGD
                sslpsAlleleDAO.insertSslpsAllele(alleleIncoming);
                rowsInserted++;
            }
        }

        // whatever was left from inRgd alleles, is not matching the incoming alleles, so it must be deleted from RGD
        for( SslpsAllele alleleInRgd: sslpsAllelesInRgd ) {
            sslpsAlleleDAO.deleteAllele(alleleInRgd);
            rowsDeleted++;
        }

        // build final message
        String msg = "";
        if( rowsInserted>0 )
            msg += rowsInserted+" allele(s) inserted, ";
        if( rowsDeleted>0 )
            msg += rowsDeleted+" allele(s) deleted, ";
        if( rowsUpdated>0 )
            msg += rowsUpdated+" allele(s) updated ";
        return msg;
    }
}