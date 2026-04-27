<%@ page import="edu.mcw.rgd.gviewer.GViewerBean" %>
<link rel="stylesheet" type="text/css" href="/rgdweb/css/ontology.css">
<script src="/rgdweb/js/sorttable.js"></script>
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
  <%
      GViewerBean bean = (GViewerBean) request.getAttribute("bean");
      String assemblyName = bean.getAssemblyName();
  %>
  <% if( assemblyName!=null && !assemblyName.isEmpty() ) { %>
  <div style="padding: 6px 10px; font-size:13px; color:#555;">
      <strong>Assembly:</strong> <%=assemblyName%>
  </div>
  <% } %>
  <table border='0' style='font-size:13px;' width='95%' class="sortable" cellpadding=3>
      <thead>
      <tr style="font-weight:bold;" class="srH1">
          <th>Type</th>
          <th>Object Symbol</th>
          <th>Chromosome</th>
          <th>Position</th>
          <%
          for( int t=0; t<bean.getTerms().length; t++ ) {
          %>
          <th>Annotated Term</th>
          <%
          }
          %>
      </tr>
      </thead>
      <tbody>
      <%
          int rowCount = 0;
          for( String[] line: bean.getLines() ) {
              //String rgdId = line[0];
              String objectType = line[1];
              String symbol = line[2];
              String link = line[3];
              String chromosome = line[4];
              String position = line[5];

              if( ++rowCount %2 == 0) { %>
       <tr class="oddRow">
       <% } else { %>
       <tr class="evenRow">
       <% } %>

          <td class="objtag_<%=objectType%>" style="color:white;" title="<%=objectType%>"><%=objectType.substring(0,1).toUpperCase() + objectType.substring(1)%></td>
          <td><a href="<%=link%>"><%=symbol%></a></td>
          <td><%=chromosome==null?"":chromosome%></td>
          <td><%=position==null?"":position%></td>
          <%
            for( int termIndex=0; termIndex<bean.getTerms().length; termIndex++ ) {
          %>
          <td class="trm"><%=line[6+termIndex]==null?"-":line[6+termIndex]%></td>
          <%
              }
          %>
      </tr>
      <% } %>
      </tbody>
  </table>
