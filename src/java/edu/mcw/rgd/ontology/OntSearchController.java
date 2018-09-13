package edu.mcw.rgd.ontology;

import edu.mcw.rgd.datamodel.ontologyx.Ontology;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: Mar 30, 2011
 * Time: 11:45:07 AM
 * To change this template use File | Settings | File Templates.
 */
public class OntSearchController implements Controller {
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/ontology/search.jsp");
        OntSearchBean bean = new OntSearchBean();
        mv.addObject("bean", bean);

        // retrieve parameters
        String matchType = request.getParameter("match_type");
        String searchString = request.getParameter("search_string");
        String[] ontologyIds = request.getParameterValues("ontology");
        Map<Ontology, List<TermWithStats>> results;

        // load all available ontologies
        OntDagUtils dao = new OntDagUtils();
        List<Ontology> ontologies = dao.dao.getOntologies();
        bean.setOntologies(ontologies);

        // all parameters must be given
        if( ontologyIds!=null && ontologyIds.length>0 || searchString!=null || matchType!=null ) {

            bean.setSearchString(searchString);

            results = new HashMap<Ontology,List<TermWithStats>>();
            bean.setResults(results);

            // temporary lookup map: ont_id => Ontology object
            Map<String, Ontology> ontIds = new HashMap<String, Ontology>();

            // validate the ontologies to be searched
            for( String ontologyId: ontologyIds ) {
                for( Ontology ont: ontologies ) {
                    if( ont.getId().equals(ontologyId) ) {
                        ontIds.put(ont.getId(), ont);
                        results.put(ont, new LinkedList<TermWithStats>());
                        break;
                    }
                }
            }

            List<Term> terms = null; // all terms found

            // determine if search string is term accession
            int pos = searchString.indexOf(':');
            if( pos>0 && pos+1<searchString.length() && Character.isDigit(searchString.charAt(pos+1)) ) {
                // search string contains a colon ':' in the middle followed by a digit;
                // it could be a term accession id
                Term term = dao.dao.getTermByAccId(searchString);
                if( term!=null ) {
                    terms = new ArrayList<Term>(1);
                    terms.add(term);
                }
            }
            else {
                // not a term accession id -- try the searchString and matchType
                terms = dao.dao.searchForTerms(matchType, searchString, false);
            }

            // assign all found terms to proper ontologies
            if( terms!=null ) {
                for( Term term: terms ) {

                    // look if the term ontology is one of the searchable ontologies
                    Ontology ont = ontIds.get(term.getOntologyId());
                    if( ont==null )
                        continue; // skip any term which ontology is not among searchable ontologies

                    // add the term to the results
                    List<TermWithStats> termList = results.get(ont);
                    TermWithStats termWithStats = dao.getTermWithStats(term.getAccId());
                    termList.add(termWithStats);
                }
            }

            // sort terms alphabetically for every ontology
            for( List<TermWithStats> termList: results.values() ) {
                Collections.sort(termList, new Comparator<TermWithStats>() {
                    public int compare(TermWithStats o1, TermWithStats o2) {
                        return o1.getTerm().compareToIgnoreCase(o2.getTerm());
                    }
                });
            }
        }

        return mv;
    }

}