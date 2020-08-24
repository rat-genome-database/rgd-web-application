<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ include file="sectionHeader.jsp"%>

<%
    List<XdbId> ei = DaoUtils.getInstance().getExternalDbLinks(obj.getRgdId(), obj.getSpeciesTypeKey());
    if (ei.size() > 0) {
%>

<%//ui.dynOpen("xdbAssociation", "External Database Links")%>
<div class="sectionHeading" id="externalDatabaseLinks">External Database Links</div>

<div id="externalDatabaseLinksTableDiv">

    <div id="modelsViewContent" >
        <div id="externalDatabaseLinksPager" class="pager" style="float:right;margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="3">3</option>
                    <option value="5">5</option>
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


<table border="0" id="externalDatabaseLinksTable" class="tablesorter">
    <thead>
        <tr>
            <td style="background-color:#a2a2a2;"><b>Database</b></td>
            <td style="background-color:#a2a2a2;"><b>Acc Id</b></td>
            <td style="background-color:#a2a2a2;"><b>Source(s)</b></td>
        </tr>
    </thead>
    <tbody>
<%
    int lastXdbKey=0;
    String lastLink="", fullUrl;
    for (XdbId xid: ei) {
        Xdb xdb = XDBIndex.getInstance().getXDB(xid.getXdbKey());
%>
    <tr><%
               if (lastXdbKey != xid.getXdbKey()) {
                   lastXdbKey= xid.getXdbKey();
                   lastLink = null;
                   if( xdb!=null ) {
                       lastLink = xdb.getUrl(obj.getSpeciesTypeKey());
                   }
            %>

               <td style="background-color:#e2e2e2;"><b><%=xdb.getName()%></b></td>
           <% } else {%>
               <td style="background-color:#e2e2e2;">&nbsp;</td>
           <% }
              if( lastLink == null ) {
           %>
               <td style="background-color:#e2e2e2;"><%=xid.getAccId()%></td>
           <% } else {

               String link=xid.getLinkText()==null?xid.getAccId():xid.getLinkText();

               // some links have placeholder string "[ID_HERE]" to be replaced by actual accession id
               if( lastLink.contains("[ID_HERE]") ) {
                   fullUrl = lastLink.replace("[ID_HERE]", xid.getAccId());
               }
               else {
                   fullUrl = lastLink + xid.getAccId();
               }
           %>
           <td style="background-color:#e2e2e2;"><a href="<%=fullUrl%>"><%=link%></a></td>
           <td style="background-color:#e2e2e2;"><%=Utils.defaultString(xid.getSrcPipeline())%></td>
          <% } %>
    </tr>
<%
    }
%>
    </tbody>
</table>
</div>
<br>
<%//ui.dynClose("xdbAssociation")%>
<%
    }
%>
<%@ include file="sectionFooter.jsp"%>
