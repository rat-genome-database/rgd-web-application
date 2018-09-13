
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Marker Search (SSLP and SNP) - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "SSLP and SNP reports provide mapping data, primer information, and size variations among strains.";
    
%>

<%@ include file="/common/headerarea.jsp"%>

<% boolean includeMapping = true; %>
<% String title="Markers"; %>

<div class="searchBox">
<h2>Marker Search</h2>
SSLP and SNP reports provide mapping data, primer information, and size variations among strains.
<% if( !RgdContext.isChinchilla(request) ) { %>
    <!--a href="/wg/searchHelp">(Search Help)</a--><br>
<% } %>

<!--form name="adSearch" action="markers.html"-->
    <form name="adSearch" action="/rgdweb/elasticResults.html">

        <div class="searchExamples">

            <b>Example searches:</b> <a href="javascript:document.adSearch.term.value='d16rat31';document.adSearch.chr.value='0';document.adSearch.submit();" >d16rat31</a>, <a href="javascript:document.adSearch.term.value='36199';document.adSearch.chr.value='0';document.adSearch.submit();" > 36199</a>,<a href="javascript:document.adSearch.term.value='D5Rhw';document.adSearch.chr.value='0';document.adSearch.submit();" >D5Rhw</a>, <a href="javascript:document.adSearch.term.value='oxsts7961';document.adSearch.chr.value='0';document.adSearch.submit();" >oxsts7961</a>
                </div>
    <br>

<%@ include file="advancedSearchForm.jsp"%> 

    <!--input type="hidden" name="obj" value="marker" /-->
        <input type="hidden" name="category" id="objectSearchCat" value="SSLP" />
        <input type="hidden" name="objectSearch" value="true"/>

</form>
<% if( !RgdContext.isChinchilla(request) ) { %>
    <a href="/objectSearch/sslpQuery.jsp">Switch to classic marker search</a> <br>
    <a href="/wg/searchHelp">View all search features</a>
<% } %>
</div>
<%@ include file="/common/footerarea.jsp"%>
