package edu.mcw.rgd.models;

/**
 * Created by jthota on 8/18/2016.
 */

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class StrainSubmissionHelp implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/models/strainSubmissionFormHelp.jsp");
    }
}
