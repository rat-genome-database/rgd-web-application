package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GenomicElementDAO;

/**
 * @author mtutaj
 * @since 2019-07-25
 */
public class ProteinDomainReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "proteinDomain/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new GenomicElementDAO().getElement(rgdId);
    }
}
