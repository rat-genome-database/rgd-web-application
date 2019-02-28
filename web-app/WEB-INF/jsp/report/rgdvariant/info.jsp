<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ include file="../sectionHeader.jsp"%>
<style>
    .wrap660 {
        display: block;
        width: 660px;
        word-break: break-all;
    }
</style>
<%
    String objType = "{unknown object type}";
    String description = null;
    RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());
    if( rgdId!=null ) {
        objType = rgdId.getObjectTypeName();
        description = obj.getDescription();
    }
    OntologyXDAO odao = new OntologyXDAO();
    Term t = odao.getTermByAccId(obj.getType());
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3>Variant: <%=Utils.NVL(obj.getName(), "")%>&nbsp;-&nbsp; <%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%></h3></td></tr>

    <tr>
        <td class="label" valign="top">Name:</td>
        <td><%=Utils.NVL(obj.getName(), "")%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Description:</td>
        <td><%=Utils.NVL(description, "")%></td>
    </tr>

    <tr>
        <td class="label">Type:</td>
        <td><%=t.getTerm()%>&nbsp;<a href="<%=Link.ontView(obj.getType())%>" title="click to go to sequence ontology"><%= "("+ obj.getType() + ")"%></a></td>
    </tr>
    <%  GeneDAO gdao = new GeneDAO();
        List<Gene> geneList = gdao.getAssociatedGenes(obj.getRgdId());
        String genes="";
        if (geneList.size() > 0) {

            // sort strains by symbol
            Collections.sort(geneList, new Comparator<Gene>() {
                public int compare(Gene o1, Gene o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                }
            });
         for(Gene g: geneList){
             String url = Link.gene(g.getRgdId());
             genes = genes.concat("&nbsp;<a href="+url+">");
             genes=genes.concat(g.getSymbol());
             genes = genes.concat("</a>&nbsp;,");
         }
    %>
    <tr>
        <td class="label" valign="top">Associated Genes:</td>
        <td><%=genes%></td>
    </tr>
    <% }  %>
    <tr>
        <td class="label" valign="top">Reference Nucleotide:</td>
        <td class="wrap660"><%=Utils.NVL(obj.getRefNuc(), "")%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Variant Nucleotide:</td>
        <td class="wrap660"><%=Utils.NVL(obj.getVarNuc(), "")%></td>
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
        <td class="label" valign="top">Aliases:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% }  %>


</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
