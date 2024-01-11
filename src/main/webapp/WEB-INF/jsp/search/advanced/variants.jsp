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

<link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css">

<div class="rgd-panel rgd-panel-default">
  <div class="rgd-panel-heading">Variant Search</div>
</div>
<div class="searchBox">
  <%=pageDescription%>
  <div class="searchExamples">
    <b>Example searches:</b> <a href="javascript:document.adSearch.term.value='A2m';document.adSearch.chr.value='0';document.adSearch.submit();" >A2m</a>,<a href="javascript:document.adSearch.term.value='2004';document.adSearch.chr.value='0';document.adSearch.submit();" >2004</a>,<a href="javascript:document.adSearch.term.value='lepr';document.adSearch.chr.value='0';document.adSearch.submit();" >lepr</a>, <a href="javascript:document.adSearch.term.value='leprot';document.adSearch.chr.value='0';document.adSearch.submit();" >leprot</a>, <a href="javascript:document.adSearch.term.value='Adora2a';document.adSearch.chr.value='0';document.adSearch.submit();" >Adora2a</a>
  </div>
  <br>


  <form name="adSearch" action="/rgdweb/elasticResults.html">
    <%@ include file="advancedSearchForm.jsp"%>
    <input type="hidden" name="category" id="objectSearchCat" value="Variant" />
    <input type="hidden" name="objectSearch" value="true"/>
  </form>


</div>
<%@ include file="/common/footerarea.jsp"%>
