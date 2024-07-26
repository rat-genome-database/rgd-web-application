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
                    <option selected="selected" value="3">3</option>
                    <option value="5">5</option>
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

<%

    for (Transcript t : tlist) {
        String accStr = t.getAccId();
        if( t.getProteinAccId()!=null ) {
            accStr += " &nbsp; &xrArr; &nbsp; " + t.getProteinAccId();
        }
    %>


<table width="100%" border="0" style="background-color: rgb(249, 249, 249)" class="nucleotideReferenceSequencesTable" >
    <thead></thead>
    <tbody>
    <tr>
        <%
            String refDB = "RefSeq";
            if (accStr.startsWith("ENS")) {
                refDB="Ensembl";
            }
        %>

        <td class="label" valign="top" width="100"><%=refDB%> Acc Id:</td>
        <td style="font-weight: bold; color: #2865A3"><%=accStr%></td>
    </tr>
    <% if( t.getRefSeqStatus()!=null ) { %>
    <tr>
        <td class="label" valign="top" width="100">RefSeq Status:</td>
        <td><%=fu.chkNull(t.getRefSeqStatus())%></td>
    </tr>
    <% } %>
    <tr>
        <td class="label" valign="top" width="100">Type:</td>
        <td><%=t.isNonCoding() ? "NON-CODING" : "CODING"%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Position:</td>
        <td><%=MapDataFormatter.buildTable(t.getRgdId(), obj.getSpeciesTypeKey())%></td>
    </tr>

    <%
        // show transcript sequences
        for( Sequence seq: sequenceDAO.getObjectSequences(t.getRgdId(), "ncbi_rna") ) {

            // break sequence into several lines, 64 nucleotides per line
            String seqFormatted = FormUtility.formatFasta(seq.getSeqData());
    %>
    <tr>
        <td class="label" valign="top">Sequence:</td>
        <td>
            <div id="s_<%=t.getAccId()%>">
                <A HREF="javascript:toggleDivs('s_<%=t.getAccId()%>','l_<%=t.getAccId()%>');" class="seqExtInfo"
                        title="click to see full sequence">show sequence</A>
            </div>
            <div id="l_<%=t.getAccId()%>" style="display:none">
            <pre><%=seqFormatted%></pre>
            <A HREF="javascript:toggleDivs('l_<%=t.getAccId()%>','s_<%=t.getAccId()%>');" class="seqExtInfo"
                    title="click to hide sequence">hide sequence</A>
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
                    <option selected="selected" value="3">3</option>
                    <option value="5">5</option>
                    <option value="10">10</option>
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
