
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Reference Search - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "Reference reports provide full citations, abstracts, and links to Pubmed.";

%>

<%@ include file="/common/headerarea.jsp"%>
<% boolean includeMapping = false; %>
<% String title="References"; %>

<link href="/rgdweb/css/searchForm.css" rel="stylesheet" type="text/css">

<%-- class "rsm" opts this page into the modern search form styling, see /rgdweb/css/searchForm.css --%>
<div class="rsm">
    <h1 class="rsm-title">Reference Search</h1>
    <p class="rsm-lead"><%=pageDescription%></p>

    <div class="rsm-examples">
        <span class="rsm-examples-label">Try an example:</span>
        <button type="button" class="rsm-chip" data-term="jacobsen 2004">jacobsen 2004</button>
        <button type="button" class="rsm-chip" data-term="obesity smith nat genet">obesity smith nat genet</button>
        <button type="button" class="rsm-chip" data-term="cardiomyopathy">cardiomyopathy</button>
    </div>

    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <%@ include file="advancedSearchForm.jsp"%>
        <input type="hidden" name="category" id="objectSearchCat" value="Reference" />
    </form>
</div>
<%@ include file="/common/footerarea.jsp"%>
