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

    // Full report, CSV, TAB and Printer are replaced by one Excel download. Both it and GViewer
    // come from this legacy search report, so qtlSearchUrl stays; the legacy elasticsearch
    // region url that only "Full report" used went with it.
%>
    <%-- Excel is fmt=7 on the same search report the CSV and TAB links used, so it carries this
         table's own columns - Relevance, RGD ID, Symbol, Name, LOD, P Value, Trait, Sub Trait,
         Chr, Start, Stop, Species, Annotations, Match, Type.

         It used to be the RGD tools' excel action, which scraped the symbols out of the page and
         posted them to the generator. That worked, but the generator's sheet is six fixed columns
         for every object type - no LOD, no p value, no trait - which is most of what a QTL list
         is for. See also markersInRegion.jsp, which has to use this route: the generator cannot
         resolve markers at all. --%>
    <div class="rgdLinkRow">
        <span class="rgdLinkRowLead">The following <b>QTLs</b> overlap with this region.</span>
        <a class="rgdChipLink" href="<%=qtlSearchUrl%>&fmt=7"
           title="Download these QTLs as an Excel workbook"><i class="fa fa-download rgdChipIcon" aria-hidden="true"></i>Excel</a>
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
                        // no list class here: the Excel link is a plain fmt=7 download off the
                        // search report, not the RGD tools' DOM-scraping export
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


