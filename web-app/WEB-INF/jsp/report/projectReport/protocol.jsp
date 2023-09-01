<%
    List<ProjectFile> pf1= new ProjectFileDAO().getProjectFiles(obj.getRgdId());
%>
<% if(!pf1.isEmpty()){%>
<br>
<li><a href="<%=pf1.get(0).getProtocol()%>">Breeding Protocol for HS Rats</a></li>
<br>
<%}%>