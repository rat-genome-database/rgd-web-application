<%@ page import="edu.mcw.rgd.dao.impl.SearchDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.search.IndexRow" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>

<table border="0" width="95%">
    <tr>
        <td width="20%"></td>
        <td width="20%" style="border-bottom: 1px solid black; font-weight:700;">Symbol</td>
        <td width="20%" style="border-bottom: 1px solid black; font-weight:700;">RGD ID</td>
        <td>&nbsp;</td>
        <td width="20%" style="border-bottom: 1px solid black; font-weight:700;">Type</td>
        <td>&nbsp;</td>
        <td width="20%" style="border-bottom: 1px solid black; font-weight:700;">SPC</td>
    </tr>
<%
    SearchDAO dao = new SearchDAO();

    String searchStringLc = request.getParameter("search");
    if (searchStringLc!=null) {
        searchStringLc = searchStringLc.toLowerCase();
    }

    List<IndexRow> lookupList = dao.findSymbol(searchStringLc, SpeciesType.parse(request.getParameter("speciesTypeKey")), request.getParameter("objectType"));
    for( IndexRow ir: lookupList ) {
%>
<tr>
    <td><a href="javascript:lookup_update('<%=ir.getRgdId()%>')">(select)</a></td>
    <td><%=ir.getKeyword()%></td>
    <td align="right"><%=ir.getRgdId()%></td>
    <td>&nbsp;</td>
    <td><%=ir.getObjectType()%></td>
    <td>&nbsp;</td>
    <td><%=ir.getSpeciesTypeKey()%></td>
</tr>
<% } %>
</table>

<% if (lookupList.size() == 0) { %>
  <br>&nbsp;&nbsp;<b>O</b> records found for search term <b>"<%=request.getParameter("search")%>"</b>     
<% } %>
