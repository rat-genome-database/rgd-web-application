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
<table>
    <tr>
        <td>The following <b>Markers</b> overlap with this region.&nbsp;&nbsp;&nbsp;</td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>">Full Report</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=2">CSV</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=3">TAB</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=4">Printer</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/markers.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=5">Gviewer</a></span></td>
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
<%--<%=ui.dynClose("mark2Asscociation")%>--%>
</div>
<%@ include file="sectionFooter.jsp"%>


