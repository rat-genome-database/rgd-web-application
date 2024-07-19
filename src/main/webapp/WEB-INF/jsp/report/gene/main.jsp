<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>

<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>


<% boolean includeMapping = true;
    String title = "Genes";
    Gene obj = (Gene) request.getAttribute("reportObject");
    String ref_seq_acc_id="";
    if(obj.getSpeciesTypeKey()==3){
        ref_seq_acc_id="GCF_000001895.5";
    }
    if(obj.getSpeciesTypeKey()==1){
        ref_seq_acc_id="GCF_000001405.37";
    }
    if(obj.getSpeciesTypeKey()==2){
        ref_seq_acc_id="GCF_000001635.26";
    }
    if(obj.getSpeciesTypeKey()==6){
        ref_seq_acc_id="GCF_000002285.3";
    }
    if(obj.getSpeciesTypeKey()==7){
        ref_seq_acc_id="GCF_000236235.1";
    }
    if(obj.getSpeciesTypeKey()==4){
        ref_seq_acc_id="GCF_000276665.1";
    }
    if(obj.getSpeciesTypeKey()==5){
        ref_seq_acc_id="GCF_000258655.2";
    }
    String objectType="gene";
    String displayName=obj.getSymbol();
    String geneSource = Utils.NVL(obj.getGeneSource(),"NCBI");
    if( !(geneSource.equals("NCBI") || geneSource.equals("Ensembl")) ) {
        geneSource = "NCBI";
    }
    edu.mcw.rgd.datamodel.Map refMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey(), geneSource);
    List mapDataList = mapDAO.getMapData(obj.getRgdId(), refMap.getKey());
    MapData md = new MapData();
    if (mapDataList.size() > 0) {
        md = (MapData) mapDataList.get(0);
    }
    // handling of RETIRED/WITHDRAWN genes: rgd id history is searched for an active rgd id that possibly
    // replaced this retired/withdrawn object
    RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    boolean isGeneStatusNotActive = !rgdId.getObjectStatus().equals("ACTIVE");
    Gene newGene = null; // gene that replaced the current one
    if( isGeneStatusNotActive ) {
        int newRgdId = managementDAO.getActiveRgdIdFromHistory(obj.getRgdId());
        if( newRgdId>0 )
            newGene = geneDAO.getGene(newRgdId);
    }
    String description = Utils.getGeneDescription(obj);
    String pageTitle = obj.getSymbol() + " (" + obj.getName() + ") - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = description;
%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script type="application/ld+json">
{
"@context": "http://schema.org",
"@type": "Dataset",
"name": "<%=obj.getSymbol()%>",
"description": "<%=Utils.getGeneDescription(obj)%>",
"url": "https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=<%=obj.getRgdId()%>",
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



<%
    String tutorialLink="/wg/home/rgd_rat_community_videos/rgd-s-gene-report-pages-tutorial";
    String pageHeader="Gene: " + obj.getSymbol() + "&nbsp;(" + obj.getName() + ")&nbsp;" + SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey());
%>

<script>
    let reportTitle = "gene";
