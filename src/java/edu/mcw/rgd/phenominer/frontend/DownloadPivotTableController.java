package edu.mcw.rgd.phenominer.frontend;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by jdepons on 5/11/2017.
 */
public class DownloadPivotTableController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        return new ModelAndView("/WEB-INF/jsp/phenominer/download.jsp", "", null);
    }

}
