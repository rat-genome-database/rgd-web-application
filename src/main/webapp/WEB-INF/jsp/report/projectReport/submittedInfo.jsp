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
    <h5 class="inline-heading">Submitter Name: </h5> <%=i.getSubmitterName()%>
<%}%>
<br>
    <%if(p1.get(0).getPiName()!=null){%>
    <br>
    <h4 class="inline-heading">Principal Investigator Name:</h4> <%=i.getPiName()%>
<%}%>
<%--</ul>--%>
<%}%>
