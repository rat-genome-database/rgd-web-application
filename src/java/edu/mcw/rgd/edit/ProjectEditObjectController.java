package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.Project;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.dao.impl.ProjectDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.dao.impl.ProjectDAO;
import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

/**
 * Curation reference edit: edit a row from REFERENCES table, and/or corresponding PMID id
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
//        return dao.getReferenceByRgdId(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }

    public Object newObject() throws Exception{
//        Reference ref = new Reference();
        Project pro = new Project();
//        ref.setReferenceType("DIRECT DATA TRANSFER");
        return pro;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        String rgdId = req.getParameter("rgdId");
//        int rgdId=Integer.parseInt(req.getParameter("rgdId"));
//        Reference ref = null;
        Project pro = null;
        if( !rgdId.isEmpty()) {
            try {
//                ref = (Reference) getObject(Integer.parseInt(rgdId));
                pro=(Project) getObject(Integer.parseInt(rgdId));
            } catch (Exception e) {

            }
        }
//        boolean isNew = ref==null;
        boolean isNew = pro==null;

        if( isNew ) {
//            ref=(Reference) newObject();
            pro = (Project) newObject();
        }

          pro.setDesc(req.getParameter("desc"));
          pro.setName(req.getParameter("name"));
          pro.setSub_name(req.getParameter("sub_name"));
          pro.setPrinci_name(req.getParameter("princ_name"));
        if (persist) {
            if( isNew ) {
                // create a new rgd id
                RGDManagementDAO rgdIdDao = new RGDManagementDAO();
//                RgdId id = rgdIdDao.createRgdId(RgdId.OBJECT_KEY_REFERENCES, "ACTIVE", "created by ReferenceEditObject", 0);
                RgdId id = rgdIdDao.createRgdId(RgdId.OBJECT_KEY_EXPERIMENTS, "ACTIVE", "created by ProjectEditObject",0);
//                ref.setRgdId(id.getRgdId());
                pro.setRgdId(id.getRgdId());

//                dao.insertReference(ref);
                prodao.insertProject(pro);
            } else {
//                dao.updateReference(ref);
                prodao.updateProject(pro);
            }

//            updatePmid(req.getParameter("pmid"), ref.getRgdId());
        }
        return pro;
    }

//    void updatePmid(String pmidParam, int refRgdId) throws Exception {
//
//        if( Utils.isStringEmpty(pmidParam) ) {
//            return; // nothing to do -- empty PMID???
//        }
//
//        // check if reference PMID is up-to-date
//        XdbIdDAO xdao = new XdbIdDAO();
//        List<XdbId> xdbIds = xdao.getPubmedIdsByRefRgdId(refRgdId);
//        for( XdbId xdbId: xdbIds ) {
//            if( Utils.stringsAreEqual(pmidParam, xdbId.getAccId()) ) {
//                return; // yes it is
//            }
//        }
//
//        // no PMID: assign PMID to this reference
//        if( xdbIds.isEmpty() ) {
//            XdbId xdbId = new XdbId();
//            xdbId.setRgdId(refRgdId);
//            xdbId.setAccId(pmidParam);
//            xdbId.setXdbKey(XdbId.XDB_KEY_PUBMED);
//            xdao.insertXdb(xdbId);
//        } else {
//            // different PMID: change PMID for this reference
//            XdbId xdbId = xdbIds.get(0);
//            xdbId.setAccId(pmidParam);
//            xdao.updateByKey(xdbId);
//        }
//    }
}