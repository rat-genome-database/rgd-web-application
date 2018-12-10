<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    String objType = "{unknown object type}";
    String description = null;
    RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());
    if( rgdId!=null ) {
        objType = rgdId.getObjectTypeName();
        description = obj.getDescription();
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3><%=objType%> : <%=obj.getName()!=null?"("+obj.getName()+")":""%>&nbsp;<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%></h3></td></tr>

    <tr>
        <td class="label" valign="top">Name:</td>
        <td><%=obj.getName()==null ? "" : obj.getName()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Description:</td>
        <td><%=description==null ? "" : description%></td>
    </tr>

    <tr>
        <td class="label">Type:</td>
        <td><%=obj.getType()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Reference Nucleotide:</td>
        <td><%=obj.getRef_nuc()==null ? "" : obj.getRef_nuc()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Variant Nucleotide:</td>
        <td><%=obj.getVar_nuc()==null ? "" : obj.getVar_nuc()%></td>
    </tr>
    <%

        List<MapData> mapData = mapDAO.getMapData(obj.getRgdId());
    %>
    <tr>
        <td class="label">Position</td>
        <td><%=MapDataFormatter.buildTable(obj.getRgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>


    <%
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
        if (aliases.size() > 0 ) {
            // sort aliases alphabetically by alias value
            Collections.sort(aliases, new Comparator<Alias>() {
                public int compare(Alias o1, Alias o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
                }
            });
    %>
    <tr>
        <td class="label" valign="top">Trait Synonyms:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>


</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
