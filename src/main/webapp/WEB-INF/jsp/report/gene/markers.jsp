<%@ include file="../sectionHeader.jsp"%>
<%
    List<SSLP> sslps = sslpDAO.getSSLPsForGene(obj.getKey());
    if (sslps.size() > 0 ) {
%>

<%//ui.dynOpen("markerAssociation", "Position Markers")%>

<div id="positionMarkersTableDiv" class="light-table-border">
    <div class="sectionHeading" id="positionMarkers">Markers in Region</div>

<table border="0" id="positionMarkersTable">
    <thead></thead>
    <tbody>
<% for (SSLP ss: sslps) { %>
    <tr >
        <td class="report-page-grey"> <a href="<%=Link.marker(ss.getRgdId())%>"><b><%=ss.getName()%></b></a> &nbsp; </td>
        <td><%=MapDataFormatter.buildTable(ss.getRgdId(), ss.getSpeciesTypeKey(), RgdId.OBJECT_KEY_SSLPS, ss.getName())%></td>
    </tr>
<% } %>
    </tbody>
</table>
<br>

<%//ui.dynClose("markerAssociation")%>

<%-- #positionMarkersTableDiv is opened inside the "if (sslps.size() > 0)" above, so it has to
     be closed inside it too. This </div> used to sit after the closing brace, so a gene with
     no position markers emitted a </div> with nothing to match it, which closed #content-wrap
     and left every later section outside the selector reportModernUx.js collapses on. --%>
</div>

<% } %>
<%@ include file="../sectionFooter.jsp"%>
