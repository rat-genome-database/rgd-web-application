<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% try {
    boolean includeMapping = true;
    String title = "Genes";
    String titleTerm = request.getParameter("term");

    if (titleTerm == null ) {
        titleTerm = "";
    }

    String pageTitle = titleTerm + " Gene Search Result";
    String headContent = "";
    String pageDescription = "Gene reports include a comprehensive description of function and biological process as well as disease, expression, regulation and phenotype information.";
    
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

<% }catch (Exception e) {
    e.printStackTrace();
   }
%>