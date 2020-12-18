<%
    List<Gene> homologs = geneDAO.getHomologs(obj.getRgdId());
    List<Association> weakOrthos = associationDAO.getAssociationsForMasterRgdId(obj.getRgdId(), "weak_ortholog");
    weakOrthos.addAll(associationDAO.getAssociationsForMasterRgdId(obj.getRgdId(), "ortholog"));

    List<Gene> agrOrthos = geneDAO.getAgrOrthologs(obj.getRgdId());

    if( !homologs.isEmpty() || !weakOrthos.isEmpty() || !agrOrthos.isEmpty() ) {

        // sort weak orthologs by species and then by longest evidence
        Collections.sort(weakOrthos, new Comparator<Association>() {
            public int compare(Association o1, Association o2) {
                int len1 = Utils.defaultString(o1.getAssocSubType()).length();
                int len2 = Utils.defaultString(o2.getAssocSubType()).length();
                return len2-len1;
            }
        });
        String note1 = "'Orthologs' are chosen by consensus from multiple sources via HGNC's Comparison of Orthology Predictions (HCOP).  "+
           "In the absence of HCOP assignments, ortholog predictions may be provided by RGD based on manual review of gene homology.  "+
           "Only one assignment per species is made.";
        String note2 = "'Other homologs' lists all HCOP homology assignments other than the consensus orthologs. "+
           "Where no orthologs are known this section may still contain non-orthologous homolog assignments.";
        String note3 = "'Aliance orthologs' lists all stringent orthology assignments as available at Alliance of Genome Resources.";
        String buttonCaption;
%>
<tr>
    <td class="label" valign="top">Orthologs:</td>
    <td>
      <div class="ortho_short">
        <table><tr><td>
        <% for (Gene gene : homologs) { %>
            <%=SpeciesType.getTaxonomicName(gene.getSpeciesTypeKey())%>
            (<%=SpeciesType.getGenebankCommonName(gene.getSpeciesTypeKey())%>) : <a
            href="main.html?id=<%=gene.getRgdId()%>"><%=gene.getSymbol()%> (<%=gene.getName()%>)</a>

        <% if (gene.getSpeciesTypeKey()==1) {
            List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(21,gene.getRgdId());
            if (xids.size()==1) {
                XdbId xid = xids.get(0);
        %>
                &nbsp;<a href="<%=XDBIndex.getInstance().getXDB(21).getUrl(SpeciesType.HUMAN)+xid.getAccId()%>" title="HUGO Gene Nomenclature Committee">
                    <img border="0" src="/rgdweb/common/images/HUGO_Gene_Nomenclature_Committee_logo.svg" height="40" width="65"/>
                </a>
        <%
            }
         }else if (gene.getSpeciesTypeKey()==2){
            List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(5,gene.getRgdId());
            if (xids.size()==1) {
                XdbId xid = xids.get(0);
        %>
                &nbsp;<a href="<%=XDBIndex.getInstance().getXDB(5).getUrl(SpeciesType.MOUSE)+xid.getAccId()%>" title="Mouse Genome Informatics">
                    <img border="0" src="/rgdweb/common/images/mgi_logo.svg"/>
                </a>
         <% }}
         %>

        <%-- AGR GENES --%>
        <%
            List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(63,gene.getRgdId());
            if (xids.size()>0 ) {
                XdbId xid = xids.get(0);
            %> &nbsp;<a href="<%=XDBIndex.getInstance().getXDB(63).getUrl()+xid.getAccId()%>" title="Alliance of Genome Resources">
                    <img border="0" src="/rgdweb/common/images/alliance_logo_small.svg"/>
                </a>
            <% }
        %>

        <br>
     <% }
         if( homologs.isEmpty() ) {
            buttonCaption = "homologs&nbsp;...";
     %>
        No known orthologs.
     <% } else {
            buttonCaption = "more&nbsp;info&nbsp;...";
        }
     %>
        </td>
        <TD style="vertical-align: bottom;">
            <A HREF="javascript:showAllOrthos();" class="orthoExtInfo"
                    title="click to see extended ortholog information from HGNC HCOP"><%=buttonCaption%></A>
        </TD>
        </tr></table>
     </div>
     <div class="ortho_long" style="display: none;">
     <table>
         <TR>
             <TH style="background-color: #b6baba;">Species</TH>
             <TH style="background-color: #b6baba;">Gene symbol and name</TH>
             <TH style="background-color: #b6baba;">Data Source</TH>
             <TH style="background-color: #b6baba;">Assertion derived from</TH>
             <TH rowspan="2" style="padding-left:20px;">
                 <A HREF="javascript:hideAllOrthos();" class="orthoExtInfo"
                         title="click to see simple ortholog information">less&nbsp;info&nbsp;...</A>
             </TH>
         </TR>
     <%
         if( !homologs.isEmpty() ) {
     %>
         <TR>
             <TH colspan="4" class="orthoExtBar" title="<%=note1%>">Orthologs <sup><u>1</u></sup></TH>
         </TR>
         <% }
         OrthologDAO orthologDAO = new OrthologDAO();
         for (Gene gg: homologs) {
             Ortholog o = orthologDAO.getOrthologs(obj.getRgdId(), gg.getRgdId()).get(0);
     %>
         <TR>
             <TD style="background-color:#e2e2e2"><%=SpeciesType.getTaxonomicName(gg.getSpeciesTypeKey())%> (<%=SpeciesType.getGenebankCommonName(gg.getSpeciesTypeKey())%>):</TD>
             <TD style="background-color:#e2e2e2"><A href="<%=Link.gene(gg.getRgdId())%>"><%=gg.getSymbol()%> (<%=gg.getName()%>)</A></TD>
             <TD style="background-color:#e2e2e2"><%=o.getXrefDataSrc()%></TD>
             <TD style="background-color:#e2e2e2"><%=o.getXrefDataSet()%></TD>
         </TR>
     <% }
         if( !weakOrthos.isEmpty() ) {
     %>
         <TR>
             <TH colspan="4" class="orthoExtBar" title="<%=note2%>">Other homologs <sup><u>2</u></sup></TH>
         </TR>
         <%
             for (Association ass: weakOrthos) {
                 Gene gg = geneDAO.getGene(ass.getDetailRgdId());
         %>
             <TR>
                 <TD style="background-color:#e2e2e2"><%=SpeciesType.getTaxonomicName(gg.getSpeciesTypeKey())%> (<%=SpeciesType.getGenebankCommonName(gg.getSpeciesTypeKey())%>):</TD>
                 <TD style="background-color:#e2e2e2"><A href="<%=Link.gene(gg.getRgdId())%>"><%=gg.getSymbol()%> (<%=gg.getName()%>)</A></TD>
                 <TD style="background-color:#e2e2e2"><%=Utils.defaultString(ass.getSrcPipeline()).equals("ortholog")?"NCBI ortholog":ass.getSrcPipeline()%></TD>
                 <TD style="background-color:#e2e2e2"><%=ass.getAssocSubType()%></TD>
             </TR>
         <% }}

         if( !agrOrthos.isEmpty() ) {
         %>
         <TR>
             <TH colspan="4" class="orthoExtBar" title="<%=note3%>">Alliance orthologs <sup><u>3</u></sup></TH>
         </TR>
             <%
             for (Gene gg: agrOrthos) {
         %>
         <TR>
             <TD style="background-color:#e2e2e2"><%=SpeciesType.getTaxonomicName(gg.getSpeciesTypeKey())%> (<%=SpeciesType.getGenebankCommonName(gg.getSpeciesTypeKey())%>):</TD>
             <TD style="background-color:#e2e2e2">
                <a href="<%=XDBIndex.getInstance().getXDB(63).getUrl()+gg.getDescription()%>" title="see this gene at the Alliance">
                  <%-- do not print null gene name or gene name same as gene symbol --%>
                  <%=gg.getSymbol()%><% if( !Utils.NVL(gg.getName(), gg.getSymbol()).equals(gg.getSymbol()) ) { out.print(" ("+gg.getName()+")"); } %></a>
             </TD>
             <TD style="background-color:#e2e2e2">Alliance</TD>
             <TD style="background-color:#e2e2e2">DIOPT (<%=gg.getNotes()%>)</TD><%-- methods matched --%>
         </TR>
         <% }} %>

     </table>
    </div>
  </td>
</tr>
<% } %>

<script type="text/javascript">
function showAllOrthos() {
  if( $ ) {
    $(".ortho_short").hide(400);
    $(".ortho_long").show(900);
  }
}

function hideAllOrthos() {
  if( $ ) {
    $(".ortho_long").hide(400);
    $(".ortho_short").show(900);
  }
}
</script>
