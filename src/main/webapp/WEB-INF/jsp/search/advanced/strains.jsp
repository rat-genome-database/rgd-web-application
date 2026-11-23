
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Strain Search";
    String headContent = "";
    String pageDescription = "";

%>

<%@ include file="/common/headerarea.jsp"%>
<% boolean includeMapping = false; %>
<% String title="Strains"; %>

<link href="/rgdweb/css/searchForm.css" rel="stylesheet" type="text/css">

<%-- class "rsm" opts this page into the modern search form styling, see /rgdweb/css/searchForm.css --%>
<div class="rsm">
    <h1 class="rsm-title">Strain Search</h1>
    <p class="rsm-lead">Strain reports include a comprehensive description of strain origin, disease, phenotype, genetics, immunology, behavior with links to related genes, QTLs, sub-strains, and strain sources.</p>

    <div class="rsm-examples">
        <span class="rsm-examples-label">Try an example:</span>
        <button type="button" class="rsm-chip" data-term="fhl">fhl</button>
        <button type="button" class="rsm-chip" data-term="wild">wild</button>
        <button type="button" class="rsm-chip" data-term="Adora2a">Adora2a</button>
        <button type="button" class="rsm-chip" data-term="hypertension">hypertension</button>
        <button type="button" class="rsm-chip" data-term="d16rat31">d16rat31</button>
    </div>

    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <%@ include file="advancedSearchForm.jsp"%>
        <input type="hidden" name="category" id="objectSearchCat" value="Strain" />
    </form>

    <div class="rsm-links">
        <a class="rsm-link" href="/rgdweb/ontology/view.html?acc_id=RS:0000457">
            <span class="rsm-link-title">Browse all strains</span>
            <span class="rsm-link-text">Explore the Rat Strain Ontology</span>
        </a>
        <a class="rsm-link" href="/rgdweb/models/findModels.html">
            <span class="rsm-link-title">Find models <span class="rsm-badge">New</span></span>
            <span class="rsm-link-text">Search rat models by disease or phenotype</span>
        </a>
    </div>
</div>
<%@ include file="/common/footerarea.jsp"%>
