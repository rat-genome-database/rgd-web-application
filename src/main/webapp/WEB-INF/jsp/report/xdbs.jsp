<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ include file="sectionHeader.jsp"%>

<%
    List<XdbId> ei = DaoUtils.getInstance().getExternalDbLinks(obj.getRgdId(), obj.getSpeciesTypeKey());
    if (ei.size() > 0) {
%>

<%//ui.dynOpen("xdbAssociation", "External Database Links")%>


<div id="externalDatabaseLinksTableDiv" class="light-table-border">
    <div class="sectionHeading" id="externalDatabaseLinks">External Database Links</div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="externalDatabaseLinksPager" class="pager" >
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
                    <option value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <input class="search table-search" id="externalDatabaseLinksSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <table border="0" id="externalDatabaseLinksTable" class="tablesorter rgdCompactTable">
    <thead>
        <tr>
            <th>Database</th>
            <th>Acc Id</th>
            <th>Source(s)</th>
        </tr>
    </thead>
    <tbody>
<%
    for (XdbId xid: ei) {
        Xdb xdb = XDBIndex.getInstance().getXDB(xid.getXdbKey());

        String dbName = xdb==null ? "" : xdb.getName();
        String baseUrl = xdb==null ? null : xdb.getUrl(obj.getSpeciesTypeKey());

        // some databases give a url with an "[ID_HERE]" placeholder for the accession;
        // the rest just take it appended. No url at all means the accession is plain text.
        String fullUrl = null;
        if( baseUrl!=null ) {
            fullUrl = baseUrl.contains("[ID_HERE]")
                    ? baseUrl.replace("[ID_HERE]", xid.getAccId())
                    : baseUrl + xid.getAccId();
        }
        String linkText = xid.getLinkText()==null ? xid.getAccId() : xid.getLinkText();

        // The database name used to be printed only when it changed from the row above,
        // and the Source(s) cell was skipped entirely on rows with no url - which left
        // those rows a column short. Both are per-row now: the table sorts, and a name
        // that only appears on the first row of a run stops meaning anything once sorted.
%>
    <tr>
        <td class="rgdCellNowrap"><span class="rgdCellTag"><%=dbName%></span></td>
        <td class="rgdCellStrong"><% if( fullUrl!=null ) { %><a href="<%=fullUrl%>"><%=linkText%></a><% } else { %><%=xid.getAccId()%><% } %></td>
        <td class="rgdCellMuted"><%=Utils.defaultString(xid.getSrcPipeline())%></td>
    </tr>
<%
    }
%>
    </tbody>
</table>
    <div class="modelsViewContent" >
        <div class="externalDatabaseLinksPager pager" >
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
                    <option value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<br>
<%//ui.dynClose("xdbAssociation")%>
<%
    }
%>
<%@ include file="sectionFooter.jsp"%>
