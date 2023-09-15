package edu.mcw.rgd.jbrowse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 5/29/14
 * Time: 1:01 PM
 * To change this template use File | Settings | File Templates.
 */

public class ContextMenuController  implements Controller {

        public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
            return new ModelAndView("/WEB-INF/jsp/jbrowse/contextMenu.jsp");
     }
}
