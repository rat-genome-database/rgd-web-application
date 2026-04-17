<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantDAO" %>
<%@ include file="../sectionHeader.jsp"%>


<%
    VariantDAO vdao = new VariantDAO();
    Object flank1 = null;
    VariantMapData flank1Var = null;
    Object flank2 = null;
    VariantMapData flank2Var = null;
    Object peak = null;
    VariantMapData peakVar = null;
    VariantMapData peakRsId = null;
    if (obj.getFlank1RgdId() != null) {
        flank1 = managementDAO.getObject(obj.getFlank1RgdId());
        if(flank1 == null) {
            flank1Var = vdao.getVariant(obj.getFlank1RgdId());
        }
    }
    else if (obj.getFlank1RsId() != null){
        flank1Var = vdao.getVariantByRsId(obj.getFlank1RsId());
    }
    if (obj.getFlank2RgdId() != null) {
        flank2 = managementDAO.getObject(obj.getFlank2RgdId());
        if(flank2 == null){
            flank2Var = vdao.getVariant(obj.getFlank2RgdId());
        }
    }
    else if (obj.getFlank2RsId() != null){
        flank2Var = vdao.getVariantByRsId(obj.getFlank2RsId());
    }
    if (obj.getPeakRgdId() != null) {
        peak = managementDAO.getObject(obj.getPeakRgdId());
        if(peak == null){
            peakVar = vdao.getVariant(obj.getPeakRgdId());
        }
    }
    else if (obj.getPeakRsId() != null){
        peakVar = vdao.getVariantByRsId(obj.getPeakRsId());
    }
//    if (obj.getPeakRsId() != null){
//        // get variant object with rsId
//        // rsId is the symbol that'll link to variant page
////        VariantDAO vdao = new VariantDAO();
////
////        List<VariantMapData> vmds = vdao.getAllActiveVariantsByRsId(obj.getPeakRsId());
////        if (!vmds.isEmpty())
////            peakRsId = vmds.get(0);
//    }

    if (flank1 != null || flank1Var != null || peak != null || peakVar != null || flank2 != null || flank2Var != null || obj.getPeakRsId()!=null) {

%>


<%--<%=ui.dynOpen("markAssociation", "Position Markers")%>--%>
<div id="markAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="markAssociation">Position Markers</div>
<%

    String f1symbol = "";
    String f2symbol = "";
    String psymbol = "";
    String pRsSymbol = "";

    int f1RgdId = 0;
    int f2RgdId = 0;
    int pRgdId = 0;
    int pRsRgdId = 0;

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

    int mapKey = refMap.getKey();
    if (obj.getPeakRsId()!=null){
        pRsSymbol = obj.getPeakRsId();

        if (obj.getSpeciesTypeKey()==3) // don't have it for latest rat assembly
            mapKey = 380;
    }

%>
<br>
<table>

    <% if (flank1Var != null) {%>
    <tr>
        <td valign="top">Flank 1: (<a href="<%=!Utils.isStringEmpty(flank1Var.getRsId()) ? "/rgdweb/report/rsId/main.html?id="+flank1Var.getRsId() : Link.it((int)flank1Var.getId())%>"><%=!Utils.isStringEmpty(flank1Var.getRsId()) ? flank1Var.getRsId() : "RGD:"+flank1Var.getId()%></a>)</td>
        <td><%=!Utils.isStringEmpty(flank1Var.getRsId()) ? MapDataFormatter.buildTable(flank1Var.getRsId(), obj.getSpeciesTypeKey(),mapKey) : MapDataFormatter.buildTable(obj.getFlank1RgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>

    <% } else if (flank1 != null) {  %>
    <tr>
        <td valign="top">Flank 1: (<a href="<%=Link.it(f1RgdId)%>"><%=f1symbol%></a>)</td>
        <td><%=MapDataFormatter.buildTable(obj.getFlank1RgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } %>
    <% if (peakVar != null) {%>
    <tr>
        <td valign="top">Peak: (<a href="<%=!Utils.isStringEmpty(peakVar.getRsId()) ? "/rgdweb/report/rsId/main.html?id="+peakVar.getRsId() : Link.it((int)peakVar.getId())%>"><%=!Utils.isStringEmpty(peakVar.getRsId()) ? peakVar.getRsId() : "RGD:"+peakVar.getId()%></a>)</td>
        <td><%=!Utils.isStringEmpty(peakVar.getRsId()) ? MapDataFormatter.buildTable(peakVar.getRsId(), obj.getSpeciesTypeKey(),mapKey) : MapDataFormatter.buildTable(obj.getPeakRgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } else if (peak != null) { %>
    <tr>
        <td valign="top">Peak: (<a href="<%=Link.it(pRgdId)%>"><%=psymbol%></a>)</td>
        <td><%=MapDataFormatter.buildTable(obj.getPeakRgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } %>
<%--    <% if (obj.getPeakRsId()!=null){ %>--%>
<%--    <tr>--%>
<%--        <td valign="top">Peak: (<a href="/rgdweb/report/rsId/main.html?id=<%=pRsSymbol%>"><%=pRsSymbol%></a>)</td>--%>
<%--        <td>--%>
<%--            <%=MapDataFormatter.buildTable(pRsSymbol, obj.getSpeciesTypeKey(),mapKey)%>--%>
<%--        </td>--%>
<%--    </tr>--%>
<%--    <% } %>--%>
    <% if (flank2Var != null) { %>
    <tr>
        <td valign="top">Flank 2: (<a href="<%=!Utils.isStringEmpty(flank2Var.getRsId()) ? "/rgdweb/report/rsId/main.html?id="+flank2Var.getRsId() : Link.it((int)flank2Var.getId())%>"><%=!Utils.isStringEmpty(flank2Var.getRsId()) ? flank2Var.getRsId() : "RGD:"+flank2Var.getId()%></a>)</td>
        <td><%=!Utils.isStringEmpty(flank2Var.getRsId()) ? MapDataFormatter.buildTable(flank2Var.getRsId(), obj.getSpeciesTypeKey(),mapKey) : MapDataFormatter.buildTable(obj.getFlank2RgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } else if (flank2 != null) { %>
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
