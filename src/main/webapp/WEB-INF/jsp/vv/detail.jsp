<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.TranscriptDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.XdbIdDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantDAO" %>

<%@ include file="carpeHeader.jsp"%>

<style>
    .drag-contentarea{ /*CSS for Content Display Area div*/
        border-top: 1px solid brown;
        background-image: url(/rgdweb/common/images/bg3.png);
        color: black;
        height: 150px;
        padding: 2px;
        overflow: auto;
        scroll-top:0;
    }
</style>

<%
    VariantDAO dao = new VariantDAO();
    boolean isList = false;

//    VariantMapData vmd = dao.getVariant(Integer.parseInt(vid));
    List<SearchResult> searchResults = (List<SearchResult>) request.getAttribute("searchResults");
    XdbIdDAO xDao = new XdbIdDAO();
    List<Long> varRgdIds = new ArrayList<>();
    for (SearchResult searchResult: searchResults) {

        //SearchResult searchResult = searchResults.get(0);
        List<VariantResult> resultList = searchResult.getVariantResults();
        String dbSnpUrl = XDBIndex.getInstance().getXDB(48).getUrl();

   /* String mapName = "";

    try {
        mapName = MapManager.getInstance().getMap(Integer.parseInt(request.getParameter("mapKey"))).getName();
    }catch (Exception e) {
        throw e;
    }
*/

%>


<div class="typerMat">

    <br>

    <% if (resultList.isEmpty()) { %>
    <hr>
    <span style="font-size:16px; color:white;font-weight:700">Variant Not Found</span>
    <hr>
    <% } %>

    <%
        for (VariantResult result: resultList) {

            if (!varRgdIds.contains(result.getVariant().getId())){
            Sample sample = SampleManager.getInstance().getSampleName(result.getVariant().getSampleId());
            boolean isClinVar = sample.getMapKey()==17 || sample.getMapKey()==38;
            VariantMapData vmd = dao.getVariant((int)result.getVariant().getId());
            varRgdIds.add(vmd.getId());
//            System.out.println(vmd.getId());
    if (vmd!=null && vmd.getRsId()!=null && !vmd.getRsId().equals(".")) {
    %>
    <div class="typerTitle"><div class="typerTitleSub"><%=vmd.getRsId()%></div></div>
    <% } %>
    <table border="0" width="650" style="border:2px solid #D8D8DB; color:#053867; background-color:white; font-size:11px;" align="center">
        <tr>
            <td>
                <table cellspacing=2 border=0 style="color:#053867;font-size:12px;">
                    <tr><% if( !isClinVar ) { %>
                        <td class="carpeLabel" width=150>Strain:</td>
                        <% } else { %>
                        <td class="carpeLabel" width=150>Source:</td>
                        <% } %>
                        <td><%=sample.getAnalysisName()%></td>
                    </tr>
                    <tr>
                        <td class="carpeLabel">Assembly:</td><td><%=MapManager.getInstance().getMap(sample.getMapKey()).getName()%></td>
                    </tr>
                    <tr>
                        <td class="carpeLabel">Position:</td><td>Chromosome: <%=result.getVariant().getChromosome()%> - <%=Utils.formatThousands((int) result.getVariant().getStartPos())%></td>
                    </tr>
                    <tr>
                        <td class="carpeLabel">Reference Nucleotide:</td><td><%=Utils.NVL(result.getVariant().getReferenceNucleotide(),"-")%></td>
                    </tr>
                    <tr>
                        <td class="carpeLabel">Variant Nucleotide:</td><td><%=Utils.NVL(result.getVariant().getVariantNucleotide(),"-")%></td>
                    </tr>
                    <tr>
                        <td class="carpeLabel">Location:</td><td><%=result.getVariant().getGenicStatus()%></td>
                    </tr>

                    <% if( !isClinVar ) {
                        String zygosity = "n/a";
                        if (result.getVariant().getZygosityStatus() != null) {
                            zygosity = result.getVariant().getZygosityStatus();
                        }
                    %>
                    <tr>
                        <td class="carpeLabel">Zygosity:</td><td><%=zygosity%></td>
                    </tr>
                    <% } %>

                    <% if( result.getVariant().getHgvsName()!=null ) {%>
                    <tr>
                        <td class="carpeLabel">Hgvs Name:</td><td><%=result.getVariant().getHgvsName()%></td>
                    </tr>
                    <% } %>
                </table>
            </td>
            <td valign="top">

                <table cellspacing=2 border=0 class="carpeVarTable">
                    <%
                        String variantType = result.getVariant().getVariantType();
                        if (result.getVariant().getVariantType().equals("ins")) {
                            variantType="Insertion";
                        }else if (result.getVariant().getVariantType().equals("del")) {
                            variantType="Deletion";
                        }
                    %>
                    <tr>
                        <td class="carpeLabel" style="color:#053867;">Variant Type:</td><td><%=variantType%></td>
                    </tr>

                    <% if (result.getDbSNPIds().size() > 0) { %>
                    <tr >
                        <td class="carpeLabel" style="color:#053867;">Related Variants:</td>
                        <% for (String dbsnpId: result.getDbSNPIds()) { %>
                        <td><a href="<%=dbSnpUrl+dbsnpId%>" target="_blank"><%=dbsnpId%></a></td>
                        <% } %>

                    </tr>
                    <% }else {%>
                    <tr>
                        <td class="carpeLabel" style="color:#053867;">Related Variants:</td><td>n/a</td>
                    </tr>
                    <% } %>
                    <tr >
                        <td class="carpeLabel" style="color:#053867;">Conservation:</td>
                        <% if (result.getVariant().conservationScore.size() > 0) { %>
                        <td><%= result.getVariant().conservationScore.get(0).getScore()%> (<%= result.getVariant().conservationScore.get(0).getScoreRating()%>)</td>
                        <% } else { %>
                        <td>n/a</td>
                        <% } %>
                    </tr>

                    <% if( !isClinVar ) { %>
                    <tr>
                        <td class="carpeLabel" style="color:#053867;">Total Depth:</td>
                        <td><%=result.getVariant().getDepth()>0 ? result.getVariant().getDepth() : "n/a"%></td>
                    </tr>
                    <%
                        String percentRead = result.getVariant().getZygosityPercentRead() + "%";
                        String numAlleles = result.getVariant().getZygosityNumberAllele() + "";

                        if (percentRead.equals("0.0%") || percentRead.equals("0%")) {
                            percentRead = "n/a";
                        }
                        if (numAlleles.equals("0")) {
                            numAlleles = "n/a";
                        }
                    %>
                    <tr>
                        <td class="carpeLabel" style="color:#053867;">% Variant Reads:</td><td><%=percentRead%></td>
                    </tr>
                    <tr>
                        <td class="carpeLabel" style="color:#053867;">Total Alleles Read:</td><td><%=numAlleles%></td>
                    </tr>
                    <% } else if(sample.getMapKey()!=17){
                    if(result!=null && result.getClinvarInfo()!=null && result.getClinvarInfo().getClinicalSignificance()!=null){%>
                    <tr><td class="carpeLabel" style="color:#053867;">Clinical Significance:</td><td><%=result.getClinvarInfo().getClinicalSignificance()%></td>
                    </tr>
                    <tr><td class="carpeLabel" style="color:#053867;">Condition:</td><td><%=result.getClinvarInfo().getTraitName()%></td>
                    </tr>
                    <% } }%>

                    <tr>
                        <td class="carpeLabel" style="color:#053867;">VID:</td><td><%=result.getVariant().getId()%></td>
                    </tr>

                    <% if( result.getVariant().getRgdId()!=0 ) { %>
                    <tr>
                        <td class="carpeLabel" style="color:#053867;">RGD_ID:</td>
                        <td><a href="<%=Link.variant(result.getVariant().getRgdId())%>"><%=result.getVariant().getRgdId()%></a></td>
                    </tr>
                    <% } %>
                    <tr>
                        <td><a target="_blank" href="/rgdweb/report/variants/main.html?id=<%=result.getVariant().getId()%>">Go to Variant Page</a></td>
                    </tr>
                </table>

            </td>
        </tr>

    </table>


    <%   if (result.getTranscriptResults().size() > 0) {  %>

    <table align="center" border=0>
        <tr>
            <td>

                <div style="width:650px;background-color:#EEEEEE;margin-top:20px;" >

                    <div class="typerTitle"><div class="typerTitleSub">Transcripts</div></div>

                    <table  width="650" border=0 >

                        <tr>
                            <td>

                                <% for (TranscriptResult tr: result.getTranscriptResults()) { %>

                                <%

                                %>
                                <table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                    <% try { %>
                                    <tr>
                                        <td class="carpeLabel" width=200>Gene Symbol:</td><td width=70%><%=xDao.getGenesByXdbId(1,tr.getAminoAcidVariant().getTranscriptSymbol(),"protein-coding").get(0).getSymbol()%></td>
                                    </tr>
                                    <% } catch (Exception e) { %>

                                    <% } %>
                                    <tr>
                                        <td class="carpeLabel" width=200>Accession:</td><td width=70%><%=tr.getAminoAcidVariant().getTranscriptSymbol()%></td>
                                    </tr>
                                    <tr>
                                        <td class="carpeLabel" >Location:</td><td><%=tr.getAminoAcidVariant().getLocation()%></td>
                                    </tr>

                                    <% if (tr.getAminoAcidVariant().getVariantAminoAcid() != null && !tr.getAminoAcidVariant().getLocation().equals("Unknown")) {%>
                                    <tr>
                                        <td class="carpeLabel">Amino Acid Prediction:</td><td> <%=tr.getAminoAcidVariant().getReferenceAminoAcid()%> to  <%=tr.getAminoAcidVariant().getVariantAminoAcid()%> (<%=tr.getAminoAcidVariant().getSynonymousFlag()%>)</td>
                                    </tr>
                                    <% }else if (tr.getAminoAcidVariant().getSynonymousFlag() != null){ %>
                                    <tr>
                                        <td class="carpeLabel">Amino Acid Prediction:</td><td> <%=tr.getAminoAcidVariant().getSynonymousFlag()%></td>
                                    </tr>
                                    <%}%>
                                    <% if (tr.getAminoAcidVariant().getAaPosition() > 0) { %>
                                    <td class="carpeLabel">Amino Acid Position:</td><td> <%=tr.getAminoAcidVariant().getAaPosition()%></td>

                                    <% } %>


                                    <% if (tr.getAminoAcidVariant().getTripletError().equals("T") || tr.getAminoAcidVariant().getLocation().equals("Unknown")) { %>
                                    <tr>
                                        <td colspan=2 align="center" style="font-weight:700; color:red;"><br>TRANSCRIPT MAY BE FAULTY.  PLEASE CHECK WITH NCBI FOR CORRECTIONS</td>
                                    </tr>
                                    <% } %>


                                    <tr><td></td></tr>

                                    <% if (tr.getPolyPhenPrediction().size() > 0) { %>
                                    <tr>
                                        <td colspan=2 style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                    </tr>
                                    <tr>
                                        <td colspan=2>
                                            <table border=1 cellspacing=0 cellpadding=4 style="background-color:white; font-size:12px;" width="640">
                                                <tr>
                                                    <td class="carpeLabel">Prediction</td>
                                                    <td class="carpeLabel">Basis</td>
                                                    <td class="carpeLabel">Effect</td>
                                                    <td class="carpeLabel">Site</td>
                                                    <td class="carpeLabel">Score1</td>
                                                    <td class="carpeLabel">Score2</td>
                                                    <td class="carpeLabel">Diff</td>
                                                    <td class="carpeLabel">Number Observed</td>
                                                    <td class="carpeLabel">Structures</td>
                                                    <td class="carpeLabel">Protein ID</td>
                                                    <td class="carpeLabel">PDB ID</td>
                                                    <td class="carpeLabel">Inverted</td>
                                                </tr>

                                                <% for (int i=0; i< tr.getPolyPhenPrediction().size(); i++) {  %>
                                                <tr>
                                                    <td><%=tr.getPolyPhenPrediction().get(i).getPrediction()%></td>
                                                    <td><%=tr.getPolyPhenPrediction().get(i).getBasis()%></td>
                                                    <td><%=fu.blank(tr.getPolyPhenPrediction().get(i).getEffect())%></td>
                                                    <td><%=fu.blank(tr.getPolyPhenPrediction().get(i).getSite())%></td>
                                                    <td><%=tr.getPolyPhenPrediction().get(i).getScore1()%></td>
                                                    <td><%=tr.getPolyPhenPrediction().get(i).getScore2()%></td>
                                                    <td><%=tr.getPolyPhenPrediction().get(i).getDiff()%></td>
                                                    <td><%=tr.getPolyPhenPrediction().get(i).getNumObserved()%></td>
                                                    <td><%=fu.blank(tr.getPolyPhenPrediction().get(i).getNumStructureFilt())%></td>
                                                    <td><%=fu.blank(tr.getPolyPhenPrediction().get(i).getProteinId())%></td>
                                                    <td><%=fu.blank(tr.getPolyPhenPrediction().get(i).getPdbId())%></td>
                                                    <td><%=fu.blank(tr.getPolyPhenPrediction().get(i).getInvertedFlag())%></td>
                                                </tr>
                                                <% } %>
                                            </table>
                                        </td>
                                    </tr>

                                    <% } %>
                                    <%
                                        if (tr.getAminoAcidVariant().getAASequence() !=null && tr.getAminoAcidVariant().getAASequence().length()  > 1) {

                                            String aaSequence="";
                                            StringBuilder sb = new StringBuilder(tr.getAminoAcidVariant().getAASequence());

                                            if (tr.getAminoAcidVariant().getAaPosition() != -1) {
                                                sb.replace(tr.getAminoAcidVariant().getAaPosition()-1, tr.getAminoAcidVariant().getAaPosition(), "=");
                                            }

                                            int pos;
                                            for (pos=0; pos<sb.length()-80; pos+=80) {
                                                aaSequence += sb.substring(pos, pos+80);
                                                aaSequence += "<br>";
                                            }
                                            aaSequence += sb.substring(pos);

                                            if (tr.getAminoAcidVariant().getAaPosition() != -1) {
                                                aaSequence = aaSequence.replace("=", "<span style='color:red;font-weight:700;font-size:16px;'>" + tr.getAminoAcidVariant().getVariantAminoAcid() + "</span>" );
                                            }

                                    %>
                                    <tr><td  colspan=2 style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;">Amino Acid Sequence<br><span style="font-size:12px;">(Calculated using NCBI transcript definition)</span></td></tr>
                                    <tr><td  colspan=2 style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre><%=aaSequence%></pre></td></tr>
                                    <%
                                        }
                                    %>


                                    <tr><td>&nbsp;</td></tr>

                                    <% }%>


                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
                    <% } %>
                <br>


                    <%
        }
    }
%>
</div>



<br><br>

<% } %>