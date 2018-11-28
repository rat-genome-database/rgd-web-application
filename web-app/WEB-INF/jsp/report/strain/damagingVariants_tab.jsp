<%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %><%@ page contentType="text/plain;charset=UTF-8" language="java" %><%
    String strainSymbol = request.getAttribute("strainSymbol").toString();
    response.setHeader("Content-disposition","attachment;filename=\""+strainSymbol+"_damagingVariants.tab\"");
    Report report = (Report) request.getAttribute("report");
    DelimitedReportStrategy drs = new DelimitedReportStrategy();
    drs.setDelimiter("\t");
    out.println(report.format(drs));
%>