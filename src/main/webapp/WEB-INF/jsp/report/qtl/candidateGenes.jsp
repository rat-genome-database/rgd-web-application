<%@ include file="../sectionHeader.jsp"%>

<%

List genes = associationDAO.getGeneAssociationsByQTL(obj.getRgdId());


if (genes.size() > 0) {
%>

<%--<%=ui.dynOpen("candAsscociation", "Candidate Gene Status")%>    <br>--%>
<div class="sectionHeading" id="candidateGenes">Candidate Gene Status</div>
<table>
<%

    Iterator qit = genes.iterator();
    while (qit.hasNext()) {
        Gene g = (Gene) qit.next();
%>

<tr>
    <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="<%=Link.gene(g.getRgdId())%>"><%=g.getSymbol()%></a> is a candidate Gene for <span class="highlight"><%=obj.getSymbol()%></span></td>
</tr>

        <% } %>
</table>
<br>
<%--    <%=ui.dynClose("candAsscociation")%>--%>

<% } %>    

<%@ include file="../sectionFooter.jsp"%>
