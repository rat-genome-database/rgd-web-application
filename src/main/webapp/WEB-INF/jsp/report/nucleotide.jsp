<%@ include file="sectionHeader.jsp"%>

<div id="nucleotideSequencesTableDiv" class="light-table-border">

    <div class="sectionHeading" id="nucleotideSequences">Nucleotide Sequences</div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="nucleotideSequencesPager" class="pager" style="margin-bottom:2px;">
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
                    <option value="30">30</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <input class="search table-search" id="nucleotideSequencesSearch" type="search" data-column="all" placeholder="Search table">
</div>


<table border="0" id="nucleotideSequencesTable" class="tablesorter rgdCompactTable">
    <thead>
        <tr>
            <th>Source</th>
            <th>Accession</th>
            <th class="rgdColRight sorter-false">Links</th>
        </tr>
    </thead>
    <tbody>
<%
    List<XdbId> nei = DaoUtils.getInstance().getNucleotideSequences(obj.getRgdId(), obj.getSpeciesTypeKey());

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

        // an accession like NM_012345 is a RefSeq; anything else is named by its xdb.
        // The label used to be printed only when it changed from the row above, which a
        // sortable, paged table cannot honour, so every row carries it now.
        String accId = nxid.getAccId();
        boolean isRefSeq = accId!=null && accId.length()>3 && accId.charAt(2)=='_';
        String sourceName = isRefSeq ? "RefSeq Transcripts" : xdbi.getXDB(nxid.getXdbKey()).getName();
%>
    <tr>
        <td class="rgdCellNowrap"><span class="rgdCellTag"><%=sourceName%></span></td>
        <td class="rgdCellStrong"><a href="<%=lastLinkN%><%=accId%>"><%=Utils.NVL(nxid.getLinkText(), accId)%></a></td>
        <td class="rgdColRight">
            <a class="rgdChipLink" href="<%=lastLinkN%><%=accId%>?report=fasta">FASTA</a>
            <a class="rgdChipLink" href="https://www.ncbi.nlm.nih.gov/projects/sviewer/?id=<%=accId%>"
               title="NCBI Sequence Viewer">Sequence Viewer</a>
            <a class="rgdChipLink" href="<%=geoUrl%><%=accId%>"
               title="Search GEO for Microarray Profiles">GEO Profiles</a>
        </td>
    </tr>
<%
    }
%>
    </tbody>
    </table>

    <div class="modelsViewContent" >
        <div class="nucleotideSequencesPager" class="pager" style="margin-bottom:2px;">
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
                    <option value="30">30</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


</div>
<br>

<% if( objectType.equals("gene") ) { %>
<%@ include file="gene/transcripts.jsp"%>
<% } %>

<%@ include file="sectionFooter.jsp"%>
