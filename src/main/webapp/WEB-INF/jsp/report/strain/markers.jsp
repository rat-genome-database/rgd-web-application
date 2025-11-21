<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ include file="../sectionHeader.jsp"%>

<% List<Strain2MarkerAssociation> strainAssocs = associationDAO.getStrain2SslpAssociations(obj.getRgdId());
    strainAssocs.addAll(associationDAO.getStrain2GeneAssociations(obj.getRgdId()));
    strainAssocs.addAll(associationDAO.getStrain2StrainAssociations(obj.getRgdId()));
    strainAssocs.addAll(associationDAO.getStrain2VariantAssociations(obj.getRgdId()));

    // remove alleles from the list (many genes are alleles)
    Iterator<Strain2MarkerAssociation> its2m = strainAssocs.iterator();
    while( its2m.hasNext() ) {
        if( Utils.stringsAreEqual(Utils.NVL(its2m.next().getMarkerType(),"allele"), "allele") ) {
            its2m.remove();
        }
    }

    if(!strainAssocs.isEmpty()) { %>
<%--<%=ui.dynOpen("markerAssociation", "Position Markers")%>--%>
<div id="markerAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="markerAssociation">Position Markers</div>
<table>
<%
    for( Strain2MarkerAssociation sa: strainAssocs ) {
%>
    <tr>
        <td valign="top"><br><%=StringUtils.capitalize(sa.getAssocType())%> / <%=sa.getRegionName()%> (<a href="<%=Link.it(sa.getMarkerRgdId())%>"><%=!Utils.isStringEmpty(sa.getMarkerSymbol()) ? sa.getMarkerSymbol() : "RGD:"+sa.getMarkerRgdId()%></a>)</td>
        <td><%=MapDataFormatter.buildTable(sa.getMarkerRgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
    <% } %>
</table>
<%--<%=ui.dynClose("markerAssociation")%>--%>
<% } %>
</div>
<%@ include file="../sectionFooter.jsp"%>
