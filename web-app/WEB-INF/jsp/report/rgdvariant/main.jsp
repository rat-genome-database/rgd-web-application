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

    String pageTitle = obj.getName() + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = pageTitle;
%>

<div id="top" ></div>


<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>


    <div id="content-wrap">


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
</div>
<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>

<script src="/rgdweb/js/reportPages/geneReport.js?v=6"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js"> </script>