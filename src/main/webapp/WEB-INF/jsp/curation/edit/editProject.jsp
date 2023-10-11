<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.ProjectDAO" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%
    String pageTitle = "Edit Project";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>

<%
    ProjectDAO projDAO = new ProjectDAO();
    Project pro1 = (Project) request.getAttribute("editObject");
    int rgdId = pro1.getRgdId();
    int displayRgdId = rgdId;
    String title = pro1.getName();
    if (isClone) {
        Project clone = (Project) request.getAttribute("cloneObject");
        pro1 = clone;
        displayRgdId = pro1.getRgdId();
        title = pro1.getName() + " (COPY)";
    }
    String action;
%>
<% if( isClone ) {
    action = "add"; %>
<h1>Clone Project: <%=title%></h1>
<% } else if( isNew ) {
    action = "add"; %>
<h1>New Project</h1>
<% } else {
    action = "upd"; %>
<h1>Edit Project: <%=title%></h1>
<% } %>

<form action="editProject.html" method="get">
    <input type="hidden" name="rgdId" value="<%=rgdId%>" />
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
    <input type="hidden" name="act" value="<%=action%>" />

    <table>
        <tr>
            <td valign="top">
                <table >
                    <tr>
                        <td class="label">Project ID:</td>
                        <td><%=pro1.getRgdId()%></td>
                    </tr>
                    <tr>
                        <td class="label">Project Name:</td>
                        <td><textarea name="name" cols="45" rows="4"><%=dm.out("name",pro1.getName())%></textarea></td>
                    </tr>
                    <tr>
                        <td class="label">Project Description:</td>
                        <td><textarea name="desc" cols="45" rows="6"><%=dm.out("desc",pro1.getDesc())%></textarea></td>
                    </tr>
                    <tr>
                        <td class="label">Submitter Name:</td>
                        <td><input type="text" name="submitterName" size="45" value="<%=dm.out("submitterName",pro1.getSubmitterName())%>" /> </td>
                    </tr>
                    <tr>
                        <td class="label">Principal Investigator Name:</td>
                        <td><input type="text" name="piName" size="45" value="<%=dm.out("piName",pro1.getPiName())%>" /> </td>
                    </tr>


                    <tr>
                        <% if( isClone ) { %>
                        <td colspan="2" align="center"><input type="submit" value="Clone Project"/></td>
                        <% } else if( isNew ) { %>
                        <td colspan="2" align="center"><input type="submit" value="Insert Project"/></td>
                        <% } else { %>
                        <td colspan="2" align="center"><input type="button" value="Update Project" onclick="makePOSTRequest(this.form)"/></td>
                        <% } %>
                    </tr>


                </table>
            </td>
            <td>&nbsp;</td>
            <td valign="top" align="center">
                <%@ include file="idInfo.jsp"%>
            </td>
        </tr>
    </table>
</form>
<br>
<%@include file="projectAssociationData.jsp"%>
<%if(!isNew){%>
<%@include file="projectFileDetailsNew.jsp"%><%}%>
<br>
<%@ include file="externalLinksData.jsp" %>
<%@ include file="/common/footerarea.jsp"%>
