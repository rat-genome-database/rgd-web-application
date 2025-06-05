package edu.mcw.rgd.projects;

import edu.mcw.rgd.dao.impl.ProjectDAO;
import edu.mcw.rgd.datamodel.Project;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.util.List;

public class ProjectController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        // ✅ Prevent session creation
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Optional: clear existing session if present
        }

        // ✅ Strip Set-Cookie header (if added early by servlet container)
        response.setHeader("Set-Cookie", null);

        String rgdidParam = request.getParameter("id");
        ProjectDAO pdao = new ProjectDAO();

        if (rgdidParam != null && !rgdidParam.isEmpty()) {
            List<Project> project = pdao.getProjectByRgdId(Integer.parseInt(rgdidParam));
            if (project != null) {
                ModelAndView mv = new ModelAndView("/WEB-INF/jsp/report/projectReport/main.jsp");
                mv.addObject("project", project);
                return mv;
            }
        }

        List<Project> proj = pdao.getAllProjects();
        request.setAttribute("test", proj);

        return new ModelAndView("/WEB-INF/jsp/project/report.jsp");
    }
}
