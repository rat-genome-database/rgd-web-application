
<div class="ssIDTable light-table-border" id="ssIDTableWrapper">
    <div class="sectionHeading" id="ssID">Associated ss ID's</div>
    <div id="ssIDTableDiv" class="annotation-detail">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Associated Strain</th>
            </tr>
            </thead>
            <tbody>
            <%for (VariantSSId ssId : ssIds){
                String evaUrl = xdbDAO.getXdbUrlnoSpecies(158);
                Strain s = strainDAO.getStrain(ssId.getStrainRgdId());%>
            <tr>
                <td>
                    <!-- ss ID -->
                    <a href="<%=evaUrl+ssId.getSSId()%>"><%=ssId.getSSId()%></a>
                </td>
                <td>
                    <!-- strain associated with ss Id -->
                    <a href="/rgdweb/report/strain/main.html?id=<%=s.getRgdId()%>"><%=s.getSymbol()%></a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>