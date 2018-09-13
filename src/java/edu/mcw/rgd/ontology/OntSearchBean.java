package edu.mcw.rgd.ontology;

import edu.mcw.rgd.datamodel.ontologyx.Ontology;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: Mar 30, 2011
 * Time: 11:47:25 AM
 *
 * Contains all objects needed to be shown on ontSearch.jsp
 */
public class OntSearchBean {

    private String searchString;
    private String selOntId; // ontology id for selected ontology
    private List<Ontology> ontologies;
    private Map<Ontology, List<TermWithStats>> results;
    private Map<String, OntInfo> hitCount; // ont_id => OntInfo
    private Map<String, String> rootTerms; // ont_id => root term acc id
    // count of obsolete terms returned by ontology search, but not shown on search result list
    private int obsoleteTermsInSearch;

    public String getSearchString() {
        return searchString;
    }

    public void setSearchString(String searchString) {
        this.searchString = searchString;
    }

    public List<Ontology> getOntologies() {
        return ontologies;
    }

    public void setOntologies(List<Ontology> ontologies) {
        this.ontologies = ontologies;
    }

    public Map<Ontology, List<TermWithStats>> getResults() {
        return results;
    }

    public void setResults(Map<Ontology, List<TermWithStats>> results) {
        this.results = results;
    }

    public Map<String, OntInfo> getHitCount() {
        return hitCount;
    }

    public void setHitCount(Map<String, OntInfo> hitCount) {
        this.hitCount = hitCount;
    }

    public String getSelOntId() {
        return selOntId;
    }

    public void setSelOntId(String selOntId) {
        this.selOntId = selOntId;
    }

    public Map<String, String> getRootTerms() {
        return rootTerms;
    }

    public void setRootTerms(Map<String, String> rootTerms) {
        this.rootTerms = rootTerms;
    }

    public int getObsoleteTermsInSearch() {
        return obsoleteTermsInSearch;
    }

    public void setObsoleteTermsInSearch(int obsoleteTermsInSearch) {
        this.obsoleteTermsInSearch = obsoleteTermsInSearch;
    }

    public void sortOntologiesAlphabetically() {
        if( ontologies==null )
            return;
        Collections.sort(ontologies, new Comparator<Ontology>(){
            public int compare(Ontology o1, Ontology o2) {
                return o1.getName().compareToIgnoreCase(o2.getName());
            }
        });
    }

    public OntInfo createOntInfo(Ontology ont, int hitCount) {
        OntInfo info = new OntInfo();
        info.ontology = ont;
        info.hitCount = hitCount;
        return info;
    }

    /**
     * search information for every ontology
     */
    public class OntInfo {
        public Ontology ontology;
        public int hitCount; // count of terms for given ontology matching the search criteria
        public boolean hasAnnots; // these ontology has matching terms with annotations
    }
}