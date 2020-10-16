<%@ page import="edu.mcw.rgd.datamodel.CellLine" %>
<%@ page import="edu.mcw.rgd.datamodel.GenomicElement" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.*" %>
<%
    List<GenomicElement> relatedElements = associationDAO.getAssociatedGenomicElementsForDetailRgdId(obj.getRgdId(), "cellline_to_"+objectType);
    if( relatedElements.size() > 0 ) {

        // sort by gene symbol
        Collections.sort(relatedElements, new Comparator<GenomicElement>() {
            public int compare(GenomicElement o1, GenomicElement o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
            }
        });
%>
<%@ include file="sectionHeader.jsp"%>
<div class="light-table-border">
<div class="sectionHeading" id="cellLines">Cell Lines</div>
<table cellpadding="3" cellspacing="1" border="1">
  <tr class="headerRow">
    <td><b>Symbol</b></td>
  </tr>
<% for( GenomicElement ge: relatedElements ) { %>
  <tr>
      <td> <a href="<%=Link.cellLine(ge.getRgdId())%>"><%=ge.getSymbol()%></a> </td>
  </tr>
<% } %>
</table>
</div>
 <p>
<%@ include file="sectionFooter.jsp"%>
<%}%>
