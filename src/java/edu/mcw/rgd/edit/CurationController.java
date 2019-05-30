package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class CurationController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

            return new ModelAndView("/WEB-INF/jsp/curation/home.jsp","hello", null);
    }

}