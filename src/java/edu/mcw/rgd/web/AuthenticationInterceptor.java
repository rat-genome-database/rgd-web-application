package edu.mcw.rgd.web;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: hsnalabolu
 * Date: 9/10/19
 * check authentication for every curation request
 */

public class AuthenticationInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler )  throws Exception {
        String loggedIn="";

        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("loggedIn"))
                loggedIn = request.getCookies()[0].getValue();

        System.out.println(loggedIn);
        if(loggedIn.equals("")) {
            System.out.println("Sendinf");
            response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
            return false;
        }else {System.out.println("logged"); return true;}
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
}
