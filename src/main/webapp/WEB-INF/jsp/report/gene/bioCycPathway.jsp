<%
//    String biocycImageUrl = xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_BIOCYC_PATHWAY);
    String bioCycPathwayUrl = xdbDAO.getXdbUrlnoSpecies(140);

    if (!xdbBioCycPathway.isEmpty()) {
        PathwayDAO pdao = new PathwayDAO();
    %>

<div class="reportTable light-table-border" id="bioCycPathwayTableWrapper">
    <h4>BioCyc Pathways</h4>

    <div id="bioCycPathwayTableDiv" >
        <table border="0" id="bioCycPathway">
            <thead></thead>
            <tbody>
<%      int i = 0;
        for (XdbId xdb : xdbBioCycPathway){
            BioCycRecord r = pdao.getBioCycRecord(obj.getRgdId(), xdb.getAccId());
            if (i % 6 == 0) {
%>
            <tr style="background: #f1f1f1">
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>" onclick="return redirect()">
                        <%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%>
                    </a>
                </td>
                <% }
                else if (i % 6 == 5 ) {%>
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>" onclick="redirect()">
                        <%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%>
                    </a>
                </td>
            </tr>
                <%}
                else {%>
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>" onclick="redirect()">
                        <%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%>
                    </a>
                </td>
                <%}%>
<%--            <tr style="text-align: center; padding-bottom: 100px">--%>
<%--                <td>--%>
<%--                    <a href="javascript:void(0)" onclick="redirect('<%=bioCycPathwayUrl+xdb.getAccId()%>')">--%>
<%--                        <img style="padding-bottom: 15px; padding-top: 5px" src="<%=biocycImageUrl+xdb.getAccId()%>">--%>
<%--                    </a>--%>
<%--                </td>--%>
<%--            </tr>--%>
<%      i++;}   %>
            </tbody>
        </table>
    </div>
</div>
<style>
    #bioCycPathway {
        border-collapse:collapse;
        border: none;
    }

    #bioCycPathway tr td {
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