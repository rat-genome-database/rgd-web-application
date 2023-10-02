<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% try { %>

<%  boolean includeMapping = true;
    String title = "Promoters, Cell Lines";
    String titleTerm = request.getParameter("term");
    if (titleTerm == null ) {
        titleTerm = "";
    }

    String pageTitle = titleTerm + " Promoters, Cell Lines Search Result - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "Promoters, Cell Line reports ....";
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