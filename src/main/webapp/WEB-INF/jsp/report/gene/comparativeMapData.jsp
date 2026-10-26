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
%>

<%-- One table, one header row, species in the first column: the markup is all in
     MapDataFormatter.buildComparativeTable(), which also hides every assembly past each
     species' reference one behind the toggle wired up below.

     This replaced a per-homolog nested buildTable() - see the comment on that method for
     why. The page directive above still imports datamodel.Map because other fragments
     statically included into main.jsp resolve Map against it. --%>
<%=MapDataFormatter.buildComparativeTable(compareHomologs, rgdId.getObjectKey())%>
<%//ui.dynClose("mapAssociation")%>

<%-- One delegated handler for the whole section. Rows and buttons carry data-cmap-species,
     so a button reveals its own species' assemblies and leaves every other species alone.
     The rows are already in the page, so this never goes back to the server. --%>
<script>
(function () {
    var section = document.getElementById("comparativeMapDataTableDiv");
    if (!section) {
        return;
    }
    section.addEventListener("click", function (e) {
        var btn = e.target.closest ? e.target.closest(".mapDataMoreBtn") : null;
        if (!btn) {
            return;
        }
        var species = btn.getAttribute("data-cmap-species");
        var table = btn.closest("table");
        if (!species || !table) {
            return;
        }
        var expanded = btn.getAttribute("aria-expanded") === "true";
        var rows = table.querySelectorAll('tr.mapDataExtra[data-cmap-species="' + species + '"]');
        Array.prototype.forEach.call(rows, function (tr) {
            tr.hidden = expanded;
        });
        btn.setAttribute("aria-expanded", expanded ? "false" : "true");
        btn.textContent = btn.getAttribute(expanded ? "data-label-more" : "data-label-less");
    });
}());
</script>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>
