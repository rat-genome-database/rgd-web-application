package edu.mcw.rgd.report.ajax;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GeneDamagingVariantsController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/report/gene/ajax/damagingVariants.jsp");

        int rgdId = Integer.parseInt(request.getParameter("id"));
        String symbol = request.getParameter("s");

        mv.addObject("id", rgdId);
        mv.addObject("symbol", symbol);

        return mv;
    }

}
