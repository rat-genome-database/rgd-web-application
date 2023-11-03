<%@ include file="../sectionHeader.jsp"%>
<style>
    h1,h3{
        color:#2865A3;
        font-size: 24px;
        font-weight: 700;
        ont-style: italic;
    }
    .label {
        font-size:16px;

    }
    .labelValue {
        font-size:16px;
    }
    .subTitle {
        font-style:normal;
    }
    .mylink {
        color: #5072A7;
    }
</style>
<%
    ProjectDAO pdao1 = new ProjectDAO();
    List<Project> project1 = pdao1.getProjectByRgdId(obj.getRgdId());
%>

    <br>
<h1><span color="black">Project:</span> <% for(Project i:project1){ %><%= i.getName() %><% } %></h1>
    <br>

<%
    List<Project> p1=new ProjectDAO().getProjectByRgdId(obj.getRgdId());
%>

<table>
<% for (Project i:p1){%>
<%--<ul>--%>
<%if(p1.get(0).getSubmitterName()!=null){%>
<tr>
    <td class="label">Submitter Name:</td>
    <td>&nbsp;</td>
    <td class="labelValue">
        <%=i.getSubmitterName()%>
    </td>
</tr>
<%}%>
<%if(p1.get(0).getPiName()!=null){%>
<tr>
    <td class="label">Principal Investigator:</td>
    <td>&nbsp;</td>
    <td class="labelValue"><%=i.getPiName()%></td>
</tr>
<%}%>
<%}%>

<tr>
    <td class="label">Project ID:</td>
    <td>&nbsp;</td>
    <td class="labelValue">RGD:<%=project1.get(0).getRgdId()%></td>
</tr>

</table>
<br>

<hr>
<h2>Project Description:</h2>
<div style="font-size:16px;"><%=project1.get(0).getDesc()%></div><br>
<%
    ReferenceDAO test = new ReferenceDAO();
    List<Reference> p=test.getReferencesForObject(obj.getRgdId());
%>
<%if(!p.isEmpty()){%>

<hr>
<div id="references" class="subTitle"><h2>Associated References</h2></div>
<br>
<% for (Reference i:p){
    List<XdbId> pmIds = xdbDAO.getXdbIdsByRgdId(2, i.getRgdId());
    String pmId = "";
    if (pmIds.size() > 0) {
        pmId = pmIds.get(0).getAccId();
    }
%>
<p><b><%=i.getTitle()%></b>.<br><%=i.getCitation() %>
    <% if(pmIds.size()>0){%>
       PMID: <a class="mylink" href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmId%>"><%=pmId%></a>,
<%}
%>
RGD ID: <a class="mylink" href="/rgdweb/report/reference/main.html?id=<%=i.getRgdId()%>"><%=i.getRgdId()%></a></p>
<%}%>
<%}%>
<%@ include file="../sectionFooter.jsp"%>