<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ include file="sectionHeader.jsp"%>

<%
    List<Reference> refs = associationDAO.getReferenceAssociations(obj.getRgdId());
    // sort references by citation
    Collections.sort(refs, new Comparator<Reference>() {
        public int compare(Reference o1, Reference o2) {
            return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
        }
    });
%>
<br><br>
<div class="reportSection">References - curated</div>
    <br>

<% if( refs.isEmpty() ) { %>
<b>No references found.</b>
<% } else { %>

<table>
    <%
        int count=1;
        for(Reference ref: refs ) {
    %>
    <tr>
        <td><%=count++%>.</td>
        <td><a href="<%=Link.ref(ref.getRgdId())%>"><%=ref.getCitation()%></a><br></td>
    </tr>
    <% } %>
</table>
<% } %>

<%@ include file="sectionFooter.jsp"%>