</script>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>


    <div id="content-wrap">
        <table width="95%" style="padding-top:10px;" border="0">
            <tr>
                <% if( RgdContext.isChinchilla(request) ) { %>
                <td style="font-size:20px; color:#96151d; font-weight:700;"><%=pageHeader%></td>
                <% } else { %>
                <td style="font-size:20px; color:#2865A3; font-weight:700;"><%=pageHeader%></td>
                <% } %>
                <td align="center" valign="bottom"><div ng-click="rgd.addWatch(pageObject)"><img heght="30" width="30" src="/rgdweb/common/images/binoculars.png" border="0"/><br><a href="javascript:void(0)" >{{ watchLinkText }}</a></div></td>
                <td align="center" valign="bottom"><img src="/rgdweb/common/images/tools-white-40.png" style="cursor:hand; border: 0px solid black;" border="0" ng-click="rgd.showTools('geneList',<%=obj.getSpeciesTypeKey()%>,<%=MapManager.getInstance().getReferenceAssembly(obj.getSpeciesTypeKey()).getKey()%>,1,'')"/><br><a href="javascript:void(0)" ng-click="rgd.showTools('geneList',<%=obj.getSpeciesTypeKey()%>,<%=MapManager.getInstance().getReferenceAssembly(obj.getSpeciesTypeKey()).getKey()%>,1,'')">Analyze</a></td>

                <% if( tutorialLink!=null && !tutorialLink.isEmpty() && !RgdContext.isChinchilla(request) ) { %>
                <td align="right">
                    <a  href="<%=tutorialLink%>"><img src="http://rgd.mcw.edu/common/images/tutorial.png" border=0/></a>
                </td>
                <% } %>
            </tr>
        </table>




        <%@ include file="menu.jsp"%>

        <% if (view.equals("2")) { %>

        <%-- handling of RETIRED/WITHDRAWN genes --%>
        <% } else if (isGeneStatusNotActive) { %>
        <br><br>The gene <b><%=obj.getSymbol()%></b> (RGD:<%=obj.getRgdId()%>) has been <b><%=rgdId.getObjectStatus()%></b>
        &nbsp; on <%=new SimpleDateFormat("MMMMM d, yyyy").format(rgdId.getLastModifiedDate())%>. <br><br>
        <% if(newGene!=null ) { %>
        This gene has been replaced by the gene <a href="<%=edu.mcw.rgd.reporting.Link.gene(newGene.getRgdId())%>" title="click to see the gene report"><b><%=newGene.getSymbol()%></b> (RGD:<%=newGene.getRgdId()%>)</a>.
        <br><br>
        <%}%>

        <% if (true) return; %>

        <% } else if (view.equals("4")) { %><table width="95%"><tr><td valign="top">
        <%@ include file="../arrayIds.jsp"%>
            <% } else if (view.equals("5")) { %><table width="95%"><tr><td valign="top">
        <%@ include file="../referencesTab.jsp"%>
            <% } else { %>



        <!-- above symbol, name description table--->
        <table width="95%" border="0">
            <tr>
                <td>

                    <%@ include file="info.jsp"%>

                    <a name="annotation"></a>
                    <br><div class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation');">Click to see Annotation Detail View</a></div><br>

                    <div id="associationsCurator" style="display:none;">
                        <%@ include file="../associationsCurator.jsp"%>
                    </div>

                    <div id="associationsStandard" style="display:block;">
                        <%@ include file="../associations.jsp"%>
                    </div>

                    <div class ="subTitle" id="references">References</div>
                    <%@ include file="../references.jsp"%>
                    <%@ include file="../pubMedReferences.jsp"%>
                    <!--above genomics table--->

                    <a name="genomics"></a>
                    <br>
                    <div class="subTitle" id="genomics">Genomics</div>
                    <br>

                    <%
                        SearchBean sb = new SearchBean();
                        sb.setTerm(obj.getSymbol() + "[gene]");
                        sb.setSpeciesType(obj.getSpeciesTypeKey());
                    %>

                    <%@ include file="comparativeMapData.jsp"%>
                    <%@ include file="../cnVariants.jsp"%>
                    <%try {%>
                    <jsp:include page="clinicalVariants.jsp"/>
                    <%} catch (Exception e){e.printStackTrace();}%>
                    <%@ include file="damagingVariants.jsp"%>
                    <%@ include file="../rgdVariants.jsp"%>
                    <%@ include file="../miRnaTargets.jsp"%>
<%--                    <%@ include file="candidateGenes.jsp"%>--%>
                    <%@ include file="../qtlsInRegion.jsp"%>
                    <%@ include file="markers.jsp"%>
                    <%@ include file="../cellLines.jsp"%>
                    <%@ include file="../relatedStrains.jsp"%>
                    <%@ include file="../geneticModels.jsp"%>
                    <!---Above expression table-->
                    <a name="expression"></a>
                    <br>
                    <div class="subTitle" id="expression">Expression</div>
                    <br>
                    <%try {%>
                    <jsp:include page="expressionDataNew.jsp"/>
                    <%} catch (Exception e){e.printStackTrace();}%>
                    <!--above sequence table--->
                    <a name="sequence"></a>
                    <br>
                    <div class="subTitle" id="sequence">Sequence</div>
                    <br>
                    <%@ include file="../nucleotide.jsp"%>
                    <%@ include file="../proteins.jsp"%>
                    <%@ include file="proteinStructures.jsp"%>

                    <%@ include file="../transcriptome.jsp"%>
                    <%@ include file="../promoters.jsp"%>
<%--                    <%@ include file="../variants.jsp"%>--%>
                    
                    <!--above additional information--->
                    <a name="additional"></a>
                    <br><div  class="subTitle" id = "additionalInformation">Additional Information</div><br>

                    <%@ include file="../xdbs.jsp"%>
                    <%@ include file="../nomen.jsp"%>
                    <%@ include file="../curatorNotes.jsp"%>
<%--                    <%@ include file="../rgdVariants.jsp"%>--%>

                </td>
                <td>&nbsp;</td>
                <%--                <td valign="top">--%>

                <%--                    <%@ include file="links.jsp" %>--%>
                <%--                    <br>--%>
                <%--                    <%@ include file="../idInfo.jsp" %>--%>
                <%--                </td>--%>
            </tr>
        </table>
    </table>
    </table>
    </div>
</div>
<% } %>
<%-- --%>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>


<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>










