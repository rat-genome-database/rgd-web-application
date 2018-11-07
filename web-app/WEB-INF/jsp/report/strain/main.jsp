<%@ page import="edu.mcw.rgd.datamodel.Strain" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>

<% boolean includeMapping = true;
    String title = "Strains";

    String titleTerm = request.getParameter("term");
    if (titleTerm == null ) {
       titleTerm = "";
    }
    String pageTitle = titleTerm + " Strain Report - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Strain reports include a comprehensive description of function and biological process as well as disease, expression, regulation and phenotype information.";

    Strain obj = (Strain) request.getAttribute("reportObject");
    String objectType="strain";
    String displayName=obj.getSymbol();

%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script type="application/ld+json">
{
"@context": "http://schema.org",
"@type": "Dataset",
"name": "<%=obj.getSymbol()%>",
"description": "Rat Strain",
"url": "https://rgd.mcw.edu/rgdweb/report/strain/main.html?id=<%=obj.getRgdId()%>",
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


<% RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
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

            <%@ include file="substrains.jsp"%>
            <%@ include file="congenics.jsp"%>
            <%@ include file="mutants.jsp"%>

            <br>
            <br><div  style="color:#2865a3; font-size: 16px; font-weight: 700; font-style: italic; ">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" onclick="toggleAssociations()">(Toggle Annotation Detail/Summary View)</a></div><br>
            <br>
            <%@ include file="diseaseModels.jsp"%>
            <div id="associationsCurator" style="display:none;">
                <%@ include file="../associationsCurator.jsp"%>
                <%@ include file="phenominerDetails.jsp"%>
            </div>
            <div id="associationsStandard" style="display:block;">
                <%@ include file="../associations.jsp"%>
                <%@ include file="phenominer.jsp"%>
            </div>

            <%@ include file="../references.jsp"%>
            <%@ include file="../pubMedReferences.jsp"%>
            <%@ include file="../portal.jsp"%>

            <br>
            <div class="subTitle">Region</div>
            <br>
            <%@ include file="../cellLines.jsp"%>
            <%@ include file="markers.jsp"%>
            <%@ include file="../sequence.jsp"%>
            <%@ include file="qtlAssociation.jsp"%>

            <br>
            <div class="subTitle">Additional Information</div>
            <br>

            <%@ include file="../curatorNotes.jsp"%>
            <%@ include file="../nomen.jsp"%>
            <%@ include file="../xdbs.jsp"%>

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
