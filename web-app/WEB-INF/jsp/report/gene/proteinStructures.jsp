<%@ include file="../sectionHeader.jsp"%>
<%
List<ProteinStructure> protStructs = new ProteinStructureDAO().getProteinStructuresForGene(obj.getRgdId());
if( !protStructs.isEmpty() ) {
%>

<%--<%=ui.dynOpen("proteinStructures", "Protein Structures")%><br>--%>
<div class="light-table-border">
    <div class="sectionHeading" id="proteinStructures">Protein Structures</div>
<table cellpadding="2" cellspacing="1" class="sortable" id="protStruTab">
    <tr class="headerRow">
        <td title="click to sort by name">Name</td>
        <td title="click to sort by modeller">Modeller</td>
        <td title="click to sort by protein">Protein Id</td>
        <td title="click to sort by aminoacid range">AA Range</td>
        <td>Protein Structure</td>
        <td>Video</td>
    </tr>
<%
    String rowClass="oddRow";
    for (ProteinStructure ps: protStructs) {

        // alternate rows {even,odd}
        if( rowClass.equals("oddRow") )
            rowClass = "evenRow";
        else
            rowClass = "oddRow";

        String videoUrl="&nbsp;";
        if( ps.getVideoUrl()!=null ) {
            videoUrl = "<A HREF=\""+ps.getVideoUrl()+"\">view video</A>";
        }
%>
    <tr class="<%=rowClass%>">
        <td><%=ps.getName()%></td>
        <td><%=ps.getModeller()%></td>
        <td><%=ps.getProteinAccId()%></td>
        <td><%=ps.getProteinAaRange()%></td>
        <% if( ps.getModeller().equals("AlphaFold") ) {%>
        <td><a href="/rgdweb/jsmol/alphafold.jsp?p=<%=ps.getProteinAccId()%>&species=<%=SpeciesType.getShortName(obj.getSpeciesTypeKey())%>">view protein structure</a></td>
        <% } else { %>
        <td><a href="/rgdweb/jsmol/rgd.jsp?d=<%=ps.getName()%>">view protein structure</a></td>
        <% } %>
        <td><%=videoUrl%></td>
    </tr>
    <% } %>
</table>
<br>
<%--    <%=ui.dynClose("proteinStructures")%>--%>
</div>
<% } %>

<%@ include file="../sectionFooter.jsp"%>
