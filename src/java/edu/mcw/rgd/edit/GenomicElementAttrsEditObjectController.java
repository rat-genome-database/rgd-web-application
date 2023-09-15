package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.GenomicElementDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class GenomicElementAttrsEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        

        HttpRequestFacade req = new HttpRequestFacade(request);

        String[] akey = request.getParameterValues("attrKey");
        String[] atn = request.getParameterValues("attrName");
        String[] av = request.getParameterValues("atrrValue");


        if (akey == null) {
            akey = new String[0];
        }

        GenomicElementDAO adao = new GenomicElementDAO();
        /*
        List<GenomicElementAttr> existingAttrs = adao.getElementAttrs(Integer.parseInt(request.getParameter("rgdId")));

        for (GenomicElementAttr a : existingAttrs) {
            boolean found = false;
            for (String anAkey : akey) {
                if (a.getKey() == Integer.parseInt(anAkey)) {
                    found = true;
                }
            }
            if (!found) {
                adao.deleteElementAttr(a.getKey());
            }
        }


        for (int i = 0; i < akey.length; i++) {
            if (akey[i].equals("0")) {
                GenomicElementAttr a = new GenomicElementAttr();
                a.setName(atn[i]);
                a.setTextValue(av[i]);
                a.setRgdId(Integer.parseInt(request.getParameter("rgdId")));
                adao.insertElementAttr(a);
            }else {
               GenomicElementAttr a = adao.getElementAttr(Integer.parseInt(akey[i]));

               a.setName(atn[i]);
               a.setTextValue(av[i]);

               adao.updateElementAttr(a);
            }
        }
        */
        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }



}