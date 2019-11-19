<%@ page import="
    edu.mcw.rgd.reporting.Report
    ,edu.mcw.rgd.reporting.DelimitedReportStrategy
"%><%
    response.setHeader("Content-Type", "text/tab");
    response.setHeader("Content-Disposition","attachment; filename=" + "interactions.txt" );

    Report report = (Report) request.getAttribute("report");
    DelimitedReportStrategy strategy = new DelimitedReportStrategy();
    strategy.setDelimiter("\t");
    out.print(report.format(strategy));
%>