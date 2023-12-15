<%
//    String biocycImageUrl = xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_BIOCYC_PATHWAY);
    String bioCycPathwayUrl = xdbDAO.getXdbUrlnoSpecies(140);

    if (!xdbBioCycPathway.isEmpty()) {
        PathwayDAO pdao = new PathwayDAO();
    %>

<div class="reportTable light-table-border" id="bioCycPathwayTableWrapper">
    <h4>BioCyc Pathways</h4>

    <div id="bioCycPathwayTableDiv" >
        <table border="0" id="bioCycPathwayTable" class="tablesorter">
            <thead></thead>
            <tbody>
<%      int i = 0;
        boolean isEven = false;
        for (XdbId xdb : xdbBioCycPathway){
            BioCycRecord r = pdao.getBioCycRecord(obj.getRgdId(), xdb.getAccId());
            if (i % 6 == 0) {
                String rowColor = "";
                if (isEven){
                    rowColor = "#ffffff";
                }
                else {
                    rowColor = "#ebf2fa";
                }
                isEven = !isEven;
%>
            <tr style="background: <%=rowColor%>">
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>" onclick="return redirect()">
                        <%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%>
                    </a>
                </td>
                <% }
                else if (i % 6 == 5 ) {%>
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>" onclick="return redirect()">
                        <%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%>
                    </a>
                </td>
            </tr>
                <%}
                else {%>
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>" onclick="return redirect()">
                        <%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%>
                    </a>
                </td>
                <%}%>
            <% i++;}   %>
            </tbody>
        </table>
    </div>
</div>
<style>
    #bioCycPathwayTable {
        border-collapse:collapse;
        border: none;
    }

    #bioCycPathwayTable tr td {
        border: solid #ccc 1px;
        padding: 5px 7px;
    }

    .ui-widget-header,.ui-state-default, ui-button{
        background: #2865A3;
        border: 2px solid black;
        color: white;
        font-weight: bold;
    }
    .ui-dialog-titlebar-close {

    }
</style>
<script>
    function redirect() {
        return confirm("You are attempting to leave RGD to go to BioCyc.\n" +
            "You have a certain amount of views per day before you need to subscribe to their service.");
    }
</script>
<%  } %>