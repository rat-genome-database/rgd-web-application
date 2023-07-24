package edu.mcw.rgd.ga;

import edu.mcw.rgd.process.mapping.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class GAUIController extends GAController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        this.init(request, response);

        ObjectMapper om = new ObjectMapper();
        try {

            om = this.buildMapper(req.getParameter("idType"));

        }catch (Exception e) {
            error.add(e.getMessage());
            e.printStackTrace();
        }

        request.setAttribute("objectMapper", om);
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/ga/ui.jsp","hello", null);
    }



}