package edu.mcw.rgd.web;

import jakarta.servlet.*;
import java.io.IOException;
import java.util.Enumeration;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 8/21/14
 * Time: 2:42 PM
 * <p>
 * Verifies input parameter for script tag for every request
 */
public class InputValueFilter implements Filter {
    public void init(FilterConfig filterConfig) throws ServletException {
        // nothing to do
    }

    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        Enumeration<String> parameterNames=servletRequest.getParameterNames();
        while (parameterNames.hasMoreElements()){
            String paramName=parameterNames.nextElement();
            String[] paramValues=servletRequest.getParameterValues(paramName);
            for(String value:paramValues){
                if(value!=null && value.contains("<script>")){
                    System.out.println("Script tag found in: "+ paramName );
                    throw new RuntimeException("invalid input value for parameter "+ paramName);
                }
            }
        }
        // call the next filter in chain
        filterChain.doFilter(servletRequest, servletResponse);
    }

    public void destroy() {
        // nothing to do
    }
}
