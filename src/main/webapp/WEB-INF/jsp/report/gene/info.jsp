<%@ page import="java.util.TreeMap" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    RgdId id = null;
    try {
        id = managementDAO.getRgdId(obj.getRgdId());
    } catch (Exception e) {
        e.printStackTrace();
    }
    List<MapData> mapData = mapDAO.getMapData(obj.getRgdId());

%>

<script>
    <%
    MapData currentAssemblyMapData = null;
    for (MapData md2: mapData) {
        Map currentMap = MapManager.getInstance().getReferenceAssembly(obj.getSpeciesTypeKey());

        if (md2.getMapKey() == currentMap.getKey()) {
            currentAssemblyMapData=md2;
        %>
            var chr='<%=md2.getChromosome()%>';
            var start="<%=md2.getStartPos()%>";
            var stop="<%=md2.getStopPos()%>";
            var guideId="10000000089";
            var mapKey="<%=md.getMapKey()%>"
            var guide='{"guide_id":10000000089,"species":"human","targetLocus":"AAVS1","targetSequence":"GTCACCAATCCTGTCCCTAG","pam":"GTCACCAATCCTGTCCCTAGNGG","assembly":"hg38","chr":"chr19","start":"55115744","stop":"55115767","strand":"+","grnaLabId":"AAVS1_site_01","spacerLength":"20","spacerSequence":"GUCACCAAUCCUGUCCCUAG","repeatSequence":"","guide":"AAVS1_site_01","forwardPrimer":"CTGCCTAACAGGAGGTGGGGGTT","reversePrimer":"ACCCGGGCCCCTATGTCCACTTC","linkerSequence":"","antiRepeatSequence":"","stemloop1Sequence":"","stemloop2Sequence":"","stemloop3Sequence":"","source":"lab IVT","guideFormat":"sgRNA","modifications":"none","guideDescription":"Targets AAVS1 safe harbor locus","standardScaffoldSequence":"yes","tier":4,"ivtConstructSource":"Addgene","vectorId":"153997","vectorName":"pCRL01","vectorDescription":"Plasmid for single guide RNA IVT","vectorType":"plasmid","annotatedMap":"addgene-plasmid-153997-sequence-304516","specificityRatio":"0.02","guideCompatibility":"SpyCas9"}';
        <%
        }
    }
    %>

    function goToJBrowse() {
        window.open("<%=MapDataFormatter.generateJbrowse2URL( 1, currentAssemblyMapData)%>");
    }
</script>

