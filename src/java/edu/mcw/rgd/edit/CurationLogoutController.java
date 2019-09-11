package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;


public class CurationLogoutController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        Cookie cookie1 = new Cookie("accessToken", "");
        cookie1.setMaxAge(0);
        cookie1.setPath("/");
        response.addCookie(cookie1);

        Cookie[] cookies = request.getCookies();
        for (Cookie cookie : cookies) {
            cookie.setMaxAge(0);
            cookie.setValue(null);
            cookie.setPath("/");
            response.addCookie(cookie);
        }

            response.addHeader("Cache-Control","max-age=5, must-revalidate");
            return new ModelAndView("/WEB-INF/jsp/curation/logout.jsp", "hello", null);
        }

}