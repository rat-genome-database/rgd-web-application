<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>

<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>


<%
    String pageTitle = "Records";
    String headContent = "";
    String pageDescription = "";
%>


<%@ include file="editHeader.jsp"%>
<span class="phenominerPageHeader">View Records</span>

<style>
    .phenominerNavBar {
        background-color:#1E392A;
        color:white;
        margin-top:10px;
        padding:5px;
        margin-bottom:10px;
    }
    .phenominerNavBar a{
        color:white;
        text-decoration: none;
        font-weight:700;
        margin-left:20px;
    }
</style>


<div class="phenominerNavBar">
<table >
    <tr>
        <td><a href='javascript:edit("id");'>Edit</a></td>
        <td><a href='javascript:selectAll("id")'>Toggle All</a></td>

        <% if (!req.getParameter("act").equals("search") && (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1)) { %>
            <td><a href='javascript:create("id")'>Create New Record</a></td>
        <% } %>
        
        <td><a href='home.html'>Home</a></td>
        <td><a href='search.html'>Search</a></td>
        <% if (req.getParameter("studyId") != null && req.getParameter("studyId").length() > 0) { %>
        <td><a href="experiments.html?studyId=<%=req.getParameter("studyId")%>">All Experiments</a></td>
        <td><a href="records.html?act=editSS&expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">Edit All
            Records</a></td>
        <% } %>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>

<form name="form1" action="records.html" method="get">

<input type="hidden" name="act" value=""/>
<% if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) {%>
    <input type="hidden" name="expId" value="<%=req.getParameter("expId")%>"/>
<% } %>
<% if (req.getParameter("studyId") != null && req.getParameterValues("studyId").size() == 1) {%>
    <input type="hidden" name="studyId" value="<%=req.getParameter("studyId")%>"/>
<% } %>

<%

    Report report = (Report) request.getAttribute("report");

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");

    
    out.print(report.format(strat));


%>




    </form>
<%@ include file="editFooter.jsp"%>
