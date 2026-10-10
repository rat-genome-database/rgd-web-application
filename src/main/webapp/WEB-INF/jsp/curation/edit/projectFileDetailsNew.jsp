<%@ page import="edu.mcw.rgd.datamodel.ProjectFile" %>
<%@ page import="java.util.List" %>
<%
    ProjectFileDAO projectFileDAO = new ProjectFileDAO();
    List<ProjectFile> projectFiles = projectFileDAO.getProjectFiles(rgdId);
%>


<table>
    <tr>
        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700;" width="22.5%">Update Submitted Files</td>
    </tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr>
        <table border="1">
            <thead>
            <tr>
                <%--                <th class="label">File Key</th>--%>
                <th class="label">Project File Type</th>
                <th class="label">File Name</th>
                <th class="label">Download URL</th>
                <th class="label">Actions</th>
            </tr>
            </thead>
            <tbody>
            <% for(ProjectFile pf : projectFiles) { %>
            <form action="projectFileUpdate.html" method="post" onsubmit="return validateForm(this)">
                <tr>
                    <input type="hidden" name="rgd_id" value="<%= pf.getRgdId() %>">
                    <input type="hidden" name="fileKey" value="<%= pf.getFileKey() %>">
                    <%--                    <td>--%>
                    <%--                        <input type="hidden" name="file_key" value="<%= pf.getFileKey() %>">--%>
                    <%--                        <%= pf.getFileKey() %>--%>
                    <%--                    </td>--%>
                    <td>
                        <select name="projectFileType">
                            <option value="Phenotypes" <%= (pf.getProjectFileType() != null && pf.getProjectFileType().equals("Phenotypes")) ? "selected" : "" %>>Phenotypes</option>
                            <option value="Genotypes" <%= (pf.getProjectFileType() != null && pf.getProjectFileType().equals("Genotypes")) ? "selected" : "" %>>Genotypes</option>
                            <option value="Protocol" <%= (pf.getProjectFileType() != null && pf.getProjectFileType().equals("Protocol")) ? "selected" : "" %>>Protocol</option>
                        </select>
                    </td>
                    <td><textarea name="fileName" cols="90" rows="1" ><%= pf.getFileTypeName() != null ? pf.getFileTypeName(): "" %></textarea></td>
                    <td><textarea name="downloadUrl" cols="90" rows="1" ><%= pf.getDownloadUrl() != null ? pf.getDownloadUrl() : "" %></textarea></td>
                    <td>
                        <input type="submit" value="update" name="action">
                        <input type="submit" value="delete" name="action" onclick="isDeleteAction=true;return confirm('Are you sure you want to delete?')">
                    </td>
                </tr>
            </form>
            <% } %>
            </tbody>
        </table>
    </tr>
</table>
<br>
<table>
<%--    <tr>--%>
<%--        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700;" width="607.7px">Add New Submitted File</td>--%>
<%--    </tr>--%>
    <tr>
        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700; display: flex; justify-content: space-between; align-items: center;" width="607.7px">
            Add New Submitted File
            <button onclick="toggleSection()">Add</button>
        </td>
    </tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr>
        <td><div id="sectionContainer1" style="display: none;">
            <form action="projectFileUpdate.html" method="post" onsubmit="return validateForm(this)">
                <input type="hidden" name="action" value="add" class="label">
                <input type="hidden" name="rgd_id" value="<%= request.getParameter("rgdId") %>">
                <table>
                    <tr>
                        <td class="label">Project File Type: </td>
                        <td>
                            <select name="projectFileType">
                                <option value=""></option>
                                <option value="Phenotypes">Phenotypes</option>
                                <option value="Genotypes">Genotypes</option>
                                <option value="Protocol">Protocol</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="label">File Name: </td>
                        <td><textarea name="fileName" cols="90" rows="1"></textarea></td>
                    </tr>
                    <tr>
                        <td class="label">Download URL: </td>
                        <td><textarea name="downloadUrl" cols="90" rows="1"></textarea></td>
                    </tr>
                    </tr>
                    <tr>
                        <td colspan="2" align="center"><input type="submit" value="Insert Submitted File"></td>
                    </tr>
                </table>
            </form>
        </div>
        </td>
    </tr>
</table>

<script>
    let isDeleteAction = false;
    function validateForm(form) {
        let downloadUrl1 = form.downloadUrl.value;
        let fileType = form.projectFileType.value;
        let fileName1=form.fileName.value;

        if (isDeleteAction) {
            isDeleteAction = false;
            return true;
        }

        if (!downloadUrl1.trim() || !fileType.trim() || !fileName1.trim()) {
            alert("Please ensure all the input fields are given.");
            return false;
        }
        return true;
    }
</script>

<script>
    function toggleSection() {
        var section = document.getElementById('sectionContainer1');
        var button = document.querySelector('[onclick="toggleSection()"]');
        section.style.display = (section.style.display === "none") ? "block" : "none";
        button.textContent = (button.textContent === "Add") ? "Cancel" : "Add";
    }
</script>