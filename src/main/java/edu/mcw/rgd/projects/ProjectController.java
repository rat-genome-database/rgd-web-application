package edu.mcw.rgd.projects;

import edu.mcw.rgd.dao.impl.ProjectDAO;
import edu.mcw.rgd.datamodel.Project;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

public class ProjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

//        ProjectDAO pdao = new ProjectDAO();
//        List<Project> proj = pdao.getAllProjects();
//
//        //Method 1 by creating a dao object in the jsp itself
//
//        //Method 2 using request attriubtes
//        request.setAttribute("test",proj);
//        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/project/report.jsp");
//
//        //Method 3 using addObject and calling beansid in the jsp page
//        mv.addObject("allProjects", proj);
//        String id = request.getParameter("id");
//        if(id!=null){
//            mv = new ModelAndView("/WEB-INF/jsp/project/report.jsp");
//        }
//return null;
//        return mv;
        String rgdidParam = request.getParameter("id");
        ProjectDAO pdao = new ProjectDAO();
        // If rgdid parameter is present, fetch the specific project
        if (rgdidParam != null && !rgdidParam.isEmpty()) {
            List<Project> project = pdao.getProjectByRgdId(Integer.parseInt(rgdidParam));
            if (project != null) {
//                ModelAndView mv = new ModelAndView("/WEB-INF/jsp/project/project_details.jsp");
                ModelAndView mv = new ModelAndView("/WEB-INF/jsp/report/projectReport/main.jsp");
                mv.addObject("project", project);
//                request.setAttribute("project",project);
                return mv;
            }
        }

        // If rgdid parameter is not present or no project found, show the list of all projects
        List<Project> proj = pdao.getAllProjects();
        request.setAttribute("test", proj);
        response.setHeader("Set-Cookie", null);  // removes the header

        return new ModelAndView("/WEB-INF/jsp/project/report.jsp");
    }
    }



