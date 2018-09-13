<%@ include file="../sectionHeader.jsp"%>

<%
    List<Transcript> tlist = transcriptDAO.getTranscriptsForGene(obj.getRgdId());
    if (tlist.size() > 0) {
%>
    <br><span class="highlight"><u>Reference Sequences</u></span><br>
<%

    for (Transcript t : tlist) {
        String accStr = t.getAccId();
        if( t.getProteinAccId()!=null ) {
            accStr += " &nbsp; &xrArr; &nbsp; " + t.getProteinAccId();
        }
    %>
<br>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr>
        <td class="label" valign="top" width="100">RefSeq Acc Id:</td>
        <td style="font-weight: bold; color: #2865A3"><%=accStr%></td>
    </tr>
    <tr>
        <td class="label" valign="top" width="100">RefSeq Status:</td>
        <td><%=fu.chkNull(t.getRefSeqStatus())%>
        </td>
    </tr>
    <tr>
        <td class="label" valign="top" width="100">Type:</td>
        <td><%=t.isNonCoding() ? "NON-CODING" : "CODING"%>
        </td>
    </tr>
    <tr>
        <td class="label" valign="top">Position:</td>
        <td><%=MapDataFormatter.buildTable(t.getRgdId(), obj.getSpeciesTypeKey())%>
        </td>
    </tr>

    <%
        // show transcript sequences
        for( Sequence seq: sequenceDAO.getObjectSequences(t.getRgdId()) ) {
            if( seq.getSeqTypeKey()!=7 ) // show only RefSeq nucleotide sequences
                continue;

            // break sequence into several lines, 64 nucleotides per line
            String seqFormatted = "";
            if( seq.getCloneSeq()!=null ) {
                int loopCount = (seq.getCloneSeq().length() + 63) / 64;
                for (int i=0; i<loopCount; i++) {
                    if( i+1 == loopCount ) {
                        seqFormatted += seq.getCloneSeq().substring(i*64) + "<br>";
                    }else {
                        seqFormatted += seq.getCloneSeq().substring(i*64, (i+1)*64) + "<br>";
                    }
                }
            }
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
</table>
<br>

<% }} %>

<%@ include file="../sectionFooter.jsp"%>
