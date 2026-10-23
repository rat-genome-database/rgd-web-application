<%@ page import="java.util.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>

<%
    String title = "Protein Domains";
    GenomicElement obj = (GenomicElement) request.getAttribute("reportObject");
    String objectType="proteinDomain";
    String displayName=obj.getSymbol();

    List<Gene> genes = geneDAO.getGenesForProteinDomain(obj.getRgdId());

    // one row per lower-case gene symbol, with that symbol's gene in each species
    Map<String, Map<Integer, Gene>> geneSymbolsMap = new TreeMap<>();
    Map<Integer, Integer> geneCountBySpecies = new HashMap<>();
    for( Gene g: genes ) {
        geneSymbolsMap.computeIfAbsent(g.getSymbol().toLowerCase(), k -> new HashMap<>()).put(g.getSpeciesTypeKey(), g);
        geneCountBySpecies.merge(g.getSpeciesTypeKey(), 1, Integer::sum);
    }

    // a column for each species with genes; species without genes are listed under the table
    List<Integer> speciesColumns = new ArrayList<>();
    List<String> speciesWithoutGenes = new ArrayList<>();
    for( int sp: SpeciesType.getSpeciesTypeKeys() ) {
        if( !SpeciesType.isSearchable(sp) ) {
            continue;
        }
        if( geneCountBySpecies.containsKey(sp) ) {
            speciesColumns.add(sp);
        } else {
            speciesWithoutGenes.add(SpeciesType.getCommonName(sp));
        }
    }
    int ratGeneCount = geneCountBySpecies.getOrDefault(SpeciesType.RAT, 0);

    String description = displayName;
    String pageTitle = obj.getSymbol() + " (" + obj.getName() + ") - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = description;
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script type="application/ld+json">
{
"@context": "http://schema.org",
"@type": "Dataset",
"name": "<%=obj.getSymbol()%>",
"description": "<%=pageDescription%>",
"url": "https://rgd.mcw.edu/rgdweb/report/proteinDomain/main.html?id=<%=obj.getRgdId()%>",
"keywords": "Rat Gene RGD Genome",
"includedInDataCatalog": "https://rgd.mcw.edu",
"creator": {
"@type": "Organization",
"name": "Rat Genome Database"
},
"version": "1",
"license": "Creative Commons CC BY 4.0"
}
</script>


<style>
    #domain-info td.label { white-space: nowrap; width: 160px; font-weight: 700; color: #2865A3; padding: 3px 8px; }
    #domain-info td { padding: 3px 8px; }
    #domainGenes { width: auto; margin-top: 6px; }
    #domainGenes th { white-space: nowrap; padding: 6px 22px 6px 10px; }
    #domainGenes td { white-space: nowrap; padding: 4px 10px; }
    #domainGenes th .gene-count { font-weight: 400; }
    .domain-note { color: #555; font-size: 12px; margin-top: 8px; }
</style>

<table width="95%" style="padding-top:10px;" border="0">
    <tr>
        <td valign="top">
            <table id="domain-info" width="100%" border="0" style="background-color: rgb(249, 249, 249)">
                <tr><td colspan="2"><h3>Protein Domain : <%=obj.getSymbol()%><%=obj.getName()==null || obj.getName().trim().isEmpty() || obj.getName().equals(obj.getSymbol()) ? "" : " ("+obj.getName()+")"%></h3></td></tr>
                <tr>
                    <td class="label">Symbol:</td>
                    <td><%=obj.getSymbol()%></td>
                </tr>
                <tr>
                    <td class="label">Name:</td>
                    <td><%=Utils.NVL(obj.getName(), "N/A")%></td>
                </tr>
                <tr>
                    <td class="label">Description:</td>
                    <td><%=Utils.NVL(obj.getDescription(), "N/A")%></td>
                </tr>
                <tr>
                    <td class="label">Source:</td>
                    <td><%=Utils.NVL(obj.getSource(), "N/A")%></td>
                </tr>
                <tr>
                    <td class="label">SO Acc Id:</td>
                    <td><% if( obj.getSoAccId()==null ) { %>N/A<% } else { %><a href="<%=Link.ontView(obj.getSoAccId())%>" title="click to go to sequence ontology"><%=obj.getSoAccId()%></a><% } %></td>
                </tr>
                <tr>
                    <td class="label">Genes:</td>
                    <td><%=ratGeneCount%> rat gene<%=ratGeneCount==1?"":"s"%>; <%=genes.size()%> gene<%=genes.size()==1?"":"s"%> in <%=speciesColumns.size()%> species</td>
                </tr>
            </table>

            <br>
            <div class="sectionHeading">Genes with the <%=obj.getSymbol()%> Domain</div>
            <% if( genes.isEmpty() ) { %>
                <p>No genes are annotated with this protein domain.</p>
            <% } else { %>
            <table id="domainGenes" class="tablesorter">
                <thead>
                <tr>
                    <% for( int sp: speciesColumns ) { %>
                    <th><%=SpeciesType.getCommonName(sp)%> <span class="gene-count">(<%=geneCountBySpecies.get(sp)%>)</span></th>
                    <% } %>
                </tr>
                </thead>
                <tbody>
                <% for( Map<Integer, Gene> row: geneSymbolsMap.values() ) { %>
                <tr>
                    <% for( int sp: speciesColumns ) {
                        Gene g = row.get(sp); %>
                    <td><% if( g!=null ) { %><a href="<%=Link.gene(g.getRgdId())%>"><%=g.getSymbol()%></a><% } %></td>
                    <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% if( !speciesWithoutGenes.isEmpty() ) { %>
            <div class="domain-note">No genes with this domain in: <%=String.join(", ", speciesWithoutGenes)%>.</div>
            <% } %>
            <script>
                $(function() {
                    $("#domainGenes").tablesorter({ theme: 'blue', widgets: ['zebra'], emptyTo: 'bottom' });
                });
            </script>
            <% } %>
        </td>
        <td>&nbsp;</td>
        <td valign="top">
            <%@ include file="../idInfo.jsp" %>
        </td>
    </tr>
</table>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>