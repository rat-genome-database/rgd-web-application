package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: Akhilanand K
 * Date: 2023
 */
public class ProjectReportController extends ReportController {

    public String getViewUrl() throws Exception {
        return "projectReport/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new ProjectDAO().getProject(rgdId);
    }}
