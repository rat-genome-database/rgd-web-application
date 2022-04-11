<a name="ViewDataTable"></a>
<table>
    <tr>
        <td><b>Options:&nbsp;</b></td>
        <td><a href="#ViewChart">View chart</a></td>
        <td>&nbsp;|&nbsp;</td>
        <td><a href="<%=tableUrl%>&fmt=3">Download data table</a></td>
        <td>&nbsp;|&nbsp;</td>
        <% if (format==2) { %>
        <td><a href="<%=tableUrl%>&fmt=1">View compact data table</a></td>
        <% } else { %>
        <td><a href="<%=tableUrl%>&fmt=2">View expanded data table</a></td>
        <% } %>
    </tr>
</table>
<style>
.headerRow{
position:sticky;
top: 0 ;
}
</style>
<script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>
<div class="overflow-auto" style="height:400px">
<%
    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties(" class='sortable' lign='center' ");
    out.print(strat.format(report));
%>
    </div>