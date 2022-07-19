package edu.mcw.rgd.report;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;


/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public abstract class ReportController implements Controller {

    public abstract String getViewUrl() throws Exception;
    public abstract Object getObject(int rgdId) throws Exception;


    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;
    HttpRequestFacade req=null;
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        String path = "/WEB-INF/jsp/report/";

       req = new HttpRequestFacade(request);

        String strRgdId = req.getParameter("id");
        strRgdId = strRgdId.replaceAll("RGD:", "");
        strRgdId = strRgdId.replaceAll("\\)","");

        int rgdId=0;
        Object object = null;

        try {
            rgdId = Integer.parseInt(strRgdId);

            try {
                object = this.getObject(rgdId);
                if( object==null ) {
                    error.add("Invalid RGD ID for this type of object!");
                }
            }
            catch( Exception e ) {
                error.add(e.getMessage());
            }
        }catch (Exception e) {
            error.add("RGD ID must be Numeric. Please Search Again.");
        }

        request.setAttribute("reportObject", object);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);


        if (error.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        }else {
            return new ModelAndView(path + this.getViewUrl());
        }
    }
}