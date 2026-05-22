<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.search.elasticsearch1.model.SearchBean" %>
<%
    SearchBean searchBean = (SearchBean) request.getAttribute("searchBean");
    String pageTitle = "Assembly " + searchBean.getAssembly() + " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<script type="text/javascript" src="/rgdweb/js/elasticsearch/elasticsearch.js"></script>
<script src="/rgdweb/js/elasticsearch/searchFilterTree.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/jstree.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/themes/default/style.min.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css" integrity="sha384-/Y6pD6FV/Vv2HJnA6t+vslU6fwYXjCFtcEpHbNJ0lyAFsXTsjBbfaDjzALeQsN6M" crossorigin="anonymous">
<style>
    em { background-color: yellow; }
</style>
<div class="container-fluid">
<div style="width:100%;background-color:white">
    <div style="background-color:white;">
        <input type="hidden" value="${model.term}" id="searchTerm" name="term"/>
        <input type="hidden" value="${model.searchBean.category}" id="searchCategory" name="category"/>
        <input type="hidden" name="cat1" id="cat1" value="${model.cat1}">
        <input type="hidden" name="sp1" id="sp1" value="${model.sp1}">
        <input type="hidden" name="type" id="type">
        <input type="hidden" name="filter" id="filter">
        <input type="hidden" name="subCat" id="subCat" value="${model.searchBean.subCat}">
        <input type="hidden" name="start" id="start" value="${model.searchBean.start}"/>
        <input type="hidden" name="stop" id="stop" value="${model.searchBean.stop}"/>
        <input type="hidden" name="chr" id="chr" value="${model.searchBean.chr}"/>
        <input type="hidden" name="match_type" id="match_type" value="${model.searchBean.matchType}"/>
        <input type="hidden" id="species" name="species" value="${model.searchBean.species}"/>
        <input type="hidden" id="objectAssembly" name="objectAssembly" value="${model.searchBean.assembly}"/>

        <div class="views" style="float:right;">
            <a href="javascript:history.back()"><span style="font-size: 15px;font-weight: bold;padding:10px"><i class="fa fa-arrow-left" aria-hidden="true" style="color:green"></i>&nbsp;Back to Search Results</span></a>
        </div>
    </div>

    <div class="headContent" style="background-color: white">
        <h2><span style="color:#24609c">${model.searchBean.category}</span> results for <span style="color:#24609c">${model.searchBean.species}</span> &mdash; Assembly <span style="color:#24609c">${model.searchBean.assembly}</span></h2>
        <c:if test="${not empty model.term and model.term ne ''}">
            <h4>Search term: "<span style="color:#24609c">${model.term}</span>"</h4>
        </c:if>
        <%@include file="resultHeader.jsp"%>
    </div>
    <hr>

    <c:if test="${model.totalHits>0}">
        <div>
            <table id="contentTable" width="100%">
                <tr>
                    <td style="width:20%;vertical-align:top">
                        <div class="sidebarFilters" style="background-color: white;overflow: auto;overflow-y: hidden;">
                            <jsp:include page="facets/assemblySidebar.jsp"/>
                        </div>
                    </td>
                    <td style="vertical-align:top">
                        <div class="mainContent" style="background-color: white">
                            <jsp:include page="content.jsp"/>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </c:if>
    <c:if test="${model.totalHits==0 or empty model.totalHits}">
        <div style="padding:20px"><em>No ${fn:toLowerCase(model.searchBean.category)} results found for this assembly.</em></div>
    </c:if>
</div>
</div>
<%@ include file="/common/footerarea.jsp"%>
