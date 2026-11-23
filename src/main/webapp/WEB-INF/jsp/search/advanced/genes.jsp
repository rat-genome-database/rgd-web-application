<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Gene Search - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "Gene reports include a comprehensive description of function and biological process as well as disease, expression, regulation and phenotype information.";
    boolean includeMapping = true;
    String title="Genes";
%>
<%@ include file="/common/headerarea.jsp"%>

<link href="/rgdweb/css/searchForm.css" rel="stylesheet" type="text/css">

<%-- class "rsm" opts this page into the modern search form styling, see /rgdweb/css/searchForm.css --%>
<div class="rsm">
    <h1 class="rsm-title">Gene Search</h1>
    <p class="rsm-lead"><%=pageDescription%></p>

    <div class="rsm-examples">
        <span class="rsm-examples-label">Try an example:</span>
        <button type="button" class="rsm-chip" data-term="A2m">A2m</button>
        <button type="button" class="rsm-chip" data-term="2004">2004</button>
        <button type="button" class="rsm-chip" data-term="serine threonine kinase">serine threonine kinase</button>
        <button type="button" class="rsm-chip" data-term="NM_012488">NM_012488</button>
        <button type="button" class="rsm-chip" data-term="Adora2a">Adora2a</button>
    </div>

    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <%@ include file="advancedSearchForm.jsp"%>
        <input type="hidden" name="category" id="objectSearchCat" value="Gene" />
        <input type="hidden" name="objectSearch" value="true"/>
    </form>
</div>

<%@ include file="/common/footerarea.jsp"%>
