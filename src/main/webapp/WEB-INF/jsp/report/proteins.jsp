<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ include file="sectionHeader.jsp"%>
<%
    List<XdbId> pei = DaoUtils.getInstance().getProteinSequences(obj.getRgdId(), obj.getSpeciesTypeKey());
    List<GenomicElement> pdomains = geDAO.getProteinDomainsForGene(obj.getRgdId());
    if( pei.size()+pdomains.size()>0 ) {
%>

<div id="proteinSequencesTableDiv" class="light-table-border">
    <div class="sectionHeading" id="proteinSequences">Protein Sequences</div>

    <div class="search-and-pager">

        <div class="modelsViewContent" >
            <div class="proteinSequencesPager" class="pager" style="margin-bottom:2px;">
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option value="10" selected="selected">10</option>
                        <option value="20">20</option>
                        <option value="30">30</option>
                        <option  value="40">40</option>
                        <option   value="100">100</option>
                        <option value="9999">All Rows</option>
                    </select>
                </form>
            </div>
        </div>
        <input class="search table-search" id="proteinSequencesSearch" type="search" data-column="all" placeholder="Search table">
    </div>


    <table border="0" id="proteinSequencesTable" class="tablesorter rgdCompactTable">
        <thead>
        <tr>
            <th>Source</th>
            <th>Accession</th>
            <th class="rgdColRight sorter-false">Links</th>
        </tr>
        </thead>
        <tbody>
        <%
            String prevAccId = null;

            for (XdbId pxid: pei) {
                if( Utils.stringsAreEqual(prevAccId, pxid.getAccId()) ) {
                    // don't show duplicate lines
                    continue;
                }
                prevAccId = pxid.getAccId();

                Xdb xdb = XDBIndex.getInstance().getXDB(pxid.getXdbKey());
                String lastLinkP = xdb.getUrl(obj.getSpeciesTypeKey());
                String accId = pxid.getAccId();

                // an accession like NP_036728 is a RefSeq; anything else is named by its xdb.
                // The label used to be printed only when it changed from the row above, which a
                // sortable table cannot honour, so every row carries it now.
                boolean isRefSeq = accId!=null && accId.length()>3 && accId.charAt(2)=='_';
                String sourceName = isRefSeq ? "Protein RefSeqs" : xdb.getName();

                boolean isEnsembl = xdb.getName().contains("Ensembl");
        %>
        <tr>
            <td class="rgdCellNowrap"><span class="rgdCellTag"><%=sourceName%></span></td>
            <td class="rgdCellStrong"><a href="<%=lastLinkP%><%=accId%>"><%=Utils.NVL(pxid.getLinkText(),accId)%></a></td>
            <td class="rgdColRight">
                <% if( !isEnsembl ) { %>
                <a class="rgdChipLink" href="<%=lastLinkP%><%=accId%>?report=fasta">FASTA</a>
                <a class="rgdChipLink" href="https://www.ncbi.nlm.nih.gov/projects/sviewer/?id=<%=accId%>"
                   title="NCBI Sequence Viewer">Sequence Viewer</a>
                <% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>


    <div class="modelsViewContent" >
        <div class="proteinSequencesPager" class="pager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option value="10" selected="selected">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<%
    List<Transcript> tlist = transcriptDAO.getTranscriptsForGene(obj.getRgdId());
    if (tlist.size() > 0) {
%>


<div id="proteinReferenceSequencesTableDiv" class="reportTable light-table-border">

    <div class="sectionHeading sidebar-item" id="referenceProteinSequences">Reference Protein Sequences</div>

    <div class="modelsViewContent" >
        <div class="proteinReferenceSequencesPager" class="pager" style="margin-bottom:2px;">
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

            String protSource = t.getProteinAccId().startsWith("EN") ? "Ensembl" : "RefSeq";
    %>
    <table width="100%" border="0" class="proteinReferenceSequencesInnerTable refSeqCard">
        <tbody>
        <tr class="refSeqCardHead">
            <td colspan="2">
                <span class="refSeqAcc" title="<%=protSource%> protein accession"><%=t.getProteinAccId()%></span>
                <span class="refSeqArrow" aria-hidden="true">&xlArr;</span>
                <span class="refSeqAcc refSeqAcc--paired" title="transcript it is translated from"><%=t.getAccId()%></span>
                <span class="refSeqTag"><%=protSource%></span>
                <% if( t.getPeptideLabel()!=null ) { %>
                <span class="refSeqTag refSeqTag--status" title="peptide label"><%=t.getPeptideLabel()%></span>
                <% } %>
            </td>
        </tr>
        <% if( uniProtAccIds!=null ) { %>
        <tr>
            <td class="refSeqLabel">UniProtKB</td>
            <td class="refSeqValue"><%=uniProtAccIds%></td>
        </tr>
        <% } %>

        <%
            // show RefSeq protein sequences
            for( Sequence seq: sequenceDAO.getObjectSequences(t.getRgdId(), "ncbi_protein") ) {

                // break sequence into several lines, 64 nucleotides per line
                String seqFormatted = FormUtility.formatFasta(seq.getSeqData());
        %>
        <tr>
            <td class="refSeqLabel">Sequence</td>
            <td class="refSeqValue">
                <div id="s_<%=t.getProteinAccId()%>">
                    <a href="javascript:toggleDivs('s_<%=t.getProteinAccId()%>','l_<%=t.getProteinAccId()%>');" class="seqExtInfo"
                       title="click to see full sequence">show sequence</a>
                </div>
                <div id="l_<%=t.getProteinAccId()%>" style="display:none">
                    <pre><%=seqFormatted%></pre>
                    <a href="javascript:toggleDivs('l_<%=t.getProteinAccId()%>','s_<%=t.getProteinAccId()%>');" class="seqExtInfo"
                       title="click to hide sequence">hide sequence</a>
                </div>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>

    <% } %>

    <div class="modelsViewContent" >
        <div class="proteinReferenceSequencesPager" class="pager" style="margin-bottom:2px;">
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
<% } %>

<%  // PROTEIN DOMAINS
    if (pdomains.size() > 0) {
%>
<div class="light-table-border">
    <div class="sectionHeading" id="proteinDomains">Protein Domains</div>
    <% for( int z=0; z<pdomains.size(); z++ ) {
        GenomicElement el = pdomains.get(z); %>

    <% if(z>0 ) { out.print(" &nbsp; "); } %>
    <a href="/rgdweb/report/proteinDomain/main.html?id=<%=el.getRgdId()%>" title="see protein domain report page"><%=el.getSymbol()%></a>
    <% } %>
    <% } %><p>
</div>
<% } %>

<%@ include file="sectionFooter.jsp"%>