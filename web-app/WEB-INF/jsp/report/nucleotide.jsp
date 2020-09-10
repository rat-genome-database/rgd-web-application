<%@ include file="sectionHeader.jsp"%>

<%//ui.dynOpen("nucAssociation", "Nucleotide Sequences")%>

<div id="nucleotideSequencesTableDiv" class="light-table-border">

    <div class="sectionHeading" id="nucleotideSequences">Nucleotide Sequences</div>

    <div id="modelsViewContent" >
        <div id="nucleotideSequencesPager" class="pager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
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



<table border="0" id="nucleotideSequencesTable" class="tablesorter">
    <thead></thead>
<%
    List<XdbId> nei = DaoUtils.getInstance().getNucleotideSequences(obj.getRgdId(), obj.getSpeciesTypeKey());

    int row = 0;
    int prevRefSeqCode = -1;
    XDBIndex xdbi = XDBIndex.getInstance();
    String geoUrl = xdbi.getXDB(59).getUrl();
    String lastLinkN = xdbi.getXDB(XdbId.XDB_KEY_GENEBANKNU).getUrl(obj.getSpeciesTypeKey());
    String prevAccId = "?";
    for (XdbId nxid: nei) {
        if( Utils.stringsAreEqual(prevAccId, nxid.getAccId()) ) {
            // don't show duplicate lines
            continue;
        }
        prevAccId = nxid.getAccId();
        String bkColor = (++row%2==0) ? "#f1f1f1" : "#e2e2e2"; // alternating lighter or brighter grey
%>
    <tr>
       <%  // 1: is ref seq, 0 - is not
           int refSeqCode = (nxid.getAccId()!=null && nxid.getAccId().length()>3 && nxid.getAccId().charAt(2)=='_') ? 1 : 0;
           if( refSeqCode != prevRefSeqCode ) {
               prevRefSeqCode = refSeqCode;
        %>

           <td style="background-color:<%=bkColor%>;"><b><%=refSeqCode>0 ? "RefSeq Transcripts" : xdbi.getXDB(nxid.getXdbKey()).getName()%></b></td>
       <% } else {%>
           <td style="background-color:<%=bkColor%>;">&nbsp;</td>
       <% } %>

        <td style="background-color:<%=bkColor%>;"><a href="<%=lastLinkN%><%=nxid.getLinkText()%>"><%=nxid.getAccId()%></a></td>
        <td style="background-color:<%=bkColor%>;"><a href="<%=lastLinkN%><%=nxid.getAccId()%>?report=fasta">(Get FASTA)</a> </td>
        <td style="background-color:<%=bkColor%>;"> &nbsp; <a href="https://www.ncbi.nlm.nih.gov/projects/sviewer/?id=<%=nxid.getAccId()%>">NCBI Sequence Viewer</a> &nbsp;</td>
        <td style="background-color:<%=bkColor%>;"><a href="<%=geoUrl%><%=nxid.getAccId()%>">Search GEO for Microarray Profiles</a></td>
    </tr>
<%
    }
%>
    </table>
</div>
<br>

<% if( objectType.equals("gene") ) { %>
<%@ include file="gene/transcripts.jsp"%>
<% } %>

<%//ui.dynClose("nucAssociation")%>

<%@ include file="sectionFooter.jsp"%>
