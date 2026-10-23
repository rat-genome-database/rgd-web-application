<%@ page import="edu.mcw.rgd.process.search.ReportFactory" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>

<%@ include file="sectionHeader.jsp"%>

<%
    String geneAssotitle = "Genes in Region (" + refMap.getName() + ")";
    Report r = ReportFactory.getInstance().getGeneReport(sb);

    if (r.records != null && r.records.size() > 1) {

%>

<%--<%=ui.dynOpen("geneAsscociation", geneAssotitle)%>    <br>--%>
<div id="geneAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="geneAssociation">Genes in Region</div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="geneAssociationPager" class="pager" style="margin-bottom:2px;">
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
    <input class="search table-search" id='geneAssociationSearch' type="search" data-column="all" placeholder="Search table">
</div>
<%  // Full report, CSV, TAB and Printer are replaced by one Excel download off this same legacy
    // search report; the legacy elasticsearch region url that only "Full report" used is gone.
    String geneSearchUrl = "/rgdweb/search/genes.html?term=" + displayName + "%5B" + objectType
            + "%5D&speciesType=" + obj.getSpeciesTypeKey();

    // the reference assembly the Analysis tools link is handed
    int toolsMapKey = MapManager.getInstance().getReferenceAssembly(obj.getSpeciesTypeKey()).getKey();
%>
    <%-- Excel is fmt=7 on the same search report the CSV and TAB links used, so it carries this
         table's own columns - Relevance, RGD ID, Symbol, Name, Description, Chr, Start, Stop,
         Species, Annotations, Match, Type.

         It used to be the RGD tools' excel action, which scraped the symbols out of the page and
         posted them to the generator. The generator's sheet is six fixed columns for every object
         type, so Name, Description and Annotations were all dropped on the way.

         Analysis tools still goes through the tools dialog, which is why the symbol column below
         keeps class="geneList" - toolSubmit() in my/my.js collects that class into the list it
         posts. Nothing else reads it now. --%>
    <div class="rgdLinkRow">
        <span class="rgdLinkRowLead">The following <b>Genes</b> overlap with this region.</span>
        <a class="rgdChipLink" href="<%=geneSearchUrl%>&fmt=7"
           title="Download these genes as an Excel workbook"><i class="fa fa-download rgdChipIcon" aria-hidden="true"></i>Excel</a>
        <%-- the tools icon next to this link ran showTools('geneList',3,360) - rat, and an
             assembly key from years ago - regardless of the species being reported on. The
             link beside it always passed the right species and assembly, so only it is kept --%>
        <a class="rgdChipLink" href="javascript:void(0)"
           ng-click="rgd.showTools('geneList',<%=obj.getSpeciesTypeKey()%>,<%=toolsMapKey%>)">Analysis tools</a>
    </div>

    <%
        r.removeColumn(11);
        r.removeColumn(10);
        r.removeColumn(9);
        r.removeColumn(4);
        r.removeColumn(0);

        List symbols = r.getColumn(1);
        Iterator it = symbols.iterator();
        int count=1;
        it.next();
        while (it.hasNext()) {
            String sym = (String) it.next();
            String ident =  (String) r.getColumn(0).get(count);
            r.updateRecordValue(count, 1, "<a class='geneList' href='" + Link.gene(Integer.parseInt(ident)) + "'>" + sym + "</a>");
            count++;
        }

        out.print(r.format(new HTMLTableReportStrategy()));
    %>
<br>

    <div class="modelsViewContent" >
        <div class="geneAssociationPager" class="pager" style="margin-bottom:2px;">
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
<%--<%=ui.dynClose("geneAsscociation")%>--%>
</div>
<% } %>

<%@ include file="sectionFooter.jsp"%>

