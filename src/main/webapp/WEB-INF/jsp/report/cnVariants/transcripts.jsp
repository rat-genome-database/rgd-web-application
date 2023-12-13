<%@ page import="edu.mcw.rgd.vv.VariantController" %>
<%@ page import="java.util.List" %>

<%@ page import="edu.mcw.rgd.datamodel.TranscriptResult" %>

<%@ include file="../sectionHeader.jsp"%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<%
    VariantController ctrl = new VariantController();
    List<TranscriptResult> results =
    ctrl.getVariantTranscriptResults((int) var.getId(),var.getMapKey() );
    if (!results.isEmpty()){
        Collections.sort(results, new Comparator<TranscriptResult>() {
            public int compare(TranscriptResult tr1, TranscriptResult tr2) {
                return Utils.stringsCompareToIgnoreCase(tr1.getAminoAcidVariant().getLocation(), tr2.getAminoAcidVariant().getLocation());
            }
        });
%>
<div class="reportTable light-table-border" id="variantTranscriptsTableWrapper">
    <div class="sectionHeading" id="variantTranscripts" >Variant Transcripts</div>
        <div id="variantTranscriptsTableDiv" class="annotation-detail">
            <table id="variantTranscriptsTable" width="650" border=0 ><tr></tr>
            <tr>
                <td>
                    <a></a>
                    <div id="sampleTranscripts">
            <% for (TranscriptResult tr: results) { %>
                    <table border="0" width="100%" style="background-color:white; color:#053867;font-size:12px;">
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
                    <td class="carpeLabel" >Location:</td><td><%=tr.getAminoAcidVariant().getLocation().replace(",",";")%></td>
                </tr>

                <% if (tr.getAminoAcidVariant().getVariantAminoAcid() != null && !tr.getAminoAcidVariant().getLocation().equals("Unknown")) {%>
                <tr>
                    <td class="carpeLabel">Amino Acid Prediction:</td><td> <%=tr.getAminoAcidVariant().getReferenceAminoAcid()%> to  <%=tr.getAminoAcidVariant().getVariantAminoAcid()%> (<%=tr.getAminoAcidVariant().getSynonymousFlag()%>)</td>
                </tr>
                        <tr>
                            <td class="carpeLabel">Amino Acid Position:</td><td> <%=tr.getAminoAcidVariant().getAaPosition()%></td>
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

<%--                <tr><td>&nbsp;</td></tr>--%>
                    </table>
                    <br>
                <% } %>
                    </div>
                </td>
            </tr>

            </table>
        </div>
</div>
<% } %>
<%--else {%>--%>
<%--    <h1>No transcripts for sample.--%>
<%--<%}%>--%>
    <%@ include file="../sectionFooter.jsp"%>
<style>
    /*#variantTranscriptsTableWrapper{*/
    /*    background-image: url(/rgdweb/common/images/bg3.png);*/
    /*}*/
    /*table {*/
    /*    display: table;*/
    /*    border-collapse: separate;*/
    /*    box-sizing: border-box;*/
    /*    text-indent: initial;*/
    /*    white-space: normal;*/
    /*    line-height: normal;*/
    /*    font-weight: normal;*/
    /*    font-size: medium;*/
    /*    font-style: normal;*/
    /*    color: -internal-quirk-inherit;*/
    /*    text-align: start;*/
    /*    border-spacing: 2px;*/
    /*    border-color: grey;*/
    /*    font-variant: normal;*/
    /*}*/
    /*#variantTranscripts{*/
    /*    background-color: white;*/
    /*    width: 180px;*/
    /*    padding-left: 4px;*/
    /*    font-size: 22px;*/
    /*}*/
</style>