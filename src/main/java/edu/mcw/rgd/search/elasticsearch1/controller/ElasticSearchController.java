package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SearchLogDAO;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SearchLog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.search.RGDSearchController;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.service.SearchService;

import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import jakarta.servlet.RequestDispatcher;
import org.apache.lucene.search.TotalHits;
import org.elasticsearch.action.search.SearchResponse;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Elasticsearch-based search functionality.
 */
public class ElasticSearchController extends RGDSearchController {

    private static final Logger logger = Logger.getLogger(ElasticSearchController.class.getName());

    private static final int MIN_SEARCH_LENGTH = 1;
    private static final int MAX_SEARCH_LENGTH = 200;
    private static final int DEFAULT_PAGE_SIZE = 50;
    private static final String DEFAULT_SPECIES = "rat";
    private static final String ALL = "all";
    private static final String GENERAL = "general";

    private static final String VIEW_CONTENT = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/content.jsp";
    private static final String VIEW_SUMMARY = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResultsSummary.jsp";
    private static final String VIEW_RESULTS = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp";

    private static final java.util.Map<Integer, String> assemblyMapsByRank = initializeAssemblyMaps();

    private static java.util.Map<Integer, String> initializeAssemblyMaps() {
        try {
            MapDAO mapDAO = new MapDAO();
            List<Map> mapList = mapDAO.getActiveMapsByRankASC();
            java.util.Map<Integer, String> maps = new LinkedHashMap<>();
            for (Map m : mapList) {
                maps.put(m.getRank(), m.getDescription());
            }
            return Collections.unmodifiableMap(maps);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to initialize assembly maps", e);
            return Collections.emptyMap();
        }
    }

    @Override
    public Report getReport(edu.mcw.rgd.process.search.SearchBean search, HttpRequestFacade req) throws Exception {
        return null;
    }

    @Override
    public String getViewUrl() throws Exception {
        return null;
    }

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String searchTerm = req.getParameter("term").trim();
        String category = req.getParameter("category");

        // Validate search term
        String validationError = validateSearchTerm(searchTerm, category);
        if (validationError != null) {
            request.setAttribute("error", Collections.singletonList(validationError));
            request.getServletContext().getRequestDispatcher("/").forward(request, response);
            return null;
        }

        // Normalize search term
        String term = normalizeSearchTerm(searchTerm);

        SearchService service = new SearchService();
        SearchBean searchBean = service.getSearchBean(req, term);

        // Set assembly
        String assembly = req.getParameter("assembly");
        searchBean.setAssembly(isBlank(assembly) ? ALL : assembly);

        // Check for redirect
        String redirectUrl = getRedirectUrl(request, term, searchBean);
        if (redirectUrl != null) {
            response.sendRedirect(redirectUrl);
            return null;
        }

        // Build model
        ModelMap model = buildSearchModel(request, req, service, term, searchBean);

