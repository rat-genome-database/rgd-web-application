package edu.mcw.rgd.search.elasticsearch1.model;

public class GeneSearchBean extends SearchBean {

    String matchType;//:equals
    String searchFields;//:all_with_aliases
    boolean sslpLimit;//:no
    boolean homologLimit;//:no
    String ontType;//:GO
    String ontValue;
    String order;//:symbol
    int hitsPerPage;//:25

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
}
