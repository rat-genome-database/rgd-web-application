package edu.mcw.rgd.projects;

import edu.mcw.rgd.dao.impl.ProjectDAO;
import edu.mcw.rgd.datamodel.Project;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;

public class ProjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ProjectDAO pdao = new ProjectDAO();
        List<Project> proj = pdao.getAllProjects();

        //Method 1 by creating a dao object in the jsp itself

        //Method 2 using request attriubtes
        request.setAttribute("test",proj);
        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/project/report.jsp");

        //Method 3 using addObject and calling beansid in the jsp page
        mv.addObject("allProjects", proj);
//        String id = request.getParameter("id");
//        if(id!=null){
//            mv = new ModelAndView("/WEB-INF/jsp/project/report.jsp");
//        }
//return null;
        return mv;
    }

}
