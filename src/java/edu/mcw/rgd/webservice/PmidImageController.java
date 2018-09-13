package edu.mcw.rgd.webservice;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: 3/6/12
 * Time: 2:27 PM
 * To change this template use File | Settings | File Templates.
 */
public class PmidImageController implements Controller{

    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(httpServletRequest);

        String pmid = req.getParameter("pmid");
        String term_acc = req.getParameter("term_acc");
        String object_key = req.getParameter("obj_key");
        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/webservice/testPmidService.jsp");
        mv.addObject("pmid", pmid);
        mv.addObject("term_acc", term_acc);
        mv.addObject("obj_key", object_key);
        return mv;
    }
}
