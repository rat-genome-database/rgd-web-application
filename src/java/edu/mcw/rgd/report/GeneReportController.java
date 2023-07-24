package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class GeneReportController extends ReportController {


    public String getViewUrl() throws Exception {
       return "gene/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new GeneDAO().getGene(rgdId);
    }

}