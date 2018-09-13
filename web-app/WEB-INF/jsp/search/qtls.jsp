<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <% boolean includeMapping = true; %>
  <% String title = "QTLs"; %>
<%
    String titleTerm = request.getParameter("term");

    if (titleTerm == null ) {
        titleTerm = "";
    }

    String pageTitle = titleTerm + " QTL (quantitative trait loci) Search Result - Rat Genome Database ";
    String headContent = "";
    String pageDescription = "QTL reports provide phenotype and disease descriptions, mapping, and strain information as well as links to markers and candidate genes.";
    
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="reportHeader.jsp"%>

  <%
      SearchReportStrategy strat = new SearchReportStrategy();
      strat.hideColumn(0);
      strat.setTableProperties("border='0' cellpadding='2' cellspacing='2' width=100%");
      strat.setHighlightedTerms(search.getRequired());

      out.println(report.format(strat));
  %>

<%@ include file="reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>
