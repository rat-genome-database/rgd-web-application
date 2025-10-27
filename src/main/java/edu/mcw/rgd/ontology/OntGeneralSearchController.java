package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.StatisticsDAO;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.ontologyx.Ontology;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.datamodel.search.GeneralSearchResult;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.search.ReportFactory;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.stats.ScoreBoardManager;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.text.SimpleDateFormat;
import java.time.*;
import java.util.*;

/**
 * @author mtutaj
 * @since Apr 14, 2011
 */
public class OntGeneralSearchController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {



        ModelAndView mv = new ModelAndView();

        OntSearchBean bean = new OntSearchBean();
        mv.addObject("bean", bean);

        // load all ontologies
        OntDagUtils dao = new OntDagUtils();
        List<Ontology> ontologies = dao.dao.getOntologies();
        bean.setOntologies(ontologies);

        loadRootTerms(bean);

        String term = request.getParameter("term");
        // if 'term' param is null, try 'term' attribute
        if( term==null )
            term = (String) request.getAttribute("term");
        // null term has its simple jsp page
        if( term==null || term.isEmpty() ) {

            //added by Pushkala 16th May 2012 - RGDD447
            bean.sortOntologiesAlphabetically();
            Map<String, Integer> annotsCnt = new HashMap<>();
            ScoreBoardManager sbm = new ScoreBoardManager();
            StatisticsDAO sdao = new StatisticsDAO();

            List<String> pastDates = sdao.getStatArchiveDates();
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
            Date d = formatter.parse(pastDates.get(0));

            Map<String, String> annotMap = sbm.getOntologyAnnotationCount(0, 0, d);
            for(Ontology o : bean.getOntologies()){
                String mapCnt = annotMap.get(o.getName());
                int cnt = 0;
                if (Utils.isStringEmpty(mapCnt))
                    annotsCnt.put(o.getRootTermAcc(),cnt);
                else {
                    cnt = Integer.parseInt(mapCnt);
                    annotsCnt.put(o.getRootTermAcc(),cnt);
                }
            }
            bean.setAnnotCount(annotsCnt);
            mv.setViewName("/WEB-INF/jsp/ontology/search.jsp");
            return mv;
        }

        // term is given
        mv.setViewName("/WEB-INF/jsp/ontology/gsearch.jsp");

        // break term into words
        SearchBean search = new SearchBean();
        search.setTerm(term);
		
		// setTerm is filtering out any common words so you can end having no terms to search;
		// but, if term, being one of common words, is quoted, it won't be checked against common word list :-)
		if( search.getRequired().isEmpty()  &&  search.getNegated().isEmpty() ) {
			search.setTerm("\""+term+"\"");
		}
		
        // get search result for the words
        GeneralSearchResult result = ReportFactory.getInstance().searchOntologies(search);

        // replace any double quotes with &quot; to present it correctly
        bean.setSearchString(term.replace("\"", "&quot;"));

        // generate map of 'ontology' to 'hit count'; ontologies sorted alphabetically
        Map<String, OntSearchBean.OntInfo> hitCountMap = new TreeMap<String, OntSearchBean.OntInfo>(new Comparator<String>(){
            public int compare(String o1, String o2) {
                // fix sorting order for GO ontologies
                String s1 = fixSortForGo(o1);
                String s2 = fixSortForGo(o2);
                return s1.compareToIgnoreCase(s2);
            }
            private String fixSortForGo(String ontId) {
                if( ontId.equals("BP") )
                    return "GO BP";
                else if( ontId.equals("CC") )
                    return "GO CC";
                else if( ontId.equals("MF") )
                    return "GO MF";
                else
                    return ontId;
            }
        });
        for( Map.Entry<String, Integer> entry: result.ontTermHits.entrySet() ) {
            String ontId = entry.getKey();
            int hitCount = entry.getValue();
            OntSearchBean.OntInfo info = bean.createOntInfo(getOntology(ontId, ontologies), hitCount);
            hitCountMap.put(ontId, info);
        }
        bean.setHitCount(hitCountMap);

        // now traverse the ontology terms and see if there are any annotations for given ontology
        for( Map.Entry<String, String> entry: result.ontologyTerms.entrySet() ) {
            String ontId = entry.getValue();
            OntSearchBean.OntInfo info = hitCountMap.get(ontId);
            if( info.hasAnnots )
                continue; // if given ontology already has annotations, it is no need to check for it again
            TermWithStats stats = dao.getTermWithStats(entry.getKey());
            if( stats!=null ) {
                // yes: this matching term has some annotations!
                info.hasAnnots = stats.getAnnotObjectCountForTermAndChildren()>0;
            }
        }

        // if parameter 'ont' is present, we load the terms for this ontology
        // assign all found terms to proper ontologies
        Ontology selOntology = getOntology(request.getParameter("ont"), ontologies);
        if( selOntology!=null ) {
            bean.setSelOntId(selOntology.getId());
            List<TermWithStats> terms = loadTermsForOntology(selOntology, result.ontologyTerms, dao, bean);
            Map<Ontology, List<TermWithStats>> termsMap = new HashMap<Ontology, List<TermWithStats>>();
            termsMap.put(selOntology, terms);
            bean.setResults(termsMap);
        }

        mv.addObject("bean", bean);
        return mv;
    }

    private Ontology getOntology(String ontId, List<Ontology> ontologies) {
        if( ontId==null )
            return null;
        for( Ontology ont: ontologies ) {
            if( ont.getId().equals(ontId) )
                return ont;
        }
        return null;
    }

    private List<TermWithStats> loadTermsForOntology(Ontology ont, Map<String,String> termAccIds, OntDagUtils utils, OntSearchBean bean) throws Exception {

        List<TermWithStats> termList = new LinkedList<TermWithStats>();

        int obsoleteTerms = 0; // count of obsolete terms

        // if parameter 'ont' is present, we load the terms for this ontology
        // assign all found terms to proper ontologies
        for( Map.Entry<String,String> entry: termAccIds.entrySet() ) {
            // ignore acc ids from other ontologies
            if( !entry.getValue().equals(ont.getId()) )
                continue;

            // term for our ontology: load term info and stats
            Term term = utils.dao.getTermByAccId(entry.getKey());
            if( term==null )
                continue; // unexpected -- no such term?

            // ignore obsolete terms
            if( term.isObsolete() ) {
                obsoleteTerms++;
                continue;
            }

            // add the term to the results
            TermWithStats termWithStats = utils.getTermWithStats(term.getAccId());
            termList.add(termWithStats);
        }

        // sort terms alphabetically
        Collections.sort(termList, new Comparator<TermWithStats>() {
            public int compare(TermWithStats o1, TermWithStats o2) {
                return o1.getTerm().compareToIgnoreCase(o2.getTerm());
            }
        });

        bean.setObsoleteTermsInSearch(obsoleteTerms);

        return termList;
    }

    private void loadRootTerms(OntSearchBean bean) throws Exception {

        OntologyXDAO dao = new OntologyXDAO();

        HashMap<String, String> rootTerms = new HashMap<String, String>();
        for( Ontology ont: bean.getOntologies() ) {
            rootTerms.put(ont.getId(), dao.getRootTerm(ont.getId()));
        }
        bean.setRootTerms(rootTerms);
    }
}
