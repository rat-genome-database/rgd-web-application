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
//List<Project> project1 = pdao1.getProjectByRgdId(Integer.parseInt("476081962"));
List<Project> project1 = pdao1.getProjectByRgdId(obj.getRgdId());
%>

<h1>Project: <% for(Project i:project1){ %><%= i.getName() %><% } %></h1>
<br>
<h3>Description:</h3><% for(Project i:project1){ %><%= i.getDesc() %><% } %>.
<br>
<%--<br><h3>RGD References:</h3>--%>
<%
    ReferenceDAO test = new ReferenceDAO();
//    List<Reference> p=test.getReferencesForObject(476081962);
    List<Reference> p=test.getReferencesForObject(obj.getRgdId());
//    Reference p1=test.getReference(476081962);
//    out.println(p1.getCitation());
%>
<%--<% for (Reference i:p){%>--%>
<%--<p><b><%=i.getTitle()%></b>.<%=i.getCitation()%>. RGD ID:<%=i.getRgdId()%></p>--%>
<%--<%}--%>
<%--%>--%>
<br>
<div class ="subTitle" id="references">RGD References</div>
<br>
<% for (Reference i:p){%>
<p><b><%=i.getTitle()%></b>.<br><%=i.getCitation()%>. RGD ID: <a class="mylink" href=""><%=i.getRgdId()%></a> </p>
<%}
%>
<style>

     .mylink {
        color: #5072A7;
    }
</style>
<br>
<%
    PhenominerDAO phDAO1 = new PhenominerDAO();
//    List<Record> allRecords = phDAO1.getFullRecordsForProject(476081962);
    List<Record> allRecords = phDAO1.getFullRecordsForProject(obj.getRgdId());

%>
<%--<h1><%=obj.getRgdId()%></h1>--%>
<%--<h1><%=allRecords.get(2).getClinicalMeasurement()%></h1>--%>

<%--    <%for(Record i:allRecords){%>--%>
<%--<tr id="b">--%>
<%--    <td class="he"><%= i.getClinicalMeasurement() %></td>--%>
<%--&lt;%&ndash;    <td class="he"><%= i.getExperimentNotes() %></td>&ndash;%&gt;--%>
<%--&lt;%&ndash;    <td class="he"><%= i.getSample() %></td>&ndash;%&gt;--%>
<%--</tr>--%>
<%--<%}%>--%>
<%
    List<Integer> refRgdIds = new ProjectDAO().getReferenceRgdIdsForProject(obj.getRgdId());
    List<Annotation> annotList = annotationDAO.getAnnotationsByReference(refRgdIds.get(1));
%>
<%@ include file="../sectionFooter.jsp"%>