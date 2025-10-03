<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>

<style>
.citations-table tr:hover {
    background-color: #f5f5f5 !important;
}
.citations-table a:hover {
    text-decoration: underline !important;
    color: #0056b3 !important;
}
@media (max-width: 768px) {
    .citations-table {
        font-size: 14px;
    }
    .citations-table th, .citations-table td {
        padding: 4px 6px !important;
    }
}
</style>
<br>
<%--<div class="rgd-panel rgd-panel-default">--%>
    <h2>About these ontologies</h2>
<%--</div>--%>
<%
    if (refs.size() > 0 ) {
        // sort references by citation
        Collections.sort(refs, new Comparator<Reference>() {
            public int compare(Reference o1, Reference o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
            }
        });
%>
 <table class="citations-table" style="width: 100%; border-collapse: collapse; margin: 20px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <thead><tr style="background-color: #f8f9fa; border-bottom: 2px solid #dee2e6;">
            <th style="padding: 6px 8px; text-align: left; font-weight: bold; border: 1px solid #dee2e6; width: 5%;">#</th>
            <th style="padding: 6px 8px; text-align: left; font-weight: bold; border: 1px solid #dee2e6; width: 50%;">Reference Title</th>
            <th style="padding: 6px 8px; text-align: left; font-weight: bold; border: 1px solid #dee2e6; width: 45%;">Reference Citation</th>
        </tr></thead>
        <tbody>
    <%
    int count=1;
    for(Reference ref: refs ) {
    %>
        <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 6px 8px; border: 1px solid #dee2e6; text-align: center; background-color: #f8f9fa;"><%=count++%>.</td>
            <td style="padding: 6px 8px; border: 1px solid #dee2e6; vertical-align: top;"><%=ref.getTitle()%></td>
            <td style="padding: 6px 8px; border: 1px solid #dee2e6; vertical-align: top;"><a href="<%=Link.ref(ref.getRgdId())%>" style="color: #007bff; text-decoration: none;"><%=ref.getCitation()%></a></td>
        </tr>
    <%
        }
    %>
        </tbody>
    </table>

<% } %>
