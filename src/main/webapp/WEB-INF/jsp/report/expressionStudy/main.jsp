<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 5/20/2025
  Time: 10:23 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%
    String title = "Expression Study";
    Study obj = (Study)request.getAttribute("reportObject");
    String pageTitle = "RGD Expression Study Report - " + obj.getName() + " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
    String pageHeader="Expression Study: " +(obj.getName()!=null?obj.getName():"");
%>
<html>
<script>
    let reportTitle = "Expression Study";
</script>
<body>
<div id="top" ></div>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<div id="page-container">
    <div id="left-side-wrap">
        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">
        <h1 style="width: 95%;font-size:20px; color:#2865A3; font-weight:700;"><%=pageHeader%></h1>
        <table>
            <tr>
                <td>
                    <br>
                   <%@ include file="info.jsp"%>
                </td>
            </tr>
        </table>
    </div>

</div>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>
</body>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>
</html>
