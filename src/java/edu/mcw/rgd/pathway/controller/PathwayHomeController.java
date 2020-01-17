package edu.mcw.rgd.pathway.controller;

import edu.mcw.rgd.dao.impl.PathwayDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: Apr 4, 2011
 * Time: 9:31:06 AM
 * To change this template use File | Settings | File Templates.
 */
public class PathwayHomeController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        HttpRequestFacade req = new HttpRequestFacade(request);
        //status.add("is this the Pathway you are talking about?");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        

        Map<String, String> pwAccMap = makePathwayListsMap();

       // error.add("hello");


        return new ModelAndView("/WEB-INF/jsp/curation/pathway/home.jsp", "pwMap", pwAccMap);
    }

    public Map<String, String> makePathwayListsMap() throws Exception{

        PathwayDAO pwdao = new PathwayDAO();
        List<String> pwList = pwdao.getPathwayList();

        //map with key(term) and value(acc_id)
        Map<String, String> pathwayMap = new TreeMap<String, String>(new Comparator<String>(){
            public int compare(String o1, String o2) {
                return o1.compareToIgnoreCase(o2);
            }
        });

        for(String pwId: pwList){
            String pwName = pwdao.getPathwayInfo(pwId).getName();
            pathwayMap.put(pwName, pwId);
        }

        return pathwayMap;
    }


}