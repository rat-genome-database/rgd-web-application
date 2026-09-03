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
<div id="page-container" class="<%=reportSkinClass%>">
    <div id="left-side-wrap">
        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">

        <%
            heroEyebrow = "HGNC Gene Family";
            heroTitle = Utils.NVL(obj.getName(), "");
            heroTitleClass = "report-hero-title--long";
            heroShortName = Utils.NVL(obj.getAbbreviation(), obj.getName());
            heroIcon = "fa-sitemap";
            heroWatch = false;
            if( familyGenes!=null && !familyGenes.isEmpty() ) {
                heroChips.add("fa-list|" + familyGenes.size() + " genes");
            }
        %>
        <%@ include file="../reportHero.jsp"%>

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
<script src="/rgdweb/js/reportPages/geneReport.js?v=20"> </script>
<script src="/rgdweb/js/reportPages/reportModernUx.js?v=4"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=4"> </script>
</html>
