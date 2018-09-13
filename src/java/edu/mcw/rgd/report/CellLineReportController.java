package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.CellLineDAO;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: May 20, 2014
 */
public class CellLineReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "cellline/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new CellLineDAO().getCellLine(rgdId);
    }

}