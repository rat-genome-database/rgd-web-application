package edu.mcw.rgd.search.elasticsearch1.controller;

import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.TotalHits;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.search.RGDSearchController;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.service.SearchService;

import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import jakarta.servlet.RequestDispatcher;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.mvc.Controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ElasticSearchController implements Controller {

    private static final Logger logger = Logger.getLogger(ElasticSearchController.class.getName());

    /** Was 1, which meant only an empty term was turned away while the error message promised 2.
     *  A single character general search does not come back - it was still running after four
     *  minutes - so the message was describing the rule that was wanted and this was not it. */
    private static final int MIN_SEARCH_LENGTH = 2;
    private static final int MAX_SEARCH_LENGTH = 200;
    private static final int DEFAULT_PAGE_SIZE = 50;
    private static final String DEFAULT_SPECIES = "rat";
    private static final String ALL = "all";
    private static final String GENERAL = "general";

    private static final String VIEW_CONTENT = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/content.jsp";
    private static final String VIEW_SUMMARY = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResultsSummary.jsp";
    private static final String VIEW_RESULTS = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp";
    private static final String VIEW_ASSEMBLY = "/WEB-INF/jsp/search/elasticsearch/elasticsearch1/assemblyResults.jsp";

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
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        // HttpRequestFacade.getParameter returns "" rather than null for a parameter that is not
        // there, but this is the first thing every request to this controller touches, so it does
        // not lean on that
        String searchTerm = searchTerm(req.getParameter("term"));

        // Normalized before it is validated, because the normalized term is what the search
        // actually runs on and the two lengths differ: "RGD" is three characters that reduce to
        // nothing, "RGD:2" is five that reduce to one. Validating what was typed let both past.
        String term = normalizeSearchTerm(searchTerm);

        String validationError = validateSearchTerm(searchTerm, term, isPositionalSearch(req));
        if (validationError != null) {
            request.setAttribute("error", Collections.singletonList(validationError));
            request.getServletContext().getRequestDispatcher("/").forward(request, response);
            return null;
        }

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

    /** the typed term, never null and with the surrounding whitespace off */
    private String searchTerm(String raw) {
        return raw == null ? "" : raw.trim();
    }

    /**
     * A region search carries its query in chr/start/stop and its term is legitimately empty -
     * that is exactly what buildElasticSearchUrl() in RGDSearchController emits for one. So the
     * minimum length cannot apply to it.
     *
     * This replaces a test on the category. The minimum used to be skipped for every category
     * but "general", which was far wider than the case it was protecting: "?category=Gene" with
     * no term and no position ran as a match-all. "all" is not a chromosome, which is how
     * SearchService reads it too.
     */
    private boolean isPositionalSearch(HttpRequestFacade req) {
        String chr = req.getParameter("chr");
        boolean hasChr = !isBlank(chr) && !ALL.equalsIgnoreCase(chr);
        return hasChr || !isBlank(req.getParameter("start")) || !isBlank(req.getParameter("stop"));
    }

    /**
     * @param typed      what was entered, which is what the ceiling applies to
     * @param normalized what the search will run on, which is what the floor applies to
     * @param positional whether chr/start/stop carry the query, in which case an empty term is
     *                   the normal case rather than a mistake
     */
    private String validateSearchTerm(String typed, String normalized, boolean positional) {

        // the ceiling is on what was typed, because it is there to bound the input rather than to
        // judge how much of it the search can use
        if (typed.length() > MAX_SEARCH_LENGTH) {
            return "That search is too long. Please shorten it to " + MAX_SEARCH_LENGTH
                    + " characters or fewer and search again.";
        }
        if (positional || searchableLength(normalized) >= MIN_SEARCH_LENGTH) {
            return null;
        }

        // One message per reason the term came up short. They used to share "must be at least 2
        // characters long", which reads as plainly wrong to anyone who typed more than that:
        // "a*" and "%a" are two characters and "RGD" is three, and all three land here.
        //
        // None of these quote what was typed. headerarea.jsp, where this is rendered, builds the
        // span by concatenation, and other pages render the same attribute, so a term echoed back
        // into the message could come back as markup.
        if (typed.indexOf('*') >= 0 || typed.indexOf('%') >= 0) {
            return "A wildcard (* or %) cannot stand in for the characters you search on. Please "
                    + "enter at least " + MIN_SEARCH_LENGTH + " letters or numbers with it - "
                    + "\"ab*\" rather than \"a*\".";
        }
        if (normalized.isEmpty() && !typed.isEmpty()) {
            // what is left after the RGD prefix comes off - "RGD", "rgd:", "RGD_"
            return "Please include the ID digits after \"RGD\" - for example RGD:2004.";
        }
        // "letters or numbers", not "characters": punctuation does not narrow a search, so "a."
        // is as short as "a" as far as the index is concerned
        return "Please enter at least " + MIN_SEARCH_LENGTH + " letters or numbers to search.";
    }

    /**
     * How much of a term the search can actually narrow on: letters and digits only.
     *
     * Discounting "*" alone was not enough. A wildcard is not the only character that contributes
     * nothing - the analyzer drops punctuation as well, so "%a" reaches Elasticsearch as the one
     * character "a", and a one character search does not come back. ("%ab" and "ab" return the
     * same results in the same time, which is what showed the "%" was being ignored.) Counting
     * only letters and digits covers *, %, quotes, hyphens and anything else in a single rule,
     * instead of a list of characters to remember.
     */
    private static int searchableLength(String term) {
        if (term == null) {
            return 0;
        }
        int count = 0;
        for (int i = 0; i < term.length(); i++) {
            if (Character.isLetterOrDigit(term.charAt(i))) {
                count++;
            }
        }
        return count;
    }

    /**
     * Drops an "RGD" identifier prefix, so "RGD:2004", "RGD_2004", "RGD 2004" and "RGD2004" all
     * search as 2004, and lower cases the rest.
     *
     * Two things were wrong before. The prefix tests were case sensitive while the fallback lower
     * cased, so the two disagreed: "RGD:2004" came out as "2004" but "rgd:2004" fell through to
     * the fallback and came out as ":2004" - a different search for the same thing typed in
     * another case. And the fallback ran replaceAll("rgd", " ") across the whole string rather
     * than the prefix, so any term that merely contained those three letters was rewritten:
     * "Nrgdx" became "n x". Case is folded once up front now, and only a prefix is removed.
     */
    private String normalizeSearchTerm(String searchTerm) {
        String term = searchTerm == null ? "" : searchTerm.trim().toLowerCase();

        if (term.startsWith("rgd:") || term.startsWith("rgd_") || term.startsWith("rgd ")) {
            return term.substring(4).trim();
        }
        if (term.startsWith("rgd")) {
            return term.substring(3).trim();
        }
        return term;
    }

    private ModelMap buildSearchModel(HttpServletRequest request, HttpRequestFacade req,
                                       SearchService service, String term, SearchBean searchBean) throws Exception {
        ModelMap model = new ModelMap();
        boolean shouldLog = "true".equals(req.getParameter("log"));
        int postCount = parseIntOrDefault(req.getParameter("postCount"), 0) + 1;

        String cat1 = (postCount <= 1) ? searchBean.getCategory() : req.getParameter("cat1");
        String sp1 = (postCount <= 1) ? searchBean.getSpecies() : req.getParameter("sp1");

        int pageSize = (searchBean.getSize() > 0) ? searchBean.getSize() : DEFAULT_PAGE_SIZE;
        SearchResponse<java.util.Map> searchResponse = service.getSearchResponse(request, term, searchBean);

        int totalPages = 0;
        if (searchResponse != null) {
            TotalHits hits = searchResponse.hits().total();
            long hitCount = (hits != null) ? hits.value() : 0L;
            totalPages = (int) ((hitCount + pageSize - 1) / pageSize);
            model.putAll(service.getResultsMap(searchResponse, term));

            if (shouldLog) {
                logResults(term, searchBean.getCategory(), hitCount);
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
        model.addAttribute("termEncoded", URLEncoder.encode(term, StandardCharsets.UTF_8));
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

        if ("true".equalsIgnoreCase(req.getParameter("assemblyView"))
                && !isBlank(searchBean.getAssembly())
                && !ALL.equalsIgnoreCase(searchBean.getAssembly())) {
            return VIEW_ASSEMBLY;
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
            if (term.matches("\\d+")) {
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
    /**
     * Whether the number is an expression study id.
     *
     * It is only ever used to suppress a redirect, never to make one: getRedirectForRgdId() had a
     * branch building an /report/expressionStudy/main.html url, but reaching it required this to
     * be true, and that case returned null before getting there. So a study id has always fallen
     * through to the search. The dead branch is gone rather than left looking live - if a study id
     * should redirect to its report, that is a feature to add deliberately.
     */
    private boolean isStudyId(int id) throws Exception {
        StudySampleMetadataDAO dao=new StudySampleMetadataDAO();
        List<StudySampleMetadata> studies=dao.getStudySampleMetadata(id);
        return studies!=null && studies.size()>0;

    }
    /**
     * The report page a purely numeric term goes straight to, or null to let the search answer.
     *
     * getRgdId2() returns null for a number that is not an RGD id - which is most numbers people
     * type - and the status was read off it before that was checked, so searching for "22" threw
     * an NPE. It was caught and logged by getRedirectUrl(), so the search still ran, but every
     * such search left a warning and a stack trace in the log.
     *
     * The null checks that followed could not help: inside "if (id.getObjectStatus()...)" the id
     * is never null, so "id == null && !studyId" was unreachable - and with id non-null the whole
     * condition reduced to "studyId". A number that is both an RGD id and a study id therefore
     * falls through to the search, which is the behaviour kept here. See the note on isStudyId().
     */
    private String getRedirectForRgdId(String term) throws Exception {
        int rgdId = Integer.parseInt(term);

        RGDManagementDAO dao = new RGDManagementDAO();
        RgdId id = dao.getRgdId2(rgdId);

        // not an RGD id at all, or not an active one: nothing to go to
        if (id == null || !"active".equalsIgnoreCase(id.getObjectStatus())) {
            return null;
        }

        // also a study id, so there are two places it could mean: let the search show both
        if (isStudyId(rgdId)) {
            return null;
        }

        String url;
        if (id.getSpeciesTypeKey() != 1 && id.getObjectKey() == 7) {
            // non-human variants have their own report page
            url = "/rgdweb/report/variants/main.html?id=" + id.getRgdId();
        } else {
            url = Link.it(rgdId, id.getObjectKey());
        }

        // Link.it hands back just the id when it has no page for that object type
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
        SearchResponse<java.util.Map> response = service.getSearchResponse(request, term, searchBean);

        if (response != null) {
            TotalHits hits = response.hits().total();
            if (hits != null && hits.value() == 1) {
                return getUrlFromSearchHit(response, request, term);
            }
        }
        return null;
    }

    private String buildFullUrl(String path) {
        return path;
    }
    private String getUrlFromSearchHit(SearchResponse<java.util.Map> response, HttpServletRequest request, String term) {
        TotalHits totalHits = response.hits().total();
        logResults(term, request.getParameter("category"), totalHits != null ? totalHits.value() : 0L);

        @SuppressWarnings("unchecked")
        java.util.Map<String, Object> source = (java.util.Map<String, Object>) response.hits().hits().get(0).source();
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
