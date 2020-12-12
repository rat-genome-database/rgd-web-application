<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.SSLP" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%--
  User: jdepons
  Date: May 30, 2008
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>


<%  boolean includeMapping = true;
    String title = "Markers";
    SSLP obj = (SSLP) request.getAttribute("reportObject");
    String objectType="marker";
    String displayName=obj.getName();

    String pageTitle = obj.getName() + " Marker Search Result - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Rat Genome Database report page for " + obj.getName();
    Map refMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey());

    List mapDataList = mapDAO.getMapData(obj.getRgdId(), refMap.getKey());

    MapData md;
    if (mapDataList.size() > 0) {
        md = (MapData) mapDataList.get(0);
    }else{
        md = null;
    }

    // handling of RETIRED/WITHDRAWN genes: rgd id history is searched for an active rgd id that possibly
    // replaced this retired/withdrawn object
    RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    boolean isStatusNotActive = !rgdId.getObjectStatus().equals("ACTIVE");
    SSLP newSSLP = null; // sslp that replaced the current one
    if( isStatusNotActive ) {
        int newRgdId = managementDAO.getActiveRgdIdFromHistory(obj.getRgdId());
        if( newRgdId>0 )
            newSSLP = new SSLPDAO().getSSLP(newRgdId);
    }
%>


<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script>
    let reportTitle = "marker";
</script>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>


    <div id="top" ></div>

    <div id="content-wrap">
<%@ include file="menu.jsp"%>


<% if (view.equals("3")) { %>

<%-- handling of RETIRED/WITHDRAWN genes --%>
<% } else if (isStatusNotActive) { %>
    <br><br>The marker <%=obj.getName()%> (RGD ID: <%=obj.getRgdId()%>) has been <%=rgdId.getObjectStatus()%>. <br><br>
    <% if(newSSLP!=null ) { %>
      This marker has been replaced by the marker <a href="<%=edu.mcw.rgd.reporting.Link.marker(newSSLP.getRgdId())%>" title="click to see the marker report"><%=newSSLP.getName()%> (RGD ID: <%=newSSLP.getRgdId()%>)</a>.
     <br><br>
    <%}%>

<% } else {%>


<table width="95%" border="0">
    <tr>
        <td>
            <%@ include file="info.jsp"%>

            <%
            SearchBean sb = new SearchBean();
            sb.setTerm(obj.getName() + "[marker]");
            sb.setSpeciesType(obj.getSpeciesTypeKey());
            %>

            <br>
            <br><div  id='annotation' style="color:#2865a3; font-size: 16px; font-weight: 700; font-style: italic; ">Annotation</div><br>

            <%@ include file="../associations.jsp"%>
            <%@ include file="../references.jsp"%>


            <br><div  class="subTitle" id="strainsAndSequences">Strains and Sequence</div><br>
            <%@ include file="sequence.jsp"%>
            <%@ include file="strainVariation.jsp"%>

            <br><div  class="subTitle" id="region">Region</div><br>
            <%@ include file="../genesInRegion.jsp"%>
            <%@ include file="../nucleotide.jsp"%>
            <%@ include file="../proteins.jsp"%>
            <%@ include file="../qtlsInRegion.jsp"%>

            <br><div  class="subTitle" id="additionalInformation">Additional Information</div><br>

            <%@ include file="../curatorNotes.jsp"%>
            <%@ include file="../xdbs.jsp"%>
            <%@ include file="../nomen.jsp"%>


        </td>
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

<script src="/rgdweb/js/reportPages/geneReport.js?v=14"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>