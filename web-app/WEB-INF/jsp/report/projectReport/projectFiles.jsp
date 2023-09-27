<%--<style>--%>
<%--    .projFileLink{--%>
<%--        text-decoration: none;--%>
<%--    }--%>
<%--</style>--%>
<%
    List<ProjectFile> pf = new ProjectFileDAO().getProjectFiles(obj.getRgdId());
    List<ProjectFile> phenotypeFiles = new ArrayList<>();
    List<ProjectFile> genotypeFiles = new ArrayList<>();

    // Separate the files into phenotype and genotype lists
    for (ProjectFile file : pf) {
        if (file.getProject_file_type() != null) {
            if (file.getProject_file_type().equals("Phenotypes")) {
                phenotypeFiles.add(file);
            } else if (file.getProject_file_type().equals("Genotypes")) {
                genotypeFiles.add(file);
            }
        }
    }
%>
<% if(!phenotypeFiles.isEmpty()){%>
<div class="sectionHeading" id="Phenotypes">Phenotypes</div>
<ul>
    <% for (ProjectFile phenotypeFile : phenotypeFiles) { %>
    <%
        String filename = phenotypeFile.getDownload_url().substring(phenotypeFile.getDownload_url().lastIndexOf('/')+1);
    %>
    <li><a href="<%=phenotypeFile.getDownload_url()%>" class="projFileLink"><%=filename%></a></li>
    <% } %>
</ul>
<% } %>
<% if(!genotypeFiles.isEmpty()){%>
<div class="sectionHeading" id="Genotypes">Genotypes</div>
<ul>
    <% for (ProjectFile genotypeFile : genotypeFiles) { %>
    <%
        String filename = genotypeFile.getDownload_url().substring(genotypeFile.getDownload_url().lastIndexOf('/') + 1);
    %>
    <li><a href="<%=genotypeFile.getDownload_url()%>" class="projFileLink"><%=filename%></a></li>
    <% } %>
</ul>
<% } %>



