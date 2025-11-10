package edu.mcw.rgd.search.elasticsearch1.model;

import java.util.Set;

/**
 * Created by jthota on 11/19/2018.
 */
public class SearchBean {
    private String term;
    private String category;
    private String variantCategory;

    private String species;
    private String type;
    private String subCat;
    private int from;
    private int size;
    private boolean page;
    private String sortOrder;
    private String sortBy;
    private String assembly;
    private String trait;
    private String polyphenStatus;
    private String sample;
    private String region;
    private String start;
    private String stop;
    private String chr;
    private int currentPage;
    private boolean redirect;
    /********************************************GENE SEARCH ADDITIONAL FIELDS************************/
    String matchType;//:equals
    String searchFields;//:all_with_aliases
    boolean sslpLimit;//:no
    boolean homologLimit;//:no
    String ontType;//:GO
    String ontValue;
    String order;//:symbol
    int hitsPerPage;//:25
    boolean objectSearch;

    String expressionLevel;
    String strainTerms;
    String tissueTerms;
    String cellTypeTerms;

    public String getStrainTerms() {
        return strainTerms;
    }

    public void setStrainTerms(String strainTerms) {
        this.strainTerms = strainTerms;
    }

    public String getTissueTerms() {
        return tissueTerms;
    }

    public void setTissueTerms(String tissueTerms) {
        this.tissueTerms = tissueTerms;
    }

    public String getCellTypeTerms() {
        return cellTypeTerms;
    }

    public void setCellTypeTerms(String cellTypeTerms) {
        this.cellTypeTerms = cellTypeTerms;
    }

    public String getExpressionLevel() {
        return expressionLevel;
    }

    public void setExpressionLevel(String expressionLevel) {
        this.expressionLevel = expressionLevel;
    }

    public boolean isObjectSearch() {
        return objectSearch;
    }

    public void setObjectSearch(boolean objectSearch) {
        this.objectSearch = objectSearch;
    }

    public String getMatchType() {
        return matchType;
    }

    public void setMatchType(String matchType) {
        this.matchType = matchType;
    }

    public String getSearchFields() {
        return searchFields;
    }

    public void setSearchFields(String searchFields) {
        this.searchFields = searchFields;
    }

    public boolean isSslpLimit() {
        return sslpLimit;
    }

    public void setSslpLimit(boolean sslpLimit) {
        this.sslpLimit = sslpLimit;
    }

    public boolean isHomologLimit() {
        return homologLimit;
    }

    public void setHomologLimit(boolean homologLimit) {
        this.homologLimit = homologLimit;
    }

    public String getOntType() {
        return ontType;
    }

    public void setOntType(String ontType) {
        this.ontType = ontType;
    }

    public String getOntValue() {
        return ontValue;
    }

    public void setOntValue(String ontValue) {
        this.ontValue = ontValue;
    }

    public String getOrder() {
        return order;
    }

    public void setOrder(String order) {
        this.order = order;
    }

    public int getHitsPerPage() {
        return hitsPerPage;
    }

    public void setHitsPerPage(int hitsPerPage) {
        this.hitsPerPage = hitsPerPage;
    }

    public String getPolyphenStatus() {
        return polyphenStatus;
    }

    public void setPolyphenStatus(String polyphenStatus) {
        this.polyphenStatus = polyphenStatus;
    }
    public String getSample() {
        return sample;
    }

    public void setSample(String sample) {
        this.sample = sample;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public boolean isRedirect() {
        return redirect;
    }

    public void setRedirect(boolean redirect) {
        this.redirect = redirect;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }

    public boolean isViewAll() {
        return viewAll;
    }

    public void setViewAll(boolean viewAll) {
        this.viewAll = viewAll;
    }

    private boolean viewAll;



    public String getTerm() {
        return term;
    }

    public void setTerm(String term) {
        this.term = term;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getSpecies() {
        return species;
    }

    public void setSpecies(String species) {
        this.species = species;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getSubCat() {
        return subCat;
    }

    public void setSubCat(String subCat) {
        this.subCat = subCat;
    }

    public int getFrom() {
        return from;
    }

    public void setFrom(int from) {
        this.from = from;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public boolean isPage() {
        return page;
    }

    public void setPage(boolean page) {
        this.page = page;
    }

    public String getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(String sortOrder) {
        this.sortOrder = sortOrder;
    }

    public String getSortBy() {
        return sortBy;
    }

    public void setSortBy(String sortBy) {
        this.sortBy = sortBy;
    }

    public String getAssembly() {
        return assembly;
    }

    public void setAssembly(String assembly) {
        this.assembly = assembly;
    }

    public String getTrait() {
        return trait;
    }

    public void setTrait(String trait) {
        this.trait = trait;
    }

    public String getStart() {
        return start;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public String getStop() {
        return stop;
    }

    public void setStop(String stop) {
        this.stop = stop;
    }

    public String getChr() {
        return chr;
    }

    public void setChr(String chr) {
        this.chr = chr;
    }

    public String getVariantCategory() {
        return variantCategory;
    }

    public void setVariantCategory(String variantCategory) {
        this.variantCategory = variantCategory;
    }
}