package edu.mcw.rgd.report;


import edu.mcw.rgd.dao.impl.VariantsDAO;

/**
 * Created by hsnalabolu on 12/10/2018.
 */
public class VariantsReportController extends ReportController {

    public String getViewUrl() throws Exception {
        return "variants/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantsDAO().getVariant(rgdId);
    }
}