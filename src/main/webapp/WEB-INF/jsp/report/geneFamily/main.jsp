<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="edu.mcw.rgd.datamodel.HgncFamily" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.List" %>

<%@ include file="../dao.jsp"%>

<%
    HgncFamily obj = (HgncFamily) request.getAttribute("reportObject");
    List<Gene> familyGenes = (List<Gene>) request.getAttribute("familyGenes");

    String title = "HGNC Gene Family";
    String pageTitle = obj.getName() + " - HGNC Gene Family Report - Rat Genome Database";
    String headContent = "";
    String pageDescription = "RGD report page for HGNC gene family: " + obj.getName();
    String pageHeader = "HGNC Gene Family: " + obj.getName();
%>

<html>
<script>
    let reportTitle = "HGNC Gene Family";
</script>
<body>
<style>
    html{
        scroll-behavior: smooth;
    }
</style>
<div id="top" ></div>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<div id="page-container">
    <div id="left-side-wrap">
        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">
        <h1 style="width: 95%;font-size:20px; color:#2865A3; font-weight:700;"><%=pageHeader%></h1>
        <table style="width:95%;border: none">
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
