<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    List compareHomologs = geneDAO.getHomologs(obj.getRgdId());

    /*
    // species-specific filtering
    Iterator<Gene> chIt = compareHomologs.iterator();
    while( chIt.hasNext() ) {
        Gene gh = chIt.next();
        if( RgdContext.isChinchilla(request) ) {
            // for chinchilla view, show only human-chinchilla orthologs
            if( gh.getSpeciesTypeKey()!=SpeciesType.HUMAN && gh.getSpeciesTypeKey()!=SpeciesType.CHINCHILLA )
                chIt.remove();
        } else {
            // if not chinchilla view, do not show chinchilla
            if( gh.getSpeciesTypeKey()==SpeciesType.CHINCHILLA )
                chIt.remove();
        }
    }
*/
    if (compareHomologs.size() > 0) {
%>
<%//ui.dynOpen("mapAssociation", "Comparative Map Data")%>

<div id="comparativeMapDataTableDiv" class="light-table-border">
    <div class="sectionHeading" id="comparativeMapData">Comparative Map Data</div>

<%
    compareHomologs.add(0,obj);
    List<Map> primaryAssemblies = mapDAO.getPrimaryRefAssemblies();

    MapData currentMapData = null;
%>

<%-- the <thead> was empty; nothing reads it and an empty row group only confuses the
     table rules --%>
<table id="comparativeMapDataTable">
    <tbody>
<%

for (Object thisObject: compareHomologs) {
    Gene g = (Gene) thisObject;
%>
    <tr>
        <td class="cmapSpecies">
            <span class="cmapSymbol"><%=g.getSymbol()%></span>
            <span class="cmapTaxon"><%=SpeciesType.getTaxonomicName(g.getSpeciesTypeKey())%></span>
            <span class="cmapCommon"><%=SpeciesType.getGenebankCommonName(g.getSpeciesTypeKey())%></span>
        </td>
        <td class="cmapMap"><%=MapDataFormatter.buildTable(g.getRgdId(),g.getSpeciesTypeKey(), rgdId.getObjectKey(), g.getSymbol())%></td>
    </tr>

<% } %>
    </tbody>
</table>
<%//ui.dynClose("mapAssociation")%>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>