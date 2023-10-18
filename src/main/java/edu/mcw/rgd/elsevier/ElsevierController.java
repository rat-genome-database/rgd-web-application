package edu.mcw.rgd.elsevier;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: 3/6/12
 * Time: 2:27 PM
 * To change this template use File | Settings | File Templates.
 */
public class ElsevierController implements Controller{

    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(httpServletRequest);
        String doiId = req.getParameter("doi");
        return new ModelAndView("/WEB-INF/jsp/elsevier/elsevierTest.jsp", "doi",doiId);  //To change body of implemented methods use File | Settings | File Templates.
    }
}
