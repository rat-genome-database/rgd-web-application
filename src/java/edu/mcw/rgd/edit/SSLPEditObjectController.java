package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.SSLPDAO;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;

/**
 * User: jdepons
 * Date: Jun 2, 2008
 */
public class SSLPEditObjectController extends EditObjectController {

    SSLPDAO dao = new SSLPDAO();
    RGDManagementDAO rdao = new RGDManagementDAO();

    public String getViewUrl() throws Exception {
       return "editSSLP.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new SSLPDAO().getSSLP(rgdId);
    }

    public Object newObject() throws Exception{
        return new SSLP();
    }
    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }
    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_SSLPS;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

         // new sslp: both parameters 'key' and 'rgdId' are 0
        int rgdId = Integer.parseInt(req.getParameter("rgdId"));
        SSLP sslp;
        if( rgdId==0 ) {
            // create a new sslp
            sslp = createNewSslp(req);
        }
        else {
            sslp = dao.getSSLP(rgdId);
            if (!req.getParameter("key").equals("")) {
                sslp.setName(req.getParameter("name"));
                if (!req.getParameter("expectedSize").isEmpty()) {
                   sslp.setExpectedSize(Integer.parseInt(req.getParameter("expectedSize")));
                }
                sslp.setNotes(req.getParameter("notes"));
                sslp.setSslpType(req.getParameter("sslp_type"));

                if (persist) {
                    dao.updateSSLP(sslp);
                    updateSequences(rgdId, req);
                }
            }
        }

        return sslp;
    }

    SSLP createNewSslp(HttpRequestFacade req) throws Exception {

        // create new rgd id
        RgdId id = rdao.createRgdId(this.getObjectTypeKey() ,req.getParameter("objectStatus"), SpeciesType.parse(req.getParameter("speciesType")));

        // now create a gene object
        SSLP obj = new SSLP();
        obj.setRgdId(id.getRgdId());
        obj.setSpeciesTypeKey(id.getSpeciesTypeKey());
        obj.setName(req.getParameter("name"));
        obj.setNotes(req.getParameter("notes"));
        obj.setSslpType(req.getParameter("sslp_type"));
        String expectedSize = req.getParameter("expectedSize");
        if( !expectedSize.isEmpty() ) {
            obj.setExpectedSize(Integer.parseInt(expectedSize));
        }
        dao.insertSSLP(obj);
        return obj;
    }

    void updateSequences(int rgdId, HttpRequestFacade req) throws Exception {

        // get incoming template sequence (and strip all whitespace from it)
        String template = req.getParameter("templateSeq").replaceAll("[\\s]+","");
        String forward = req.getParameter("forwardPrimer").replaceAll("[\\s]+","");
        String reverse = req.getParameter("reversePrimer").replaceAll("[\\s]+","");

        String sql = "UPDATE sslps SET seq_template=?,seq_forward=?,seq_reverse=? WHERE rgd_id=?";
        dao.update(sql, template, forward, reverse, rgdId);
    }
}
