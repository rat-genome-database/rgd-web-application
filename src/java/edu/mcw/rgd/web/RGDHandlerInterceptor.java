package edu.mcw.rgd.web;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.portlet.handler.HandlerInterceptorAdapter;
import org.springframework.web.servlet.ModelAndView;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jan 24, 2008
 * Time: 4:17:28 PM
 * <p>
 * RGD web application HandlerInterceptorAdaptor.  All rgd requests execute this class.
 */
public class RGDHandlerInterceptor extends HandlerInterceptorAdapter {

    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws java.lang.Exception {
        // set-up RgdContext static class
        //RgdContext.setChinchilla(request);
        return true;
    }

    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

        /*
        System.out.println(request.getRequestURI());

        System.out.println(request.getRemoteAddr());

        if (request.getRequestURI().indexOf(".jsp") != -1) {
            response.getWriter().println("Can't call jsp");
            return;
        }
        */
        //response.getWriter().println("in interceptor");
    }
}
