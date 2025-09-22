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
                    <option  value="10">10</option>
                    <option selected="selected" value="20">20</option>
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
<table>
    <tr>
        <td>The following <b>Genes</b> overlap with this region.&nbsp;&nbsp;&nbsp;</td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/genes.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>">Full Report</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/genes.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=2">CSV</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/genes.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=3">TAB</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/genes.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=4">Printer</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><img src="/rgdweb/common/images/tools-white-30.png" style="cursor:hand; border: 1px solid black;" border="0" ng-click="rgd.showTools('geneList',3,360)"/></td>
        <td><a href="javascript:void(0)" ng-click="rgd.showTools('geneList',<%=obj.getSpeciesTypeKey()%>,<%=MapManager.getInstance().getReferenceAssembly(obj.getSpeciesTypeKey()).getKey()%>)">Analysis Tools</a></td>
    </tr>
</table>

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
                    <option  value="10">10</option>
                    <option selected="selected" value="20">20</option>
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

