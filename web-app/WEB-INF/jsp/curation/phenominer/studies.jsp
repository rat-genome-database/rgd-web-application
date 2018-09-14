<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.process.Stamp" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%
    String pageTitle = "Studies";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">Phenominer Studies</span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='javascript:edit("studyId");'>Edit</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:editExperiments("studyId");'>Show Experiments</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:del("studyId")'>Delete</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:selectAll("studyId")'>Toggle All</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html?act=new'>Create New Study</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>

<form name="form1" action="studies.html" method="get">

<input type="hidden" name="act" value=""/>
<%
    Report report = (Report) request.getAttribute("report");

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");

    out.print(report.format(strat));

%>

</form>

<%@ include file="editFooter.jsp"%>
