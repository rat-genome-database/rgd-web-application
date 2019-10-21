package edu.mcw.rgd.phenominer.metaAnalysis;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by jthota on 2/6/2019.
 */
public class ForestPlotController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/phenominer/newTool/forestPlot.jsp");
    }
}
