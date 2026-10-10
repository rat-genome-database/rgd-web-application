<%@ page import="edu.mcw.rgd.datamodel.Note" %>
<%@ page import="edu.mcw.rgd.dao.impl.AliasDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Alias" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>

<%
    if (displayRgdId!=0) {
    AliasDAO aliasDAO = new AliasDAO();
    List<Alias> aliasList = aliasDAO.getAliases(displayRgdId);

    // remove array_id_affy_ aliases (they are updated weekly by pipeline)
    int countOfArrayIdAffyAliases = 0;
    Iterator<Alias> itAlias = aliasList.iterator();
    while( itAlias.hasNext() ) {
        Alias alias = itAlias.next();
        if( alias.getTypeName()!=null && alias.getTypeName().startsWith("array_id_") ) {
            itAlias.remove();
            countOfArrayIdAffyAliases++;
        }
    }

    // sort by type, then by name
    Collections.sort(aliasList, new Comparator<Alias>() {
        public int compare(Alias o1, Alias o2) {
            int res = Utils.stringsCompareToIgnoreCase(o1.getTypeName(), o2.getTypeName());
            if (res != 0)
                return res;
            return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
        }
    });
%>

<form action="updateAliases.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="aliasTable" border="0" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td style="background-color:#2865a3;color:white; font-weight: 700;">Aliases</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="2" align="right"><a href="javascript:addAlias(); void(0);" style="font-weight:700; color: green;">Add Alias</a></td>
    </tr>

    <tr>
        <td class="label">Type</td>
        <td class="label">Value</td>
    </tr>

    <%
        int aliasCount=1;
        for (Alias alias : aliasList) {
            if (rgdId != displayRgdId) {
                alias.setKey(0);
            }
    %>
<tr id="aliasRow<%=aliasCount%>">
    <input type="hidden" name="aliasKey" value="<%=alias.getKey()%>"/>
    <td><%=fu.buildSelectList("aliasTypeName", aliasDAO.getAliasTypesExcludingArrayIds(), dm.out("aliasTypeName", alias.getTypeName()))%>
    <td><input type="text" id="aliasValue" size=66 name="aliasValue" value="<%=dm.out("aliasValue", alias.getValue())%>"/>
      <a style="color:red; font-weight:700;" href="javascript:removeAlias('aliasRow<%=aliasCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        aliasCount++;
    }
    %>
    </tbody>
</table>
</form>
<% if( countOfArrayIdAffyAliases>0 ) { %>
   <div style="font-weight:bold;color:red">Note: <%=countOfArrayIdAffyAliases%> Array Ids are not shown, because they are automatically updated by a pipeline on a weekly basis.<p></div>
<% } %>
<% } %>
