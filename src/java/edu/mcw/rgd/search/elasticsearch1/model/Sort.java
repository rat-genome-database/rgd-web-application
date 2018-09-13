package edu.mcw.rgd.search.elasticsearch1.model;

/**
 * Created by jthota on 8/10/2017.
 */
public class Sort {
    private String sortBy;
    private String sortOrder;

    public Sort(String sortBy, String sortOrder){
        this.sortBy=sortBy;
        this.sortOrder=sortOrder;
    }
    public String getSortBy() {
        return sortBy;
    }

    public void setSortBy(String sortBy) {
        this.sortBy = sortBy;
    }

    public String getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(String sortOrder) {
        this.sortOrder = sortOrder;
    }
}
