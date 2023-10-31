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
        if (file.getProjectFileType()!= null) {
            if (file.getProjectFileType().equals("Phenotypes")) {
                phenotypeFiles.add(file);
            } else if (file.getProjectFileType().equals("Genotypes")) {
                genotypeFiles.add(file);
            }
        }
    }
%>
<% if(!phenotypeFiles.isEmpty()){%>
<div class="sectionHeading" id="Phenotypes">Phenotypes</div>
<ul>
    <% for (ProjectFile phenotypeFile : phenotypeFiles) { %>
    <%--    <%--%>
    <%--        String filename = phenotypeFile.getDownloadUrl().substring(phenotypeFile.getDownloadUrl().lastIndexOf('/')+1);--%>
    <%--    %>--%>
    <%--    <li><a href="<%=phenotypeFile.getDownloadUrl()%>" class="projFileLink"><%=filename%></a></li>--%>
    <li><a href="<%= phenotypeFile.getDownloadUrl() %>"><%= phenotypeFile.getFileTypeName() %></a></li>
    <% } %>
</ul>
<% } %>
<% if(!genotypeFiles.isEmpty()){%>
<div class="sectionHeading" id="Genotypes">Genotypes</div>
<ul>
    <% for (ProjectFile genotypeFile : genotypeFiles) { %>
    <%--    <%--%>
    <%--        String filename = genotypeFile.getDownloadUrl().substring(genotypeFile.getDownloadUrl().lastIndexOf('/') + 1);--%>
    <%--    %>--%>
    <%--    <li><a href="<%=genotypeFile.getDownloadUrl()%>" class="projFileLink"><%=filename%></a></li>--%>
    <li><a href="<%= genotypeFile.getDownloadUrl() %>"><%= genotypeFile.getFileTypeName() %></a></li>
    <% } %>
</ul>
<% } %>



