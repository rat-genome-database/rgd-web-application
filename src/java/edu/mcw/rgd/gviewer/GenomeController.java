package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.ga.GAController;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class GenomeController extends GviewerController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        this.init(request, response);

        ObjectMapper om = new ObjectMapper();
        try {

            om = this.buildMapper(req.getParameter("idType"));

        }catch (Exception e) {
            e.printStackTrace();
            error.add(e.getMessage());
        }

        request.setAttribute("objectMapper", om);
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/gviewer/genome.jsp","hello", null);
    }



}