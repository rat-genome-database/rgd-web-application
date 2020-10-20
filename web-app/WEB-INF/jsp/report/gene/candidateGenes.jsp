<%@ include file="../sectionHeader.jsp"%>

<%
List<QTL> qtls = associationDAO.getQtlAssociationsByGene(obj.getKey());
if( !qtls.isEmpty() ) {
%>
<div class="light-table-border">
<div class="sectionHeading" id="candidateGeneStatus">Candidate Gene Status</div>

<table>
<%
    for (QTL q : qtls) {
%>
    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png'/></td>
        <td><span class="highlight"><%=obj.getSymbol()%></span> is a candidate Gene for QTL <a
                href="<%=Link.qtl(q.getRgdId())%>"><%=q.getSymbol()%>
        </td>
    </tr>
    <% } %>
</table>


<% } %>    
</div>
<%@ include file="../sectionFooter.jsp"%>
