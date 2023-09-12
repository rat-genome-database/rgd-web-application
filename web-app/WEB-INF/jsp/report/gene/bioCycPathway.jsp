<%
    String biocycImageUrl = xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_BIOCYC_PATHWAY);
    String bioCycPathwayUrl = xdbDAO.getXdbUrlnoSpecies(140);

    if (!xdbBioCycPathway.isEmpty()) {
        PathwayDAO pdao = new PathwayDAO();
    %>

<div class="dialog-2" >You are attempting to leave RGD to go to BioCyc.
    <br>
    You have a certain amount of views per day before you need to subscribe to their service.
</div>

<div class="reportTable light-table-border" id="bioCycPathwayTableWrapper">
    <h4>BioCyc Pathways</h4>

    <div id="bioCycPathwayTableDiv" >
        <table border="0" id="bioCycPathway">
            <thead></thead>
            <tbody>
<%
        for (XdbId xdb : xdbBioCycPathway){
            BioCycRecord r = pdao.getBioCycRecord(rgdId.getRgdId(), xdb.getAccId());
%>
            <tr style="background: #f1f1f1">
                <td>
                    <table id="rowTable" style="width: 100%">
                        <tr style="width: inherit">
                            <td style="border: none">
                            <b><%= (r != null && !r.getPathwayRatCycName().isEmpty()) ? r.getPathwayRatCycName() : xdb.getAccId()%></b>
                            </td>
                            <td style="float: right; border: none">
                                <button style="border: none; text-underline: black" onclick="redirect('<%=bioCycPathwayUrl+xdb.getAccId()%>')"><u>View at BioCyc</u></button>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr style="text-align: center; padding-bottom: 100px">
                <td>
                    <a href="javascript:void(0)" onclick="redirect('<%=bioCycPathwayUrl+xdb.getAccId()%>')">
                        <img style="padding-bottom: 15px; padding-top: 5px" src="<%=biocycImageUrl+xdb.getAccId()%>">
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
    function redirect(redirectLink) {
        $( ".dialog-2" ).data('redirectLink',redirectLink).dialog( "open" );
    }

    $(function() {
        $( ".dialog-2" ).dialog({
            autoOpen: false,
            buttons: {
                OK: function() {
                    window.open($(this).data('redirectLink'), '_blank').focus();
                    $(this).dialog("close");
                },
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            title: "Are you sure?",
            position: {
                my: "top center",
                at: "top+200",
                of: "body"
            },
            minWidth: 500,
            modal: true,
            closeText: "X",
            closeOnEscape: true
        });
    });
</script>
<%  } %>