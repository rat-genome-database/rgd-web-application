<%@ include file="../sectionHeader.jsp"%>

<%
List<QTL> qtls = associationDAO.getQtlAssociationsByGene(obj.getKey());
if( !qtls.isEmpty() ) {
%>

<%=ui.dynOpen("candAsscociation", "Candidate Gene Status")%>    <br>
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
<br>
    <%=ui.dynClose("candAsscociation")%>

<% } %>    

<%@ include file="../sectionFooter.jsp"%>
