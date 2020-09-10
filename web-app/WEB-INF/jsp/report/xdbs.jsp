<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ include file="sectionHeader.jsp"%>

<%
    List<XdbId> ei = DaoUtils.getInstance().getExternalDbLinks(obj.getRgdId(), obj.getSpeciesTypeKey());
    if (ei.size() > 0) {
%>

<%//ui.dynOpen("xdbAssociation", "External Database Links")%>
<div class="sectionHeading" id="externalDatabaseLinks">External Database Links</div>

<div id="externalDatabaseLinksTableDiv">

<table border="0" id="externalDatabaseLinksTable">
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
