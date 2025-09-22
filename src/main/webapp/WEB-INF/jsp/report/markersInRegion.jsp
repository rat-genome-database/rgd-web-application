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
    <input class="search table-search" id='mark2AssociationSearch' type="search" data-column="all" placeholder="Search table">
</div>
<table>
    <tr>
        <td>The following <b>Markers</b> overlap with this region.&nbsp;&nbsp;&nbsp;</td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>">Full Report</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=2">CSV</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=3">TAB</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=4">Printer</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>%5B<%=objectType%>%5D&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=5">Gviewer</a></span></td>
    </tr>
</table>


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


<%--<%=ui.dynClose("mark2Asscociation")%>--%>
</div>
<%@ include file="sectionFooter.jsp"%>


