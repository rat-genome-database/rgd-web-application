<%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    String sample = request.getAttribute("sample").toString();
    response.setHeader("Content-disposition","attachment;filename=\""+sample+"damagingVariants.csv\"");
    Report report = (Report) request.getAttribute("report");
    out.println(report.format(new DelimitedReportStrategy()));
%>