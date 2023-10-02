<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: Jun 13, 2008
  Time: 10:43:43 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
  <%
      response.setHeader("Content-disposition","attachment;filename=\"report.tab\"");
      Report report = (Report) request.getAttribute("report");
      DelimitedReportStrategy drs = new DelimitedReportStrategy();
      drs.setDelimiter("\t");
      out.println(report.format(drs));
  %>