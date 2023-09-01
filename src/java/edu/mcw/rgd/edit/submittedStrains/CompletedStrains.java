package edu.mcw.rgd.edit.submittedStrains;

import edu.mcw.rgd.dao.impl.AliasDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainAvailablityDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by jthota on 10/5/2016.
 */
public class CompletedStrains implements Controller {
    SubmittedStrainDao sdao=new SubmittedStrainDao();
    SubmittedStrainAvailablityDAO adao= new SubmittedStrainAvailablityDAO();
    SubmittedStrainsPageController ctrl=new SubmittedStrainsPageController();
    GeneDAO gdao=new GeneDAO();
    AliasDAO aliasDAO=new AliasDAO();
    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        ModelMap model= new ModelMap();
        List<SubmittedStrain> completedStrains= ctrl.getSubmittedStrains("complete");
        model.put("completedStrains", completedStrains);
        return new ModelAndView("/WEB-INF/jsp/curation/edit/submittedStrains/completedStrains.jsp", "model", model);
    }
}
