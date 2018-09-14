package edu.mcw.rgd.edit;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class AliasesEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        

        String[] atn = request.getParameterValues("aliasTypeName");
        String[] akey = request.getParameterValues("aliasKey");
        String[] av = request.getParameterValues("aliasValue");


        if (akey == null) {
            akey = new String[0];
        }

        AliasDAO adao = new AliasDAO();
        List<Alias> existingAliases = adao.getAliases(Integer.parseInt(request.getParameter("rgdId")));

        for (Alias a : existingAliases) {
            boolean found = false;
            for (String anAkey : akey) {
                if (a.getKey() == Integer.parseInt(anAkey)) {
                    found = true;
                }
            }
            if (!found && !a.getTypeName().startsWith("array_id_")) {
                adao.deleteAlias(a.getKey());
            }
        }


        for (int i = 0; i < akey.length; i++) {
            if (akey[i].equals("0")) {
                Alias a = new Alias();
                a.setTypeName(atn[i]);
                a.setValue(av[i]);
                a.setRgdId(Integer.parseInt(request.getParameter("rgdId")));
                adao.insertAlias(a);
            }else {
               Alias a = adao.getAliasByKey(Integer.parseInt(akey[i]));

               a.setTypeName(atn[i]);
               a.setValue(av[i]);

               adao.updateAlias(a);
            }
        }

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }



}