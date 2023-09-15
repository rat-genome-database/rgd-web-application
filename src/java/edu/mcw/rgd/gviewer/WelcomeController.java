package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class WelcomeController implements org.springframework.web.servlet.mvc.Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        int mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        }catch (Exception e) {
        }
        request.setAttribute("mapKey",mapKey);


        return new ModelAndView("/WEB-INF/jsp/gviewer/welcome.jsp","hello", null);
    }

}