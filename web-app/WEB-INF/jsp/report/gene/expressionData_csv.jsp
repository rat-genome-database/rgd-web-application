<%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    String geneSymbol = request.getAttribute("geneSymbol").toString();
    String tissueId = request.getParameter("tissueId");
    response.setHeader("Content-disposition","attachment;filename=\""+geneSymbol+"_"+tissueId+"expressionData.csv\"");
    Report report = (Report) request.getAttribute("report");
    out.println(report.format(new DelimitedReportStrategy()));
%>