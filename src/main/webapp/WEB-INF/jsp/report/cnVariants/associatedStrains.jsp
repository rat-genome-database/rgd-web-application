
<div class="ssIDTableWrapper light-table-border" id="ssIDTableWrapper">
    <div class="sectionHeading" id="ssID">Associated ss ID's</div>
<%--    <div id="ssIDTableDiv" class="annotation-detail">--%>
        <table id="ssIDTable" class="tablesorter" style="width: auto">
            <thead>
<%--            <tr>--%>
<%--                <th>ID</th>--%>
<%--                <th>Associated Strain</th>--%>
<%--            </tr>--%>
            </thead>
            <tbody>
            <% int ssIdRow = 0;
                for (VariantSSId ssId : ssIds){
                String evaUrl = xdbDAO.getXdbUrlnoSpecies(158);
//                Strain s = strainDAO.getStrain(ssId.getStrainRgdId());
            if (ssIdRow % 5 == 0){%>
            <tr>
                <%}%>
                <td>
                    <!-- ss ID -->
                    <a href="<%=evaUrl+ssId.getSSId()%>"><%=ssId.getSSId()%></a>
                </td>
                <%if (ssIdRow % 5 == 4){%>
            </tr>
            <% }
                ssIdRow++;} %>
            </tbody>
        </table>
<%--    </div>--%>
</div>