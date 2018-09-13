<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ include file="sectionHeader.jsp"%>
<%
    List<XdbId> pei = DaoUtils.getInstance().getProteinSequences(obj.getRgdId(), obj.getSpeciesTypeKey());
    if( !pei.isEmpty() ) {
%>
    <%=ui.dynOpen("protAssociation", "Protein Sequences")%>
    <table border="0" >
<%
    int row = 0;
    int prevRefSeqCode = -1;
    String prevAccId = null;

    for (XdbId pxid: pei) {
        if( Utils.stringsAreEqual(prevAccId, pxid.getAccId()) ) {
            // don't show duplicate lines
            continue;
        }
        prevAccId = pxid.getAccId();
        String bkColor = (++row%2==0) ? "#f1f1f1" : "#e2e2e2"; // alternating lighter or brighter grey
        Xdb xdb = XDBIndex.getInstance().getXDB(pxid.getXdbKey());
%>
    <tr>
       <%
           String lastLinkP = xdb.getUrl(obj.getSpeciesTypeKey());
           // 1: is ref seq, 0 - is not
           int refSeqCode = (pxid.getAccId()!=null && pxid.getAccId().length()>3 && pxid.getAccId().charAt(2)=='_') ? 1 : 0;
           if( refSeqCode != prevRefSeqCode ) {
               prevRefSeqCode = refSeqCode;
       %>
           <td style="background-color:<%=bkColor%>;"><b><%=refSeqCode>0 ? "Protein RefSeqs" : xdb.getName()%></b></td>
       <% } else {%>
           <td style="background-color:<%=bkColor%>;">&nbsp;</td>
       <% } %>
        <td style="background-color:<%=bkColor%>;"><a href="<%=lastLinkP%><%=pxid.getLinkText()%>"><%=pxid.getAccId()%></a></td>
        <td style="background-color:<%=bkColor%>;"><a href="<%=lastLinkP%><%=pxid.getAccId()%>?report=fasta">(Get FASTA)</a></td>
        <td style="background-color:<%=bkColor%>;"> &nbsp; <a href="https://www.ncbi.nlm.nih.gov/projects/sviewer/?id=<%=pxid.getAccId()%>">NCBI Sequence Viewer</a> &nbsp;</td>
    </tr>
<% } %>
</table>

<%
    List<Transcript> tlist = transcriptDAO.getTranscriptsForGene(obj.getRgdId());
    if (tlist.size() > 0) {
%>
    <br><span class="highlight"><u>Reference Sequences</u></span><br>
<%

    for (Transcript t : tlist) {
        if( t.getProteinAccId()==null )
            continue;

        String uniProtAccIds = null;
        List<XdbId> uniProtXdbIds = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_UNIPROT, t.getRgdId());
        if( !uniProtXdbIds.isEmpty() ) {
            Xdb xdb = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_UNIPROT);
            String url = xdb.getUrl(obj.getSpeciesTypeKey());

            for( XdbId id: uniProtXdbIds ) {

                String uniProtAccId = "<a href=\""+url+id.getAccId()+"\">"+id.getAccId()+"</a> ("+id.getNotes()+")";
                if( uniProtAccIds==null ) {
                    uniProtAccIds = uniProtAccId;
                } else {
                    // Swiss-Prot should go first
                    if( uniProtAccId.contains("Swiss") ) {
                        // prepend at the beginning
                        uniProtAccIds = uniProtAccId + ", &nbsp; " + uniProtAccIds;
                    } else { // append at the end
                        uniProtAccIds += ", &nbsp; " + uniProtAccId;
                    }
                }
            }
        }
    %>
<br>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr>
        <td class="label" valign="top" width="110">RefSeq Acc Id:</td>
        <td style="font-weight: bold; color: #2865A3"><%=t.getProteinAccId()%> &nbsp; &xlArr; &nbsp; <%=t.getAccId()%></td>
    </tr>
    <% if( t.getPeptideLabel()!=null ) { %>
    <tr>
        <td class="label" valign="top" style="background-color: #f1f1f1"> - Peptide Label:</td>
        <td><%=t.getPeptideLabel()%></td>
    </tr>
    <% } %>
    <% if( uniProtAccIds!=null ) { %>
    <tr>
        <td class="label" valign="top" style="background-color: #f1f1f1"> - UniProtKB:</td>
        <td><%=uniProtAccIds%></td>
    </tr>
    <% } %>

<%
    // show RefSeq protein sequences
    for( Sequence2 seq: sequenceDAO.getObjectSequences2(t.getRgdId(), "ncbi_protein") ) {

        // break sequence into several lines, 64 nucleotides per line
        String seqFormatted = "";
        int loopCount = (seq.getSeqData().length() + 63) / 64;
        for (int i=0; i<loopCount; i++) {
            if( i+1 == loopCount ) {
                seqFormatted += seq.getSeqData().substring(i*64) + "<br>";
            }else {
                seqFormatted += seq.getSeqData().substring(i*64, (i+1)*64) + "<br>";
            }
        }
%>
<tr>
    <td class="label" valign="top" style="background-color: #f1f1f1"> - Sequence:</td>
    <td>
        <div id="s_<%=t.getProteinAccId()%>">
            <A HREF="javascript:toggleDivs('s_<%=t.getProteinAccId()%>','l_<%=t.getProteinAccId()%>');" class="seqExtInfo"
                    title="click to see full sequence">show sequence</A>
        </div>
        <div id="l_<%=t.getProteinAccId()%>" style="display:none">
        <pre><%=seqFormatted%></pre>
        <A HREF="javascript:toggleDivs('l_<%=t.getProteinAccId()%>','s_<%=t.getProteinAccId()%>');" class="seqExtInfo"
                title="click to hide sequence">hide sequence</A>
        </div>
    </td>
</tr>
<% } %>
</table>
<% } %>
<% } %>

    <%=ui.dynClose("protAssociation")%>
<% } %>

<%@ include file="sectionFooter.jsp"%>