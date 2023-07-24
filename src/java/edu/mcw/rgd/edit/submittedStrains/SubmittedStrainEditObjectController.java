package edu.mcw.rgd.edit.submittedStrains;

import edu.mcw.rgd.dao.impl.SubmittedStrainAvailablityDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.datamodel.models.SubmittedStrainAvailabiltiy;
import edu.mcw.rgd.edit.StrainEditObjectController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;

import java.util.List;

/**
 * Created by jthota on 10/7/2016.
 */
public class SubmittedStrainEditObjectController extends StrainEditObjectController {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        SubmittedStrainDao sdao = new SubmittedStrainDao();
        SubmittedStrainAvailablityDAO adao= new SubmittedStrainAvailablityDAO();
        String submissionKey = request.getParameter("submissionKey");
        int key = Integer.parseInt(submissionKey);
        SubmittedStrain s = sdao.getSubmittedStrainBySubmissionKey(key);
        String notes= s.getNotes();
        String backgroundStrain= s.getBackgroundStrain();
        int alleleRgdId= s.getAlleleRgdId();
        String displayStatus=s.getDisplayStatus();
        String status;
        if(displayStatus.equalsIgnoreCase("nonpublic")){
            status="WITHDRAWN";
        }else{
            status="ACTIVE";
        }

        String references= s.getReference();
        List<SubmittedStrainAvailabiltiy> availabiltiyList= adao.getAvailabilityByStrainKey(key);
        StringBuilder sb= new StringBuilder();
        boolean first=true;
        for(SubmittedStrainAvailabiltiy a:availabiltiyList){
            if(first){
                sb.append(a.getAvailabilityType());
                first=false;
            }else{
                sb.append("; ");
                sb.append(a.getAvailabilityType());
            }
        }
        if (s.getStrainRgdId() != 0) {
            response.sendRedirect(request.getContextPath() + "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?rgdId=" +s.getStrainRgdId() + "&submittedAlleleRgdIdInfo="+alleleRgdId);
        } else {

            ModelAndView mav= new ModelAndView("redirect:"+  "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?submissionKey=" + key + "&act=submitted&objectType=editStrain.html&speciesType=Rat&objectStatus="+ status+ "&submittedAvailability=" + sb.toString() + "&submittedAlleleRgdId="+alleleRgdId);
            mav.addObject("additionalInfo",notes );
            mav.addObject("references", references);
            mav.addObject("backgroundStrain", backgroundStrain);


            return mav;

        }  return null;
    }
}
