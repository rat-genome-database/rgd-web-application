package edu.mcw.rgd.ga;

import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class GAReportController extends GAController {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        this.init(request,response);

        ObjectMapper om = this.buildMapper(req.getParameter("idType"));
        request.setAttribute("objectMapper", om);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/ga/report.jsp", "hello", null);
    }

}