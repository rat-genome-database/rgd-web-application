package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class CurationController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
            if(request.getParameter("accessToken") != null)
                return new ModelAndView("/WEB-INF/jsp/curation/home.jsp","hello", null);
            else response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
            return null;
    }

}