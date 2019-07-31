package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class CurationController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
            if(request.getParameter("accessToken") != null) {
                Cookie cookie1 = new Cookie("accessToken", request.getParameter("accessToken"));
                cookie1.setMaxAge(24*60*60);
                response.addCookie(cookie1);
                return new ModelAndView("/WEB-INF/jsp/curation/home.jsp", "hello", null);
            }
            else {
                Cookie cookie = new Cookie("accessToken", "");
                cookie.setMaxAge(0);
                response.addCookie(cookie);
                response.addHeader("Cache-Control","max-age=5, must-revalidate");
                response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
            }
            return null;
    }

}