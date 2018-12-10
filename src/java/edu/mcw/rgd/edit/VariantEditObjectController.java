package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: hsnalabolu
 * Date: Dec 7, 2018
 * Time: 8:55:47 AM
 */
public class VariantEditObjectController extends EditObjectController {

    public String getViewUrl() throws Exception {
        return "editVariant.jsp";

    }

    public int getObjectTypeKey() {
        return 24;
    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantsDAO().getVariant(rgdId);
    }
    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }
    public Object newObject() throws Exception{
        Variants variants = new Variants();
        variants.setRgdId(-1);
        return variants;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        VariantsDAO dao = new VariantsDAO();
        Variants variants = null;

        boolean isNew = false;

        if (!req.getParameter("type").equals("")) {

            String name = req.getParameter("name");
        //    this.checkSet("Name", name);

            int rgdId = Integer.parseInt(req.getParameter("rgdId"));

            if (rgdId == -1 ) {
                isNew = true;
                variants = new Variants();
            }else {
                variants = dao.getVariant(rgdId);
            }


            variants.setName(req.getParameter("name"));
            variants.setDescription(req.getParameter("description"));
            variants.setType(req.getParameter("type"));
            variants.setRef_nuc(req.getParameter("refNuc"));
            variants.setVar_nuc(req.getParameter("varNuc"));
            variants.setNotes(req.getParameter("notes"));


            if (persist) {
                if (isNew) {
                    dao.insertVariant(variants, req.getParameter("objectStatus"),SpeciesType.parse(req.getParameter("speciesType")) );
                } else {
                    dao.updateVariant(variants);
                }
            }
        }
        return variants;
    }
}