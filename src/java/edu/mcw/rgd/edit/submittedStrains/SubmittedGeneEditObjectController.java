package edu.mcw.rgd.edit.submittedStrains;

import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.edit.GeneEditObjectController;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by jthota on 10/7/2016.
 */
public class SubmittedGeneEditObjectController extends GeneEditObjectController {
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        SubmittedStrainDao sdao = new SubmittedStrainDao();
        String submissionKey = request.getParameter("submissionKey");
        String geneType=request.getParameter("geneType");
        int key = Integer.parseInt(submissionKey);
        SubmittedStrain s = sdao.getSubmittedStrainBySubmissionKey(key);
        String notes= s.getNotes();
        String parentGene=s.getGeneSymbol();

        String displayStatus=s.getDisplayStatus();
        String status;
        if(displayStatus.equalsIgnoreCase("nonpublic")){
            status="WITHDRAWN";
        }else{
            status="ACTIVE";
        }
        String references= s.getReference();
        if(geneType!=null){
            if(geneType.equalsIgnoreCase("allele")){
                if (s.getAlleleRgdId() != 0) {
                    response.sendRedirect(request.getContextPath() + "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?rgdId=" + s.getAlleleRgdId()+ "&submittedParentGeneInfo=" +parentGene);
                } else {
                    ModelAndView mav= new ModelAndView("redirect:"+  "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?submissionKey=" + key + "&act=submitted&objectType=editGene.html&speciesType=Rat&objectStatus=" + status +"&geneType=" +geneType  + "&submittedParentGene=" +parentGene);
                    mav.addObject("additionalInfo",notes );
                    mav.addObject("references", references);
                    return mav;
                   // response.sendRedirect(request.getContextPath() + "/curation/edit/"+ this.getViewUrl().replaceAll(".jsp", ".html") +"?submissionKey=" + key + "&act=submitted&objectType=editGene.html&speciesType=Rat&objectStatus=ACTIVE&geneType=" +geneType + "&additionalInfo=" +notes + "&submittedParentGene=" +parentGene);
                }
                return null;
            }
            if(geneType.equalsIgnoreCase("gene")){
                if (s.getGeneRgdId() != 0) {
                    response.sendRedirect(request.getContextPath() + "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?rgdId=" + s.getGeneRgdId());
                } else {
                    ModelAndView mav= new ModelAndView("redirect:"+  "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?submissionKey=" + key + "&act=submitted&objectType=editGene.html&speciesType=Rat&objectStatus=" + status+ "&geneType=" +geneType );
                    mav.addObject("additionalInfo",notes );
                    mav.addObject("references", references);
                    return mav;
                   // response.sendRedirect(request.getContextPath() + "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?submissionKey=" + key + "&act=submitted&objectType=editGene.html&speciesType=Rat&objectStatus=ACTIVE&geneType=" +geneType + "&additionalInfo=" + notes );
                }
                return null;
            }
        }


       return null;

    }
}