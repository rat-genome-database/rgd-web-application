package edu.mcw.rgd.nomenclatureinterface;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jan 22, 2008
 * Time: 2:19:35 PM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Search result object returned from the NomenclatureManager to the nomenclature interface.
 */
public class SearchResult {

    private List nomenclatureResultBeans = new ArrayList();
    private int totalCount;
    private int page;
    private int pageSize;

    /**
     * Returns the next page number.  If at the last page, last page number is returned
     * @return
     */
    public int getNextPage() {
        if (page + 1 > getTotalPages()) {
            return page;
        }else {
            return page + 1;
        }
    }

    /**
     * Returns the previous page number.  If at the first page, first page number is returned
     * @return
     */
    public int getPreviousePage() {
        if (page - 1 < 1) {
            return page;
        }else {
            return page - 1;    
        }
    }

    /**
     * Returns the row index of the start of the current page.
     * @return
     */
    public int getStartIndex() {
        return (page * pageSize) - 9;
    }

    /**
     * Returns the row index of the end of the current page.
     * @return
     */
    public int getEndIndex() {
        if ((page * pageSize) > this.getTotalCount()) {
            return this.getTotalCount();    
        }else {
            return (page * pageSize);
        }
    }

    /**
     * Returns the total amound of pages available
     * @return
     */
    public int getTotalPages() {
        return (int) ((pageSize-1+totalCount)/ pageSize);
    }

    /**
     * Returns the current page number
     * @return
     */
    public int getPage() {
        return page;
    }

    /**
     * Sets the current page number
     * @param page
     */
    public void setPage(int page) {
        this.page = page;
    }

    /**
     * Returns the number of rows contained in each page
     * @return
     */
    public int getPageSize() {
        return pageSize;
    }

    /**
     * Sets the number of rows contained in each page
     * @return
     */
    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    /**
     * returns the total row count returned by the search
     * @return
     */
    public int getTotalCount() {
        return totalCount;
    }

    /**
     * Sets the total row count returned by the search
     * @return
     */
    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    /**
     * Returs a list of nomenclature result beans.  Max size for the list is getPageSize()
     *
     * Each NomenclatureResultBean contains information for one search result
     * @return
     */
    public List getNomenclatureResultBeans() {
        return nomenclatureResultBeans;
    }

    /**
     * Sets the nomenclature search result list
     *
     * @param nomenclatureResultBeans
     */
    public void setNomenclatureResultBeans(List nomenclatureResultBeans) {
        this.nomenclatureResultBeans = nomenclatureResultBeans;
    }
}
