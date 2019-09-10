package edu.mcw.rgd.web;

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
public class AuthenticationFilter implements Filter {
    public void init(FilterConfig filterConfig) throws ServletException {
        // nothing to do
    }

    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) servletResponse;
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        String loggedIn="";

        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("loggedIn"))
                loggedIn = request.getCookies()[0].getValue();

        if(loggedIn.equals("")) {
            response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
        } else
            filterChain.doFilter(request,response);
    }

    public void destroy() {
        // nothing to do
    }
}
