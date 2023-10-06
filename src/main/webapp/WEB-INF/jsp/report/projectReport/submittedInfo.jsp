<%
    List<Project> p1=new ProjectDAO().getProjectByRgdId(obj.getRgdId());
%>

<% for (Project i:p1){%>
<%--<ul>--%>
    <%if(p1.get(0).getSub_name()!=null){%>
    <h3>Submitter Name:</h3>
    <li><%=i.getSub_name()%></li>
    <%}%>
    <%if(p1.get(0).getPrinci_name()!=null){%>
    <br>
    <h3>Principal Investigator Name:</h3>
    <li><%=i.getPrinci_name()%></li>
<%}%>
<%--</ul>--%>
<%}%>