        // Determine view
        return new ModelAndView(selectView(req, searchBean), "model", model);
    }

    private String validateSearchTerm(String searchTerm, String category) {
        int termLength = searchTerm.replaceAll("\\*", "").length();
        boolean isGeneralCategory = isBlank(category) || GENERAL.equalsIgnoreCase(category);

        if (termLength > MAX_SEARCH_LENGTH) {
            return "Search term must be less than 200 characters long. Please search again.";
        }
        if (termLength < MIN_SEARCH_LENGTH && isGeneralCategory) {
            return "Search term must be at least 2 characters long. Please search again.";
        }
        return null;
    }

    private String normalizeSearchTerm(String searchTerm) {
        if (searchTerm.startsWith("RGD:") || searchTerm.startsWith("RGD_") || searchTerm.startsWith("RGD ")) {
            return searchTerm.substring(4).toLowerCase();
        }
        if (searchTerm.startsWith("RGD")) {
            return searchTerm.substring(3).toLowerCase();
        }
        return searchTerm.toLowerCase().replaceAll("rgd", " ").trim();
    }

    private ModelMap buildSearchModel(HttpServletRequest request, HttpRequestFacade req,
                                       SearchService service, String term, SearchBean searchBean) throws Exception {
        ModelMap model = new ModelMap();
        boolean shouldLog = "true".equals(req.getParameter("log"));
        int postCount = parseIntOrDefault(req.getParameter("postCount"), 0) + 1;

        String cat1 = (postCount <= 1) ? searchBean.getCategory() : req.getParameter("cat1");
        String sp1 = (postCount <= 1) ? searchBean.getSpecies() : req.getParameter("sp1");

        int pageSize = (searchBean.getSize() > 0) ? searchBean.getSize() : DEFAULT_PAGE_SIZE;
        SearchResponse searchResponse = service.getSearchResponse(request, term, searchBean);

        int totalPages = 0;
        if (searchResponse != null) {
            TotalHits hits = searchResponse.getHits().getTotalHits();
            totalPages = (int) ((hits.value + pageSize - 1) / pageSize);
            model.putAll(service.getResultsMap(searchResponse, term));

            if (shouldLog) {
                logResults(term, searchBean.getCategory(), hits.value);
            }
        }

        // Add assembly maps for specific species
        String species = searchBean.getSpecies();
        if (hasSpecificSpecies(species) && !searchBean.getCategory().equalsIgnoreCase("expression study")) {
            List<Map> maps = MapManager.getInstance().getAllMaps(SpeciesType.parse(species), "bp");
            model.addAttribute("assemblyMaps", maps);
        }

        model.addAttribute("assemblyMapsByRank", assemblyMapsByRank);
        model.addAttribute("mapKey", getMapKey(searchBean.getAssembly(), species));
        model.addAttribute("defaultAssembly", searchBean.getAssembly());
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("postCount", postCount);
        model.addAttribute("cat1", cat1);
        model.addAttribute("sp1", sp1);
        model.addAttribute("term", term);
        model.addAttribute("searchBean", searchBean);
        request.setAttribute("searchBean", searchBean);

        String objectSearch = req.getParameter("objectSearch");
        if (objectSearch != null) {
            model.addAttribute("objectSearch", objectSearch);
        }

        return model;
    }

    private String selectView(HttpRequestFacade req, SearchBean searchBean) {
        if ("true".equals(req.getParameter("page"))) {
            return VIEW_CONTENT;
        }

        if (GENERAL.equalsIgnoreCase(searchBean.getCategory())
                && isBlank(searchBean.getSpecies())
                && !searchBean.isViewAll()) {
            return VIEW_SUMMARY;
        }

        return VIEW_RESULTS;
    }

    private boolean hasSpecificSpecies(String species) {
        return !isBlank(species) && !ALL.equalsIgnoreCase(species);
    }

    private boolean isBlank(String str) {
        return str == null || str.isEmpty();
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (isBlank(value)) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public String getRedirectUrl(HttpServletRequest request, String term, SearchBean searchBean) {
        try {
            // Check for RGD ID (numeric term)
            if (term.matches("\\d+") && !searchBean.isRedirect()) {
                return getRedirectForRgdId(term);
            }

            // Check for rsID (e.g., rs12345)
            if (term.toLowerCase().startsWith("rs") && term.substring(2).matches("\\d+")) {
                return buildFullUrl(Link.rsId(term));
            }

            // Check for ontology accession ID (contains colon)
            if (term.contains(":")) {
                return getRedirectForOntologyTerm(term);
            }

            // Handle single result redirect
            if (searchBean.isRedirect()) {
                return getRedirectForSingleResult(request, term, searchBean);
            }

        } catch (Exception e) {
            logger.log(Level.WARNING, "Error getting redirect URL for term: " + term, e);
        }
        return null;
    }

    private String getRedirectForRgdId(String term) throws Exception {
        int rgdId = Integer.parseInt(term);
        RGDManagementDAO dao = new RGDManagementDAO();
        RgdId id = dao.getRgdId2(rgdId);

        if (id == null) {
            return null;
        }

        String url;
        // Non-human variants use different report page
        if (id.getSpeciesTypeKey() != 1 && id.getObjectKey() == 7) {
            url = "/rgdweb/report/variants/main.html?id=" + id.getRgdId();
        } else {
            url = Link.it(rgdId, id.getObjectKey());
        }

        // Only redirect if Link.it returned a valid URL (not just the ID)
        if (url != null && !url.equals(String.valueOf(rgdId))) {
            return buildFullUrl(url);
        }
        return null;
    }

    private String getRedirectForOntologyTerm(String term) throws Exception {
        OntologyXDAO dao = new OntologyXDAO();
        Term ontologyTerm = dao.getTermByAccId(term.toUpperCase());

        if (ontologyTerm != null) {
            return buildFullUrl(Link.ontAnnot(term.toUpperCase()));
        }
        return null;
    }

    private String getRedirectForSingleResult(HttpServletRequest request, String term, SearchBean searchBean) throws Exception {
        SearchService service = new SearchService();
        SearchResponse response = service.getSearchResponse(request, term, searchBean);

        if (response != null && response.getHits() != null) {
            TotalHits hits = response.getHits().getTotalHits();
            if (hits.value == 1) {
                return getUrlFromSearchHit(response, request, term);
            }
        }
        return null;
    }

    private String buildFullUrl(String path) {
        return (path != null) ? RgdContext.getHostname() + path : null;
    }
    private String getUrlFromSearchHit(SearchResponse response, HttpServletRequest request, String term) {
        logResults(term, request.getParameter("category"), response.getHits().getTotalHits().value);

        java.util.Map<String, Object> source = response.getHits().getHits()[0].getSourceAsMap();
        String docId = (String) source.get("term_acc");
        String category = (String) source.get("category");
        String species = (String) source.get("species");
        String rsId = (String) source.get("rsId");

        try {
            String url = buildUrlFromHit(docId, category, species, rsId);
            return buildFullUrl(url);
        } catch (Exception e) {
            logger.log(Level.WARNING, "Error building URL from search hit", e);
            return null;
        }
    }

    private String buildUrlFromHit(String docId, String category, String species, String rsId) throws Exception {
        // Handle rsID
        if (!isBlank(rsId)) {
            return Link.rsId(rsId);
        }

        // Handle Expression Study
        if ("Expression Study".equalsIgnoreCase(category)) {
            return "/rgdweb/report/expressionStudy/main.html?id=" + docId;
        }

        // Handle RGD ID (numeric with more than 2 digits)
        if (docId.matches("\\d+") && docId.length() > 2) {
            return buildUrlForRgdId(Integer.parseInt(docId), category, species);
        }

        // Handle ontology accession ID
        if (docId.contains(":")) {
            return Link.ontAnnot(docId);
        }

        return null;
    }

    private String buildUrlForRgdId(int rgdId, String category, String species) throws Exception {
        RGDManagementDAO dao = new RGDManagementDAO();
        RgdId id = dao.getRgdId2(rgdId);

        if (id == null) {
            return null;
        }

        // Non-human variants use different report page
        if ("variant".equalsIgnoreCase(category) && !"human".equalsIgnoreCase(species)) {
            return "/rgdweb/report/variants/main.html?id=" + rgdId;
        }

        return Link.it(rgdId, id.getObjectKey());
    }

    public void logResults(String term, String category, long results) {
        try {
            SearchLog searchLog = new SearchLog();
            searchLog.setSearchTerm(term);
            searchLog.setCategory(category);
            searchLog.setResults(results);
            new SearchLogDAO().insert(searchLog);
        } catch (Exception e) {
            logger.log(Level.WARNING, "Failed to log search results for term: " + term, e);
        }
    }

    public int getMapKey(String assembly, String species) throws Exception {
        if (hasSpecificSpecies(species)) {
            // Try to find map by assembly description
            int mapKey = findMapKeyByAssembly(assembly, species);
            if (mapKey > 0) {
                return mapKey;
            }
            // Fall back to reference assembly for species
            mapKey = getReferenceAssemblyMapKey(species);
            if (mapKey > 0) {
                return mapKey;
            }
        }
        // Default to rat reference assembly
        return getReferenceAssemblyMapKey(DEFAULT_SPECIES);
    }

    private int findMapKeyByAssembly(String assembly, String species) throws Exception {
        List<Map> maps = MapManager.getInstance().getAllMaps(SpeciesType.parse(species));
        for (Map m : maps) {
            if (m.getDescription().equalsIgnoreCase(assembly)) {
                return m.getKey();
            }
        }
        return 0;
    }

    public int getReferenceAssemblyMapKey(String species) throws Exception {
        Map referenceAssembly = MapManager.getInstance().getReferenceAssembly(SpeciesType.parse(species));
        return (referenceAssembly != null) ? referenceAssembly.getKey() : 0;
    }
}
