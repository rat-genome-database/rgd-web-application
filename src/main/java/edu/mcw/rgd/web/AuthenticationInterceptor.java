package edu.mcw.rgd.web;

import org.json.JSONObject;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.*;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Created by IntelliJ IDEA.
 * User: hsnalabolu
 * Date: 9/10/19
 * check authentication for every curation request
 */

public class AuthenticationInterceptor implements HandlerInterceptor {

    String login = "";
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler )  throws Exception {

        // no access checking on DEV -- everything is allowed on DEV
        // TEMPORARILY REMOVED FOR DEBUGGING
        // if( RgdContext.isDev() ) {
        //     return true;
        // }

        // Skip authentication for POST requests to strainFileUpload (file uploads)
        // Authentication should have already been checked on initial page load (GET)
        if ("POST".equalsIgnoreCase(request.getMethod()) && 
            request.getRequestURI().contains("/rgdweb/curation/strainFileUpload")) {
            return true;
        }

        String token = request.getParameter("token");
        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken"))
                token = request.getCookies()[0].getValue();


        if(checkToken(token)) {
            if(request.getCookies() == null && request.getCookies().length == 0) {
                Cookie cookie1 = new Cookie("accessToken", token);
                response.addCookie(cookie1);
            }
            return true;
        }
        else {
           // response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
           response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());
            return false;
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res,
                                Object handler, Exception ex)  throws Exception {
        //do nothing
    }

    // Called after handler method request completion, before rendering the view
    @Override
    public void postHandle(HttpServletRequest req, HttpServletResponse res,
                           Object handler, ModelAndView model)  throws Exception {
        //do nothing
    }


    protected boolean checkToken(String token) throws Exception {

        if (token == null || token.isEmpty())
            return false;
        else {
            URL url = new URL("https://api.github.com/user");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setRequestProperty("Authorization", "Token " + token);

            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String line = in.readLine();
                JSONObject json = new JSONObject(line);
                login = (String) json.get("login");
                if (!login.equals("")) {
                    URL checkUrl = new URL("https://api.github.com/orgs/rat-genome-database/members/" + login);
                    HttpURLConnection connection = (HttpURLConnection) checkUrl.openConnection();
                    connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                    connection.setRequestProperty("Authorization", "Token " + token);
                    if (connection.getResponseCode() == 204)
                        return true;
                }
            }


            return false;
        }
    }
}
