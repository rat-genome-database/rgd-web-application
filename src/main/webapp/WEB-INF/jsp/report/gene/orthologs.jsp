<%
    List<Gene> homologs = geneDAO.getHomologs(obj.getRgdId());
    List<Integer> rgdIds = new ArrayList<>();
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

      <tbody class="ortho_short">
        <tr>
            <td class="label"> RGD Orthologs</td>
            <td>
                <table>
                    <tr>
        <% for (Gene gene : homologs) {
            if (!rgdIds.contains(gene.getRgdId())){
                rgdIds.add(gene.getRgdId());
                String imageSource = getSpeciesImage(gene);
                String orthTitle = "Species: &nbsp; "+SpeciesType.getCommonName(gene.getSpeciesTypeKey())+" ("+SpeciesType.getTaxonomicName(gene.getSpeciesTypeKey())+")"
                        +"\nGene Symbol: &nbsp; "+gene.getSymbol();
        %>
                <td>
                    <a class="speciesCardOverlay" href="/rgdweb/report/gene/main.html?id=<%=gene.getRgdId()%>" title="<%=orthTitle%>">
                    <div style="margin:5px; font-weight:700;" >
                        <%=SpeciesType.getCommonName(gene.getSpeciesTypeKey())%></div>
                    </a>
                    <img border="0" src=<%=imageSource%> class="speciesIcon">
                </td>
        <%} }%>
        </tr>
        </table>
            </td>
        </tr>

        <%-- AGR GENES --%>
            <tr>
                <td class="label">Alliance Orthologs</td>
                <td style="height: 60px">

                <%
                    String imageSource = getAllianceImage(obj);
                    List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(63,obj.getRgdId());
                    if (xids.size()>0 ) {
                        XdbId xid = xids.get(0);
                        String popupTitle = "Species: &nbsp; "+SpeciesType.getCommonName(obj.getSpeciesTypeKey())+" ("+SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())+")"
                            +"\nGene Symbol: &nbsp; "+obj.getSymbol()
                            +"\nAlliance Gene ID: &nbsp; "+xid.getAccId();
                %>
                    <a href="<%=XDBIndex.getInstance().getXDB(63).getUrl()+xid.getAccId()%>" title="<%=popupTitle%>">
                        <img border="0" src=<%=imageSource%> width="50px" height="50px">
                    </a>
                    <%}
                    Gene prevGene = null;
                    for (Gene gene : agrOrthos) {
                        imageSource = getAllianceImage(gene);
                        String allianceToolTip = "Species: &nbsp; "+SpeciesType.getCommonName(gene.getSpeciesTypeKey())+" ("+SpeciesType.getTaxonomicName(gene.getSpeciesTypeKey())+")"
                                +"\nGene Symbol: &nbsp; "+gene.getSymbol()
                                +"\nAlliance Gene ID: &nbsp; "+gene.getDescription();
                        boolean isDuplicate = false;

                        if(prevGene != null){
                            isDuplicate = Utils.stringsAreEqualIgnoreCase(prevGene.getDescription(),gene.getDescription()); //prevGene.getDescription().equalsIgnoreCase(gene.getDescription());
                        }
                        prevGene = gene;

                        xids = xdbDAO.getXdbIdsByRgdId(63,gene.getRgdId());
                        if (xids.size()>0 ) {
                            XdbId xid = xids.get(0);

                            if(!isDuplicate){
                        %>
                            <a title ="<%=allianceToolTip%>" href="<%=XDBIndex.getInstance().getXDB(63).getUrl()+xid.getAccId()%>">
                                <img border="0" src=<%=imageSource%> width="50px" height="50px">
                            </a>
                        <%}
                        }%>
                    <% } %>
            </td>
            </tr>
            <%
         if( homologs.isEmpty() ) {
            buttonCaption = "homologs&nbsp;...";
     %>
        No known orthologs.
     <% } else {
            buttonCaption = "more&nbsp;info&nbsp;...";
        }
     %>

            <tr style="height: 40px;">
                <td class="label">More Info</td>
                <TD style="vertical-align: middle;">
                    <A HREF="javascript:showAllOrthos();" class="orthoExtInfo"
                            title="click to see extended ortholog information from HGNC HCOP"><%=buttonCaption%></A>
                </TD>
            </tr>
     </tbody>


         <tbody class="ortho_long" style="display: none;">
             <tr>
                <td class="label">More Info</td>
                <td>
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
                </td>
             </tr>
         </tbody>

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
<%!
    private String getSpeciesImage(Gene gene) {
        String imageSource = "/rgdweb/common/images/species/";
        int speciesTypeKey = gene.getSpeciesTypeKey();
        switch (speciesTypeKey){
            case 1 :
                imageSource += "humanI.png";
                break;
            case 2 :
                imageSource += "mouseI.jpg";
                break;
            case 3 :
                imageSource +=  "ratI.png";
                break;
            case 4 :
                imageSource +=  "chinchillaI.jpg";
                break;
            case 5 :
                imageSource +=  "bonoboI.jpg";
                break;
            case 6 :
                imageSource +=  "dogI.jpg";
                break;
            case 7 :
                imageSource +=  "squirrelI.jpg";
                break;

            case 9 :
                imageSource +=  "pigI.png";
                break;
            case 13 :
                imageSource +=  "green-monkeyI.png";
                break;
            case 14 :
                imageSource +=  "mole-ratI.png";
                break;
        }
        return imageSource;
    }

    private String getAllianceImage(Gene gene) {
        String imageSource = "/rgdweb/common/images/";
        int speciesTypeKey = gene.getSpeciesTypeKey();
        switch(speciesTypeKey){
            case 1 :
                imageSource += "alliance_logo_hgnc.png";
                break;
            case 2 :
                imageSource += "alliance_logo_rgd.png";
                break;
            case 3 :
                imageSource += "alliance_logo_mgd.png";
                break;
            case 8 :
                imageSource += "alliance_logo_zfin.png";
                break;
            case 10 :
                imageSource += "alliance_logo_flybase.png";
                break;
            case 11 :
                imageSource += "alliance_logo_wormbase.png";
                break;
            case 12 :
                imageSource += "alliance_logo_sgd.png";
                break;
            case 15 :
                imageSource += "alliance_logo_xenbase15.png";
                break;
            case 16 :
                imageSource += "alliance_logo_xenbase16.png";
                break;

        }
        return imageSource;
    }

    //helper method for species tile text
    private String convertToTitleCase(String text) {
        if (text == null || text.isEmpty()) {
            return text;
        }

        StringBuilder converted = new StringBuilder();

        boolean convertNext = true;
        for (char ch : text.toCharArray()) {
            if (Character.isSpaceChar(ch)) {
                convertNext = true;
            } else if (convertNext) {
                ch = Character.toTitleCase(ch);
                convertNext = false;
            } else {
                ch = Character.toLowerCase(ch);
            }
            converted.append(ch);
        }

        return converted.toString();
    }

%>