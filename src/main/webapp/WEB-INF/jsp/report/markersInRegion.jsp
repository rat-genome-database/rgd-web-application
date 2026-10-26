<%@ page import="edu.mcw.rgd.process.search.ReportFactory" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>


<%@ include file="sectionHeader.jsp"%>

<% String markAssotitle = "Markers in Region (" + refMap.getName() + ")";            %>

<%--<%=ui.dynOpen("mark2Asscociation", markAssotitle)%>    <br>--%>
<div id="mark2AssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="mark2Asscociation">Markers in Region</div>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="mark2AssociationPager" class="pager" style="margin-bottom:2px;">
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
    <input class="search table-search" id='mark2AssociationSearch' type="search" data-column="all" placeholder="Search table">
</div>
<%  String markerSearchUrl = "/rgdweb/search/markers.html?term=" + displayName + "%5B" + objectType
            + "%5D&speciesType=" + obj.getSpeciesTypeKey();

    // Full report, CSV, TAB and Printer are replaced by one Excel download. GViewer below still
    // comes from the legacy report, and so does Excel now, so markerSearchUrl stays.
%>
    <%-- Excel is fmt=7 on the same legacy search report the CSV and TAB links used, so it
         carries this table's own columns - Relevance, RGD ID, Symbol, Expected Size, Chr, Start,
         Stop, Species, Match, Type.

         Not the RGD tools' excel action, which is what Genes and QTLs in Region use: that route
         resolves its list through OLGAParser/GeneratorCommandParser in rgdcore, and neither of
         those knows about markers - they reach for GeneDAO, QTLDAO and StrainDAO only. oKey 3
         resolves to nothing there, so the tools hand back a workbook with headers and no rows. --%>
    <div class="rgdLinkRow">
        <span class="rgdLinkRowLead">The following <b>Markers</b> overlap with this region.</span>
        <a class="rgdChipLink" href="<%=markerSearchUrl%>&fmt=7"
           title="Download these markers as an Excel workbook"><i class="fa fa-download rgdChipIcon" aria-hidden="true"></i>Excel</a>
        <a class="rgdChipLink" href="<%=markerSearchUrl%>&fmt=5">GViewer</a>
    </div>


                <%
                    try {
                    Report r = ReportFactory.getInstance().getMarkerReport(sb);

                    r.removeColumn(0);
                    r.removeColumn(8);


                    List symbols = r.getColumn(1);
                    Iterator it = symbols.iterator();
                    int count=1;
                    it.next();
                    while (it.hasNext()) {
                        String sym = (String) it.next();
                        String ident =  (String) r.getColumn(0).get(count);
                        // no list class here: the Excel link is a plain fmt=7 download off the
                        // search report, not the RGD tools' DOM-scraping export
                        r.updateRecordValue(count, 1, "<a href='" + Link.marker(Integer.parseInt(ident)) + "'>" + sym + "</a>");
                        count++;
                    }




                    out.print(r.format(new HTMLTableReportStrategy()));
                    }catch (Exception e) {
                        e.printStackTrace();
                    }

                %>

    <div class="modelsViewContent" >
        <div class="mark2AssociationPager" class="pager" style="margin-bottom:2px;">
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


<%--<%=ui.dynClose("mark2Asscociation")%>--%>
</div>
<%@ include file="sectionFooter.jsp"%>


