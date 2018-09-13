package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.VariantInfoDAO;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 22, 2012
 */
public class VariantReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "variant/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantInfoDAO().getVariant(rgdId);
    }
}