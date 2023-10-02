<%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    String geneSymbol = request.getAttribute("geneSymbol").toString();
    response.setHeader("Content-disposition","attachment;filename=\""+geneSymbol+"_mirna_targets.csv\"");
    Report report = (Report) request.getAttribute("report");
    out.println(report.format(new DelimitedReportStrategy()));
  %>