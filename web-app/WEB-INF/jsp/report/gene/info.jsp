<%@ page import="java.util.TreeMap" %>
<%@ include file="../sectionHeader.jsp"%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr>
        <td class="label" valign="top">Symbol:</td>
        <td class="geneList"><%=obj.getSymbol()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Name:</td>
        <td><%=obj.getName()==null ? "" : obj.getName()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Description:</td>
        <td><%=description==null ? "" : description%></td>
    </tr>

    <tr>
        <td class="label" valign="top">Type:</td>
        <td><%=obj.getType()%>

            <%
                List<Gene> geneVariants =  geneDAO.getGeneFromVariant(obj.getRgdId());
                // sort variants by gene symbol
                if( geneVariants.size()>1 ) {
                    Collections.sort(geneVariants, new Comparator<Gene>() {
                        public int compare(Gene o1, Gene o2) {
                            return o1.getSymbol().compareToIgnoreCase(o2.getSymbol());
                        }
                    });
                }
                for (Gene variant: geneVariants) {
            %>
                 &nbsp;of&nbsp;<a href="<%=Link.gene(variant.getRgdId())%>"><%=variant.getSymbol()%></a>&nbsp;&nbsp;
            <% } %>
        </td>
    </tr>

    <% if (obj.getRefSeqStatus() != null) { %>
    <tr>
        <td class="label" valign="top">RefSeq Status:</td>
        <td><a href="https://www.ncbi.nlm.nih.gov/RefSeq/key.html#status"><%=obj.getRefSeqStatus()%></a></td>
    </tr>
    <% } %>

    <%
        String[] aliasTypes = {"old_gene_symbol","old_gene_name","old_uniprot_swissprot_id","old_uniprot_trembl_id"};
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId(), aliasTypes);
        if (aliases.size() > 0 ) {
            // sort aliases alphabetically by alias value
            Collections.sort(aliases, new Comparator<Alias>() {
                public int compare(Alias o1, Alias o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
                }
            });
    %>
    <tr>
        <td class="label" valign="top">Also&nbsp;known&nbsp;as:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>
    <%@ include file="orthologs.jsp"%>

    <%-- OPTIONAL SECTION: RELATED PSEUDOGENES --%>
    <%
        List<Association> assocList =  associationDAO.getAssociationsForMasterRgdId(obj.getRgdId());
        TreeMap<String, Integer> relPseudogenes = null;
        for (Association assoc: assocList) {
            if( !assoc.getAssocType().equals("related_pseudogene") )
                continue;

            Gene agene = geneDAO.getGene(assoc.getDetailRgdId());

            if( relPseudogenes==null )
                relPseudogenes = new TreeMap<String, Integer>();

            relPseudogenes.put(agene.getSymbol(), agene.getRgdId());
        }
        if( relPseudogenes!=null ) {
    %>
    <tr>
        <td class="label" valign="top">Related Pseudogenes:</td>
        <td>
    <%
            for( java.util.Map.Entry<String, Integer> entry: relPseudogenes.entrySet() ) {
    %>
            <a href="<%=Link.gene(entry.getValue())%>"><%=entry.getKey()%></a> &nbsp;
    <% } %>
        </td>
     </tr>
    <% } %>

    <%-- OPTIONAL SECTION: RELATED FUNCTIONAL GENES --%>
    <%
        TreeMap<String, Integer> relFuncGenes = null;
        for (Association assoc: assocList) {
            if( !assoc.getAssocType().equals("related_functional_gene") )
                continue;

            Gene agene = geneDAO.getGene(assoc.getDetailRgdId());

            if( relFuncGenes==null )
                relFuncGenes = new TreeMap<String, Integer>();

            relFuncGenes.put(agene.getSymbol(), agene.getRgdId());
        }
        if( relFuncGenes!=null ) {
    %>
    <tr>
        <td class="label" valign="top">Related Functional Gene:</td>
        <td>
    <%
            for( java.util.Map.Entry<String, Integer> entry: relFuncGenes.entrySet() ) {
    %>
            <a href="<%=Link.gene(entry.getValue())%>"><%=entry.getKey()%></a> &nbsp;
    <% } %>
        </td>
     </tr>
    <% } %>

    <%  // ClinVar variants
        List<VariantInfo> clinvars = new VariantInfoDAO().getVariantsForGene(obj.getRgdId());
        session.setAttribute("clinvars", clinvars);
        // gene alleles/splices
        List<Gene> variants =  geneDAO.getVariantFromGene(obj.getRgdId());

        if (variants.size() > 0) {
    %>
    <tr>
        <td class="label" valign="top">Allele / Splice:</td>
        <td><% for (Gene gene: variants) { %>
                 <a href="<%=Link.gene(gene.getRgdId())%>"><%=gene.getSymbol()%></a>&nbsp;&nbsp;
            <% } %>
        </td>
    </tr>
    <% } else if( !clinvars.isEmpty() ){ %>
    <tr>
        <td class="label" valign="top">Allele / Splice:</td>
        <td><a href="#clinicalVariants" onclick="if(! $('#clinicalVariants_content').is(':visible')){openSection(document.getElementById('clinicalVariants'))}">See ClinVar data</a></td>
    </tr>
    <% } %>

    <%
        List<GeneticModel> modelList = geneticModelsDAO.getAllModelsByGeneRgdId(obj.getRgdId());
        if (modelList.size() > 0) {
    %>
    <tr>
        <td class="label" valign="top">Genetic Models:</td>
        <td>
            <% for (GeneticModel m : modelList) {%>
            <a href=<%=Link.strain(m.getStrainRgdId())%>> <%=m.getStrainSymbol()%></a>
            <%}%>
        </td>
    </tr>
    <% }%>

    <%@ include file="../markerFor.jsp"%>
    <tr>
        <td class="label" valign="top">Latest Assembly:</td>
        <td><%=refMap.getName()%> - <%=refMap.getDescription()%></td>
    </tr>

    <% if (obj.getNcbiAnnotStatus() != null) { %>
    <tr>
        <td class="label" valign="top">NCBI Annotation Information:</td>
        <td><%=obj.getNcbiAnnotStatus()%></td>
    </tr>
    <% }

        List<MapData> mapData = mapDAO.getMapData(obj.getRgdId());
    %>

    <tr>
        <td class="label" valign="top">Position:</td>
        <td><%=MapDataFormatter.buildTable(obj.getSpeciesTypeKey(), mapData, rgdId.getObjectKey(), obj.getSymbol())%></td>
    </tr>

  <%-- show model JBrowse mini chart for genes having positions on current reference assembly --%>
    <% if(fu.mapPosIsValid(md)) {
        String dbJBrowse = obj.getSpeciesTypeKey()==SpeciesType.HUMAN ? "data_hg38"
                : obj.getSpeciesTypeKey()==SpeciesType.MOUSE ? "data_mm38"
                : obj.getSpeciesTypeKey()==SpeciesType.RAT ? "data_rgd6"
                : obj.getSpeciesTypeKey()==5 ? "data_bonobo1_1"
                : obj.getSpeciesTypeKey()==6 ? "data_dog3_1"
                : obj.getSpeciesTypeKey()==7 ? "data_squirrel2_0"
                : obj.getSpeciesTypeKey()==SpeciesType.CHINCHILLA ? "data_cl1_0"
                : "";
        String tracks = "ARGD_curated_genes";
        String jbUrl = "https://jbrowse.rgd.mcw.edu/?data="+dbJBrowse+"&tracks="+tracks+"&highlight=&tracklist=0&nav=0&overview=0&loc="+FormUtility.getJBrowseLoc(md);
    %>
    <tr>
        <td  class="label">JBrowse:</td>
        <td align="left">
            <a href="https://jbrowse.rgd.mcw.edu/?data=<%=dbJBrowse%>&loc=<%=fu.getJBrowseLoc(md)%>&tracks=<%=tracks%>">View Region in Genome Browser (JBrowse)</a>
        </td>
    </tr>
    <tr>
        <td class="label">Model</td>
        <td><div style="width:750px; align:left;">
            <iframe id="jbrowseMini" style="border: 1px solid black" width="660"></iframe>
        </div></td>
    </tr>
    <script>
        $(document).ready(function() {
            document.getElementById('jbrowseMini').src = '<%=jbUrl%>';
        });
    </script>
    <% } %>
</table>

<%@ include file="../sectionFooter.jsp"%>
