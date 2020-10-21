<%@ include file="../sectionHeader.jsp"%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3>Marker: <%=obj.getName()%></h3></td></tr>
    <tr>
        <td class="label">Symbol:</td>
        <td><%=obj.getName()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Also&nbsp;known&nbsp;as:</td>
        <td>
            <%  List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
                for (Alias a : aliases) {
                    out.print(a.getValue() + ";&nbsp;");
                }
            %>
        </td>
    </tr>

    <% if (obj.getSslpType()!=null ) { %>
    <tr>
        <td class="label">Type:</td>
        <td><%=obj.getSslpType()%></td>
    </tr>
    <% } %>

    <tr>
        <td class="label">Expected Size:</td>
        <td><%=obj.getExpectedSize()%> (bp)</td>
    </tr>

    <% if (obj.getNotes()!=null && !obj.getNotes().isEmpty() ) { %>
    <tr>
        <td class="label">Notes</td>
        <td><%=obj.getNotes()%></td>
    </tr>
    <% } %>

    <tr>
        <td class="label">Position</td>
        <td><%=MapDataFormatter.buildTable(obj.getRgdId(), obj.getSpeciesTypeKey(), rgdId.getObjectKey(), obj.getName())%></td>
    </tr>
    <%@ include file="../markerFor.jsp"%>

</table>

<%@ include file="../sectionFooter.jsp"%>
