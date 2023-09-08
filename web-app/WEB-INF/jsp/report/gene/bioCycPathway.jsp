<%
    String biocycUrl = xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_BIOCYC_PATHWAY);

    if (!xdbBioCycPathway.isEmpty()) {%>
<div class="reportTable light-table-border" id="bioCycPathwayTableWrapper">
    <h4>BioCyc Pathway</h4>
    <div id="bioCycPathwayTableDiv" class="annotation-detail">
        <table border="0">
<%
        for (XdbId xdb : xdbBioCycPathway){
%>
            <tr>
                <td>
                    <a href="https://biocyc.org/RAT/NEW-IMAGE?type=PATHWAY&object=<%=xdb.getAccId()%>">
                        <img src="<%=biocycUrl+xdb.getAccId()%>">
                    </a>
                </td>
            </tr>
<%      }   %>
        </table>
    </div>
</div>
<%  } %>