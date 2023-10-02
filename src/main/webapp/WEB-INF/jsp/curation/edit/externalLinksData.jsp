<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%  // xdb_key => xdb_name
    java.util.Map<String,String> externalLinkTypes = new LinkedHashMap<String, String>(); // to have keys in insert order
    XdbIdDAO xdbIdDAO = new XdbIdDAO();
    List<Xdb> xdbIds = xdbIdDAO.getActiveXdbs();
    Collections.sort(xdbIds, new Comparator<Xdb>(){
        public int compare(Xdb o1, Xdb o2) {
            return Utils.stringsCompareToIgnoreCase(o1.getName(), o2.getName());
        }
    });
    for( Xdb xdb: xdbIds ) {
        externalLinkTypes.put(Integer.toString(xdb.getKey()), xdb.getName());
    }
%>
<% if (!isNew) {

    XdbId filter = new XdbId();
    filter.setRgdId(rgdId);
    List<XdbId> xdbIdsInRgd = xdbIdDAO.getXdbIds(filter);
    // sort by xdb_key, then by acc_id
    Collections.sort(xdbIdsInRgd, new Comparator<XdbId>() {
        public int compare(XdbId o1, XdbId o2) {
            int r = o1.getXdbKey() - o2.getXdbKey();
            if( r!=0 )
                return r;
            return Utils.stringsCompareToIgnoreCase(o1.getAccId(), o2.getAccId());
        }
    });
%>

<form action="updateExternalLinks.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="externalLinksTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="5" style="background-color:#2865a3;color:white; font-weight: 700;">External Database Links</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="6" align="right"><a href="javascript:addExternalLink(); void(0);" style="font-weight:700; color: green;">Add External Link</a></td>
    </tr>

    <tr>
        <td class="label">Xdb</td>
        <td class="label">Acc Id</td>
        <td class="label">Link Text</td>
        <td class="label">Source</td>
        <td colspan="2" class="label">Notes</td>
    </tr>
    <%
        int externalLinksCount=1;
        for (XdbId xdbId : xdbIdsInRgd) {
            if (rgdId != displayRgdId) {
                xdbId.setKey(0);
            }
    %>
<tr id="externalLinksRow<%=externalLinksCount%>">
    <input type="hidden" name="accXdbKey" value="<%=xdbId.getKey()%>"/>
    <td><%=fu.buildSelectList("xdbKey", externalLinkTypes, dm.out("xdbKey", xdbId.getXdbKey()))%></td>
    <td><input type="text" name="accId" value="<%=fu.chkNull(xdbId.getAccId())%>"/></td>
    <td><input type="text" name="linkText" value="<%=fu.chkNull(xdbId.getLinkText())%>"/></td>
    <td><input type="text" name="srcPipeline" value="<%=fu.chkNull(xdbId.getSrcPipeline())%>"/></td>
    <td><textarea cols=32 rows="1" name="notes"><%=fu.chkNull(xdbId.getNotes())%></textarea></td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeExternalLink('externalLinksRow<%=externalLinksCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        externalLinksCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function removeExternalLink(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var externalLinksCreatedCount = 1;
    function addExternalLink() {

        var tbody = document.getElementById("externalLinksTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdExternalLinksRow" + externalLinksCreatedCount;
        row.innerHTML = '<input type="hidden" name="accXdbKey" value="0"/>';

        var td = document.createElement("TD");
        td.innerHTML = '<%=fu.buildSelectList("xdbKey", externalLinkTypes, "1")%>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" name="accId" value=""> ';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" name="linkText" value=""> ';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" name="srcPipeline" value=""> ';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<textarea cols=32 rows="1" name="notes"></textarea>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.align = "right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeExternalLink('createdExternalLinksRow" + externalLinksCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        externalLinksCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>