<%@ page import="edu.mcw.rgd.dao.impl.SearchDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.search.IndexRow" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>


<table border="0" width="95%">
    <tr>
        <td></td>
        <td style="border-bottom: 1px solid black; font-weight:700;">ACC</td>
        <td style="border-bottom: 1px solid black; font-weight:700;">Term</td>
        <td style="border-bottom: 1px solid black; font-weight:700;">Ont</td>
        <td style="border-bottom: 1px solid black; font-weight:700;">Is Obsolete</td>
    </tr>

<%
    OntologyXDAO dao = new OntologyXDAO();

    List<Term> lookupList = dao.findTermsForCuration(request.getParameter("search").toLowerCase(),request.getParameter("objectType"));


    Iterator lookIt = lookupList.iterator();

    while (lookIt.hasNext()) {
        Term t = (Term) lookIt.next();
%>
<tr>
    <td><a href="javascript:lookup_update('<%=t.getAccId()%>')">(select)</a></td>
    <td><%=t.getAccId()%></td>
    <td align="rigth"><%=t.getTerm()%></td>
    <td><%=t.getOntologyId()%></td>
    <td><%=t.getObsolete()%></td>
</tr>
<%
    }
%>

</table>

<% if (lookupList.size() == 0) { %>
  <br>&nbsp;&nbsp;<b>O</b> records found for search term <b>"<%=request.getParameter("search")%>"</b>

<% } %>
