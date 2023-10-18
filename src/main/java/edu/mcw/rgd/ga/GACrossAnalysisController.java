package edu.mcw.rgd.ga;

import edu.mcw.rgd.process.mapping.ObjectMapper;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 4/11/12
 * Time: 10:34 AM
 * To change this template use File | Settings | File Templates.
 */
public class GACrossAnalysisController extends GAController {


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

        return new ModelAndView("/WEB-INF/jsp/ga/cross.jsp", "hello", null);
    }

}
