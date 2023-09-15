package edu.mcw.rgd.search;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.ServletRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

import edu.mcw.rgd.web.HttpRequestFacade;

import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.reporting.Link;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public abstract class RGDSearchController implements Controller {


    public abstract Report getReport(SearchBean search, HttpRequestFacade req) throws Exception;

    public abstract String getViewUrl() throws Exception;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        String path = "/WEB-INF/jsp/search/";

        SearchBean search = this.buildSearchBean(req);
        request.setAttribute("searchBean", search);

        // looks for RGD ids in parameters; if valid, redirect to corresponding report page
        if( redirectedToReportPage(search, response, request) )
            return null;

        boolean termOfLength = false;
        for (String term1 : search.getRequired()) {
            if (term1.replaceAll("\\*", "").length() > 1) {
                termOfLength = true;
                break;
            }
        }

        // if search term is not given, one of the filters must be given: chromosome or ontology acc ids
        if( !termOfLength ) {
            if( Utils.isStringEmpty(search.getChr())
             && Utils.isStringEmpty(search.getTermAccId1())
             && Utils.isStringEmpty(search.getTermAccId2()) ) {

                error.add("Search term must be at least 2 characters long (common words are excluded). Please search again.");

                // redirect to search page: not enough arguments
                String page = request.getRequestURL().substring(request.getRequestURL().lastIndexOf("/") + 1);
                page = page.substring(0, page.indexOf("."));
                // patch for cell lines
                if( page.contains("cell") ) {
                    request.setAttribute("report", this.getReport(search, req));
                }
                return new ModelAndView(path + "/advanced/" + page + ".jsp");
            }
        }


        Report report = this.getReport(search, req);

        if (!termOfLength) {
            search.setTerm(req.getParameter("term"));
        }

        if (search.getSort() == -1) {
            search.setSort(0);
        }

        if (search.getSort() == 0 && search.getOrder() == -1) {
            search.setOrder(1);
        } else if (search.getOrder() == -1) {
            search.setOrder(0);
        }

        int secondarySortColumn = 2; // 2=object symbol; use -1 to avoid sort by secondary column
        if (search.getOrder() == 1) {
            report.sort(search.getSort(), Report.AUTO_DETECT_SORT, Report.DECENDING_SORT, true, secondarySortColumn);
        } else {
            report.sort(search.getSort(), Report.AUTO_DETECT_SORT, Report.ASCENDING_SORT, true, secondarySortColumn);
        }

        request.setAttribute("report", report);


        request.setAttribute("error", error);
        request.setAttribute("status", warning);
        request.setAttribute("warn", warning);

        if (search.getFmt() == 2) {
            return new ModelAndView(path + "csv.jsp");
        } else if (search.getFmt() == 3) {
            return new ModelAndView(path + "tab.jsp");

        } else if (search.getFmt() == 4) {
            return new ModelAndView(path + "print.jsp");

        } else if (search.getFmt() == 5) {
            return new ModelAndView(path + "gviewer.jsp");
        } else if (search.getFmt() == 6) {
            return new ModelAndView(path + "gviewerXML.jsp");
        }
        return new ModelAndView(path + this.getViewUrl());
    }

    public boolean redirectedToReportPage(SearchBean sb, HttpServletResponse response, ServletRequest request) {
        String term = sb.getTerm();
        try {
            int rgdIdValue = Integer.parseInt(term);
            // handle rgd ids for chinchilla
            RGDManagementDAO rdao = new RGDManagementDAO();
            RgdId id = rdao.getRgdId2(rgdIdValue);
            if( id==null ) {
                return false;
            }
            String redirUrl = Link.it(rgdIdValue, id.getObjectKey());

            if( !redirUrl.equals(term) ) {
                // Link.it handles this rgd_id with this object_key -- redirect to right report page
                response.sendRedirect(redirUrl);
                return true;
            }
            // Link.it does not handle rgd_id with this object_key -- just proceed with the search
        } catch (Exception e) {
        }
        return false;
    }

    protected SearchBean buildSearchBean(HttpRequestFacade req) throws Exception {
        SearchBean sb = new SearchBean();

        String chr = req.getParameter("chr");

        if (chr.toLowerCase().equals("x") || chr.toLowerCase().equals("y")) {
            sb.setChr(chr);
        } else {
            try {
                Integer.parseInt(chr);
                sb.setChr(chr);
            } catch (Exception e) {

            }
        }

        String term2 = req.getParameter("term").replaceAll("%", "*");
        if( term2.startsWith("RGD:") || term2.startsWith("RGD_") )
            term2 = term2.substring(4);
        sb.setTerm(term2);

        try {
            sb.setFmt(Integer.parseInt(req.getParameter("fmt")));
        } catch (Exception e) {
        }

        try {
            sb.setSort(Integer.parseInt(req.getParameter("sort")));
        } catch (Exception e) {
        }

        try {
            sb.setOrder(Integer.parseInt(req.getParameter("order")));
        } catch (Exception e) {
        }

        try {
            sb.setSpeciesType(Integer.parseInt(req.getParameter("speciesType")));
        } catch (Exception e) {
        }

        if (sb.getSpeciesType() != 0) {
            try {
                sb.setMap(Integer.parseInt(req.getParameter("map")));

                if (!MapManager.getInstance().isInMap(sb.getMap(), sb.getSpeciesType())) {
                    throw new Exception("set the default map");
                }

            } catch (Exception e) {
                sb.setMap(MapManager.getInstance().getReferenceAssembly(sb.getSpeciesType()).getKey());
            }
        }

        try {
            sb.setStart(Integer.parseInt(stripNonDigits(req.getParameter("start"))));
        } catch (Exception e) {
        }

        try {
            sb.setStop(Integer.parseInt(stripNonDigits(req.getParameter("stop"))));
        } catch (Exception e) {
        }

        // optional ontology filters
        String termName = req.getParameter("rs_term");
        if( !termName.isEmpty() ) {
            Term term = new OntologyXDAO().getTermByTermName(termName, "RS");
            if( term!=null )
                sb.setTermAccId1(term.getAccId());
        }

        termName = req.getParameter("vt_term");
        if( !termName.isEmpty() ) {
            Term term = new OntologyXDAO().getTermByTermName(termName, "VT");
            if( term!=null )
                sb.setTermAccId2(term.getAccId());
        }
        return sb;
    }

    // retain only digits from original string -- strip the rest
    private String stripNonDigits(String str) {

        StringBuilder sb = new StringBuilder(str.length());

        for( int i=0; i<str.length(); i++ ) {
            char c = str.charAt(i);
            if( Character.isDigit(c) )
                sb.append(c);
        }

        return sb.toString();
    }
}
