<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Cell Lines in RGD";
    String headContent = "";
    String pageDescription = "";
    boolean includeMapping = false;
    String title="Cell Lines";
    Report report = (Report) request.getAttribute("report");
    int pageNr = (Integer) request.getAttribute("pageNr");
    int pageSize = (Integer) request.getAttribute("pageSize");
%>

<%@ include file="/common/headerarea.jsp"%>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Cell Line Directory</div>
</div>

<div class="searchBox">

All cell lines available in RGD:<br><br>

<table border=1 cellspacing=0 cellpadding=10 style="background-color:white;">
  <tr><td>
    <table border='0' >
        <%=new HTMLTableReportStrategy().format(report)%>
    </table>
  </td></tr>

  <tr><td><table width="600" cellspacing="0" cellpadding="0"><tr><td align="right">
      <% if( pageNr>1 ) { %><a href="cellLines.html?p=<%=pageNr-1%>">Previous Page</a> &nbsp; &nbsp; <% } %>
      Page <%=pageNr%> &nbsp; &nbsp;
      <% if( report.records.size()>0 ) { %><a href="cellLines.html?p=<%=pageNr+1%>">Next Page</a> &nbsp; &nbsp; <% } %>
   </td></tr></table></td></tr>
</table>

</div>
<%@ include file="/common/footerarea.jsp"%>
