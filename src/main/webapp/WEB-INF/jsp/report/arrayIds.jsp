<%@ include file="sectionHeader.jsp"%>
<%
    List arrayIdAliases = aliasDAO.getAliases(obj.getRgdId());

    // ArrayIdFormatter renders "No array ids found." when nothing matches, which is fine for a
    // tab the reader chose to open but is just noise as a section of the report body. The test
    // mirrors the formatter's own: it strips the "array_id_" prefix and keys off the suffix, so
    // a type that reaches one reaches the other.
    boolean hasArrayIds = false;
    for( Object arrayIdAlias: arrayIdAliases ) {
        String arrayIdType = ((Alias) arrayIdAlias).getTypeName();
        if( arrayIdType == null ) {
            continue;
        }
        arrayIdType = arrayIdType.replace("array_id_", "");
        if( arrayIdType.endsWith("_affymetrix") || arrayIdType.endsWith("_ensembl") ) {
            hasArrayIds = true;
            break;
        }
    }

    if( hasArrayIds ) {
%>
<%-- A section of the report body rather than its own tab: a .reportTable .light-table-border
     with a .sectionHeading as its DIRECT child, which is what buildCards() in
     reportModernUx.js wires an accordion onto, and what addItemsToSideBar() picks up as a
     nav entry. Both tags sit inside the hasArrayIds guard, so the card is either emitted
     whole or not at all. --%>
<div class="reportTable light-table-border" id="arrayIdsTableDiv">
    <div class="sectionHeading" id="arrayIds">Array IDs</div>

    <%=ArrayIdFormatter.format(arrayIdAliases)%>
</div>
<% } %>

<%@ include file="sectionFooter.jsp"%>
