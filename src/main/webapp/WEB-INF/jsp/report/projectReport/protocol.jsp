<%
    List<ProjectFile> pf1 = new ProjectFileDAO().getProjectFiles(obj.getRgdId());
    List<ProjectFile> protocols= new ArrayList<>();
    for (ProjectFile file : pf1) {
        if(file.getProjectFileType()!=null){
            if(file.getProjectFileType().equals("Protocol")){
                protocols.add(file);
            }
        }
    }
%>
<% if (!protocols.isEmpty()) { %>
<ul>
    <% for (ProjectFile i : protocols) { %>
    <li><a href="<%= i.getDownloadUrl() %>"><%= i.getFileTypeName() %></a></li>
    <% } %>
</ul>
<% } %>
