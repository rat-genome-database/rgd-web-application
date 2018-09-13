<%@ page import="edu.mcw.rgd.gviewer.GViewerBean" %>
<link rel="stylesheet" type="text/css" href="/rgdweb/css/ontology.css">
<script src="/common/js/sorttable.js"></script>
<style>
/* Sortable tables */
table.sortable thead {
    background-color:#eee;
    color:#666666;
    font-weight: bold;
    cursor: pointer;
}

td.trm a {
    color: #0C1D2E;
    font-family: Arial, Helvetica, sans-serif;
    font-size: 12px;
    font-weight: normal;
}
</style>

<br>
  <table border='0' style='font-size:13px;' width='95%' class="sortable" cellpadding=3>
      <thead>
      <tr style="font-weight:bold;" class="srH1">
          <td></td>
          <td>Object Symbol</td>
          <%
          GViewerBean bean = (GViewerBean) request.getAttribute("bean");
          for( String selTermName: bean.getTerms() ) {
          %>
          <td><%=selTermName%></td>
          <%
          }
          %>
      </tr>
      <%
          int rowCount = 0;
          for( String[] line: bean.getLines() ) {
              //String rgdId = line[0];
              String objectType = line[1];
              String symbol = line[2];
              String link = line[3];

              if( ++rowCount %2 == 0) { %>
       <tr class="oddRow">
       <% } else { %>
       <tr class="evenRow">
       <% } %>

          <td class="objtag_<%=objectType%>" title="<%=objectType%> "><%=objectType.substring(0,1).toUpperCase()%></td>
          <td><a href="<%=link%>"><%=symbol%></a></td>
          <%
            for( int termIndex=0; termIndex<bean.getTerms().length; termIndex++ ) {
          %>
          <td class="trm"><%=line[4+termIndex]==null?"-":line[4+termIndex]%></td>
          <%
              }
          %>
      </tr>
      <% } %>
  </table>
