package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.PhenominerDAO;

public class ExpressionStudyReportController extends ReportController{
    @Override
    public String getViewUrl() throws Exception {
        return "expressionStudy/main.jsp";
    }

    @Override
    public Object getObject(int rgdId) throws Exception {
        return new PhenominerDAO().getStudy(rgdId);
    }
}
