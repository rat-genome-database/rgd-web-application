package edu.mcw.rgd.ontology;

import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;

import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Apr 4, 2011
 * Time: 1:44:19 PM
 */
public class OntAnnotBean extends OntBaseBean {

    // map of terms with lists of gene annotations
    Map<Term, List<OntAnnotation>> annots;
    // species: limit annotations to given species
    String species;
    int speciesTypeKey;
    boolean withChildren; // show annotations for child terms too
    boolean hasQualifiers; // there are annotations with qualifiers
    boolean showAnnotsForAllSpecies = true;
    boolean extendedView = false;
    boolean isDownload = false;
    int objectKey=-1;
    String geneRgdids = "";
    String qtlRgdids = "";
    String strainRgdids = "";

    public static int MAX_ANNOT_COUNT = 10000; // max count of annotations shown in gviewer and on ontology annot report page
    int annotCount; // count of all annotations

    static List<String> sortByChoices, sortByChoicesEx;
    String sortBy;
    boolean sortDesc; // sort descending

    Map<String, String> pathTypeChoices;
    String pathType;
    List<List<TermWithStats>> paths;
    List<TermWithStats> children; // child terms

    Set<Term> phenoStrains = Collections.emptySet();
    Set<Term> phenoCmoTerms = Collections.emptySet();
    Set<Term> phenoMmoTerms = Collections.emptySet();
    Set<Term> phenoXcoTerms = Collections.emptySet();

    static {
        sortByChoices = new ArrayList<String>();
        sortByChoices.add("symbol");
        sortByChoices.add("object name");
        sortByChoices.add("position");
        sortByChoices.add("reference");
        sortByChoices.add("evidence");

        sortByChoicesEx = new ArrayList<String>();
        sortByChoicesEx.add("symbol");
        sortByChoicesEx.add("name");
        sortByChoicesEx.add("qualifier");
        sortByChoicesEx.add("evidence");
        sortByChoicesEx.add("position");
        sortByChoicesEx.add("reference");
        sortByChoicesEx.add("source");
    }

    public OntAnnotBean() {
        super();

        pathTypeChoices = new HashMap<String, String>();
        pathTypeChoices.put("1", "one shortest");
        pathTypeChoices.put("2", "all shortest");
        pathTypeChoices.put("3", "one longest");
        pathTypeChoices.put("4", "all longest");
        pathTypeChoices.put("5", "one shortest and longest");
        pathTypeChoices.put("6", "all");
    }

    /**
     * if there is phenotype data to be shown
     * @return true if there is phenotype data to be shown
     */
    public boolean isPhenoData() {
        return phenoStrains!=null && !phenoStrains.isEmpty()
            || phenoCmoTerms!=null && !phenoCmoTerms.isEmpty()
            || phenoMmoTerms!=null && !phenoMmoTerms.isEmpty()
            || phenoXcoTerms!=null && !phenoXcoTerms.isEmpty()
                ;
    }

    /**
     * return true if the sort-by option is available only in extended view
     * @param sortBy sort-by option
     * @return true if the sort-by option is available only in extended view
     */
    public boolean isExtendedSortBy(String sortBy) {
        return sortBy.equals("qualifier") || sortBy.equals("source");
    }

    // set the term and compute annotation count
    public void setTerm(TermWithStats term) {
        setTerm((Term)term);
        if( term==null )
            return;

        setAnnotCount(term.getStat("annotated_object_count", getSpeciesTypeKey(), 0, isWithChildren()?1:0));
    }

    public int getObjectKey() {
        return objectKey;
    }

    public void setObjectKey(int objectKey) {
        this.objectKey = objectKey;
    }

    public Map<Term, List<OntAnnotation>> getAnnots() {
        return annots;
    }

    public void setAnnots(Map<Term, List<OntAnnotation>> annots) {
        this.annots = annots;
    }

    public String getSpecies() {
        return species;
    }

    public void setSpecies(String species) {
        this.species = species;
    }

