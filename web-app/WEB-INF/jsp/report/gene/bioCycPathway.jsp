<%
    String biocycUrl = xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_BIOCYC_PATHWAY);

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
            <tr style="text-align: center; border-bottom: 1px dashed black;">
                <td>
                    <a href="https://biocyc.org/RAT/NEW-IMAGE?type=PATHWAY&object=<%=xdb.getAccId()%>">
                        <img src="<%=biocycUrl+xdb.getAccId()%>">
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