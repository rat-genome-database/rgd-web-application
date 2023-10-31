package edu.mcw.rgd.report;


import edu.mcw.rgd.dao.impl.RgdVariantDAO;


/**
 * Created by hsnalabolu on 12/10/2018.
 */
public class VariantReportController extends ReportController {

    public String getViewUrl() throws Exception {
        return "rgdvariant/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new RgdVariantDAO().getVariant(rgdId);
    }
}