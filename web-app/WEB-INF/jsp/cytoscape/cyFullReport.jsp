<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
     Report report = (Report) request.getAttribute("report");
%>
<html>
<head><title>Protein Interactions Report </title></head>
<body>
<img src='/common/images/rgd_LOGO_blue_rgd.gif'/><br><br>
<table>
    <tr>
        <td style="color:#2865a3; font-size:16px; font-style:italic; font-weight:700;">Protein Interactions Full Report of queried Proteins/Genes </td>
        <td>
            <form action="cy.html?d=true" method="post">
                <input type="hidden" name="identifiers" value='${model.query}'>
                <input type="hidden" name="species" value='${model.species}'>
                <input type="hidden" name="browser" value="12">
                <button>Download</button>
            </form>
        </td>
    </tr>
    <tr>
        <td colspan="2"><%=report.format(new HTMLTableReportStrategy())%></td>
    </tr>
</table>
<div style="padding:20px;">
    <form action="cy.html?d=true" method="post">
        <input type="hidden" name="identifiers" value='${model.query}'>
        <input type="hidden" name="species" value='${model.species}'>
        <input type="hidden" name="browser" value="12">
        <button>Download</button>
    </form>
</div>
</body>
</html>