package edu.mcw.rgd.expressMiner;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

public class ExpressMinerController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        request.setAttribute("mapKey",380);

        return new ModelAndView("/WEB-INF/jsp/expressMiner/main.jsp");
    }
}
