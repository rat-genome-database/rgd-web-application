<%
    List<ProjectFile> pf= new ProjectFileDAO().getProjectFiles(obj.getRgdId());
%>
<% for(int i=0;i<pf.size();i++){%>
<br>
<%if(pf.get(i).getProject_file_type().equals("phenotypes")){%>
<br>
<div class="sectionHeading"><%=pf.get(i).getProject_file_type()%>
</div>
<%--<a href="<%=pf.get(i).getDownload_url()%>">Phenotype File <%=i+1%></a>--%>
<a href="<%=pf.get(i).getDownload_url()%>">Phenotype File</a>
<%}%>
<br>
<%if(pf.get(i).getProject_file_type().equals("genotypes")){%>
<div class="sectionHeading"><%=pf.get(i).getProject_file_type()%></div>
<%--<a href="<%=pf.get(i).getDownload_url()%>">Genotype File <%=i+1%></a>--%>
<a href="<%=pf.get(i).getDownload_url()%>">Genotype File</a>
<%}%>
<%}%>