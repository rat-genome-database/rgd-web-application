<%@ include file="../sectionHeader.jsp"%>
<style>
    h1,h3{
        color:#2865A3;
        font-size: 20px;
        font-weight: 700;
        font-style: italic;
    }
</style>
<%
    ProjectDAO pdao1 = new ProjectDAO();
    List<Project> project1 = pdao1.getProjectByRgdId(obj.getRgdId());
%>

<%--<h1>Project: <% for(Project i:project1){ %><%= i.getName() %><% } %></h1>--%>
<h1>Project: <%=project1.get(0).getName() %></h1>
<br>
<%--<h3>Description:</h3><% for(Project i:project1){ %><%= i.getDesc() %><% } %>.<br><br>--%>
<h3>Description:</h3><%=project1.get(0).getDesc()%><br><br>
<h4 class="inline-heading">RGD ID:</h4> <%=project1.get(0).getRgdId()%>
<br>
<%
    ReferenceDAO test = new ReferenceDAO();
    List<Reference> p=test.getReferencesForObject(obj.getRgdId());
%>
<%if(!p.isEmpty()){%>
<br>
<div class ="subTitle" id="references">RGD References</div>
<br>
<% for (Reference i:p){%>
<p><b><%=i.getTitle()%></b>.<br><%=i.getCitation()%>. RGD ID: <a class="mylink" href="/rgdweb/report/reference/main.html?id=<%=i.getRgdId()%>"><%=i.getRgdId()%></a> </p>
<%}
%>
<%}%>
<style>

    .mylink {
        color: #5072A7;
    }
</style>
<br>

<%@ include file="../sectionFooter.jsp"%>