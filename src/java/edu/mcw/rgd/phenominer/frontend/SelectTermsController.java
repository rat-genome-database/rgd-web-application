package edu.mcw.rgd.phenominer.frontend;

import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by jdepons on 5/11/2017.
 */
public class SelectTermsController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String ont = "RS";
        String ontParam = request.getParameter("ont");
        if( ontParam!=null ) {
            ont = ontParam;
        }

        // 'sex' param only valid for 'RS' ontology
        String sex = "";
        if( ont.equals("RS") ) {
            sex = "both";
            String sexParam = request.getParameter("sex");
            if( sexParam!=null && (sexParam.equals("male") || sexParam.equals("female")) ) {
                sex = sexParam;
            }
        }

        String speciesTypeKey = "3";
        String spParam = request.getParameter("species");
        if( spParam!=null ) {
            speciesTypeKey = spParam;
        }

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/phenominer/selectTerms.jsp");
        mv.addObject("sex", sex);
        mv.addObject("ont", ont);
        mv.addObject("species", speciesTypeKey);
        mv.addObject("terms", Utils.defaultString(request.getParameter("terms")));
        return mv;
    }

}
