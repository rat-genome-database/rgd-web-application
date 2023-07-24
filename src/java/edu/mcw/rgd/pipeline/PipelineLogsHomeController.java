package edu.mcw.rgd.pipeline;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

/**
 * Created by IntelliJ IDEA. <br>
 * User: mtutaj <br>
 * Date: 9/20/11 <br>
 * Time: 3:54 PM <br>
 * To change this template use File | Settings | File Templates.
 * <p>
 * CLASS DESCRIPTION HERE
 */
public class PipelineLogsHomeController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        return new ModelAndView("/WEB-INF/jsp/curation/pipeline/home.jsp");
    }
}
