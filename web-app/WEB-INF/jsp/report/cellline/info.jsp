<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    String objType = "{unknown object type}";
    RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());
    if( rgdId!=null ) {
        objType = rgdId.getObjectTypeName();
    }
%>
<p>
<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3><%=objType%> : <%=obj.getSymbol()%>&nbsp;<%=obj.getName()!=null?"("+obj.getName()+")":""%>&nbsp;<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%></h3></td></tr>
    <tr>
        <td class="label">Symbol:</td>
        <td><%=obj.getSymbol()%></td>
    </tr>

    <% if( obj.getName()!=null ) { %>
    <tr>
        <td class="label">Name:</td>
        <td><%=fu.chkNull(obj.getName())%></td>
    </tr>
    <% } %>

    <% if( obj.getObjectType()!=null ) { %>
    <tr>
        <td class="label">Cell Line Type:</td>
        <td><%=fu.chkNull(obj.getObjectType())%></td>
    </tr>
    <% } %>

    <% if( obj.getOrigin()!=null ) { %>
    <tr>
        <td class="label">Origin:</td>
        <td><%=fu.chkNull(obj.getOrigin())%></td>
    </tr>
    <% } %>

    <% if( obj.getGender()!=null ) { %>
    <tr>
        <td class="label">Gender:</td>
        <td><%=fu.chkNull(obj.getGender())%></td>
    </tr>
    <% } %>

    <% if( obj.getGermlineCompetent()!=null ) { %>
    <tr>
        <td class="label">Germline Competent:</td>
        <td><%=fu.chkNull(obj.getGermlineCompetent())%></td>
    </tr>
    <% } %>

    <% if( obj.getSource()!=null ) { %>
    <tr>
        <td class="label">Source:</td>
        <td><%=fu.chkNull(obj.getSource())%></td>
    </tr>
    <% } %>

    <% if( obj.getResearchUse()!=null ) { %>
    <tr>
        <td class="label">Research Use:</td>
        <td><%=fu.chkNull(obj.getResearchUse())%></td>
    </tr>
    <% } %>

    <% if( obj.getAvailability()!=null ) { %>
    <tr>
        <td class="label">Availability:</td>
        <td><%=fu.chkNull(obj.getAvailability())%></td>
    </tr>
    <% } %>

    <% if( obj.getCharacteristics()!=null ) { %>
    <tr>
        <td class="label">Characteristics:</td>
        <td><%=fu.chkNull(obj.getCharacteristics())%></td>
    </tr>
    <% } %>

    <% if( obj.getPhenotype()!=null ) { %>
    <tr>
        <td class="label">Phenotype:</td>
        <td><%=fu.chkNull(obj.getPhenotype())%></td>
    </tr>
    <% } %>

    <% if( obj.getNotes()!=null ) { %>
    <tr>
        <td class="label">Notes:</td>
        <td><%=fu.chkNull(obj.getNotes())%></td>
    </tr>
    <% } %>

    <%@ include file="relatedGenes.jsp"%>
    <%@ include file="relatedStrains.jsp"%>

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
        <td class="label" valign="top">Aliases:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>
</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
