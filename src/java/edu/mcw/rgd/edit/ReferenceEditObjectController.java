package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * Curation reference edit: edit a row from REFERENCES table, and/or corresponding PMID id
 */
public class ReferenceEditObjectController extends EditObjectController {

    ReferenceDAO dao = new ReferenceDAO();

    public String getViewUrl() throws Exception {
       return "editReference.jsp";
    }

    public int getObjectTypeKey() {
        return 12;
    }

    public Object getObject(int rgdId) throws Exception{
        return dao.getReferenceByRgdId(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
       return null;
    }

    public Object newObject() throws Exception{
        Reference ref = new Reference();
        ref.setReferenceType("DIRECT DATA TRANSFER");
        return ref;
    }
    
    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        String rgdId = req.getParameter("rgdId");
        Reference ref = null;
        if( !rgdId.isEmpty() ) {
            try {
                ref = (Reference) getObject(Integer.parseInt(rgdId));
            } catch (Exception e) {

            }
        }
        boolean isNew = ref==null;

        if( isNew ) {
            ref = (Reference) newObject();
        }

        ref.setTitle(req.getParameter("title"));
        ref.setEditors(req.getParameter("editors"));
        ref.setPublication(req.getParameter("publication"));
        ref.setVolume(req.getParameter("volume"));
        ref.setIssue(req.getParameter("issue"));
        ref.setPages(req.getParameter("pages"));
        ref.setNotes(req.getParameter("notes"));
        ref.setReferenceType(req.getParameter("referenceType"));
        ref.setCitation(req.getParameter("citation"));
        ref.setRefAbstract(req.getParameter("abstract"));
        ref.setPublisher(req.getParameter("publisher"));
        ref.setPublisherCity(req.getParameter("publisherCity"));
        ref.setUrlWebReference(req.getParameter("urlWebReference"));
        ref.setDoi(req.getParameter("doi"));

        if (persist) {
            if( isNew ) {
                // create a new rgd id
                RGDManagementDAO rgdIdDao = new RGDManagementDAO();
                RgdId id = rgdIdDao.createRgdId(RgdId.OBJECT_KEY_REFERENCES, "ACTIVE", "created by ReferenceEditObject", 0);
                ref.setRgdId(id.getRgdId());

                dao.insertReference(ref);
            } else {
                dao.updateReference(ref);
            }

            updatePmid(req.getParameter("pmid"), ref.getRgdId());
        }

        return ref;
    }

    void updatePmid(String pmidParam, int refRgdId) throws Exception {

        if( Utils.isStringEmpty(pmidParam) ) {
            return; // nothing to do -- empty PMID???
        }

        // check if reference PMID is up-to-date
        XdbIdDAO xdao = new XdbIdDAO();
        List<XdbId> xdbIds = xdao.getPubmedIdsByRefRgdId(refRgdId);
        for( XdbId xdbId: xdbIds ) {
            if( Utils.stringsAreEqual(pmidParam, xdbId.getAccId()) ) {
                return; // yes it is
            }
        }

        // no PMID: assign PMID to this reference
        if( xdbIds.isEmpty() ) {
            XdbId xdbId = new XdbId();
            xdbId.setRgdId(refRgdId);
            xdbId.setAccId(pmidParam);
            xdbId.setXdbKey(XdbId.XDB_KEY_PUBMED);
            xdao.insertXdb(xdbId);
        } else {
            // different PMID: change PMID for this reference
            XdbId xdbId = xdbIds.get(0);
            xdbId.setAccId(pmidParam);
            xdao.updateByKey(xdbId);
        }
    }
}