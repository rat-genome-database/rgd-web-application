package edu.mcw.rgd.edit;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ObsoleteGoTermsController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String page = "/WEB-INF/jsp/curation/edit/obsoleteGoTerms.jsp";
        ModelAndView mv = new ModelAndView(page);
        return mv;
    }
}
