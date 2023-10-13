<%
    List<Project> p1=new ProjectDAO().getProjectByRgdId(obj.getRgdId());
%>
<style>
    h4,h5{
        color:#2865A3;
        font-weight: bold;
        font-style: italic;
    }
    .inline-heading {
        display: inline;
    }
</style>
<% for (Project i:p1){%>
<%--<ul>--%>
    <%if(p1.get(0).getSubmitterName()!=null){%>
<b>Submitter Name:</b> <%=i.getSubmitterName()%>
<%}%>
<br>
    <%if(p1.get(0).getPiName()!=null){%>
    <br>
<b>P I Name:</b> <%=i.getPiName()%>
<%}%>
<%--</ul>--%>
<%}%>
