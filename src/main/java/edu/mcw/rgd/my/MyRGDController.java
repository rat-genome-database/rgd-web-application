package edu.mcw.rgd.my;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class MyRGDController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        return new ModelAndView("/WEB-INF/jsp/my/myRgd.jsp");


    }

  
}