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

/* Hovering a result row highlights the matching dot in the chromosome view */
table.sortable tbody tr[data-symbol]:hover {
    background-color: #fff3cd !important;
    cursor: default;
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

              // Strip any HTML tags from the displayed symbol so that what
              // we send to gview().highlight matches the SVG annotation name
              // (which is set from the un-tagged label in the JSON feed).
              String hlSymbol = symbol == null ? "" : symbol.replaceAll("<.*?>", "");
              String hlChr = chromosome == null ? "" : chromosome;
              // Attribute values are HTML-quoted; double-quote and ampersand
              // are the only chars that need escaping inside the value.
              String hlSymbolAttr = hlSymbol.replace("&", "&amp;").replace("\"", "&quot;");
              String hlChrAttr = hlChr.replace("&", "&amp;").replace("\"", "&quot;");

              String hover = " data-chr=\"" + hlChrAttr + "\""
                  + " data-symbol=\"" + hlSymbolAttr + "\""
                  + " onmouseover=\"if(typeof gview==='function'&&gview())gview().highlight(this.getAttribute('data-chr'),this.getAttribute('data-symbol'),'#FFD700')\""
                  + " onmouseout=\"if(typeof gview==='function'&&gview())gview().lowlight(this.getAttribute('data-chr'),this.getAttribute('data-symbol'))\"";

              if( ++rowCount %2 == 0) { %>
       <tr class="oddRow"<%=hover%>>
       <% } else { %>
       <tr class="evenRow"<%=hover%>>
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
