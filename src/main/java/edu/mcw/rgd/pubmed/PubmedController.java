package edu.mcw.rgd.pubmed;

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
public class PubmedController implements Controller{

    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(httpServletRequest);
        String pmId = req.getParameter("pmid");
        return new ModelAndView("/WEB-INF/jsp/pubmed/pubmedDisplay.jsp", "pmid",pmId);  //To change body of implemented methods use File | Settings | File Templates.
    }
}
