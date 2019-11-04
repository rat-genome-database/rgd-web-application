<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String geneSymbol = request.getAttribute("geneSymbol").toString();
    String title = "Expression Data Report for gene "+geneSymbol;
    String pageDescription = title;
    String headContent = "";
    String pageTitle = title;




    Report report = (Report) request.getAttribute("report");
    int geneId = (int) request.getAttribute("geneId");
    String level = request.getParameter("level");
    String tissueId = request.getParameter("tissue");
%>
<%@ include file="/common/compactHeaderArea.jsp" %>
<div class="container-fluid" style="background-color: white ">

<table style="margin: 2%">
     <tr>
        <td style="color:#2865a3; font-size:16px; font-style:italic; font-weight:700;"><%=title%></td>
         </tr>
    <tr>
        <td><span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=geneId%>&fmt=csv&level=<%=level%>&tissue=<%=tissueId%>">Download Expression Data</a></span></td>

    </tr>
    <tr>
        <td colspan="2"><%=report.format(new HTMLTableReportStrategy())%></td>
    </tr>
</table>
</div>

