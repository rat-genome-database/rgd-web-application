<%
    List<XdbId> xdbBioCycPathway = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_BIOCYC_PATHWAY, obj.getRgdId());

    if (!xdbBioCycPathway.isEmpty()) {%>

<table>
<%
        for (XdbId xdb : xdbBioCycPathway){
%>


<%      }   %>
</table>

<%  } %>