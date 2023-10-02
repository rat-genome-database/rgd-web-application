<% if (!isNew) { %>

<%
   GenomicElementDAO geDAO = new GenomicElementDAO();
   List<GenomicElementAttr> attrList = geDAO.getElementAttrs(displayRgdId);
%>

<form action="updateGenomicElementAttr.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="attrTable" border="0" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Attributes</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="3" align="right"><a href="javascript:addElementAttr(); void(0);" style="font-weight:700; color: green;">Add Attribute</a></td>
    </tr>

    <tr>
        <td class="label">Type</td>
        <td colspan="2" class="label">Value</td>
    </tr>

    <%
        int attrCount=1;
        for (GenomicElementAttr attr : attrList) {
            if (rgdId != displayRgdId) {
                attr.setKey(0);
            }
    %>
<tr id="attrRow<%=attrCount%>">
    <input type="hidden" name="attrKey" value="<%=attr.getKey()%>"/>
    <td><input type="text" id="attrName" name="attrName"
               value="<%=dm.out("attrName", attr.getName())%>" /></td>
    <td><input type="text" size=40 id="attrValue" name="attrValue"
               value="<%=dm.out("attrValue", attr.getTextValue())%>"/></td>
    <td align="right"><a style="color:red; font-weight:700;"
                         href="javascript:removeElementAttr('attrRow<%=attrCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        attrCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>
