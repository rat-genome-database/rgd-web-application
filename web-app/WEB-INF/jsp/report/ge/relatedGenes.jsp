<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.Association" %>
<%-- to be included as a line in info.jsp --%>
<%
    List<Association> associations = associationDAO.getAssociationsForMasterRgdId(obj.getRgdId(), "promoter_to_gene");
    if( associations.size() > 0 ) { %>
        <tr>
            <td class="label">Related Genes:</td>
            <td><%
            for( Association assoc: associations ) {
                Gene gene = geneDAO.getGene(assoc.getDetailRgdId());
            %>
                <a href="<%=Link.gene(gene.getRgdId())%>"><%=gene.getSymbol()%></a> &nbsp;<%
         }%></td>
        </tr>
    <%}%>
