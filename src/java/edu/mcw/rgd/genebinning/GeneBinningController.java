package edu.mcw.rgd.genebinning;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GeneBinningController implements Controller {


    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        ModelMap model = new ModelMap();
        return new ModelAndView("/WEB-INF/jsp/gene_binning/index.jsp");
    }
}
