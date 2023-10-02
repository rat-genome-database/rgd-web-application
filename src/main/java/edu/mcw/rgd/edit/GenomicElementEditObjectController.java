package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.GenomicElementDAO;
import edu.mcw.rgd.datamodel.GenomicElement;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 22, 2012
 * Time: 8:59:47 AM

 */
public class GenomicElementEditObjectController extends EditObjectController {

    public String getViewUrl() throws Exception {
       return "editGenomicElement.jsp";

    }

    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_PROMOTERS;
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }
    public Object getObject(int rgdId) throws Exception{
        return new GenomicElementDAO().getElement(rgdId);
    }

    public Object newObject() throws Exception{
        return new GenomicElement();
    }
    
    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        GenomicElementDAO dao = new GenomicElementDAO();
        GenomicElement ge = dao.getElement(Integer.parseInt(req.getParameter("rgdId")));

        if (!req.getParameter("rgdId").equals("")) {
             ge.setDescription(req.getParameter("description"));
             ge.setName(req.getParameter("name"));
             ge.setSource(req.getParameter("source"));
             ge.setSoAccId(req.getParameter("soAccId"));
             ge.setSymbol(req.getParameter("symbol"));

             if (persist) {
                 dao.updateElement(ge);
             }
        }
        return ge;
    }
}
