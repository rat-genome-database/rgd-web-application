<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "QTL (quantitative trait loci) Search - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "QTL reports provide phenotype and disease descriptions, mapping, and strain information as well as links to markers and candidate genes.";
    boolean includeMapping = true;
    String title="QTLs";
%>

<%@ include file="/common/headerarea.jsp"%>
 <script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<link href="/rgdweb/css/searchForm.css" rel="stylesheet" type="text/css">

<%-- class "rsm" opts this page into the modern search form styling, see /rgdweb/css/searchForm.css --%>
<div class="rsm">
    <h1 class="rsm-title">QTL Search</h1>
    <p class="rsm-lead"><%=pageDescription%></p>

    <div class="rsm-examples">
        <span class="rsm-examples-label">Try an example:</span>
        <button type="button" class="rsm-chip" data-term="Mcs">Mcs</button>
        <button type="button" class="rsm-chip" data-term="61387">61387</button>
        <button type="button" class="rsm-chip" data-term="renal function">renal function</button>
        <button type="button" class="rsm-chip" data-term="bp1">bp1</button>
    </div>

    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <%@ include file="advancedSearchForm.jsp"%>
        <input type="hidden" name="category"  value="QTL" />
        <input type="hidden" name="objectSearch" value="true"/>
    </form>
</div>
<%@ include file="/common/footerarea.jsp"%>
