<%@ include file="../sectionHeader.jsp"%>

<%
    List<Strain> strains = strainDAO.getSubStrains(obj.getSymbol());
    if (strains.size() > 0) {
%>

<%--<%=ui.dynOpen("subAsscociation", "Substrains")%>--%>
<div id="subAsscociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="subAsscociation">Substrains</div>
<%
    List records = new ArrayList();
    for (Strain strain: strains) {
        records.add("<tr><td><a href=\"" + Link.strain(strain.getRgdId()) + "\">" + strain.getSymbol() + "</a></td></tr>");
    }
    out.print(formatter.buildTable(records, 3));
%>
<br>
<%--<%=ui.dynClose("subAsscociation")%>--%>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>
