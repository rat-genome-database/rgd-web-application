package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.datamodel.variants.VariantMapData;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

public class CNVariantsRsIdController implements Controller {
    protected VariantDAO vdao = new VariantDAO();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        String path = "/WEB-INF/jsp/report/";

        HttpRequestFacade req = new HttpRequestFacade(request);

        String rsId = req.getParameter("id");
        List<VariantMapData> objects = null;

        try {
            if (!rsId.equals(".")){
                objects = vdao.getAllVariantByRsId(rsId);
                if( objects==null ) {
                    error.add("Invalid rs ID!");
                }else if(objects.isEmpty()){
                    error.add("No variants with given rs ID!");
                }
            }
            else
                error.add("Invalid rs ID!");
        }
        catch( Exception e ) {
            error.add(e.getMessage());
        }
// show distinct rgd ids, rs715 an example to go right to page

        HashMap<Long,Boolean> duplicateRgdId = new HashMap<>();
        List<VariantMapData> objectsNonDupe = new ArrayList<>();
        for (VariantMapData obj : objects){
            if (duplicateRgdId.get(obj.getId())==null ){
                duplicateRgdId.put(obj.getId(),true);
                objectsNonDupe.add(obj);
            }
        }

        request.setAttribute("reportObjects", objectsNonDupe);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);


        if (error.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        } else if (objectsNonDupe.size()==1){
            request.setAttribute("reportObject", objectsNonDupe.get(0));
            return new ModelAndView("/WEB-INF/jsp/report/cnVariants/main.jsp");
        } else{
            return new ModelAndView("/WEB-INF/jsp/report/rsIds/main.jsp");
        }
    }
}