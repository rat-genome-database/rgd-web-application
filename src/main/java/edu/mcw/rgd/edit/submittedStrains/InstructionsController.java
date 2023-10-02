package edu.mcw.rgd.edit.submittedStrains;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by jthota on 10/12/2016.
 */
public class InstructionsController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/curation/edit/submittedStrains/instructions.jsp");
    }
}
