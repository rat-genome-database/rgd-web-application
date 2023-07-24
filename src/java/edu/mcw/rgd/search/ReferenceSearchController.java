package edu.mcw.rgd.search;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.search.ReportFactory;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * <p>
 * RGDSearchController implementation used by the Reference Search.
 */
public class ReferenceSearchController extends RGDSearchController {

    /**
     * Runs a reference search based on the search parameters passed in.  The result is a report object
     * containing the search result.
     * @param search
     * @param req
     * @return
     * @throws Exception
     */
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {
        // clear the species: references are indexed for all species only
        search.setSpeciesType(SpeciesType.ALL);
        return ReportFactory.getInstance().getReferenceReport(search);
    }

    /**
     * Returns a string representaion of the view url.  The string returned must be the path to a file
     * on the file system.  The defualt return is references.jsp
     * @return
     */
    public String getViewUrl() {
        return "references.jsp";
    }    
}
