package edu.mcw.rgd.web;

import jakarta.servlet.*;

import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 8/21/14
 * Time: 2:42 PM
 * <p>
 * set RgdContext.isChinchilla variable appropriately for every request
 */
public class ChinchillaFilter implements Filter {
    public void init(FilterConfig filterConfig) throws ServletException {
        // nothing to do
    }

    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        // set-up RgdContext static class
        RgdContext.setChinchilla(servletRequest);

        // call the next filter in chain
        filterChain.doFilter(servletRequest, servletResponse);
    }

    public void destroy() {
        // nothing to do
    }
}
