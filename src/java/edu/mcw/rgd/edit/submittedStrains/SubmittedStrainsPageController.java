package edu.mcw.rgd.edit.submittedStrains;


import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainAvailablityDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
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
public class SubmittedStrainsPageController extends EditHomePageController implements Controller {
    SubmittedStrainDao sdao= new SubmittedStrainDao();
    GeneDAO geneDAO= new GeneDAO();
    SubmittedStrainAvailablityDAO adao= new SubmittedStrainAvailablityDAO();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<SubmittedStrain> submittedStrains=  this.getSubmittedStrains("submitted");
        ModelMap model= new ModelMap();
        model.put("submittedStrains", submittedStrains);
        return new ModelAndView("/WEB-INF/jsp/curation/edit/submittedStrains/submittedStrains.jsp", "model", model);
    }
}
