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

<div id="top" ></div>

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


<script>
    let reportTitle = "strain";
</script>
<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>



    <div id="content-wrap">



        <div class="registrationLink"><a href="/rgdweb/models/strainSubmissionForm.html?new=true">Strain Registration</a></div>
        <%@ include file="menu.jsp"%>


        <% RgdId rgdId = null;
            try {
                rgdId = managementDAO.getRgdId(obj.getRgdId());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            if (view.equals("3")) { %>

        <% } else if (!rgdId.getObjectStatus().equals("ACTIVE")) {
            int newRgdId = 0;
            try {
                newRgdId = managementDAO.getActiveRgdIdFromHistory(rgdId.getRgdId());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            Strain newStrain = null;
            try {
                if( newRgdId>0)
                newStrain = strainDAO.getStrain(newRgdId);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }%>
        <br><br>This object has been <%=rgdId.getObjectStatus()%> <br><br>
        <%if (newStrain != null){%>
        This strain has been replaced by the strain <a href="<%=edu.mcw.rgd.reporting.Link.strain(newStrain.getRgdId())%>" title="click to see the Strain report"><b><%=newStrain.getName()%></b> (RGD:<%=newStrain.getRgdId()%>)</a>.
        <% } %>
        <% } else {%>




        <table width="95%" border="0">
            <tr>
                <td>
                    <%@ include file="info.jsp"%>

                    <% String highlights = strainDAO.getContentType(obj.getRgdId(),"Highlights");
                        if(highlights != null) {
                            Blob data =  strainDAO.getStrainAttachment(obj.getRgdId(),"Highlights");
                            InputStream is = data.getBinaryStream();
                            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                            byte[] bytes = new byte[1024];
                            int bytesRead;
                            while ((bytesRead = is.read(bytes)) != -1) {
                                outputStream.write(bytes);
                            }
                            byte[] imageBytes = outputStream.toByteArray();
                            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
                            is.close();
                            outputStream.close();
                    %>
                    <br>
                    <div class="subTitle">Highlights</div>
                    <br>
                    <img src="data:image/jpg;base64,<%=base64Image%>" class="img-responsive"/>
                    <br><br>
                    <% } %>
                    <%@ include file="substrains.jsp"%>
                    <%@ include file="congenics.jsp"%>
                    <%@ include file="mutants.jsp"%>

                    <br>
                    <br><div  class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation')">Click to see Annotation Detail View</a></div><br>
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

                    <div class ="subTitle" id="references">References</div>
                    <%@ include file="../references.jsp"%>
                    <%@ include file="../pubMedReferences.jsp"%>

                    <br>
                    <div class="subTitle" id="region">Region</div>
                    <br>
                    <%@ include file="../cellLines.jsp"%>
                    <%@ include file="markers.jsp"%>
                    <%@ include file="../sequence.jsp"%>
                    <%@ include file="qtlAssociation.jsp"%>
                    <%@ include file="damagingVariants.jsp"%>
                    <%@ include file="../rgdVariants.jsp"%>
                    <br>
                    <div class="subTitle" id="additionalInformation">Additional Information</div>
                    <br>

                    <%@ include file="../curatorNotes.jsp"%>
                    <%@ include file="../nomen.jsp"%>
                    <%@ include file="../xdbs.jsp"%>

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
