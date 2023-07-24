package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.process.Utils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class ExternalLinksEditObjectController implements Controller {

    XdbIdDAO dao = new XdbIdDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        int rgdId = Integer.parseInt(request.getParameter("rgdId"));
        List<XdbId> incomingData = parseParameters(request);

        XdbId filter = new XdbId();
        filter.setRgdId(rgdId);
        List<XdbId> existingData = dao.getXdbIds(filter);

        // update all external links shared between incoming and existing lists
        // and drop them from lists
        removeSharedExternalLinks(incomingData, existingData);

        dao.insertXdbs(incomingData);

        // delete unused external links
        dao.deleteXdbIds(existingData);

        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");
    }

    List<XdbId> parseParameters(HttpServletRequest request) {

        int rgdId = Integer.parseInt(request.getParameter("rgdId"));
        String[] accXdbKeys = request.getParameterValues("accXdbKey");
        String[] xdbKeys = request.getParameterValues("xdbKey");
        String[] accIds = request.getParameterValues("accId");
        String[] linkTexts = request.getParameterValues("linkText");
        String[] srcPipelines = request.getParameterValues("srcPipeline");
        String[] notes = request.getParameterValues("notes");
        int recCount = accXdbKeys==null ? 0 : accXdbKeys.length;
        Date currDate = new Date();

        List<XdbId> records = new ArrayList<XdbId>(recCount);
        for( int i=0; i<recCount; i++ ) {
            XdbId var = new XdbId();
            var.setRgdId(rgdId);
            var.setAccId(accIds[i]);
            var.setLinkText(linkTexts[i]);
            var.setNotes(notes[i]);
            var.setSrcPipeline(srcPipelines[i]);
            var.setXdbKey(Integer.parseInt(xdbKeys[i]));
            var.setKey(Integer.parseInt(accXdbKeys[i]));
            var.setCreationDate(currDate);
            var.setModificationDate(currDate);

            // ensure the new record is unique
            if( !records.contains(var) )
                records.add(var);
        }
        return records;
    }

    void removeSharedExternalLinks(List<XdbId> incomingData, List<XdbId> existingData) throws Exception {

        // pass 1: find incoming annotation that matches existingAnnotation
        Iterator<XdbId> it1 = incomingData.iterator();
        while( it1.hasNext() ) {
            XdbId var1 = it1.next();

            Iterator<XdbId> it2 = existingData.iterator();
            while( it2.hasNext() ) {
                XdbId var2 = it2.next();

                if( var1.getKey()!=0 && var1.getKey()==var2.getKey() ) {

                    // see if link_text or notes have to be updated
                    if( !var1.equals(var2) ||
                        !Utils.stringsAreEqual(var1.getLinkText(), var2.getLinkText()) ||
                        !Utils.stringsAreEqual(var1.getNotes(), var2.getNotes()) ) {

                        var1.setModificationDate(new Date());
                        dao.updateByKey(var1);
                    }

                    it1.remove();
                    it2.remove();
                    break; // break inner loop
                }
            }
        }

        // find incoming annotation that matches existingAnnotation
        it1 = incomingData.iterator();
        while( it1.hasNext() ) {
            XdbId var1 = it1.next();

            Iterator<XdbId> it2 = existingData.iterator();
            while( it2.hasNext() ) {
                XdbId var2 = it2.next();


                if( var1.equals(var2) ) {

                    // see if link_text or notes have to be updated
                    if( !Utils.stringsAreEqual(var1.getLinkText(), var2.getLinkText()) ||
                        !Utils.stringsAreEqual(var1.getNotes(), var2.getNotes()) ) {

                        var1.setModificationDate(new Date());
                        dao.updateByKey(var1);
                    }

                    it1.remove();
                    it2.remove();
                    break; // break inner loop
                }
            }
        }
    }
}
