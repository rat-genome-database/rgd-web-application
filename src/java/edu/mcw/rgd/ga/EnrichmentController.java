package edu.mcw.rgd.ga;

import edu.mcw.rgd.process.mapping.ObjectMapper;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by hsnalabolu on 1/2/2019.
 */
public class EnrichmentController extends GAController {
    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        this.init(request,response);

        ObjectMapper om = this.buildMapper(req.getParameter("idType"));
        request.setAttribute("objectMapper", om);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/enrichment/analysis.jsp", "hello", null);
    }

}
