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
                <th class="label">File Key</th>
                <th class="label">Project File Type</th>
                <th class="label">Download URL</th>
                <th class="label">Protocol Name</th>
                <th class="label">Protocol URL</th>
                <th class="label">Actions</th>
            </tr>
            </thead>
            <tbody>
            <% for(ProjectFile pf : projectFiles) { %>
            <form action="projectFileUpdate.html" method="post" onsubmit="return validateForm(this)">
                <tr>
                    <input type="hidden" name="rgd_id" value="<%= pf.getRgdid() %>">
                    <td>
                        <input type="hidden" name="file_key" value="<%= pf.getFileKey() %>">
                        <%= pf.getFileKey() %>
                    </td>
                    <td>
                        <select name="project_file_type">
                            <option value=""></option>
                            <option value="Phenotypes" <%= (pf.getProjectFileType() != null && pf.getProjectFileType().equals("Phenotypes")) ? "selected" : "" %>>Phenotypes</option>
                            <option value="Genotypes" <%= (pf.getProjectFileType() != null && pf.getProjectFileType().equals("Genotypes")) ? "selected" : "" %>>Genotypes</option>
                        </select>
                    </td>
<%--                    <td><input type="text" name="download_url" value="<%= pf.getDownload_url() != null ? pf.getDownload_url() : "" %>"></td>--%>
                    <td><textarea name="download_url" cols="30" rows="1" ><%= pf.getDownloadUrl() != null ? pf.getDownloadUrl() : "" %></textarea></td>
<%--                    <td><input type="text" name="protocol_name" value="<%= pf.getProtocol_name() != null ? pf.getProtocol_name() : "" %>"></td>--%>
                    <td><textarea name="protocol_name" cols="30" rows="1"><%= pf.getProtocolName() != null ? pf.getProtocolName() : "" %></textarea></td>
<%--                    <td><input type="text" name="protocol" value="<%= pf.getProtocol() != null ? pf.getProtocol() : "" %>"></td>--%>
                    <td><textarea name="protocol" cols="30" rows="1"><%= pf.getProtocol() != null ? pf.getProtocol() : "" %></textarea></td>
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
    <tr>
        <td style="padding: 4px 4px;background-color:#2865a3; color:white; font-weight:700;" width="22.5%">Add New Submitted File</td>
    </tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
    <tr><td></td></tr>
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
    </tr>
</table>

<script>
    let isDeleteAction = false;
    function validateForm(form) {
        let downloadUrl = form.download_url.value;
        let fileType = form.project_file_type.value;
        let protocol = form.protocol.value;
        let protocolName = form.protocol_name.value;

        if (isDeleteAction) {
            isDeleteAction = false;
            return true;
        }

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
