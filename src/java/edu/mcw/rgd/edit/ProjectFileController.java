package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.ProjectFileDAO;
import edu.mcw.rgd.datamodel.ProjectFile;
import java.util.List;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
public class ProjectFileController implements Controller {
    ProjectFileDAO projectFileDAO = new ProjectFileDAO();

    private ProjectFile extractProjectFileFromRequest(HttpServletRequest request) {
        ProjectFile pf = new ProjectFile();
        if (request.getParameter("file_key") != null) {
            pf.setFile_key(Integer.parseInt(request.getParameter("file_key")));
        }
        pf.setRgdid(Integer.parseInt(request.getParameter("rgd_id")));
        pf.setProject_file_type(request.getParameter("project_file_type"));
        pf.setDownload_url(request.getParameter("download_url"));
        pf.setProtocol(request.getParameter("protocol"));
        pf.setProtocol_name(request.getParameter("protocol_name"));
        return pf;
    }

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String action = request.getParameter("action");
        if ("add".equals(action)) {
            addProjectFile(request);
        } else if ("update".equals(action)) {
            updateProjectFile(request);
        } else if ("delete".equals(action)) {
            deleteProjectFile(request);
        }
        String rgdId = request.getParameter("rgd_id");
        return new ModelAndView("redirect:/curation/edit/editProject.html?edit=new&token=null&objectType=editProject.html&rgdId=" + rgdId);
    }

    void addProjectFile(HttpServletRequest request) throws Exception {
        ProjectFile pf = extractProjectFileFromRequest(request);
        pf.setFile_key(projectFileDAO.getNextKeyFromSequence("REFERENCES_SEQ"));
        projectFileDAO.insert(pf);
    }

    void updateProjectFile(HttpServletRequest request) throws Exception {
        ProjectFile pf = extractProjectFileFromRequest(request);
        projectFileDAO.update(pf);
    }

    void deleteProjectFile(HttpServletRequest request) throws Exception {
        int fileKey = Integer.parseInt(request.getParameter("file_key"));
        projectFileDAO.delete(fileKey);
    }
}
