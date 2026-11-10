<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  The results action bar. Styles live in css/elasticsearch/elasticsearch.css under .search-actions,
  which headerarea.jsp already loads on every page.

  There is no "Go To Page" box any more. Paging is from/size against Elasticsearch, which refuses
  anything past index.max_result_window (10,000 by default), so most of the page numbers a jump box
  invites you to type could not be served - and on a search with more hits than that, the page you
  want is rarely the one you can name. Narrow the search with the facets instead.
--%>
<div class="search-actions">

    <input type="hidden" value="${empty model.searchBean.assembly ? 'all' : model.searchBean.assembly}" id="objectAssembly"/>
    <input type="hidden" id="objectSearch" value="${model.objectSearch}"/>

    <%-- Sorting is on symbol, which ontology, reference and variant results are not listed by.
         This was two identical selects in a c:choose - one for "not general and not the three",
         one for "general" - which is the single condition below. --%>
    <c:set var="category" value="${model.searchBean.category}"/>
    <c:if test="${!category.equalsIgnoreCase('Ontology') && !category.equalsIgnoreCase('Reference') && !category.equalsIgnoreCase('Variant')}">
        <div class="search-actions__field">
            <label for="sortBy">Sort By</label>
            <select class="sortSelect" id="sortBy" onchange="sortFunction('change',this.value)">
                <option selected="selected" value="0">Relevance</option>
                <option value="1">Symbol - ASC</option>
                <option value="2">Symbol - DESC</option>
                <!--option value="3">Chromosome - ASC</option>
                <option value="4">Chromosome - DESC</option>
                <option value="5">Start Position - ASC</option>
                <option value="6">Start Position - DESC</option>
                <option value="7">Stop Position - ASC</option>
                <option value="8">Stop Position - DESC</option-->
            </select>
        </div>
    </c:if>

    <div class="search-actions__field">
        <label for="pageSize">View Results</label>
        <select class="pageSize" id="pageSize" name="pageSize" onchange="pagesizeFunction('change', 'pageSize', this.value)">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="30">30</option>
            <option value="40">40</option>
            <option selected="selected" value="50">50</option>
            <option value="100">100</option>
            <option value="500">500</option>
        </select>
    </div>

    <div class="search-actions__pager">
        <div class="search-actions__pagerow">
            <span class="search-actions__pageinfo">
                Page <span id="currentPage">${model.searchBean.currentPage}</span> of <span id="totalPages">${model.totalPages}</span>
            </span>
            <button type="button" id="prev" class="search-actions__nav"
                    onclick="prevFunction('click', 'prev')"
                    title="Previous page" aria-label="Previous page">&#10094;</button>
            <button type="button" id="next" class="search-actions__nav"
                    onclick="nextFunction('click','next', '${model.searchBean.currentPage}', '${model.totalPages}', $('#pageSize').find('option:selected'))"
                    title="Next page" aria-label="Next page">&#10095;</button>
        </div>
        <%-- Only when the hits run past what Elasticsearch will page through. Without this the
             pager just stops, with no way to tell a short result set from a truncated one. --%>
        <c:if test="${model.allPages > model.totalPages}">

            <span class="search-actions__pagenote"
                  title="Only the first ${model.maxResultWindow} results of a search can be paged through.">
                Showing ${model.totalPages} of ${model.allPages} pages &mdash; narrow the search to reach the rest
            </span>
        </c:if>
    </div>

</div>
