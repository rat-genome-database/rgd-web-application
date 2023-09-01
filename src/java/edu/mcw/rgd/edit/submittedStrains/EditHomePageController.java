package edu.mcw.rgd.edit.submittedStrains;

import com.google.gson.Gson;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.datamodel.models.SubmittedStrainAvailabiltiy;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by jthota on 10/5/2016.
 */

public class EditHomePageController implements Controller {
    SubmittedStrainDao sdao= new SubmittedStrainDao();
    GeneDAO geneDAO= new GeneDAO();
    SubmittedStrainAvailablityDAO adao= new SubmittedStrainAvailablityDAO();
    RGDManagementDAO rgdManagementDAO=new RGDManagementDAO();
    StrainDAO strainDAO=new StrainDAO();
    Gson gson=new Gson();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
//        ModelMap model= new ModelMap();

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
                request.setAttribute("msg",msg);
//               model.put("msg", msg);
            }
        }

        List<SubmittedStrain> submittedStrains= this.getSubmittedStrains("submitted");
        request.setAttribute("submittedStrains",submittedStrains);
//        model.put("submittedStrains", submittedStrains);
        return new ModelAndView("/WEB-INF/jsp/curation/edit/submittedStrains/edit.jsp");
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
            mapBySubmittedSymbols(s);
            mapBySubmittedRgdIds(s);
            submittedStrains.add(s);
        }
        return submittedStrains;
    }
    public void mapBySubmittedSymbols(SubmittedStrain submittedStrain) throws Exception {
        ObjectMapper om=new ObjectMapper();
        List<String> symbols=new ArrayList<>();
        if(submittedStrain.getGeneSymbol()!=null && !submittedStrain.getGeneSymbol().equals("") )
            symbols.add(submittedStrain.getGeneSymbol());
        if(submittedStrain.getStrainSymbol()!=null && !submittedStrain.getStrainSymbol().equals("") )
            symbols.add(submittedStrain.getStrainSymbol());
        if(submittedStrain.getAlleleSymbol()!=null && !submittedStrain.getAlleleSymbol().equals("") )
            symbols.add(submittedStrain.getAlleleSymbol());

        if(symbols.size()>0) {
            om.mapSymbols(symbols, 3);
            if(submittedStrain.getGeneSymbol()!=null || submittedStrain.getAlleleSymbol()!=null) {
                for (Object object : om.getMapped()) {
                    if (object instanceof Gene) {
                        Gene gene = (Gene) object;
                        if (submittedStrain.getGeneSymbol()!=null && submittedStrain.getGeneSymbol().equalsIgnoreCase(gene.getSymbol())) {
                            submittedStrain.setGene(gene);
                        } else  if (submittedStrain.getAlleleSymbol()!=null && submittedStrain.getAlleleSymbol().equalsIgnoreCase(gene.getSymbol()))
                        {
                            submittedStrain.setAllele(gene);
                        }
                    } else  {
                        try {
                            Strain strain = strainDAO.getStrainBySymbol((String) object);
                            if (strain != null)
                                submittedStrain.setStrain(strain);
                        }catch (Exception e){}
                    }
                }
            }
        }
    }
    public void mapBySubmittedRgdIds(SubmittedStrain submittedStrain) throws Exception {
        ObjectMapper om=new ObjectMapper();
        List<String> symbols=new ArrayList<>();
        if(submittedStrain.getGeneRgdId()>0)
            symbols.add(String.valueOf(submittedStrain.getGeneRgdId()));
        if(submittedStrain.getStrainRgdId()>0)
            symbols.add(String.valueOf(submittedStrain.getStrainRgdId()));
        if(submittedStrain.getAlleleRgdId()>0)
            symbols.add(String.valueOf(submittedStrain.getAlleleRgdId()));
        if(symbols.size()>0) {
            om.mapSymbols(symbols, 3, "rgd");
            for (Object object : om.getMapped()) {
                if (object instanceof Gene) {
                    Gene gene = (Gene) object;
                    if (submittedStrain.getGeneRgdId()==(gene.getRgdId())) {
                        if(submittedStrain.getGene()==null){
                            submittedStrain.setGene(gene);
                        }
                    } else  if (submittedStrain.getAlleleRgdId()==(gene.getRgdId())){
                        if(submittedStrain.getAllele()==null)
                            submittedStrain.setAllele(gene);
                    }
                } else {
                    try {
                        Strain strain = strainDAO.getStrain( Integer.parseInt(String.valueOf(object)));
                        if (strain != null)
                            submittedStrain.setStrain(strain);
                    }catch (Exception e){}
                }
            }
        }
    }
}
