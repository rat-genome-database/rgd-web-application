package edu.mcw.rgd.ontology;

import edu.mcw.rgd.datamodel.ontologyx.Relation;

/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: Mar 30, 2011
 * Time: 12:41:21 PM
 */
public class OntDagNode implements Comparable<OntDagNode> {
    private String termAcc; // term acc id for node
    private String term;    // term name
    private Relation ontRel;// ontology relation type
    private boolean isObsolete;
    private boolean hasPathwayDiagram; // only for pathway terms
    private int countOfPathwayDiagramsForTermChilds; // only for pathway terms

    private int ratAnnotCountForTerm;
    private int annotCountForTerm;
    private int annotCountForTermAndChilds;

    private int childCount;

    public OntDagNode(String termAcc) {
        setTermAcc(termAcc);
        setOntRel(Relation.NOT_SPECIFIED);
    }

    public OntDagNode(String termAcc, String ontRelId) {
        setTermAcc(termAcc);
        setOntRelId(ontRelId);
    }

    public OntDagNode(String termAcc, Relation ontRel) {
        setTermAcc(termAcc);
        setOntRel(ontRel);
    }

    public int compareTo(OntDagNode o) {
        int result = this.getTerm().compareToIgnoreCase(o.getTerm());
        if( result!=0 )
            return result;
        return this.getTermAcc().compareTo(o.getTermAcc());
    }

    public String getTermAcc() {
        return termAcc;
    }

    public void setTermAcc(String termAcc) {
        this.termAcc = termAcc;
    }

    public String getTerm() {
        return term!=null ? term : "";
    }

    public void setTerm(String term) {
        this.term = term;
    }

    public Relation getOntRel() {
        return ontRel;
    }

    public void setOntRel(Relation ontRel) {
        this.ontRel = ontRel;
    }

    public void setOntRelId(String ontRelId) {
        this.ontRel = Relation.getRelFromRelId(ontRelId);
    }

    public boolean isObsolete() {
        return isObsolete;
    }

    public void setObsolete(boolean obsolete) {
        isObsolete = obsolete;
    }

    public int getRatAnnotCountForTerm() {
        return ratAnnotCountForTerm;
    }

    public void setRatAnnotCountForTerm(int ratAnnotCountForTerm) {
        this.ratAnnotCountForTerm = ratAnnotCountForTerm;
    }

    public int getAnnotCountForTerm() {
        return annotCountForTerm;
    }

    public void setAnnotCountForTerm(int annotCountForTerm) {
        this.annotCountForTerm = annotCountForTerm;
    }

    public int getAnnotCountForTermAndChilds() {
        return annotCountForTermAndChilds;
    }

    public void setAnnotCountForTermAndChilds(int annotCountForTermAndChilds) {
        this.annotCountForTermAndChilds = annotCountForTermAndChilds;
    }

    public int getChildCount() {
        return childCount;
    }

    public void setChildCount(int childCount) {
        this.childCount = childCount;
    }

    public boolean isHasPathwayDiagram() {
        return hasPathwayDiagram;
    }

    public void setHasPathwayDiagram(boolean hasPathwayDiagram) {
        this.hasPathwayDiagram = hasPathwayDiagram;
    }

    public int getCountOfPathwayDiagramsForTermChilds() {
        return countOfPathwayDiagramsForTermChilds;
    }

    public void setCountOfPathwayDiagramsForTermChilds(int countOfPathwayDiagramsForTermChilds) {
        this.countOfPathwayDiagramsForTermChilds = countOfPathwayDiagramsForTermChilds;
    }
}