package edu.mcw.rgd.edit;


import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class CurationController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        if (request.getParameter("code") != null) {
            System.out.println("Got the code");
            return new ModelAndView("/WEB-INF/jsp/curation/home.jsp");
        } else {
            System.out.println("In Login block");
            return new ModelAndView("/WEB-INF/jsp/curation/login.jsp");
        }

    }

}