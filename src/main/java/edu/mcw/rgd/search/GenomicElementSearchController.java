package edu.mcw.rgd.search;

import edu.mcw.rgd.process.search.ReportFactory;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Apr 9, 2012
 */

/**
 * RGDSearchController implementation used by the GenomicElement Search.
 */
public class GenomicElementSearchController extends RGDSearchController {

    /**
     * Runs a gene search based on the search parameters passed in.  The result is a report object
     * containing the search result.
     * @param search
     * @param req
     * @return
     * @throws Exception
     */
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {
        return ReportFactory.getInstance().getGenomicElementReport(search);
    }

    /**
     * Returns a string representaion of the view url.  The string returned must be the path to a file
     * on the file system.  The defualt return is genes.jsp
     * @return
     */
    public String getViewUrl() {
        return "ge.jsp";
    }
}
