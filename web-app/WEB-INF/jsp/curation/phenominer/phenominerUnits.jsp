<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%
    String pageTitle = "Phenominer Units";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">Phenominer Units</span>

<div class="phenoNavBar">
    <table >

    </table>
</div>

<form name="form1" action="phenominerUnits.html" method="get">

    <input type="hidden" name="act" value=""/>
    <%
        Report report = (Report) request.getAttribute("report");

        HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
        strat.setTableProperties("class='sortable'");

        out.print(report.format(strat));

    %>

</form>

<%@ include file="editFooter.jsp"%>
