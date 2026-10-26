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
        <%-- no annotation-detail here: that class is a marker geneReport.js reads, and it means
                 "promote my first table's first row into a <thead>". The first table in this
                 div used to be the layout wrapper, whose first row was an empty <tr></tr>, so the
                 promotion was invisible; with the wrapper gone it would promote the first card's
                 Location row and paint it as a header. --%>
        <div id="variantTranscriptsTableDiv">
            <%-- One card per transcript. This was a 650px layout table holding a single cell, with
                 each transcript's own borderless table inside it and a <br> between them; the outer
                 table was also initialised as a tablesorter with a pager whose container
                 (.variantTranscriptsPager) is not on the page, so it sorted and paged nothing. --%>
            <div id="sampleTranscripts" class="rgdTranscriptList">
            <% for (TranscriptResult tr: results) {
                String aaVar = "";
                String aaRef = tr.getAminoAcidVariant().getReferenceAminoAcid();
                int aaVarPos = tr.getAminoAcidVariant().getAaPosition()-1;
                boolean isFrameshift = Utils.stringsAreEqual("T", tr.getAminoAcidVariant().getFrameshift());
                if (isFrameshift)
                    aaVar = tr.getAminoAcidVariant().getVariantAminoAcid();
                else if ( !Utils.isStringEmpty(tr.getAminoAcidVariant().getVariantAminoAcid()) ){
                    if  (Utils.stringsAreEqualIgnoreCase("snv", var.getVariantType()) )
                    {
                        aaVar = tr.getAminoAcidVariant().getVariantAminoAcid().substring(0,1);
                        aaVarPos = aaVarPos+1;
                    }
                    else if (Utils.isStringEmpty(var.getVariantNucleotide())) { // deletion
                        if (var.getReferenceNucleotide().length() % 3 != 0) {
                            // frameshift deletion (nucleotide count not divisible by 3)
                            isFrameshift = true;
                            aaVar = tr.getAminoAcidVariant().getVariantAminoAcid();
                        } else {
                            int aaAfected = var.getReferenceNucleotide().length()/3;
                            for(int i = 0; i < aaAfected; i++)
                                aaVar += "-";
                            aaVarPos = aaVarPos + aaAfected;
                        }
                    }
                    else { // insertion
                        if (var.getVariantNucleotide().length() % 3 != 0) {
                            // frameshift insertion (nucleotide count not divisible by 3)
                            isFrameshift = true;
                            aaVar = tr.getAminoAcidVariant().getVariantAminoAcid();
                        } else {
                            int aaAfected = var.getVariantNucleotide().length()/3;
                            aaVar = tr.getAminoAcidVariant().getVariantAminoAcid().substring(0,aaAfected);
                            aaRef = "-";
                        }
                    }
                }
                else
                    aaVarPos++;

                // The gene symbol is a lookup per transcript and is missing for plenty of them.
                // It used to sit in a <tr> wrapped in try/catch, which swallowed the failure but
                // left the row out; here it is resolved first so the card can lead with it.
                String transcriptGeneSymbol = "";
                try {
                    transcriptGeneSymbol = xdbDAO.getGenesByXdbId(1, tr.getAminoAcidVariant().getTranscriptSymbol()).get(0).getSymbol();
                } catch (Exception e) {
                }

                String synonymousFlag = tr.getAminoAcidVariant().getSynonymousFlag();
                boolean isFaulty = tr.getAminoAcidVariant().getTripletError().equals("T")
                        || tr.getAminoAcidVariant().getLocation().equals("Unknown");
            %>
                <div class="rgdTranscriptCard">
                    <div class="rgdTranscriptHead">
                        <% if( !Utils.isStringEmpty(transcriptGeneSymbol) ) { %>
                        <span class="rgdTranscriptSymbol"><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(transcriptGeneSymbol)%></span>
                        <% } %>
                        <span class="rgdTranscriptAcc"><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(tr.getAminoAcidVariant().getTranscriptSymbol())%></span>
                    </div>

                    <table class="rgdSeqTable">
                        <tr>
                            <td class="label">Location</td>
                            <td><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(tr.getAminoAcidVariant().getLocation().replace(",",";"))%></td>
                        </tr>
                        <% if (tr.getAminoAcidVariant().getVariantAminoAcid() != null && !tr.getAminoAcidVariant().getLocation().equals("Unknown")) {%>
                        <tr>
                            <td class="label">Amino Acid Prediction</td>
                            <td><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(aaRef)%> to <%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(isFrameshift ? tr.getAminoAcidVariant().getVariantAminoAcid() : aaVar)%>
                                <%=Utils.stringsAreEqualIgnoreCase("snv", var.getVariantType()) && synonymousFlag != null ? org.apache.commons.text.StringEscapeUtils.escapeHtml4(synonymousFlag) : ""%></td>
                        </tr>
                        <% }else if (synonymousFlag != null){ %>
                        <tr>
                            <td class="label">Amino Acid Prediction</td>
                            <td><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(synonymousFlag)%></td>
                        </tr>
                        <%}%>
                        <% if (tr.getAminoAcidVariant().getAaPosition() > 0) { %>
                        <%-- these two cells were written outside any <tr>, so the browser had to
                             invent a row for them and they came out on a line of their own --%>
                        <tr>
                            <td class="label">Amino Acid Position</td>
                            <td><%=tr.getAminoAcidVariant().getAaPosition()%></td>
                        </tr>
                        <% } %>
                    </table>

                    <% if (isFaulty) { %>
                    <p class="rgdTranscriptWarn">This transcript may be faulty. Please check with NCBI for corrections.</p>
                    <% } %>

                    <% if (tr.getPolyPhenPrediction().size() > 0) { %>
                    <div class="rgdSubHeading">Polyphen Predictions</div>
                    <div class="rgdTableScroll">
                        <table class="rgdSubTable">
                            <thead>
                            <tr>
                                <th>Prediction</th>
                                <th>Basis</th>
                                <th>Effect</th>
                                <th>Site</th>
                                <th>Score1</th>
                                <th>Score2</th>
                                <th>Diff</th>
                                <th>Number Observed</th>
                                <th>Structures</th>
                                <th>Protein ID</th>
                                <th>PDB ID</th>
                                <th>Inverted</th>
                            </tr>
                            </thead>
                            <tbody>
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
                            </tbody>
                        </table>
                    </div>
                    <% }
                        if (tr.getAminoAcidVariant().getAASequence() !=null && tr.getAminoAcidVariant().getAASequence().length()  > 1) {

                            String aaSequence="";
                            String aaSequence2="";
                            StringBuilder sb = new StringBuilder(tr.getAminoAcidVariant().getAASequence());

                            if (tr.getAminoAcidVariant().getAaPosition() != -1) {
                                sb.replace(tr.getAminoAcidVariant().getAaPosition()-1, aaVarPos, "=");
                            }
                            if (isFrameshift){
                                aaSequence2 = sb.substring(0, sb.indexOf("="));
                                int aaPos = sb.indexOf("=");
                                aaSequence2 += tr.getAminoAcidVariant().getVariantAminoAcid();

                                boolean spanOpened = false;
                                int pos;
                                for (pos = 0; pos < aaSequence2.length() - 100; pos += 100) {
                                    if (aaPos == pos) {
                                        aaSequence += "<span class='rgdSeqMark'>";
                                        spanOpened = true;
                                        aaSequence += aaSequence2.substring(aaPos, pos + 100);
                                        aaSequence += "<br>";
                                    } else if (aaPos > pos && aaPos < (pos + 100)) {
                                        aaSequence += aaSequence2.substring(pos, aaPos);
                                        aaSequence += "<span class='rgdSeqMark'>";
                                        spanOpened = true;
                                        aaSequence += aaSequence2.substring(aaPos, pos + 100);
                                        aaSequence += "<br>";
                                    } else if (aaPos == (pos + 100)) {
                                        aaSequence += aaSequence2.substring(pos, aaPos);
                                        aaSequence += "<br>";
                                        aaSequence += "<span class='rgdSeqMark'>";
                                        spanOpened = true;
                                    } else {
                                        aaSequence += aaSequence2.substring(pos, pos + 100);
                                        aaSequence += "<br>";
                                    }
                                }
                                if (!spanOpened && aaPos >= pos && aaPos <= aaSequence2.length()) {
                                    aaSequence += aaSequence2.substring(pos, aaPos);
                                    aaSequence += "<span class='rgdSeqMark'>";
                                    aaSequence += aaSequence2.substring(aaPos);
                                    spanOpened = true;
                                } else {
                                    aaSequence += aaSequence2.substring(pos);
                                }
                                if (spanOpened) {
                                    aaSequence += "</span>";
                                }
                            }
                            else {
                                int pos;
                                for (pos=0; pos<sb.length()-100; pos+=100) {
                                    aaSequence += sb.substring(pos, pos+100);
                                    aaSequence += "<br>";
                                }
                                aaSequence += sb.substring(pos);

                                if (tr.getAminoAcidVariant().getAaPosition() != -1) {
                                    aaSequence = aaSequence.replace("=", "<span class='rgdSeqMark'>" + aaVar + "</span>" );
                                }
                            }
                    %>
                    <div class="rgdSubHeading">Amino Acid Sequence
                        <span class="rgdSubNote">calculated using the NCBI transcript definition</span>
                    </div>
                    <pre class="rgdSeqBlock"><%=aaSequence%></pre>
                    <% } %>
                </div>
            <% } %>
            </div>
        </div>
</div>
<% } %>
    <%@ include file="../sectionFooter.jsp"%>
