<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>

<% boolean includeMapping = true;
    String title = "Variant";
    RgdVariant obj = (RgdVariant) request.getAttribute("reportObject");
    String objectType="RgdVariant";
    String displayName=obj.getName();

    Map refMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey());
    List mapDataList = mapDAO.getMapData(obj.getRgdId(), refMap.getKey());

    MapData md = new MapData();
    if (mapDataList.size() > 0) {
        md = (MapData) mapDataList.get(0);
    }
    RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());
    boolean isStatusNotActive = !rgdId.getObjectStatus().equals("ACTIVE");
    String pageTitle = obj.getName() + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = pageTitle;
%>

<div id="top" ></div>


<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script>
    let reportTitle = "rgdvariant";
</script>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>


    <div id="content-wrap">

        <%if (isStatusNotActive) {
            RgdVariantDAO rvdao = new RgdVariantDAO();
            int newRgdId = managementDAO.getActiveRgdIdFromHistory(rgdId.getRgdId());
            RgdVariant newVar = rvdao.getVariant(newRgdId);%>
        <table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
            <tr><td colspan="2"><h3>Variant: <%=Utils.NVL(obj.getName(), "")%>&nbsp;-&nbsp; <%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%>
        <% if (RgdContext.isCurator() || RgdContext.isTest()) {%>
        <span style="margin-left:100px; padding: 5px; border: 1px solid blue; background-color: yellow;"><a href="/rgdweb/curation/edit/editVariant.html?rgdId=<%=obj.getRgdId()%>" style="font-weight:bold;font-size:11px;color:blue" title="go to Object Edit">EDIT</a></span>
        <% } %>
            </h3></td></tr>
        </table>
        <br><br>The Variant <b><%=obj.getName()%></b> (RGD:<%=obj.getRgdId()%>) has been <b><%=rgdId.getObjectStatus()%></b>
        &nbsp; on <%=new SimpleDateFormat("MMMMM d, yyyy").format(rgdId.getLastModifiedDate())%>. <br><br>
        <%if (newVar != null){%>
        This variant has been replaced by the variant <a href="<%=edu.mcw.rgd.reporting.Link.it(newVar.getRgdId(),24)%>" title="click to see the variant report"><b><%=newVar.getName()%></b> (RGD:<%=newVar.getRgdId()%>)</a>.
        <% } %>
        <% } else { %>
<table width="95%" border="0">
    <tr>
        <td>

                <%@ include file="info.jsp"%>

            <br><div class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation');">Click to see Annotation Detail View</a></div><br>

        <div id="associationsCurator" style="display:none;">
            <%@ include file="../associationsCurator.jsp"%>
        </div>
        <div id="associationsStandard" style="display:block;">
            <%@ include file="../associations.jsp"%>
        </div>
            <%@ include file="../relatedStrains.jsp"%>
        <%@ include file="../references.jsp"%>
        <%@ include file="../pubMedReferences.jsp"%>

    <br><div  class="subTitle">Additional Information</div>
    <br>
    <%@ include file="../xdbs.jsp"%>
    </td>
    <td>&nbsp;</td>
<%--    <td valign="top">--%>
<%--        <%@ include file="../idInfo.jsp" %>--%>
<%--    </td>--%>
    </tr>
 </table>
    </div>
    <% } %>
</div>
<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>

<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>