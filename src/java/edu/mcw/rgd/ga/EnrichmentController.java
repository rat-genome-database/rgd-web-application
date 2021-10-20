package edu.mcw.rgd.ga;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by hsnalabolu on 1/2/2019.
 */
public class EnrichmentController implements Controller {

    HttpServletRequest request = null;
    HttpServletResponse response = null;
    HttpRequestFacade req = null;
    int speciesTypeKey=-1;
    List symbols=null;


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
            int mapKey=Integer.parseInt(request.getParameter("mapKey"));
            speciesTypeKey= SpeciesType.getSpeciesTypeKeyForMap(mapKey);
        }

        symbols= Utils.symbolSplit(req.getParameter("genes"));
        request.setAttribute("symbols", this.symbols);
        request.setAttribute("o", req.getParameter("o"));


        if (!req.getParameter("start").equals("") || !req.getParameter("stop").equals("")) {
            try {
                Long.parseLong(req.getParameter("start"));
                Long.parseLong(req.getParameter("stop"));
            } catch (Exception e){
                error.add("Start or Stop Coordinate is invalid");
                request.setAttribute("error",error );
                request.setAttribute("status", status);
                request.setAttribute("warn", warning);

                return new ModelAndView("/WEB-INF/jsp/enrichment/start.jsp", "hello", null);

            }
        }


        ObjectMapper om = this.buildMapper(req.getParameter("idType"));






        if (om.getMapped().size() ==0) {
            //request.setAttribute("objectMapper", om);

            error.add("Zero Genes Found in Set.  Please select a larger Region.");
            request.setAttribute("error",error );
            request.setAttribute("status", status);
            request.setAttribute("warn", warning);

            return new ModelAndView("/WEB-INF/jsp/enrichment/start.jsp", "hello", null);

        }


        request.setAttribute("objectMapper", om);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/enrichment/analysis.jsp", "hello", null);
    }
    protected ObjectMapper buildMapper(String integerIdType) throws Exception{
        ObjectMapper om = new ObjectMapper();
        if(speciesTypeKey != 0)
            om.mapSymbols(symbols, speciesTypeKey, integerIdType);
        else
            om.mapSymbols(symbols, SpeciesType.RAT, integerIdType);
        if (req.isSet("chr") && req.isSet("start") && req.isSet("stop") && req.isSet("mapKey")) {
            om.mapPosition(req.getParameter("chr"), Integer.parseInt(req.getParameter("start")), Integer.parseInt(req.getParameter("stop")), Integer.parseInt(req.getParameter("mapKey")));
        }

        return om;
    }

}
