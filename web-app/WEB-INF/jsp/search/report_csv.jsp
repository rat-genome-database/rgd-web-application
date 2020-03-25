<%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%

    response.setHeader("Content-disposition","attachment;filename=\"SearchReport.csv\"");
    Report report =  (Report)request.getAttribute("report");
    out.println(report.format(new DelimitedReportStrategy()));
%>