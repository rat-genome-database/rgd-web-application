
<%@ include file="../sectionHeader.jsp"%>


<%

    Object flank1 = null;
    Object flank2 = null;
    Object peak = null;
    if (obj.getFlank1RgdId() != null) {
        flank1 = managementDAO.getObject(obj.getFlank1RgdId());
    }
    if (obj.getFlank2RgdId() != null) {
        flank2 = managementDAO.getObject(obj.getFlank2RgdId());
    }
    if (obj.getPeakRgdId() != null) {
        peak = managementDAO.getObject(obj.getPeakRgdId());
    }

    if (flank1 != null || peak != null || flank2 != null) {

%>


<%--<%=ui.dynOpen("markAssociation", "Position Markers")%>--%>
<div id="markAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="markAssociation">Position Markers</div>
<%

    String f1symbol = "";
    String f2symbol = "";
    String psymbol = "";

    int f1RgdId = 0;
    int f2RgdId = 0;
    int pRgdId = 0;

    if( flank1 != null ) {
        if( flank1 instanceof ObjectWithSymbol )
            f1symbol = ((ObjectWithSymbol)flank1).getSymbol();
        else if( flank1 instanceof ObjectWithName )
            f1symbol = ((ObjectWithName)flank1).getName();
        f1RgdId = ((Identifiable)flank1).getRgdId();
    }

    if( flank2 != null ) {
        if( flank2 instanceof ObjectWithSymbol )
            f2symbol = ((ObjectWithSymbol)flank2).getSymbol();
        else if( flank2 instanceof ObjectWithName )
            f2symbol = ((ObjectWithName)flank2).getName();
        f2RgdId = ((Identifiable)flank2).getRgdId();
    }

    if( peak != null ) {
        if( peak instanceof ObjectWithSymbol )
            psymbol = ((ObjectWithSymbol)peak).getSymbol();
        else if( peak instanceof ObjectWithName )
            psymbol = ((ObjectWithName)peak).getName();
        pRgdId = ((Identifiable)peak).getRgdId();
    }

%>
<br>
<table>

    <% if (flank1 != null) { %>
    <tr>
        <td valign="top">Flank 1: (<a href="<%=Link.it(f1RgdId)%>"><%=f1symbol%></a>)</td>
        <td><%=MapDataFormatter.buildTable(obj.getFlank1RgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } %>
    <% if (peak != null) { %>
    <tr>
        <td valign="top">Peak: (<a href="<%=Link.it(pRgdId)%>"><%=psymbol%></a>)</td>
        <td><%=MapDataFormatter.buildTable(obj.getPeakRgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } %>
    <% if (flank2 != null) { %>
    <tr>
        <td valign="top">Flank 2: (<a href="<%=Link.it(f2RgdId)%>"><%=f2symbol%></a>)</td>
        <td><%=MapDataFormatter.buildTable(obj.getFlank2RgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } %>
</table>
<br>

<%--<%=ui.dynClose("markAssociation")%>--%>
</div>
<% } %>


<%@ include file="../sectionFooter.jsp"%>
