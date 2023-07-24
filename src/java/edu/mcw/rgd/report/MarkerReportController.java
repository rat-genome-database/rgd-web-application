package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.SSLPDAO;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class MarkerReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "marker/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new SSLPDAO().getSSLP(rgdId);
    }
}