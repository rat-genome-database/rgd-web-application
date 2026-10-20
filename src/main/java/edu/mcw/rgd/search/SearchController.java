package edu.mcw.rgd.search;

import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import edu.mcw.rgd.web.HttpRequestFacade;

import edu.mcw.rgd.process.search.SearchBean;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: May 23, 2008
 * Time: 2:50:11 PM
 * <p>
 * The general search this controller used to run was replaced by elasticsearch. It stays mapped
 * to search/search.html so the old urls - bookmarks, and the search boxes of the older page
 * headers that post here - land on the new search instead of a result page that is gone.
 */
public class SearchController extends RGDSearchController {

    @Override
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {
        return null;
    }

    @Override
    public String getViewUrl() throws Exception {
        return null;
    }

    @Override
    public String getElasticCategory() {
        return "general";
    }

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // the new search does its own rgd id / ontology id redirects and its own term validation,
        // so the parameters are simply translated and handed over
        SearchBean search = this.buildSearchBean(new HttpRequestFacade(request));
        response.sendRedirect(buildElasticSearchUrl(search));
        return null;
    }
}
