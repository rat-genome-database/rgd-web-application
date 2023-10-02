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
  <% boolean includeMapping = false; %>
  <% String title = "Strains"; %>
<%
    String titleTerm = request.getParameter("term");

    if (titleTerm == null ) {
        titleTerm = "";
    }

    String pageTitle = titleTerm + " Strain Search Result - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "Strain reports include a comprehensive description of strain origin, disease, phenotype, genetics, immunology, behavior with links to related genes, QTLs, sub-strains, and strain sources.";
    
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="reportHeader.jsp"%>
  
  <%
    try {
      SearchReportStrategy strat = new SearchReportStrategy();
      strat.hideColumn(0);
      strat.setTableProperties("border='0' cellpadding='2' cellspacing='2' width=100%");
      strat.setHighlightedTerms(search.getRequired());

      out.println(report.format(strat));

    }catch (Exception e) {
        e.printStackTrace();
    }
  %>

<%@ include file="reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>
