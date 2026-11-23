<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 1/9/2024
  Time: 12:33 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String pageTitle = "Variant Search - " + RgdContext.getLongSiteName(request);
  String headContent = "";
  String pageDescription = "Variant reports include a comprehensive description of function and biological process as well as disease, expression, regulation and phenotype information.";
  boolean includeMapping = true;
  String title="Variants";
%>
<%@ include file="/common/headerarea.jsp"%>

<link href="/rgdweb/css/searchForm.css" rel="stylesheet" type="text/css">

<%-- class "rsm" opts this page into the modern search form styling, see /rgdweb/css/searchForm.css --%>
<div class="rsm">
  <h1 class="rsm-title">Variant Search</h1>
  <p class="rsm-lead"><%=pageDescription%></p>

  <div class="rsm-examples">
    <span class="rsm-examples-label">Try an example:</span>
    <button type="button" class="rsm-chip" data-term="rs8154608">rs8154608</button>
    <button type="button" class="rsm-chip" data-term="RGD:9692267">RGD:9692267</button>
    <button type="button" class="rsm-chip" data-term="A2m">A2m</button>
    <button type="button" class="rsm-chip" data-term="lepr">lepr</button>
    <button type="button" class="rsm-chip" data-term="Adora2a">Adora2a</button>
  </div>

  <form name="adSearch" action="/rgdweb/elasticResults.html">
    <%@ include file="advancedSearchForm.jsp"%>
    <input type="hidden" name="category" id="objectSearchCat" value="Variant" />
    <input type="hidden" name="objectSearch" value="true"/>
  </form>
</div>
<%@ include file="/common/footerarea.jsp"%>
