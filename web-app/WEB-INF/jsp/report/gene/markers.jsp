<%@ include file="../sectionHeader.jsp"%>
<%
    List<SSLP> sslps = sslpDAO.getSSLPsForGene(obj.getKey());
    if (sslps.size() > 0 ) {
%>

<%//ui.dynOpen("markerAssociation", "Position Markers")%>
<div class="sectionHeading" id="positionMarkers">Position Markers</div>
<div id="positionMarkersTableDiv">

    <div id="modelsViewContent" >
        <div id="positionMarkersPager" class="pager" style="float:right;margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="3">3</option>
                    <option value="5">5</option>
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


<table border="0" id="positionMarkersTable" class="tablesorter">
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
