<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.process.search.ReportFactory" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>

<%@ include file="sectionHeader.jsp"%>

<% String qtlAssotitle = "QTLs in Region (" + refMap.getName() + ")";            %>

<%
    if (RgdContext.isChinchilla(request)) {
        sb.setChinchilla(true);
    }

    Report r = ReportFactory.getInstance().getQTLReport(sb);

    if (r.records.size() > 1) {

%>

<br>
<div class="sectionHeading" id="qtlAssociation"><%=qtlAssotitle%></div>
<table>
    <tr>
        <td>The following <b>QTLs</b> overlap with this region.&nbsp;&nbsp;&nbsp;</td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/qtls.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>">Full Report</a></span></td>

<td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/qtls.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=2">CSV</a></span></td>
<td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/qtls.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=3">TAB</a></span></td>
<td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/qtls.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=4">Printer</a></span></td>
<td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/search/qtls.html?term=<%=displayName%>[<%=objectType%>]&speciesType=<%=obj.getSpeciesTypeKey()%>&fmt=5">Gviewer</a></span></td>
</tr>
</table>
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


<% } %>

<%@ include file="sectionFooter.jsp"%>


