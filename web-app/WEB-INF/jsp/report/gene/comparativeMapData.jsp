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
<div class="sectionHeading" id="comparativeMapData">Comparative Map Data</div>
<%
    compareHomologs.add(0,obj);
    List<Map> primaryAssemblies = mapDAO.getPrimaryRefAssemblies();

    MapData currentMapData = null;
%>

<table border="0">

<%

for (Object thisObject: compareHomologs) {
    Gene g = (Gene) thisObject;
%>
    <tr >
        <td style="background-color:#e0e2e1;" ><b><%=g.getSymbol()%><br>(<%=SpeciesType.getTaxonomicName(g.getSpeciesTypeKey())%> - <%=SpeciesType.getGenebankCommonName(g.getSpeciesTypeKey())%>)</b></td>
        <td><%=MapDataFormatter.buildTable(g.getRgdId(),g.getSpeciesTypeKey(), rgdId.getObjectKey(), g.getSymbol())%></td>
    </tr>

<% } %>

</table>
</br>
<%//ui.dynClose("mapAssociation")%>

<% } %>
<%@ include file="../sectionFooter.jsp"%>