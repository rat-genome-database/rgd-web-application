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
%>

<%@ include file="/common/headerarea.jsp"%>

<div class="searchBox">
<h2>Cell Line Directory</h2>
All cell lines available in RGD:<br><br>

<table border=1 cellspacing=0 cellpadding=10 style="background-color:white;">
  <tr><td>
    <table border='0' >
        <%=new HTMLTableReportStrategy().format(report)%>
    </table>
  </td></tr>
</table>

</div>
<%@ include file="/common/footerarea.jsp"%>
