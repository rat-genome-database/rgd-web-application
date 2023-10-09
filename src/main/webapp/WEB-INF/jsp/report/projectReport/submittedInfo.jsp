<%
    List<Project> p1=new ProjectDAO().getProjectByRgdId(obj.getRgdId());
%>

<% for (Project i:p1){%>
<%--<ul>--%>
    <%if(p1.get(0).getSubmitterName()!=null){%>
    <h3>Submitter Name:</h3>
    <li><%=i.getSubmitterName()%></li>
    <%}%>
    <%if(p1.get(0).getPiName()!=null){%>
    <br>
    <h3>Principal Investigator Name:</h3>
    <li><%=i.getPiName()%></li>
<%}%>
<%--</ul>--%>
<%}%>
