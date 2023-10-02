package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;

import java.util.List;

/**
 * @author mtutaj
 * @since 3/19/13
 * all data used by term merge tool
 */
public class TermMergeBean {

    private Term termFrom;
    private Term termTo;
    private List<TermSynonym> existingSynonyms;
    private List<TermSynonym> toBeDeletedSynonyms;
    private List<TermSynonym> toBeInsertedSynonyms;

    private List<Term> termFromParents;
    private List<Term> termToParents;

    private List<Term> termFromChildren;
    private List<Term> termToChildren;

    public Term getTermFrom() {
        return termFrom;
    }

    public void setTermFrom(Term termFrom) {
        this.termFrom = termFrom;
    }

    public Term getTermTo() {
        return termTo;
    }

    public void setTermTo(Term termTo) {
        this.termTo = termTo;
    }

    public List<TermSynonym> getExistingSynonyms() {
        return existingSynonyms;
    }

    public void setExistingSynonyms(List<TermSynonym> existingSynonyms) {
        this.existingSynonyms = existingSynonyms;
    }

    public List<TermSynonym> getToBeDeletedSynonyms() {
        return toBeDeletedSynonyms;
    }

    public void setToBeDeletedSynonyms(List<TermSynonym> toBeDeletedSynonyms) {
        this.toBeDeletedSynonyms = toBeDeletedSynonyms;
    }

    public List<TermSynonym> getToBeInsertedSynonyms() {
        return toBeInsertedSynonyms;
    }

    public void setToBeInsertedSynonyms(List<TermSynonym> toBeInsertedSynonyms) {
        this.toBeInsertedSynonyms = toBeInsertedSynonyms;
    }

    public List<Term> getTermFromParents() {
        return termFromParents;
    }

    public void setTermFromParents(List<Term> termFromParents) {
        this.termFromParents = termFromParents;
    }

    public List<Term> getTermToParents() {
        return termToParents;
    }

    public void setTermToParents(List<Term> termToParents) {
        this.termToParents = termToParents;
    }

    public List<Term> getTermFromChildren() {
        return termFromChildren;
    }

    public void setTermFromChildren(List<Term> termFromChildren) {
        this.termFromChildren = termFromChildren;
    }

    public List<Term> getTermToChildren() {
        return termToChildren;
    }

    public void setTermToChildren(List<Term> termToChildren) {
        this.termToChildren = termToChildren;
    }
}
