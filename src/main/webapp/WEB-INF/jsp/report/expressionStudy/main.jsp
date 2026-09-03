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
    let objectId="<%=obj.getId()%>";
</script>
<body>
<style>
    html{
        scroll-behavior: smooth;
    }
</style>
<%
    // Check whether downloadable data/metadata exists for this study on the RGD download site.
    // Only render the row when the GEO series directory actually responds OK.
    String downloadUrl = null;
    boolean downloadAvailable = false;
    if(obj.getId()==3714){
        downloadUrl = "https://download.rgd.mcw.edu/expression/HRDP/";
        downloadAvailable = true;
    }
    else if(obj.getGeoSeriesAcc()!=null && !obj.getGeoSeriesAcc().isEmpty()){
        downloadUrl = "https://download.rgd.mcw.edu/expression/" + obj.getGeoSeriesAcc() + "/";
        try {
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) new java.net.URL(downloadUrl).openConnection();
            conn.setRequestMethod("HEAD");
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(3000);
            conn.setInstanceFollowRedirects(true);
            int code = conn.getResponseCode();
            downloadAvailable = (code >= 200 && code < 400);
            conn.disconnect();
        } catch (Exception ex) {
            downloadAvailable = false;
        }
    }
%>
<div id="top" ></div>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<div id="page-container" class="<%=reportSkinClass%>">
    <div id="left-side-wrap">
        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">

        <%
            heroEyebrow = "Expression Study Report";
            heroTitle = Utils.NVL(obj.getName(), "");
            heroTitleClass = "report-hero-title--long";
            heroShortName = "Study " + obj.getId();
            heroIcon = "fa-bar-chart";
            heroWatch = false;
        %>
        <%@ include file="../reportHero.jsp"%>

        <table style="width:95%;border: none">
            <tr>
                <td>
                    <br>
                   <%@ include file="info.jsp"%>
                    <%@ include file="sampleMetadata.jsp"%>

<%--                    <%@include file="expressionValues_heatmap.jsp"%>--%>
<%--                    <%@include file="expressionValues_dot_chatjs.jsp"%>--%>

<%--                    <%@include file="dotPlot.jsp"%>--%>
                    <%@include file="chromosomeTPMPlot.jsp"%>
                    <%@include file="genomeBrowser.jsp"%>

                    <% if (downloadAvailable) { %>
                    <%@ include file="dataProcessing.jsp"%>
                    <%@ include file="dataDownloads.jsp"%>
                    <% } %>
                </td>
            </tr>
        </table>
    </div>

</div>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>
</body>
<script src="/rgdweb/js/reportPages/geneReport.js?v=20"> </script>
<script src="/rgdweb/js/reportPages/reportModernUx.js?v=4"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=3"> </script>
</html>
