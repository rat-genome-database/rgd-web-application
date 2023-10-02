<%
    List<ProjectFile> pf1 = new ProjectFileDAO().getProjectFiles(obj.getRgdId());
%>
<% if (!pf1.isEmpty()) { %>
<ul>
    <% for (ProjectFile i : pf1) { %>
    <% if (i.getProtocol_name() != null && i.getProtocol() != null) { %>
    <li><a href="<%= i.getProtocol() %>"><%= i.getProtocol_name() %></a></li>
    <% } %>
    <% } %>
</ul>
<% } %>
