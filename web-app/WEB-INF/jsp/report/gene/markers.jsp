<%@ include file="../sectionHeader.jsp"%>
<%
    List<SSLP> sslps = sslpDAO.getSSLPsForGene(obj.getKey());
    if (sslps.size() > 0 ) {
%>

<%//ui.dynOpen("markerAssociation", "Position Markers")%>
<div class="sectionHeading" id="positionMarkers">Position Markers</div>
<div id="positionMarkersTableDiv">


<table border="0" id="positionMarkersTable">
    <thead></thead>
    <tbody>
<% for (SSLP ss: sslps) { %>
    <tr >
        <td style="background-color:#e0e2e1;"> <a href="<%=Link.marker(ss.getRgdId())%>"><b><%=ss.getName()%></b></a> &nbsp; </td>
        <td><%=MapDataFormatter.buildTable(ss.getRgdId(), ss.getSpeciesTypeKey(), RgdId.OBJECT_KEY_SSLPS, ss.getName())%></td>
    </tr>
<% } %>
    </tbody>
</table>
<br>

<%//ui.dynClose("markerAssociation")%>

<% } %>

</div>
<%@ include file="../sectionFooter.jsp"%>
