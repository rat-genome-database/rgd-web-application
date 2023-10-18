package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class QTLReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "qtl/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new QTLDAO().getQTL(rgdId);
    }
}