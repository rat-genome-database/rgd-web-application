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

<link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css">

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Gene Search</div>
</div>
<div class="searchBox">
    <%=pageDescription%>
    <div class="searchExamples">
        <b>Example searches:</b> <a href="javascript:document.adSearch.term.value='A2m';document.adSearch.chr.value='0';document.adSearch.submit();" >A2m</a>,<a href="javascript:document.adSearch.term.value='2004';document.adSearch.chr.value='0';document.adSearch.submit();" >2004</a> <a href="javascript:document.adSearch.term.value='serine threonine kinase';document.adSearch.chr.value='0';document.adSearch.submit();" > serine threonine kinase</a>, <a href="javascript:document.adSearch.term.value='NM_012488';document.adSearch.chr.value='0';document.adSearch.submit();" >NM_012488</a>, <a href="javascript:document.adSearch.term.value='Adora2a';document.adSearch.chr.value='0';document.adSearch.submit();" >Adora2a</a>
    </div>
<br>


    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <%@ include file="advancedSearchForm.jsp"%>
        <input type="hidden" name="category" id="objectSearchCat" value="Gene" />
        <input type="hidden" name="objectSearch" value="true"/>
    </form>


</div>
<%@ include file="/common/footerarea.jsp"%>
