package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


public class CurationController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
            if(request.getParameter("accessToken") != null) {
                Cookie cookie1 = new Cookie("accessToken", request.getParameter("accessToken"));
                response.addCookie(cookie1);
                return new ModelAndView("/WEB-INF/jsp/curation/home.jsp", "hello", null);
            }
            else {
                Cookie cookie = new Cookie("accessToken", "");
                cookie.setMaxAge(0);
                response.addCookie(cookie);
                response.addHeader("Cache-Control","max-age=5, must-revalidate");
                response.setHeader("Access-Control-Allow-Credentials", "true");
              //  response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
               response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());
                return null;
            }

    }

}