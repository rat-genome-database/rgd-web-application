
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

<link href="/rgdweb/css/searchForm.css" rel="stylesheet" type="text/css">

<%-- class "rsm" opts this page into the modern search form styling, see /rgdweb/css/searchForm.css --%>
<div class="rsm">
    <h1 class="rsm-title">Marker Search</h1>
    <p class="rsm-lead"><%=pageDescription%></p>

    <div class="rsm-examples">
        <span class="rsm-examples-label">Try an example:</span>
        <button type="button" class="rsm-chip" data-term="d16rat31">d16rat31</button>
        <button type="button" class="rsm-chip" data-term="36199">36199</button>
        <button type="button" class="rsm-chip" data-term="D5Rhw">D5Rhw</button>
        <button type="button" class="rsm-chip" data-term="oxsts7961">oxsts7961</button>
    </div>

    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <%@ include file="advancedSearchForm.jsp"%>
        <input type="hidden" name="category" id="objectSearchCat" value="SSLP" />
        <input type="hidden" name="objectSearch" value="true"/>
    </form>
</div>
<%@ include file="/common/footerarea.jsp"%>
