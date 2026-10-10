<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>


<%
    String pageTitle = "References";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>
<span class="phenominerPageHeader">Select a Reference</span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>

<%

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");

    Report report = (Report) request.getAttribute("report");
    out.print(report.format(strat));


%>
<%@ include file="/common/footerarea.jsp"%>