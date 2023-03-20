package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.variants.VariantDAO;
/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 22, 2012
 */
public class ClinVarReportController extends ReportController {
    public String getViewUrl() throws Exception {
        return "cnVariants/main.jsp";
    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantDAO().getVariant(rgdId);
    }
}