<%
    ReferenceDAO test1 = new ReferenceDAO();
    List<Reference> p1=test1.getReferencesForObject(476081962);
%>

<% for (Reference i:p1){%>
<ul>
    <li><%=i.getCitation()%></li>
</ul>
<%}
%>