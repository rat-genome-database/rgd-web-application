package edu.mcw.rgd.search;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PathwayDAO;
import edu.mcw.rgd.datamodel.Pathway;
import edu.mcw.rgd.datamodel.ontologyx.Ontology;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

import edu.mcw.rgd.web.HttpRequestFacade;

import edu.mcw.rgd.datamodel.search.GeneralSearchResult;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.process.search.ReportFactory;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: May 23, 2008
 * Time: 2:50:11 PM
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

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        //ArrayList status = new ArrayList();

        String path = "/WEB-INF/jsp/search/";

        HttpRequestFacade req = new HttpRequestFacade(request);
        String term = req.getParameter("term");

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

        if (!termOfLength) {
            error.add("Search term must be at least 2 characters long (common words are excluded). Please search again.");
            request.setAttribute("error", error);
            return new ModelAndView(path + "search.jsp");
        }

        request.setAttribute("error", error);
        request.setAttribute("status", warning);
        request.setAttribute("warn", warning);

        if (term.equals("")) {
            return new ModelAndView(path + "/search.jsp");
        } else {
            GeneralSearchResult result = ReportFactory.getInstance().execute(search);
            request.setAttribute("GeneralSearchResult", result);

            // build ontology map with terms
            Map<Ontology, List<TermWithStats>> ontMap = buildOntologyMap(result.ontologyTerms);
            request.setAttribute("ontMap", ontMap);

            // postprocessing: examine matching pathway ontology terms and load Pathway objects when available
            List<Pathway> pathways = buildPathwayList(result.ontologyTerms);
            request.setAttribute("pathways", pathways);

            return new ModelAndView(path + "/searchResult.jsp");
        }
    }

    private Map<Ontology, List<TermWithStats>> buildOntologyMap(Map<String,String> ontTerms) throws Exception {
        // ontTerms is a map of term accession ids ==> ont_ids
        // now we build another map: ontology => list of terms
        OntologyXDAO dao = new OntologyXDAO();
        Map<Ontology, List<TermWithStats>> ontMap = new TreeMap<Ontology, List<TermWithStats>>(new Comparator<Ontology>() {
            // sort ontologies by name
            public int compare(Ontology o1, Ontology o2) {
                return o1.getName().compareToIgnoreCase(o2.getName());
            }
        });
        for( Map.Entry<String,String> entry: ontTerms.entrySet() ) {
            String ontId = entry.getValue();
            Ontology ont = getOntology(ontId, dao);
            List<TermWithStats> terms = ontMap.get(ont); // do we have any terms for this ontology?
            if( terms==null ) {
                terms = new LinkedList<TermWithStats>();
                ontMap.put(ont, terms);
            }
            terms.add(dao.getTermWithStats(entry.getKey(), null));
        }

        // sort term lists within ontologies
        for( List<TermWithStats> terms: ontMap.values() ) {
            Collections.sort(terms, new Comparator<TermWithStats>() {
                public int compare(TermWithStats o1, TermWithStats o2) {
                    return o1.getTerm().compareToIgnoreCase(o2.getTerm());
                }
            });
        }
        return ontMap;
    }

    // get ontology given ontology id; we use static map for efficiency
    private Ontology getOntology(String ontId, OntologyXDAO dao) throws Exception {
        Ontology ont = ontologyMap.get(ontId);
        if( ont == null ) {
            ont = dao.getOntology(ontId);
            ontologyMap.put(ontId, ont);
        }
        return ont;
    }

    private static Map<String,Ontology> ontologyMap = new HashMap<String, Ontology>();


    private List<Pathway> buildPathwayList(Map<String,String> ontTerms) throws Exception {
        // ontTerms is a map of term accession ids ==> ont_ids
        PathwayDAO dao = new PathwayDAO();
        List<Pathway> pathways = null;
        for( Map.Entry<String,String> entry: ontTerms.entrySet() ) {

            String ontId = entry.getValue();
            if( !ontId.equals("PW") )
                continue;

            Pathway pathway = dao.getPathwayInfo(entry.getKey());
            if( pathway!=null ) {
                // we have a pathway! add it to result list
                if( pathways==null )
                    pathways = new ArrayList<Pathway>();
                pathways.add(pathway);
            }
        }

        return pathways;
    }
}
