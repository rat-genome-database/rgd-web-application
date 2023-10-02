package edu.mcw.rgd.ontology;

import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.RgdContext;

import java.util.Collection;
import java.util.Iterator;

/**
 * Created by IntelliJ IDEA. <br>
 * User: mtutaj <br>
 * Date: 9/8/11 <br>
 * Time: 12:03 PM
 * <p>
 * Base bean for OntAnnotBean and OntViewBean
 */
public class OntBaseBean {
    private String accId; // term accession id passed by user
    private Term term; // term shown
    private Collection<TermSynonym> termSynonyms;
    private String ctdAccId; // if the term is a CTD term, the primary synonym for MESH:xxx or OMIM:xxx is stored here

    public String getAccId() {
        return accId;
    }

    public void setAccId(String accId) {
        this.accId = accId;
    }

    public Term getTerm() {
        return term;
    }

    public void setTerm(Term term) {
        this.term = term;
    }

    public Collection<TermSynonym> getTermSynonyms() {
        return termSynonyms;
    }

    public void setTermSynonyms(Collection<TermSynonym> termSynonyms) throws Exception {
        this.termSynonyms = termSynonyms;


        // production servers should not show synonyms with name 'Not4Curation'
        if( RgdContext.isProduction() ) {

            Iterator<TermSynonym> it = termSynonyms.iterator();
            while( it.hasNext() ) {
                TermSynonym synonym = it.next();
                if( Utils.stringsAreEqualIgnoreCase(synonym.getName(), "Not4Curation") ) {
                    it.remove();
                }
            }
        }

        // now choose the synonym of type 'primary_id'
        for( TermSynonym synonym: termSynonyms ) {
            if( synonym.getType().equals("primary_id") ) {
                setCtdAccId(synonym.getName());
            }
        }
    }

    public String getCtdAccId() {
        return ctdAccId;
    }

    public void setCtdAccId(String ctdAccId) {
        this.ctdAccId = ctdAccId;
    }
}
