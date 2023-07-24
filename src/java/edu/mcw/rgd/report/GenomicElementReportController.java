package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GenomicElementDAO;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 22, 2012
 */
public class GenomicElementReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "ge/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new GenomicElementDAO().getElement(rgdId);
    }

}