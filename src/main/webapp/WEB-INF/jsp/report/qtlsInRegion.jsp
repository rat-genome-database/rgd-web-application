<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.process.search.ReportFactory" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>

<%@ include file="sectionHeader.jsp"%>

<% String qtlAssotitle = "QTLs in Region (" + refMap.getName() + ")";            %>

<%  RgdContext context = new RgdContext();
    if (context.isChinchilla(request)) {
        sb.setChinchilla(true);
    }

    Report r = ReportFactory.getInstance().getQTLReport(sb);

    if (r.records.size() > 1) {

%>

<br>

<div id="qtlAssociationTableDiv" class="light-table-border">
    <div class="sectionHeading" id="qtlAssociation"><%=qtlAssotitle%></div>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="qtlAssociationPager" class="pager" style="margin-bottom:2px;">
            <form autocomplete="off">
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10" selected="selected">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <input class="search table-search" id='qtlAssociationSearch' type="search" data-column="all" placeholder="Search table">
</div>
<%  String qtlSearchUrl = "/rgdweb/search/qtls.html?term=" + displayName + "%5B" + objectType
            + "%5D&speciesType=" + obj.getSpeciesTypeKey();

    // the html result page of the legacy "symbol[objectType]" search was replaced by
    // elasticsearch, which takes a region as chr/start/stop. The export formats below still
    // come from the legacy report, so they keep the legacy url.
    String qtlRegionUrl = qtlSearchUrl;
    if( md!=null && md.getChromosome()!=null ) {
        qtlRegionUrl = "/rgdweb/elasticResults.html?category=QTL&term=&objectSearch=true"
            + "&speciesType=" + obj.getSpeciesTypeKey()
            + "&chr=" + md.getChromosome()
            + "&start=" + md.getStartPos()
            + "&stop=" + md.getStopPos()
            + "&assembly=" + java.net.URLEncoder.encode(refMap.getDescription(), java.nio.charset.StandardCharsets.UTF_8);
    }
%>
    <%-- one sentence and five links to the same search, which used to be an eleven column
         table with a green bullet image between every pair of cells --%>
    <div class="rgdLinkRow">
        <span class="rgdLinkRowLead">The following <b>QTLs</b> overlap with this region.</span>
        <a class="rgdChipLink" href="<%=qtlRegionUrl%>">Full report</a>
        <a class="rgdChipLink" href="<%=qtlSearchUrl%>&fmt=2">CSV</a>
        <a class="rgdChipLink" href="<%=qtlSearchUrl%>&fmt=3">TAB</a>
        <a class="rgdChipLink" href="<%=qtlSearchUrl%>&fmt=4">Printer</a>
        <a class="rgdChipLink" href="<%=qtlSearchUrl%>&fmt=5">GViewer</a>
    </div>


                <%
                    try {

                    r.removeColumn(14);
                    r.removeColumn(13);
                    r.removeColumn(12);
                    r.removeColumn(0);

                    List symbols = r.getColumn(1);
                    Iterator it = symbols.iterator();
                    int count=1;
                    it.next();
                    while (it.hasNext()) {
                        String sym = (String) it.next();
                        String ident =  (String) r.getColumn(0).get(count);
                        r.updateRecordValue(count, 1, "<a href='" + Link.qtl(Integer.parseInt(ident)) + "'>" + sym + "</a>");
                        count++;
                    }

                    out.print(r.format(new HTMLTableReportStrategy()));
                    }catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
<br>

    <div class="modelsViewContent" >
        <div class="qtlAssociationPager" class="pager" style="margin-bottom:2px;">
            <form autocomplete="off">
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10" selected="selected">10</option>
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
<% } %>

<%@ include file="sectionFooter.jsp"%>


