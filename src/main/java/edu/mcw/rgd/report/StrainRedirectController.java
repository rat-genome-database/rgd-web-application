package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.datamodel.Strain2MarkerAssociation;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class StrainRedirectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> error = new ArrayList<>();
        ArrayList<String> warning = new ArrayList<>();
        ArrayList<String> status = new ArrayList<>();

        HttpRequestFacade req = new HttpRequestFacade(request);
        OntologyXDAO xdao = new OntologyXDAO();
        StrainDAO sdao = new StrainDAO();
        String strainAcc = req.getParameter("acc");

        Object obj = null;
        try{
            int rgdId = xdao.getRgdIdForStrainOntId(strainAcc);
            obj = sdao.getStrain(rgdId);
            List<Strain2MarkerAssociation> geneAlleles = new AssociationDAO().getStrain2GeneAssociations(rgdId);
            Iterator<Strain2MarkerAssociation> it = geneAlleles.iterator();
            while( it.hasNext() ) {
                Strain2MarkerAssociation i = it.next();
                if( !Utils.stringsAreEqual(Utils.NVL(i.getMarkerType(),"allele"), "allele") ) {
                    it.remove();
                }
            }
            request.setAttribute("gene_alleles", geneAlleles);
        }
        catch (Exception e){
            error.add(e.getMessage());
        }
        if (obj==null){
            error.add("Strain Accession ID does not have a RGD ID!");
        }

        request.setAttribute("reportObject", obj);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);


        if (error.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        }
        return new ModelAndView("/WEB-INF/jsp/report/strain/main.jsp");
    }
}
