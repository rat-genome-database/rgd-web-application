package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;

/**
 * User: jdepons
 * Date: Jun 2, 2008
 */
public class GeneReportController extends ReportController {


    public String getViewUrl() throws Exception {
       return "gene/main.jsp";
    }

    public Object getObject(int rgdId) throws Exception{
        return new GeneDAO().getGene(rgdId);
    }

}