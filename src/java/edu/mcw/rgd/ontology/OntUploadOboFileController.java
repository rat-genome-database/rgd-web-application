package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Jun 7, 2011
 * Time: 3:05:57 PM
 */
public class OntUploadOboFileController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/ontology/view_old.jsp");


        OntAnnotBean bean = new OntAnnotBean();
        mv.addObject("bean", bean);

        // load annotations
        OntologyXDAO dao = new OntologyXDAO();
        OntAnnotController.loadAnnotations(bean, dao, request, OntAnnotBean.MAX_ANNOT_COUNT, false);

        return mv;
    }
}
