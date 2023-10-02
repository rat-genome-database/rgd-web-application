package edu.mcw.rgd.primerCreate;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: Apr 4, 2011
 * Time: 9:31:06 AM
 * To change this template use File | Settings | File Templates.
 */
public class PrimerController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        HttpRequestFacade req = new HttpRequestFacade(request);
        //status.add("is this the Pathway you are talking about?");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        Map<String, Integer> speciesMap = makeSpeciesListsMap();

       // error.add("hello");


        return new ModelAndView("/WEB-INF/jsp/primer/home.jsp", "spMap", speciesMap);
    }

    public Map<String, Integer> makeSpeciesListsMap() throws Exception{

        MapDAO mdao = new MapDAO();
        List<edu.mcw.rgd.datamodel.Map> mapList = mdao.getActiveMaps();


        Map<String, Integer> spMap = new HashMap<String, Integer>();

        for(edu.mcw.rgd.datamodel.Map mapObj: mapList){
            String mapName = mapObj.getName();
            spMap.put(mapName, mapObj.getKey());
        }

        return spMap;
    }
}
