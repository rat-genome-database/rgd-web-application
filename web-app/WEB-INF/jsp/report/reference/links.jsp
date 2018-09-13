<%@ include file="../sectionHeader.jsp"%>

<table class="rgdRightColumnBox" width="180" cellpadding="0" cellspacing="0">
<tr>
    <td colspan="2"><b>More on this Reference</b></td>
</tr>

<%
    //see if there is a pubmed id
    List<XdbId> pmIds = xdbDAO.getXdbIdsByRgdId(2, obj.getRgdId());
    if (pmIds.size() > 0) {
    %>
        <tr>
            <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmIds.get(0).getAccId()%>">Pubmed</a></td>
        </tr>
<% } %>
<tr>
    <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="http://www.informatics.jax.org/searches/reference_form.shtml">Search MGI</a></td>
</tr>
 </table>

<%@ include file="../sectionFooter.jsp"%>