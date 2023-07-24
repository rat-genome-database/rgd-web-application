package edu.mcw.rgd.ga;

import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class GASearchController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        String geneList = req.getParameter("genes");
        String start = req.getParameter("start");
        String stop = req.getParameter("stop");

        List symbols= Utils.symbolSplit(req.getParameter("genes"));

        Iterator it = symbols.iterator();

        String page = "/WEB-INF/jsp/ga/search.jsp";
        String errorPage = "/ga/start.jsp";


        boolean foundInt = false;
        if (req.getParameter("idType").equals("")) {
            while (it.hasNext()) {
                try {
                    Integer.parseInt((String) it.next());
                    foundInt=true;
                    break;
                }catch (Exception e) {
                }
            }
        }

        if (foundInt) {
            page = "/WEB-INF/jsp/ga/idSelect.jsp";
        } else {

            if (geneList.equals("") && (start.equals("") || stop.equals(""))) {
                error.add("Please add a gene list or chromosome region");
                errorPage="/ga/welcome.jsp";


            }

            if ((start.equals("") && !stop.equals("")) || (!start.equals("") && stop.equals(""))) {
                error.add("Start and stop postion is required");
                errorPage="/ga/region.jsp";
            }

            if (!start.equals("") && !stop.equals("")) {
                try {
                    int startInt = Integer.parseInt(start);
                    int stopInt = Integer.parseInt(stop);
                }catch (Exception e) {
                    error.add("Start and stop position must be valid numeric base pair positions");
                    errorPage="/ga/region.jsp";
                }
            }
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        if (error.size() > 0) {
            return new ModelAndView(errorPage,"ret", null);
        }else {
            return new ModelAndView(page,"ret", null);
        }

    }



}