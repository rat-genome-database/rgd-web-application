<%@ page import="edu.mcw.rgd.vv.VariantController" %>
<%@ page import="edu.mcw.rgd.vv.vvservice.VVService" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    VariantController ctrl = new VariantController();
    VariantSearchBean vsb = new VariantSearchBean(var.getMapKey());
    List<SearchResult> allResults = new ArrayList<SearchResult>();
    String index = new String();
    String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(var.getMapKey()) );
    index = RgdContext.getESVariantIndexName("variants_" + species.toLowerCase() + var.getMapKey());
    VVService.setVariantIndex(index);
    for (Sample s : samples){
//        System.out.println(s.getId());
        vsb.sampleIds.add(s.getId());
    }
//    vsb.setPosition( var.getChromosome(),String.valueOf(var.getStartPos()), String.valueOf(var.getEndPos()) );
    vsb.setVariantId(var.getId());
    try {
        List<VariantResult> vr = ctrl.getVariantResults(vsb, req, true);
        SearchResult sr = new SearchResult();

        sr.setVariantResults(vr);
        allResults.add(sr);
//        System.out.println(allResults.size());
    }
    catch (Exception e){
//        System.out.println(e);
    }
    boolean emptyTranscripts = true;
    for (SearchResult sr1 : allResults){
        for (VariantResult vr : sr1.getVariantResults()){
            if (!vr.getTranscriptResults().isEmpty())
                emptyTranscripts = false;
        }
    }
    if (!allResults.isEmpty() && !emptyTranscripts){
%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div class="reportTable light-table-border" id="variantTranscriptsTableWrapper">
    <div class="sectionHeading" id="variantTranscripts">Variant Transcripts</div>

        <div id="variantTranscriptsTableDiv" class="annotation-detail">
            <table id="variantTranscriptsTable" width="650" border=0 ><tr></tr>
<% for (SearchResult searchResult : allResults){
    System.out.println("Results: "+searchResult.getVariantResults().size());
    List<VariantResult> resultList = searchResult.getVariantResults();
    for (VariantResult result : resultList) {
//        if (!result.getTranscriptResults().isEmpty()){
        System.out.println("Transcript results:"+result.getTranscriptResults().size());%>


            <tr>
                <td>

            <% for (TranscriptResult tr: result.getTranscriptResults()) { %>
                    <table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                <% try { %>
                <tr>
                    <td class="carpeLabel" width=200>Gene Symbol:</td><td width=70%><%=xdbDAO.getGenesByXdbId(1,tr.getAminoAcidVariant().getTranscriptSymbol()).get(0).getSymbol()%></td>
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

                <% }
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
                <% } %>


                <tr><td>&nbsp;</td></tr>
                    </table>
                <% } %>
                </td>
            </tr>

 <%   }  // end resultList
    } // end all result  %>
            </table>
        </div>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>