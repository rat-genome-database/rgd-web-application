<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%-- to be included as a line in info.jsp --%>
<%
    List<Gene> relatedGenes = associationDAO.getAssociatedGenesForMasterRgdId(obj.getRgdId(), "cell_line_to_gene");
    if( relatedGenes.size() > 0 ) {

        // sort by gene symbol
        Collections.sort(relatedGenes, new Comparator<Gene>() {
            public int compare(Gene o1, Gene o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
            }
        });
%>
        <tr>
            <td class="label">Related Genes:</td>
            <td><%
            for( Gene ge: relatedGenes ) {
            %>
                <a href="<%=Link.gene(ge.getRgdId())%>"><%=ge.getSymbol()%></a> &nbsp;<%
         }%></td>
        </tr>
<%}%>

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
        for( GenomicElement ge: relatedCellLines ) {
    %>
        <a href="<%=Link.ge(ge.getRgdId())%>"><%=ge.getSymbol()%> (<%=ge.getName()%>)</a><br><%
        }%></td>
</tr>
<%}%>
<%
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
        for( GenomicElement ge: relatedCellLines ) {
    %>
        <a href="<%=Link.ge(ge.getRgdId())%>"><%=ge.getSymbol()%> (<%=ge.getName()%>)</a><br><%
        }%></td>
</tr>
<%}%>
