<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%-- to be included as a line in info.jsp --%>
<%
    List<GenomicElement> relatedCellLines = associationDAO.getAssociatedGenomicElementsForMasterRgdId(obj.getRgdId(), "cell_line_to_cell_line", "derived_from");
    if( relatedCellLines.size() > 0 ) {

        // sort by symbol
        Collections.sort(relatedCellLines, new Comparator<GenomicElement>() {
            public int compare(GenomicElement o1, GenomicElement o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
            }
        });
%>
<tr>
    <td class="label" valign="top">Derived From Cell Lines:</td>
    <td><%
        for( GenomicElement ge: relatedCellLines ) { %>
        <a href="<%=Link.cellLine(ge.getRgdId())%>"><%=ge.getSymbol()%> (<%=ge.getName()%>)</a><br><%
        }%></td>
</tr>
<%}

    relatedCellLines = associationDAO.getAssociatedGenomicElementsForDetailRgdId(obj.getRgdId(), "cell_line_to_cell_line", "derived_from");
    if( relatedCellLines.size() > 0 ) {

        // sort by symbol
        Collections.sort(relatedCellLines, new Comparator<GenomicElement>() {
            public int compare(GenomicElement o1, GenomicElement o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
            }
        });
%>
<tr>
    <td class="label" valign="top">Child Cell Lines:</td>
    <td><%
        for( GenomicElement ge: relatedCellLines ) { %>
        <a href="<%=Link.cellLine(ge.getRgdId())%>"><%=ge.getSymbol()%> (<%=ge.getName()%>)</a><br><%
        }%></td>
</tr>
<%}
    relatedCellLines = associationDAO.getAssociatedGenomicElementsForMasterRgdId(obj.getRgdId(), "cell_line_to_cell_line", "originate_from_same_individual_as");
    if( relatedCellLines.size() > 0 ) {

        // sort by symbol
        Collections.sort(relatedCellLines, new Comparator<GenomicElement>() {
            public int compare(GenomicElement o1, GenomicElement o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
            }
        });
%>
<tr>
    <td class="label" valign="top">Originate from same individual as:</td>
    <td><%
        for( GenomicElement ge: relatedCellLines ) { %>
        <a href="<%=Link.cellLine(ge.getRgdId())%>"><%=ge.getSymbol()%> (<%=ge.getName()%>)</a><br><%
        }%></td>
</tr>
<%}%>
