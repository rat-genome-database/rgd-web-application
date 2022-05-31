package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

public class CNVariantReportController implements Controller {

    public String getViewUrl() throws Exception {
        return "cnVariants/main.jsp";
    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantDAO().getVariant(rgdId);
    }

    public Object getObject(String rsId) throws Exception{
        return new VariantDAO().getVariantByRsId(rsId);
    }

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        String path = "/WEB-INF/jsp/report/";

        HttpRequestFacade req = new HttpRequestFacade(request);

        String strRgdId = req.getParameter("id");
        strRgdId = strRgdId.replaceAll("RGD:", "");
        strRgdId = strRgdId.replaceAll("\\)","");

        int rgdId=0;
        Object object = null;

        if (strRgdId.startsWith("rs")){
            try{
                object = getObject(strRgdId);
                if( object==null ) {
                    error.add("Invalid rs ID for this type of object!");
                }
            }
            catch (Exception e){
                error.add("Invalid rs IS for this object!");
            }
        }
        else {
            try {
                rgdId = Integer.parseInt(strRgdId);
                try {
                    object = getObject(rgdId);
                    if (object == null) {
                        error.add("Invalid RGD ID for this type of object!");
                    }
                } catch (Exception e) {
                    error.add(e.getMessage());
                }
            } catch (Exception e) {
                error.add("RGD ID must be Numeric. Please Search Again.");
            }
        }

        request.setAttribute("reportObject", object);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);


        if (error.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        }else {
            return new ModelAndView(path + getViewUrl());
        }
    }
}
