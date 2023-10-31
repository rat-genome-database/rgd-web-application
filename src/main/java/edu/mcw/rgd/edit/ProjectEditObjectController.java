package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.Project;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.dao.impl.ProjectDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;


/**
 * Curation project edit: edit a row from project table
 */
public class ProjectEditObjectController extends EditObjectController {

    ReferenceDAO dao = new ReferenceDAO();
    ProjectDAO prodao = new ProjectDAO();

    public String getViewUrl() throws Exception {
        return "editProject.jsp";
    }

    public int getObjectTypeKey() {
        return 14;
    }

    public Object getObject(int rgdId) throws Exception{
        return prodao.getProjectByRgdId1(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }

    public Object newObject() throws Exception{
        Project pro = new Project();
        return pro;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        String rgdId = req.getParameter("rgdId");
        Project pro = null;
        if( !rgdId.isEmpty()) {
            try {
                pro=(Project) getObject(Integer.parseInt(rgdId));
            } catch (Exception e) {

            }
        }
        boolean isNew = pro==null;

        if( isNew ) {
            pro = (Project) newObject();
        }

          pro.setDesc(req.getParameter("desc"));
          pro.setName(req.getParameter("name"));
          pro.setSubmitterName(req.getParameter("submitterName"));
          pro.setPiName(req.getParameter("piName"));
        if (persist) {
            if( isNew ) {
                // create a new rgd id
                RGDManagementDAO rgdIdDao = new RGDManagementDAO();
                RgdId id = rgdIdDao.createRgdId(RgdId.OBJECT_KEY_EXPERIMENTS, "ACTIVE", "created by ProjectEditObject",3);
                pro.setRgdId(id.getRgdId());
                prodao.insertProject(pro);
            } else {
                prodao.updateProject(pro);
            }

        }
        return pro;
    }
}