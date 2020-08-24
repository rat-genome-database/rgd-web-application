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
<div id="comparativeMapDataTableDiv">

    <div id="modelsViewContent" >
        <div id="comparativeMapDataPager" class="pager" style="float:right;margin-bottom:2px;">
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
<%
    compareHomologs.add(0,obj);
    List<Map> primaryAssemblies = mapDAO.getPrimaryRefAssemblies();

    MapData currentMapData = null;
%>

<table border="0" id="comparativeMapDataTable" class="tablesorter">
    <thead></thead>
    <tbody>
<%

for (Object thisObject: compareHomologs) {
    Gene g = (Gene) thisObject;
%>
    <tr >
        <td style="background-color:#e0e2e1;" ><b><%=g.getSymbol()%><br>(<%=SpeciesType.getTaxonomicName(g.getSpeciesTypeKey())%> - <%=SpeciesType.getGenebankCommonName(g.getSpeciesTypeKey())%>)</b></td>
        <td><%=MapDataFormatter.buildTable(g.getRgdId(),g.getSpeciesTypeKey(), rgdId.getObjectKey(), g.getSymbol())%></td>
    </tr>

<% } %>
    </tbody>
</table>
</br>
<%//ui.dynClose("mapAssociation")%>

<% } %>
</div>
<%@ include file="../sectionFooter.jsp"%>