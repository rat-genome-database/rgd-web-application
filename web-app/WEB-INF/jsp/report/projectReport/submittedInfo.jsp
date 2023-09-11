<%
    List<Project> p1=new ProjectDAO().getProjectByRgdId(obj.getRgdId());
%>
<%if(p1.get(0).getSub_name()!=null){%>
<% for (Project i:p1){%>
<ul>
    <li><%=i.getSub_name()%></li>
    <%if(p1.get(0).getPrinci_name()!=null){%>
    <li><%=i.getPrinci_name()%></li>
<%}%>
</ul>
<%}%>
<%}%>