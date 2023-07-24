package edu.mcw.rgd.search;

import edu.mcw.rgd.process.search.ReportFactory;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
/**
 * RGDSearchController implementation used by the Gene Search.
 */
public class GeneSearchController extends RGDSearchController {

    /**
     * Runs a gene search based on the search parameters passed in.  The result is a report object
     * containing the search result.
     * @param search
     * @param req
     * @return
     * @throws Exception
     */
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {
        return ReportFactory.getInstance().getGeneReport(search);
    }

    /**
     * Returns a string representaion of the view url.  The string returned must be the path to a file
     * on the file system.  The defualt return is genes.jsp
     * @return
     */
    public String getViewUrl() {
        return "genes.jsp";
    }
}
