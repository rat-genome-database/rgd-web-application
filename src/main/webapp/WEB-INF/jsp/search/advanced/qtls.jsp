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


 <div class="rgd-panel rgd-panel-default">
     <div class="rgd-panel-heading">QTL Search</div>
 </div>


 <div class="searchBox">
     <%=pageDescription%>

     <div class="searchExamples">
        <b>Example searches:</b>
        <a href="javascript:document.adSearch.term.value='Mcs';document.adSearch.chr.value='0';document.adSearch.submit();" >Mcs</a>,
        <a href="javascript:document.adSearch.term.value='61387';document.adSearch.chr.value='0';document.adSearch.submit();" >61387</a>,
        <a href="javascript:document.adSearch.term.value='renal function';document.adSearch.chr.value='0';document.adSearch.submit();" >renal function</a>,
        <a href="javascript:document.adSearch.term.value='bp1';document.adSearch.chr.value='0';document.adSearch.submit();" >bp1</a>,

    </div>
    <br>
        <form name="adSearch" action="/rgdweb/elasticResults.html">

            <%@ include file="advancedSearchForm.jsp"%>
            <input type="hidden" name="category"  value="QTL" />
            <input type="hidden" name="objectSearch" value="true"/>

        </form>
</div>
<%@ include file="/common/footerarea.jsp"%>
