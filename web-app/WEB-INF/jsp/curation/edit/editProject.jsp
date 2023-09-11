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

<%
    String pageTitle = "Edit Project";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>

<%
//    ReferenceDAO referenceDAO = new ReferenceDAO();
    ProjectDAO projDAO = new ProjectDAO();
//    Reference ref = (Reference) request.getAttribute("editObject");
    Project pro1 = (Project) request.getAttribute("editObject");
    int rgdId = pro1.getRgdId();

    int displayRgdId = rgdId;
//    int key = ref.getKey();

//    String title = ref.getTitle();
    String title = pro1.getName();
    if (isClone) {
//        Reference clone = (Reference) request.getAttribute("cloneObject");
        Project clone = (Project) request.getAttribute("cloneObject");
        pro1 = clone;
        displayRgdId = pro1.getRgdId();
        title = pro1.getName() + " (COPY)";
    }

//    String pmid = "";
//    XdbIdDAO xdao = new XdbIdDAO();
//    for( XdbId xdbId: xdao.getPubmedIdsByRefRgdId(rgdId) ) {
//        pmid = xdbId.getAccId();
//    }
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
<%--    <input type="hidden" name="key" value="<%=key%>" />--%>
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
                        <td><input type="text" name="name" size="45" value="<%=dm.out("name",pro1.getName())%>" /></td>
                    </tr>
                    <tr>
                        <td class="label">Project Description:</td>
                        <td><input type="text" name="desc" size="45" value="<%=dm.out("desc",pro1.getDesc())%>" /> </td>
                    </tr>
                    <tr>
                        <td class="label">Submitter Name:</td>
                        <td><input type="text" name="sub_name" size="45" value="<%=dm.out("sub_name",pro1.getSub_name())%>" /> </td>
                    </tr>
                    <tr>
                        <td class="label">Principal Investigator Name:</td>
                        <td><input type="text" name="princ_name" size="45" value="<%=dm.out("princ_name",pro1.getPrinci_name())%>" /> </td>
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
<%@ include file="/common/footerarea.jsp"%>
