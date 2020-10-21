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
    String objectType="qtl";
    String displayName=obj.getSymbol();

    String title = "QTLs";
    String pageTitle = obj.getSymbol() + " QTL Report (" + SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey()) + ") - Rat Genome Database";
    String headContent = "";
    String pageDescription = "RGD report page for " + obj.getName();


    edu.mcw.rgd.datamodel.Map refMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey());
    List<MapData> mapDataList = mapDAO.getMapData(obj.getRgdId(), refMap.getKey());

    MapData md = null;
    if (mapDataList.size() > 0) {
        md = mapDataList.get(0);
    }
    
%>

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


<%@ include file="menu.jsp"%>


<%  RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    if (view.equals("3")) { %>

<% } else if (!rgdId.getObjectStatus().equals("ACTIVE")) { %>
    <br><br>This object has been <%=rgdId.getObjectStatus()%> <br><br>

<% } else {%>

<script>
    function toggleAssociations() {
        if (document.getElementById("associationsCurator").style.display=="none") {
            document.getElementById("associationsCurator").style.display="block";
        }else {
           document.getElementById("associationsCurator").style.display="none";
        }

        if (document.getElementById("associationsStandard").style.display=="none") {
           document.getElementById("associationsStandard").style.display="block";
        }else {
           document.getElementById("associationsStandard").style.display="none";
        }
    }
</script>

<table width="95%" border="0">
    <tr>
        <td>
            <%@ include file="info.jsp"%>

            <br><div  style="color:#2865a3; font-size: 16px; font-weight: 700; font-style: italic; ">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" onclick="toggleAssociations()">(Toggle Annotation Detail/Summary View)</a></div><br>

            <%@ include file="candidateGenes.jsp"%>

            <div id="associationsCurator" style="display:none;">
                <%@ include file="../associationsCurator.jsp"%>
            </div>
            <div id="associationsStandard" style="display:block;">
                <%@ include file="../associations.jsp"%>
            </div>

            <%@ include file="../references.jsp"%>
            <%@ include file="../pubMedReferences.jsp"%>
            <%@ include file="relatedQtls.jsp"%>


            <br><div  style="color:#2865a3; font-size: 16px; font-weight: 700; font-style: italic; ">Region</div><br>

<%
    SearchBean sb = new SearchBean();
    sb.setTerm(obj.getSymbol() + "[qtl]");
    sb.setSpeciesType(obj.getSpeciesTypeKey());

%>
            <%@ include file="../genesInRegion.jsp"%>
            <%@ include file="../markersInRegion.jsp"%>
            <%@ include file="markers.jsp"%>
            <%@ include file="../qtlsInRegion.jsp"%>
            <%@ include file="../relatedStrains.jsp"%>

            <br><div  style="color:#2865a3; font-size: 16px; font-weight: 700; font-style: italic; ">Additional Information</div><br>

            <%@ include file="../xdbs.jsp"%>
            <%@ include file="../nomen.jsp"%>
            <%@ include file="../curatorNotes.jsp"%>

        </td>
        <td>&nbsp;</td>
        <td align="right" valign="top">
            <%@ include file="links.jsp" %>
            <br>
            <%@ include file="../idInfo.jsp" %>
        </td>
    </tr>
 </table>


<% } %>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>