<table width="100%" border="0" id="info-table">
    <tbody>
    <input name="rgdId" type="hidden" value="<%=id.getRgdId()%>" />
    <tr>
        <td class="label" valign="top">Symbol:</td>
        <td class="geneList"><%=(obj.getEnsemblGeneSymbol()!=null && !Utils.stringsAreEqualIgnoreCase(obj.getSymbol(),obj.getEnsemblGeneSymbol())) ? obj.getSymbol() + "\t(Ensembl: "+obj.getEnsemblGeneSymbol()+")" : obj.getSymbol()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Name:</td>
        <td><%=obj.getName()==null ? "" : (obj.getEnsemblFullName()!=null && !Utils.stringsAreEqualIgnoreCase(obj.getName(),obj.getEnsemblFullName())) ? obj.getName() +"\t(Ensembl:"+obj.getEnsemblFullName()+")" : obj.getName()%></td>
    </tr>

    <tr>
        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=id.getRgdId()%></td>
    </tr>
    <%--link to mgi and hgnc--%>


    <% if (obj.getSpeciesTypeKey()==1) {
        List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(21,obj.getRgdId());
        if (xids.size()==1) {
            XdbId xid = xids.get(0);
    %>
    <tr>
        <td class="label">HGNC Page</td>
        <td><a href="<%=XDBIndex.getInstance().getXDB(21).getUrl(SpeciesType.HUMAN)+xid.getAccId()%>"><%=xid.getAccId()%></a></td>
    </tr>

    <%
        }
    }else if (obj.getSpeciesTypeKey()==2){
        List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(5,obj.getRgdId());
        if (xids.size()==1) {
            XdbId xid = xids.get(0);
    %>
    <tr>
        <td class="label">MGI Page</td>
        <td><a href="<%=XDBIndex.getInstance().getXDB(5).getUrl(SpeciesType.MOUSE)+xid.getAccId()%>">MGI</a></td>
    </tr>
    <% }}
    %>

    <%-- GENE DESCRIPTIONS: show merged description on PROD, and RGD, AGR, MERGED descriptions everywhere else--%>
    <% if( RgdContext.isCurator() ) { %>
    <tr>
        <td class="label" valign="top">Description:</td>
        <td style="overflow: auto"><%=description==null ? "" : description%></td>
    </tr>

    <% if( obj.getAgrDescription()!=null ) { %>
    <tr>
        <td class="label" valign="top">AGR Description:</td>
        <td><%=obj.getAgrDescription()%></td>
    </tr>
    <% } %>

    <% if( obj.getMergedDescription()!=null ) { %>
    <tr>
        <td class="label" valign="top">Merged Description:</td>
        <td><%=obj.getMergedDescription()%></td>
    </tr>
    <% } %>

    <% } else { %>

    <tr>
        <td class="label" valign="top">Description:</td>
        <td><%=Utils.NVL(obj.getMergedDescription(), description==null ? "" : description)%></td>
    </tr>

    <% } %><%-- end GENE DESCRIPTIONS --%>

    <tr>
        <td class="label" valign="top">Type:</td>
        <td><%=(obj.getEnsemblGeneType()!=null && !Utils.stringsAreEqualIgnoreCase(obj.getType(),obj.getEnsemblGeneType())) ? obj.getType() + "\t(Ensembl: "+obj.getEnsemblGeneType()+")" : obj.getType() %>

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
        <td><a href="https://www.ncbi.nlm.nih.gov/books/NBK21091/table/ch18.T.refseq_status_codes/?report=objectonly"><%=obj.getRefSeqStatus()%></a></td>
    </tr>
    <% } %>

    <%
        String[] aliasTypes = {"old_gene_symbol","old_gene_name","old_uniprot_swissprot_id","old_uniprot_trembl_id"};
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId(), aliasTypes);

        // add to aliases 'TAGLESS_ALLELE_SYMBOL'
        if( !Utils.isStringEmpty(obj.getTaglessAlleleSymbol()) && !Utils.stringsAreEqualIgnoreCase(obj.getSymbol(), obj.getTaglessAlleleSymbol()) ) {

            boolean isDuplicate = false;
            for( Alias a: aliases ) {
                if( Utils.stringsAreEqualIgnoreCase(obj.getTaglessAlleleSymbol(), a.getValue()) ) {
                    isDuplicate = true;
                    break;
                }
            }

            // if a tagless allele symbol is already the same as one of the existing aliases -- do not add it
            if( !isDuplicate ) {
                // create 'fake' alias for tagless allele symbol
                Alias alias = new Alias();
                alias.setRgdId(obj.getRgdId());
                alias.setTypeName("tagless_allele_symbol");
                alias.setValue(obj.getTaglessAlleleSymbol());
                aliases.add(alias);
            }
        }

        if (aliases.size() > 0 ) {
            // sort aliases alphabetically by alias value
            Collections.sort(aliases, new Comparator<Alias>() {
                public int compare(Alias o1, Alias o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
                }
            });
    %>
    <tr>
        <td class="label" valign="top">Previously&nbsp;known&nbsp;as:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>
    </tbody>
    <%@ include file="orthologs.jsp"%>
    <tbody>
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
        <td><%
            int count =0;
            for (Gene gene: variants) {
                ++count;
                boolean isLast = (count==variants.size());
                %>
                 <a href="<%=Link.gene(gene.getRgdId())%>"><%=gene.getSymbol()%></a><%=!isLast?" ; ":""%>
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
            <%
                int count=0;
                for (GeneticModel m : modelList) {
                    ++count;
                    boolean isLast = (count==modelList.size());
            %>
                <a href=<%=Link.strain(m.getStrainRgdId())%>> <%=m.getStrainSymbol()%></a><%=!isLast?" ; ":""%>
            <%}%>
        </td>
    </tr>
    <% }%>

    <%@ include file="../markerFor.jsp"%>
    <%@ include file="candidateGenes.jsp"%>
    <tr>
        <td class="label" valign="top">Latest Assembly:</td>
        <td><%=refMap.getName()%> - <%=refMap.getDescription()%></td>
    </tr>
    <% if (obj.getNcbiAnnotStatus() != null) { %>
    <tr>
        <td class="label" valign="top">NCBI Annotation Information:</td>
        <td><%=obj.getNcbiAnnotStatus()%></td>
    </tr>
    <% } %>
    <tr>
        <td class="label" valign="top">Position:</td>
        <td><%=MapDataFormatter.buildTable(obj.getSpeciesTypeKey(), mapData, rgdId.getObjectKey(), obj.getSymbol())%></td>
    </tr>
   <tr>
        <td  class="label">JBrowse:</td>
        <td align="left">
            <div style="padding:10px;"><a target="blank" href="<%=MapDataFormatter.generateJbrowse2URL( 1, currentAssemblyMapData)%>">View Region in Genome Browser (JBrowse)</a></div>
        </td>
    </tr>
    </tbody>
</table>


<br><br>
<div id="sequenceViewer" onclick="goToJBrowse()">
    <div class="container">
        <div id="range" style="text-align: center"></div>
        <svg className="viewer" id="viewerActnFly"/>
    </div>
</div>

<script src="https://unpkg.com/react@17/umd/react.development.js" crossorigin></script>
<script src="https://unpkg.com/react-dom@17/umd/react-dom.development.js" crossorigin></script>

<!-- Load our React component. -->
<!--script src="/toolkit/js/react/like_button.js"></script-->
<script>
    //   var range="13:32315508..32400268";
    //   createCoVExample("NC_045512.2:17894..28259", "SARS-CoV-2", "covidExample1", TRACK_TYPE.ISOFORM, false);

</script>
<link rel="stylesheet" href="/rgdweb/js/sequenceViewer/GenomeFeatureViewer.css">

<script src="/rgdweb/js/sequenceViewer/RenderFunctions.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/ApolloService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/ConsequenceService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/LegenedService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/TrackService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/VariantService.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/IsoformAndVariantTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/IsoformEmbeddedVariantTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/IsoformTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/ReferenceTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/TrackTypeEnum.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/VariantTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/VariantTrackGlobal.js"></script>
<script src="/rgdweb/js/sequenceViewer/Drawer.js"></script>
<script src="/rgdweb/js/sequenceViewer/GenomeFeatureViewer.js"></script>
<script src="/rgdweb/js/sequenceViewer/demo/index.js"></script>
<script src="https://d3js.org/d3.v7.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        loadSequenceViewer();
    });
</script>
<%@ include file="../sectionFooter.jsp"%>
