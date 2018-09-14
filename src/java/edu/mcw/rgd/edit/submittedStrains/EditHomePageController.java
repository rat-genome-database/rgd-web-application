package edu.mcw.rgd.edit.submittedStrains;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainAvailablityDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.datamodel.models.SubmittedStrainAvailabiltiy;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by jthota on 10/5/2016.
 */

public class EditHomePageController implements Controller {
    SubmittedStrainDao sdao= new SubmittedStrainDao();
    GeneDAO geneDAO= new GeneDAO();
    SubmittedStrainAvailablityDAO adao= new SubmittedStrainAvailablityDAO();
    StrainDAO strainDAO= new StrainDAO();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model= new ModelMap();

        if(request.getParameter("statusUpdate")!=null){
            if(request.getParameter(("statusUpdate")).equalsIgnoreCase("true")){
                String status=request.getParameter("status");
                String submissionKey= request.getParameter("submissionKey");
                sdao.updateApprovalStatus(Integer.parseInt(submissionKey), status);
            }
        }
        if(request.getParameter("delete")!=null){
            if(request.getParameter("delete").equalsIgnoreCase("true")){
                String submissionKey= request.getParameter("submissionKey");
                int key= Integer.parseInt(submissionKey);
                adao.delete(key);
                sdao.delete(key);
                String msg="Successfully deleted submitted strain record with submission key " + key;
               model.put("msg", msg);
            }
        }

        List<SubmittedStrain> submittedStrains= this.getSubmittedStrains("submitted");
        model.put("submittedStrains", submittedStrains);
        return new ModelAndView("/WEB-INF/jsp/curation/edit/submittedStrains/edit.jsp", "model", model);
    }

    public int getGeneOrAlleleRgdId(String symbol) throws Exception {
                List<Gene> geneOrAlleleList=geneDAO.getAllGenesBySymbol(symbol, 3);
                 int rgdId=0;
                 if(geneOrAlleleList!=null){
                         if(geneOrAlleleList.size()>0) {
                                 rgdId = geneOrAlleleList.get(0).getRgdId();
                             }else {
                                 List<Gene> aliasList=geneDAO.getGenesByAlias(symbol,3);
                                 if(aliasList!=null){
                                         if(aliasList.size()>0){
                                                 rgdId= aliasList.get(0).getRgdId();
                                         }
                                     }
                             }

                     }
                 return rgdId;
             }


    public Gene getGeneOrAllele(String symbol) throws Exception {
        List<Gene> geneOrAlleleList=geneDAO.getAllGenesBySymbol(symbol, 3);
        Gene g= new Gene();
        if(geneOrAlleleList!=null){
            if(geneOrAlleleList.size()>0) {
             g=  geneOrAlleleList.get(0);
            }else {
                List<Gene> aliasList=geneDAO.getGenesByAlias(symbol,3);
                if(aliasList!=null){
                    if(aliasList.size()>0){
                      g=   aliasList.get(0);
                    }
                }
            }

        }
        return g;
    }

    public List<SubmittedStrain> getSubmittedStrains(String status) throws Exception{
        List<SubmittedStrain> strains= new ArrayList<>();
        if(status.equalsIgnoreCase("submitted")){
            strains=  sdao.getInProcessStrains();
        }else if(status.equalsIgnoreCase("complete")){
           strains= sdao.getCompletedStrains();
        }

        List<SubmittedStrain> submittedStrains= new ArrayList<>();
        for(SubmittedStrain s: strains){
            String gene= s.getGeneSymbol();
            String allele= s.getAlleleSymbol();
            if(s.getGeneRgdId()==0){
                Gene g= this.getGeneOrAllele(gene);
                s.setGeneRgdId(g.getRgdId());
         
            }else{
                if(s.getGeneRgdId()>0){
                    Gene g=geneDAO.getGene(s.getGeneRgdId());
                     s.setGeneSymbol(g.getSymbol());
                }
            }
            if(s.getAlleleRgdId()==0){
                Gene a= this.getGeneOrAllele(allele);
                s.setAlleleRgdId(a.getRgdId());


              
            }else{
                if(s.getAlleleRgdId()>0){
                    Gene a= geneDAO.getGene(s.getAlleleRgdId());
                    s.setAlleleSymbol(a.getSymbol());
                }
            }
            if(s.getStrainRgdId()>0){
                Strain strain= strainDAO.getStrain(s.getStrainRgdId());
                if(strain!=null){
                s.setStrainSymbol(strain.getSymbol());
            }}
            List<SubmittedStrainAvailabiltiy> aList= adao.getAvailabilityByStrainKey(s.getSubmittedStrainKey());
            s.setAvailList(aList);
            submittedStrains.add(s);
        }
        return submittedStrains;
    }
}
