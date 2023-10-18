<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>
<table>
    <%
        List<Reference> refs= (List<Reference>) request.getAttribute("refs");
        int count=1;
        for(Reference ref:refs) {
            if(ref.getReferenceType().equalsIgnoreCase("journal article")){
    %>
    <tr>
        <td>
            <%=count++%>.
        </td>
        <td>
            <a href="<%=Link.it(ref.getRgdId())%>" target="_blank"><%=ref.getCitation()%></a><br>
        </td>
    </tr>
    <%
        }}
    %>
</table>