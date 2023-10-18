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
<<<<<<< HEAD:web-app/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
                <th class="label">File Key</th>
                <th class="label">Project File Type</th>
                <th class="label">Download URL</th>
                <th class="label">Protocol Name</th>
                <th class="label">Protocol URL</th>
=======
                <%--                <th class="label">File Key</th>--%>
                <th class="label">Project File Type</th>
                <th class="label">File Name</th>
                <th class="label">Download URL</th>
>>>>>>> dev:src/main/webapp/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
                <th class="label">Actions</th>
            </tr>
            </thead>
            <tbody>
            <% for(ProjectFile pf : projectFiles) { %>
            <form action="projectFileUpdate.html" method="post" onsubmit="return validateForm(this)">
                <tr>
<<<<<<< HEAD:web-app/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
                    <input type="hidden" name="rgd_id" value="<%= pf.getRgdid() %>">
                    <td>
                        <input type="hidden" name="file_key" value="<%= pf.getFile_key() %>">
                        <%= pf.getFile_key() %>
                    </td>
                    <td>
                        <select name="project_file_type">
                            <option value=""></option>
                            <option value="Phenotypes" <%= (pf.getProject_file_type() != null && pf.getProject_file_type().equals("Phenotypes")) ? "selected" : "" %>>Phenotypes</option>
                            <option value="Genotypes" <%= (pf.getProject_file_type() != null && pf.getProject_file_type().equals("Genotypes")) ? "selected" : "" %>>Genotypes</option>
                        </select>
                    </td>
<%--                    <td><input type="text" name="download_url" value="<%= pf.getDownload_url() != null ? pf.getDownload_url() : "" %>"></td>--%>
                    <td><textarea name="download_url" cols="30" rows="1" ><%= pf.getDownload_url() != null ? pf.getDownload_url() : "" %></textarea></td>
<%--                    <td><input type="text" name="protocol_name" value="<%= pf.getProtocol_name() != null ? pf.getProtocol_name() : "" %>"></td>--%>
                    <td><textarea name="protocol_name" cols="30" rows="1"><%= pf.getProtocol_name() != null ? pf.getProtocol_name() : "" %></textarea></td>
<%--                    <td><input type="text" name="protocol" value="<%= pf.getProtocol() != null ? pf.getProtocol() : "" %>"></td>--%>
                    <td><textarea name="protocol" cols="30" rows="1"><%= pf.getProtocol() != null ? pf.getProtocol() : "" %></textarea></td>
=======
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
>>>>>>> dev:src/main/webapp/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
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
<<<<<<< HEAD:web-app/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
    <tr>
        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700;" width="22.5%">Add New Submitted File</td>
=======
<%--    <tr>--%>
<%--        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700;" width="607.7px">Add New Submitted File</td>--%>
<%--    </tr>--%>
    <tr>
        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700; display: flex; justify-content: space-between; align-items: center;" width="607.7px">
            Add New Submitted File
            <button onclick="toggleSection()">Add</button>
        </td>
>>>>>>> dev:src/main/webapp/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
    </tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
<<<<<<< HEAD:web-app/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
    <tr><td></td></tr>
    <tr>
        <form action="projectFileUpdate.html" method="post" onsubmit="return validateForm(this)">
            <input type="hidden" name="action" value="add" class="label">
            <input type="hidden" name="rgd_id" value="<%= request.getParameter("rgdId") %>">
            <table>
                <tr>
                    <td class="label">Project File Type: </td>
                    <td>
                        <select name="project_file_type">
                            <option value=""></option>
                            <option value="Phenotypes">Phenotypes</option>
                            <option value="Genotypes">Genotypes</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="label">Download URL: </td>
<%--                    <td><input type="text" name="download_url"><br></td>--%>
                    <td><textarea name="download_url" cols="45" rows="1"></textarea></td>
                </tr>
                <tr>
                    <td class="label">Protocol Name:</td>
<%--                    <td><input type="text" name="protocol_name"></td>--%>
                    <td><textarea name="protocol_name" cols="45" rows="1"></textarea></td>
                </tr>
                <tr>
                    <td class="label">Protocol URL:</td>
<%--                    <td><input type="text" name="protocol"></td>--%>
                    <td><textarea name="protocol" cols="45" rows="1"></textarea></td>
                </tr>
                <tr>
                    <td colspan="2" align="center"><input type="submit" value="Insert Submitted File"></td>
                </tr>
            </table>
        </form>
=======
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
>>>>>>> dev:src/main/webapp/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
    </tr>
</table>

<script>
    let isDeleteAction = false;
    function validateForm(form) {
<<<<<<< HEAD:web-app/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
        let downloadUrl = form.download_url.value;
        let fileType = form.project_file_type.value;
        let protocol = form.protocol.value;
        let protocolName = form.protocol_name.value;
=======
        let downloadUrl1 = form.downloadUrl.value;
        let fileType = form.projectFileType.value;
        let fileName1=form.fileName.value;
>>>>>>> dev:src/main/webapp/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp

        if (isDeleteAction) {
            isDeleteAction = false;
            return true;
        }

<<<<<<< HEAD:web-app/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
        if (!downloadUrl.trim() && !fileType.trim() && !protocol.trim() && !protocolName.trim()) {
            alert("Please provide input for at least one field.");
            return false;
        }

        if ((downloadUrl.trim() && !fileType.trim()) || (!downloadUrl.trim() && fileType.trim())) {
            alert("Please ensure both Project File Type and Download URL are provided.");
            return false;
        }

        if ((protocol.trim() && !protocolName.trim()) || (!protocol.trim() && protocolName.trim())) {
            alert("Please ensure both Protocol and Protocol Name are provided.");
            return false;
        }

        return true;
    }
</script>
=======
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
>>>>>>> dev:src/main/webapp/WEB-INF/jsp/curation/edit/projectFileDetailsNew.jsp
