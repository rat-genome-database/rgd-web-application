<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.dao.impl.ReportDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>


<%
    String pageTitle = "Experiments";
    String headContent = "";
    String pageDescription = "";
%>


<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">View Experiments</span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='javascript:edit("expId");'>Edit</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:editExperimentRecords("expId");'>Show Records</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:del("expId")'>Delete</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:selectAll("expId")'>Toggle All</a></td>


        <% if (!req.getParameter("act").equals("search") && (req.getParameter("studyId") != null && req.getParameterValues("studyId").size() == 1)) { %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
            <td><a href='experiments.html?act=new&studyId=<%=req.getParameter("studyId")%>'>Create New Experiment</a></td>
        <% } %>

        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html'>Search</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>


<form name="form1" action="experiments.html" method="get">

<input type="hidden" name="act" value=""/>
    <% if (req.getParameter("studyId") != null && req.getParameterValues("studyId").size() == 1) {%>
        <input type="hidden" name="studyId" value="<%=req.getParameter("studyId")%>"/>
    <% } %>
<%

    Report report = (Report) request.getAttribute("report");

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("width='75%' class='sortable'");


    out.print(report.format(strat));
%>

</form>    

<%@ include file="editFooter.jsp"%>
