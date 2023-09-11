<%
    String biocycImageUrl = xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_BIOCYC_PATHWAY);
    String bioCycPathwayUrl = xdbDAO.getXdbUrlnoSpecies(140);

    if (!xdbBioCycPathway.isEmpty()) {%>
<div class="reportTable light-table-border" id="bioCycPathwayTableWrapper">
    <h4>BioCyc Pathway</h4>
    <div id="bioCycPathwayTableDiv" >
        <table border="0" id="bioCycPathway">
            <thead></thead>
            <tbody>
<%
        for (XdbId xdb : xdbBioCycPathway){
%>
            <tr style="background: #f1f1f1">
                <td style="text-align: center">
                    <%=xdb.getAccId()%>
                </td>
            </tr>
            <tr style="text-align: center;">
                <td>
                    <a href="<%=bioCycPathwayUrl+xdb.getAccId()%>">
                        <img src="<%=biocycImageUrl+xdb.getAccId()%>">
                    </a>
                </td>
            </tr>
<%      }   %>
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


</style>
<%  } %>