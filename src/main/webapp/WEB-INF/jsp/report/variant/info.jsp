<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    String objType = "{unknown object type}";
    RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());

    if( rgdId!=null ) {
        objType = rgdId.getObjectTypeName();
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3><%=objType%> : <%=obj.getSymbol()%>&nbsp;<%=obj.getName()!=null?"("+obj.getName()+")":""%>&nbsp;<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%></h3></td></tr>
    <tr>
        <td class="label">Symbol:</td>
        <td><%=obj.getSymbol()%></td>
    </tr>
    <tr>
        <td class="label">Name:</td>
        <td><%=fu.chkNull(obj.getName())%></td>
    </tr>
    <tr>
        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=rgdId.getRgdId()%></td>
    </tr>
    <tr>
        <td class="label">Condition:</td>
        <td><%=fu.chkNull(obj.getTraitName())%></td>
    </tr>

    <tr>
        <td class="label">Clinical Significance:</td>
        <td><%=fu.chkNull(obj.getClinicalSignificance())%></td>
    </tr>
    <tr>
        <td class="label">Last Evaluated:</td>
        <td><%=fu.chkNull(obj.getDateLastEvaluated())%></td>
    </tr>
    <tr>
        <td class="label">Review Status:</td>
        <td><%=fu.chkNull(obj.getReviewStatus())%></td>
    </tr>

    <%@ include file="relatedGenes.jsp"%>
    <tr>
        <td class="label">Variant Type:</td>
        <td><%=fu.chkNull(obj.getObjectType())%>
        <% if( obj.getSoAccId()!=null ) { %>
         (<a href="<%=Link.ontView(obj.getSoAccId())%>" title="click to go to sequence ontology"><%=obj.getSoAccId()%></a>)
        <% } %>
        </td>
    </tr>

    <tr>
        <td class="label">Source:</td>
        <td><%=obj.getSource()%></td>
    </tr>

    <% if( obj.getMolecularConsequence()!=null ) { %>
    <tr>
        <td class="label">Molecular Consequence:</td>
        <td><%=obj.getMolecularConsequence()%></td>
    </tr>
    <% } %>

    <% if( obj.getNucleotideChange()!=null ) { %>
    <tr>
        <td class="label">Nucleotide Change:</td>
        <td><%=obj.getNucleotideChange()%></td>
    </tr>
    <% } %>

    <% if( obj.getMethodType()!=null ) { %>
    <tr>
        <td class="label">Evidence:</td>
        <td><%=obj.getMethodType()%></td>
    </tr>
    <% } %>

    <%
        List<HgvsName> hgvsNames = new VariantInfoDAO().getHgvsNames(obj.getRgdId());
        if( hgvsNames!=null && !hgvsNames.isEmpty() ) { %>
    <tr>
        <td class="label">HGVS Name(s):</td>
        <td><% for( HgvsName hgvsName: hgvsNames ) { %>
            <%=hgvsName.getName()%><br>
        <% }
        %></td>
    </tr>
    <% } %>

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

    <% if( obj.getAgeOfOnset()!=null ) { %>
    <tr>
        <td class="label">Age Of Onset:</td>
        <td><%=obj.getAgeOfOnset()%></td>
    </tr>
    <% } %>

    <% if( obj.getPrevalence()!=null ) { %>
    <tr>
        <td class="label">Prevalence:</td>
        <td><%=obj.getPrevalence()%></td>
    </tr>
    <% } %>

</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
