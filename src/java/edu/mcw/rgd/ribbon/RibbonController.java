package edu.mcw.rgd.ribbon;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by jthota on 2/8/2019.
 */
public class RibbonController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/ribbon/ribbon.jsp");
    }
}
