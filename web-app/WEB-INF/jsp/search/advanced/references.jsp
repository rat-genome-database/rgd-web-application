
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

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Reference Search</div>
</div>


<div class="searchBox">

Reference reports provide full citations, abstracts, and links to Pubmed. <!--a href="/wg/searchHelp">(Search Help)</a--><br>


<!--form name="adSearch" action="references.html"-->
    <form name="adSearch" action="/rgdweb/elasticResults.html">
        <div class="searchExamples">

            <b>Example searches:</b> <a href="javascript:document.adSearch.term.value='jacobsen 2004';document.adSearch.submit();" >jacobsen 2004</a>, <a href="javascript:document.adSearch.term.value='obesity smith nat genet';document.adSearch.submit();" >obesity smith nat genet</a>, <a href="javascript:document.adSearch.term.value='cardiomyopathy';document.adSearch.submit();" >cardiomyopathy</a>
                </div>
            <br>
 <%@ include file="advancedSearchForm.jsp"%>
    <!--input type="hidden" name="obj" value="reference" /-->
        <input type="hidden" name="category" id="objectSearchCat" value="Reference" />


</form>
    <a href="/references/">Switch to classic reference search</a><br>
    <!--a href="/wg/searchHelp">View all search features</a-->
</div>
<%@ include file="/common/footerarea.jsp"%>
