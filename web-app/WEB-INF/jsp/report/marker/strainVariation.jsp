<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ include file="../sectionHeader.jsp"%>
<%
List<SslpsAllele> alleleList = sslpAlleleDAO.getSslpsAlleleByKey(obj.getKey());
if (alleleList.size() > 0 ) {

%>
<%--<%=ui.dynOpen("strainAssociation", "Strain Variation")%>--%>
<div id="strainAssociationTableDiv" class="light-table-border">
    <div class="sectionHeading" id="strainAssociation">Strain Variation</div>
Strain, Expected Size(s)<br>
<%

    List<String> records = new ArrayList<String>();
    for (SslpsAllele allele: alleleList) {
        StringBuilder buf = new StringBuilder();
        buf.append("<tr><td><a href=\"").append(Link.strain(allele.getStrainRgdId())).append("\">")
                .append(allele.getStrainSymbol()).append("</a></td>")
                .append("<td>").append(allele.getSize1());
        if( allele.getSize2()>0 ) {
            buf.append(",").append(allele.getSize2());
        }
        buf.append("</td></tr>");
        records.add(buf.toString());
    }
    out.print(formatter.buildTable(records, 4));

%>
 <br>
</div>
<%--<%=ui.dynClose("strainAssociation")%>--%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
