<%@ include file="../sectionHeader.jsp"%>
<%
    List<SSLP> sslps = sslpDAO.getSSLPsForGene(obj.getKey());
    if (sslps.size() > 0 ) {
%>

<%=ui.dynOpen("markerAssociation", "Position Markers")%>

<table border="0">
<% for (SSLP ss: sslps) { %>
    <tr >
        <td style="background-color:#e0e2e1;"> <a href="<%=Link.marker(ss.getRgdId())%>"><b><%=ss.getName()%></b></a> &nbsp; </td>
        <td><%=MapDataFormatter.buildTable(ss.getRgdId(), ss.getSpeciesTypeKey(), RgdId.OBJECT_KEY_SSLPS, ss.getName())%></td>
    </tr>
<% } %>

</table>
<br>

<%=ui.dynClose("markerAssociation")%>

<% } %>
<%@ include file="../sectionFooter.jsp"%>
