<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 1/16/2024
  Time: 3:59 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.process.Stamp" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%
    Report report = (Report) request.getAttribute("report");
    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");
    out.print(report.format(strat));
 %>

