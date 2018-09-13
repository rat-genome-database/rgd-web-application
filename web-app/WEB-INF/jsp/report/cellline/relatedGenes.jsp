<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%-- to be included as a line in info.jsp --%>
<%
    List<Gene> relatedGenes = associationDAO.getAssociatedGenesForMasterRgdId(obj.getRgdId(), "cellline_to_gene");
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
