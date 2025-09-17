<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>

<% boolean includeMapping = true; %>

<%
    QTL obj = (QTL) request.getAttribute("reportObject");
//    System.out.println(obj.getRgdId());
    String objectType="qtl";
    String displayName=obj.getSymbol();

    String title = "QTLs";
    String pageTitle = obj.getSymbol() + " QTL Report (" + SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey()) + ") - Rat Genome Database";
    String headContent = "";
    String pageDescription = "RGD report page for " + obj.getName();


    edu.mcw.rgd.datamodel.Map refMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey());
    List<MapData> mapDataList = new ArrayList<>();
    try {
        mapDataList = mapDAO.getMapData(obj.getRgdId(), refMap.getKey());
    }
    catch (Exception e){
//        System.out.println(e);
    }
    MapData md = null;
    if (mapDataList.size() > 0) {
        md = mapDataList.get(0);
    }
    boolean peakRs = Utils.isStringEmpty(obj.getPeakRsId());
    boolean isGwas = obj.getSymbol().startsWith("GWAS");
    String rsId = obj.getPeakRsId();
%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script type="application/ld+json">
{
"@context": "http://schema.org",
"@type": "Dataset",
"name": "<%=obj.getSymbol()%>",
"description": "QTL Report",
"url": "https://rgd.mcw.edu/rgdweb/report/qtl/main.html?id=<%=obj.getRgdId()%>",
"keywords": "Rat Gene RGD Genome",
"includedInDataCatalog": "https://rgd.mcw.edu",
"creator": {
"@type": "Organization",
"name": "Rat Genome Database"
},
"version": "1",
"license": "Creative Commons CC BY 4.0"
}
</script>

<script>
    let reportTitle = "qtl";
</script>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>


    <div id="content-wrap">
        <div class="registrationLink"><a href="/tools/qtls/qtlRegistrationIndex.cgi">QTL Registration</a></div>
<%@ include file="menu.jsp"%>
<%  RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());
    if (view.equals("3")) { %>

<% } else if (!rgdId.getObjectStatus().equals("ACTIVE")) {
    int newRgdId = managementDAO.getActiveRgdIdFromHistory(rgdId.getRgdId());
    QTL newQTL = qtlDAO.getQTL(newRgdId);
%>
    <br><br>This object has been <%=rgdId.getObjectStatus()%> <br><br>
        <%if (newQTL != null){%>
        This QTL has been replaced by the QTL <a href="<%=edu.mcw.rgd.reporting.Link.qtl(newQTL.getRgdId())%>" title="click to see the variant report"><b><%=newQTL.getName()%></b> (RGD:<%=newQTL.getRgdId()%>)</a>.
        <% } %>
<% } else {%>





<table width="95%" border="0">
    <tr>
        <td>

            <%@ include file="info.jsp"%>

            <br><div  class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation')">Click to see Annotation Detail View</a></div><br>

            <%@ include file="candidateGenes.jsp"%>

            <div id="associationsCurator" style="display:none;">
                <%@ include file="../associationsCurator.jsp"%>
            </div>
            <div id="associationsStandard" style="display:block;">
                <%@ include file="../associations.jsp"%>
            </div>


            <div class ="subTitle" id="references">References</div>
            <%@ include file="../references.jsp"%>
            <%@ include file="../pubMedReferences.jsp"%>
            <%@ include file="relatedQtls.jsp"%>


            <br><div class="subTitle" id="region">Region</div><br>

<%
    SearchBean sb = new SearchBean();
    sb.setTerm(obj.getSymbol() + "[qtl]");
    sb.setSpeciesType(obj.getSpeciesTypeKey());

%>
            <%@ include file="../genesInRegion.jsp"%>
            <%if (peakRs){%>
            <%@ include file="../markersInRegion.jsp"%>
            <%}%>
            <%@ include file="markers.jsp"%>
            <%@ include file="../qtlsInRegion.jsp"%>
            <%@ include file="../relatedStrains.jsp"%>


            <br><div class="subTitle" id="additionalInformation" >Additional Information</div><br>
            <%@ include file="gwasQtlInfo.jsp"%>
            <%@ include file="../xdbs.jsp"%>
            <%@ include file="../nomen.jsp"%>
            <%@ include file="../curatorNotes.jsp"%>

        </td>
        <td>&nbsp;</td>
        <td align="right" valign="top">
<%--            <%@ include file="links.jsp" %>--%>
            <br>
<%--            <%@ include file="../idInfo.jsp" %>--%>
        </td>
    </tr>
 </table>
    </div>
</div>
<% } %>
    <%@ include file="../reportFooter.jsp"%>
    <%@ include file="/common/footerarea.jsp"%>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>
