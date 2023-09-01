package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class ProjectReportController extends ReportController {

    public String getViewUrl() throws Exception {
        return "projectReport/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
//        return new ReferenceDAO().getReference(rgdId);
        return new ProjectDAO().getProject(rgdId);
    }}
//public class ProjectReportController implements Controller {
//    public ProjectReportController() {
//    }
//    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
//
//        return new ModelAndView("/WEB-INF/jsp/report/projectReport/main.jsp");
//    }
//}