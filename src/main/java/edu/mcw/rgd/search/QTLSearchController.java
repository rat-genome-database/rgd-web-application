package edu.mcw.rgd.search;

import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.process.search.ReportFactory;
import edu.mcw.rgd.reporting.Report;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * <p>
 * RGDSearchController implementation used by the QTL Search.
 */
public class QTLSearchController extends RGDSearchController {

    /**
     * Runs a QTL search based on the search parameters passed in.  The result is a report object
     * containing the search result.
     * @param search
     * @param req
     * @return
     * @throws Exception
     */
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {
        return ReportFactory.getInstance().getQTLReport(search);
    }

    /**
     * Returns a string representaion of the view url.  The string returned must be the path to a file
     * on the file system.  The defualt return is qtls.jsp
     * @return
     */
    public String getViewUrl() {
        return "qtls.jsp";
    }
}
