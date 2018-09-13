package edu.mcw.rgd.search;

import edu.mcw.rgd.process.search.ReportFactory;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: March 21, 2014
 * Time: 8:59:47 AM
 * <p>
 * RGDSearchController implementation used by the Variant Search.
 */
public class VariantSearchController extends RGDSearchController {

    /**
     * Runs a gene search based on the search parameters passed in.  The result is a report object
     * containing the search result.
     * @param search
     * @param req
     * @return
     * @throws Exception
     */
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {
        return ReportFactory.getInstance().getVariantReport(search);
    }

    /**
     * Returns a string representation of the view url.  The string returned must be the path to a file
     * on the file system.
     * @return
     */
    public String getViewUrl() {
        return "variants.jsp";
    }
}
