package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.variants.VariantDAO;

public class CNVariantReportController extends ReportController {

    public String getViewUrl() throws Exception {
        return "cnVariants/main.jsp";
    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantDAO().getAllVariantsByRgdId(rgdId);
    }
}
