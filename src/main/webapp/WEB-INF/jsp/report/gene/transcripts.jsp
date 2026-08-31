<%
    List<Transcript> tlist = transcriptDAO.getTranscriptsForGene(obj.getRgdId());
    if (tlist.size() > 0) {

        // sort transcripts by acc id
        Collections.sort(tlist, new Comparator<Transcript>() {
            @Override
            public int compare(Transcript o1, Transcript o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getAccId(), o2.getAccId());
            }
        });
%>
<%@ include file="../sectionHeader.jsp"%>


<div id="nucleotideReferenceSequencesTableDiv" class="reportTable light-table-border">

    <div class="sectionHeading sidebar-item" id="referenceSequences">Reference Sequences</div>


    <div class="modelsViewContent" >
        <div class="nucleotideReferenceSequencesPager" class="pager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option value="3">3</option>
                    <option value="5">5</option>
                    <option value="10" selected="selected">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

<%
    for (Transcript t : tlist) {
        String accId = t.getAccId()==null ? "" : t.getAccId();
        String refDB = accId.startsWith("ENS") ? "Ensembl" : "RefSeq";
%>

<table width="100%" border="0" class="nucleotideReferenceSequencesTable refSeqCard">
    <tbody>
    <tr class="refSeqCardHead">
        <td colspan="2">
            <span class="refSeqAcc" title="<%=refDB%> accession"><%=accId%></span>
            <% if( t.getProteinAccId()!=null ) { %>
            <span class="refSeqArrow" aria-hidden="true">&xrArr;</span>
            <span class="refSeqAcc refSeqAcc--paired" title="protein accession"><%=t.getProteinAccId()%></span>
            <% } %>
            <span class="refSeqTag"><%=refDB%></span>
            <span class="refSeqTag <%=t.isNonCoding() ? "refSeqTag--noncoding" : "refSeqTag--coding"%>"
                  title="transcript type"><%=t.isNonCoding() ? "non-coding" : "coding"%></span>
            <% if( t.getRefSeqStatus()!=null ) { %>
            <span class="refSeqTag refSeqTag--status" title="RefSeq status"><%=fu.chkNull(t.getRefSeqStatus())%></span>
            <% } %>
        </td>
    </tr>
    <tr>
        <td class="refSeqLabel">Position</td>
        <td class="refSeqValue"><%=MapDataFormatter.buildTable(t.getRgdId(), obj.getSpeciesTypeKey())%></td>
    </tr>

    <%
        // show transcript sequences
        for( Sequence seq: sequenceDAO.getObjectSequences(t.getRgdId(), "ncbi_rna") ) {

            // break sequence into several lines, 64 nucleotides per line
            String seqFormatted = FormUtility.formatFasta(seq.getSeqData());
    %>
    <tr>
        <td class="refSeqLabel">Sequence</td>
        <td class="refSeqValue">
            <div id="s_<%=t.getAccId()%>">
                <a href="javascript:toggleDivs('s_<%=t.getAccId()%>','l_<%=t.getAccId()%>');" class="seqExtInfo"
                   title="click to see full sequence">show sequence</a>
            </div>
            <div id="l_<%=t.getAccId()%>" style="display:none">
                <pre><%=seqFormatted%></pre>
                <a href="javascript:toggleDivs('l_<%=t.getAccId()%>','s_<%=t.getAccId()%>');" class="seqExtInfo"
                   title="click to hide sequence">hide sequence</a>
            </div>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>

<% }%>

    <div class="modelsViewContent" >
        <div class="nucleotideReferenceSequencesPager" class="pager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option value="3">3</option>
                    <option value="5">5</option>
                    <option value="10" selected="selected">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<%@ include file="../sectionFooter.jsp"%>
<% } %>
