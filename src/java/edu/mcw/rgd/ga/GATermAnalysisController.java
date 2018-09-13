package edu.mcw.rgd.ga;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.Stamp;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 4/11/12
 * Time: 10:34 AM
 * To change this template use File | Settings | File Templates.
 */
public class GATermAnalysisController extends GAController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        this.request = request;
        this.response = response;
        req=new HttpRequestFacade(request);

        if (!req.getParameter("species").equals("")) {
            speciesTypeKey = Integer.parseInt(req.getParameter("species"));

        }else {
            speciesTypeKey = SpeciesType.getSpeciesTypeKeyForMap(Integer.parseInt(req.getParameter("mapKey")));
        }

        symbols= Utils.symbolSplit(req.getParameter("genes"));
        request.setAttribute("symbols", this.symbols);

        this.init(request,response);

        ObjectMapper om = new ObjectMapper();
        om.mapSymbols(symbols, speciesTypeKey);

        if (req.isSet("chr") && req.isSet("start") && req.isSet("stop") && req.isSet("mapKey")) {
            om.mapPosition(req.getParameter("chr"), Integer.parseInt(req.getParameter("start")), Integer.parseInt(req.getParameter("stop")), Integer.parseInt(req.getParameter("mapKey")));
        }

        request.setAttribute("objectMapper", om);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/ga/terms.jsp", "hello", null);
    }

}