    public int getSpeciesTypeKey() {
        return speciesTypeKey;
    }

    public void setSpeciesTypeKey(int speciesTypeKey) {
        this.speciesTypeKey = speciesTypeKey;
    }

    public boolean isWithChildren() {
        return withChildren;
    }

    public void setWithChildren(boolean withChildren) {
        this.withChildren = withChildren;
    }

    public boolean getHasQualifiers() {
        return hasQualifiers;
    }

    public void setHasQualifiers(boolean hasQualifiers) {
        this.hasQualifiers = hasQualifiers;
    }

    public List<String> getSortByChoices() {
        return isExtendedView() ? sortByChoicesEx : sortByChoices;
    }

    public String getSortBy() {
        return sortBy;
    }

    public void setSortBy(String sortBy) {
        this.sortBy = sortBy;
    }

    public boolean isSortDesc() {
        return sortDesc;
    }

    public void setSortDesc(boolean sortDesc) {
        this.sortDesc = sortDesc;
    }

    public Map<String, String> getPathTypeChoices() {
        return pathTypeChoices;
    }

    public void setPathTypeChoices(Map<String, String> pathTypeChoices) {
        this.pathTypeChoices = pathTypeChoices;
    }

    public String getPathType() {
        return pathType;
    }

    public void setPathType(String pathType) {
        this.pathType = pathType;
    }

    public List<List<TermWithStats>> getPaths() {
        return paths;
    }

    public void setPaths(List<List<TermWithStats>> paths) {
        this.paths = paths;
    }

    public List<TermWithStats> getChildren() {
        return children;
    }

    public void setChildren(List<TermWithStats> childTerms) {
        this.children = childTerms;
    }

    public boolean isShowAnnotsForAllSpecies() {
        return showAnnotsForAllSpecies;
    }

    public void setShowAnnotsForAllSpecies(boolean showAnnotsForAllSpecies) {
        this.showAnnotsForAllSpecies = showAnnotsForAllSpecies;
    }

    public Set<Term> getPhenoStrains() {
        return phenoStrains;
    }

    public void setPhenoStrains(Set<Term> phenoStrains) {
        this.phenoStrains = phenoStrains;
    }

    public Set<Term> getPhenoCmoTerms() {
        return phenoCmoTerms;
    }

    public void setPhenoCmoTerms(Set<Term> phenoCmoTerms) {
        this.phenoCmoTerms = phenoCmoTerms;
    }

    public Set<Term> getPhenoMmoTerms() {
        return phenoMmoTerms;
    }

    public void setPhenoMmoTerms(Set<Term> phenoMmoTerms) {
        this.phenoMmoTerms = phenoMmoTerms;
    }

    public Set<Term> getPhenoXcoTerms() {
        return phenoXcoTerms;
    }

    public void setPhenoXcoTerms(Set<Term> phenoXcoTerms) {
        this.phenoXcoTerms = phenoXcoTerms;
    }

    public boolean isExtendedView() {
        return extendedView;
    }

    public void setExtendedView(boolean extendedView) {
        this.extendedView = extendedView;
    }

    public int getAnnotCount() {
        return annotCount;
    }

    public void setAnnotCount(int annotCount) {
        this.annotCount = annotCount;
    }

    public boolean getIsDownload() {
        return isDownload;
    }

    public void setIsDownload(boolean isDownload) {
        this.isDownload = isDownload;
    }

    public String getGeneRgdids() {
        return geneRgdids;
    }

    public void setGeneRgdids(String rgdids) {
        this.geneRgdids = rgdids;
    }

    public String getQtlRgdids() {
        return qtlRgdids;
    }

    public void setQtlRgdids(String rgdids) {
        this.qtlRgdids = rgdids;
    }

    public String getStrainRgdids() {
        return strainRgdids;
    }

    public void setStrainRgdids(String rgdids) {
        this.strainRgdids = rgdids;
    }



}
