<%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    String strainSymbol = request.getAttribute("strainSymbol").toString();
    response.setHeader("Content-disposition","attachment;filename=\""+strainSymbol+"damagingVariants.csv\"");
    Report report = (Report) request.getAttribute("report");
    out.println(report.format(new DelimitedReportStrategy()));
%>