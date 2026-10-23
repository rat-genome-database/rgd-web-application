package edu.mcw.rgd.search;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.report.ReportExcelWriter;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.ServletRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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

    /**
     * Category this legacy search maps to in the elasticsearch index, used to forward old
     * urls (and old bookmarks) to the new search. Returning null keeps the legacy page,
     * which is what the cell line directory needs - it is a listing, not a search.
     * @return elasticsearch category, or null to keep rendering the legacy page
     */
    public String getElasticCategory() {
        return null;
    }

    // fmt values the legacy search still serves: 2=csv, 3=tab, 4=printer, 5+6=gviewer
    /** csv, tab, printer, gviewer, gviewer xml and excel - the formats still produced from the
     *  legacy report rather than redirected to elasticsearch */
    private boolean isLegacyExportFormat(int fmt) {
        return fmt>=2 && fmt<=FMT_EXCEL;
    }

    /** the excel download, added after the other five; see the fmt dispatch in handleRequest */
    static final int FMT_EXCEL = 7;

    /**
     * What the excel download calls the search it came from, taken from the view name each
     * subclass sets - "markers.jsp" gives "markers". Defensive about that name because it is not
     * written for this purpose: CellLineSearchController returns a path ("advanced/cellLines.jsp")
     * and the two base classes return null, so only the last segment is used and an empty result
     * falls back rather than reaching POI or a response header.
     */
    String excelObjectType() throws Exception {
        String view = Utils.defaultString(getViewUrl());
        int slash = view.lastIndexOf('/');
        if( slash >= 0 ) {
            view = view.substring(slash + 1);
        }
        if( view.endsWith(".jsp") ) {
            view = view.substring(0, view.length() - 4);
        }
        return view;
    }

    String excelSheetName() throws Exception {
        String objectType = excelObjectType();
        return objectType.isEmpty()
                ? "Search results"
                : objectType.substring(0, 1).toUpperCase() + objectType.substring(1);
    }

    String excelFileName() throws Exception {
        String objectType = excelObjectType();
        return ReportExcelWriter.fileName(objectType.isEmpty() ? "" : "rgd_" + objectType,
                "rgd_search", "");
    }

    /**
     * Translates the parameters of a legacy search into an url for the elasticsearch search.
     * Old and new search happen to agree on most parameter names (term, speciesType, chr,
     * start, stop), so only the category, the assembly and the legacy "[objectType]" term
     * suffix need translating.
     */
    protected String buildElasticSearchUrl(SearchBean search) {

        String category = getElasticCategory();

        StringBuilder url = new StringBuilder("/rgdweb/elasticResults.html?category=");
        url.append(encode(category));
        url.append("&term=").append(encode(stripObjectTypeSuffix(search.getTerm())));

        // the object searches came from the advanced search forms, which mark themselves as
        // object searches so the new search drops the "view all categories" sidebar
        if( !"general".equalsIgnoreCase(category) ) {
            url.append("&objectSearch=true");
        }

        if( search.getSpeciesType()>0 ) {
            url.append("&speciesType=").append(search.getSpeciesType());
        }
        if( !Utils.isStringEmpty(search.getChr()) ) {
            url.append("&chr=").append(encode(search.getChr()));
        }
        if( search.getStart()>0 && search.getStop()>0 ) {
            url.append("&start=").append(search.getStart());
            url.append("&stop=").append(search.getStop());

            // positions are only meaningful against the assembly they were searched on; the new
            // search identifies an assembly by description, the legacy one by map key
            String assembly = getAssemblyDescription(search.getMap());
            if( assembly!=null ) {
                url.append("&assembly=").append(encode(assembly));
            }
        }
        return url.toString();
    }

    private String getAssemblyDescription(int mapKey) {
        if( mapKey<=0 ) {
            return null;
        }
        try {
            edu.mcw.rgd.datamodel.Map map = MapManager.getInstance().getMap(mapKey);
            return map==null ? null : map.getDescription();
        } catch(Exception e) {
            return null;
        }
    }

    /**
     * The legacy search read a term like "Mcs1[qtl]" as "everything overlapping the region of
     * the qtl Mcs1". The new search expresses a region as chr/start/stop instead, so the suffix
     * is dropped here - a caller that has the coordinates should pass them explicitly.
     */
    private String stripObjectTypeSuffix(String term) {
        if( term==null ) {
            return "";
        }
        int bracket = term.indexOf('[');
        return bracket<0 ? term : term.substring(0, bracket).trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value==null ? "" : value, StandardCharsets.UTF_8);
    }

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

        // the html result pages of the legacy search were replaced by elasticsearch, so send the
        // request on to the new search rather than render a report page that no longer exists.
        // the export formats (csv, tab, printer, gviewer) are still produced from the legacy
        // report below - the new search downloads those through its own controller.
        if( getElasticCategory()!=null && !isLegacyExportFormat(search.getFmt()) ) {
            response.sendRedirect(buildElasticSearchUrl(search));
            return null;
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
        } else if (search.getFmt() == FMT_EXCEL) {
            // The same report the csv format renders, as a workbook - so it carries this search's
            // own columns. Writes the response itself, hence the null ModelAndView.
            ReportExcelWriter.write(response, report, excelSheetName(), excelFileName());
            return null;
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
