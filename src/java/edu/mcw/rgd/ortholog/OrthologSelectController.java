package edu.mcw.rgd.ortholog;

import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

/**
 * Created by hsnalabolu on 4/9/2019.
 */
public class OrthologSelectController implements Controller {

    HttpServletRequest request = null;
    HttpServletResponse response = null;
    HttpRequestFacade req = null;


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;
        req=new HttpRequestFacade(request);

        if(request.getParameter("species") != null)
         return new ModelAndView("/WEB-INF/jsp/ortholog/start.jsp?species="+request.getParameter("species"), "hello", null);
        else return new ModelAndView("/WEB-INF/jsp/ortholog/start.jsp?species=3", "hello", null);
    }
}
