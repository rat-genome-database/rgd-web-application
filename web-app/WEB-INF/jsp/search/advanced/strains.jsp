
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

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Strain Search</div>
</div>


<div class="searchBox">

    Strain reports include a comprehensive description of strain origin, disease, phenotype, genetics, immunology, behavior with links to related genes, QTLs, sub-strains, and strain sources. <!--a href="/wg/searchHelp">(Search Help)</a--><br>


<!--form name="adSearch" action="strains.html"-->
    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <div class="searchExamples">

            <b>Example searches:</b> <a href="javascript:document.adSearch.term.value='fhl';document.adSearch.submit();" >fhl</a>,
            <a href="javascript:document.adSearch.term.value='wild';document.adSearch.submit();" > wild</a>,
             <a href="javascript:document.adSearch.term.value='Adora2a';document.adSearch.submit();" >Adora2a</a>,
            <a href="javascript:document.adSearch.term.value=' hypertension';document.adSearch.submit();" > hypertension</a>,
            <a href="javascript:document.adSearch.term.value='d16rat31';document.adSearch.submit();" >d16rat31</a>
                </div>
       <br>
    <%@ include file="advancedSearchForm.jsp"%>
    <!--input type="hidden" name="obj" value="strain" /-->
        <input type="hidden" name="category" id="objectSearchCat" value="Strain" />


</form>
    <a href="/rgdweb/models/findModels.html" style="font-weight: bold">Find Models by Disease or Phenotype </a>&nbsp;&nbsp;&nbsp;<span style="color:red;font-weight: bold">new</span> <br><br>
    <a href="/strains/">Switch to classic strain search</a><br>
    <!--a href="/wg/searchHelp">View all search features</a-->
    
</div>
<%@ include file="/common/footerarea.jsp"%>
