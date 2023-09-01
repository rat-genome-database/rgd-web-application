<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.datamodel.Project" %>
<%@ page import="edu.mcw.rgd.datamodel.ProjectFile" %>

<%--
  Created by IntelliJ IDEA.
  User: Akhilanand Kundurthi
  Date: August 2023
  Time:
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>

<% boolean includeMapping = true; %>
<%
    String title = "Projects";
    Project obj = (Project) request.getAttribute("reportObject");
    String pageTitle = "RGD Project Report - " + obj.getName() + " - " + RgdContext.getLongSiteName(request);;
    String headContent = "";
    String pageDescription = obj.getDesc()!=null ? obj.getDesc() : "";


    // handling of RETIRED/WITHDRAWN references: rgd id history is searched for an active rgd id that possibly
    // replaced this retired/withdrawn object
    RgdId refRgdId = managementDAO.getRgdId(obj.getRgdId());
%>

<div id="top" ></div>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<script>
    let reportTitle = "project";
</script>

<%--to check if there are any references and submitted filesfor the project--%>

<%List<Integer> projRef=new ProjectDAO().getReferenceRgdIdsForProject(obj.getRgdId());
    List<ProjectFile> pf2 = new ProjectFileDAO().getProjectFiles(obj.getRgdId());
%>
<div id="page-container">

    <div id="left-side-wrap">
        <%@ include file="reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">

        <%@ include file="menu.jsp"%>

        <% if (view.equals("2")) { %>

        <% }%>
        <table width="95%" border="0">
            <tr>
                <td>
                    <%@ include file="info.jsp"%>
                    <div class ="subTitle" id="info">Submitter Information</div><br>
                    <%@ include file="submittedInfo.jsp"%>
                    <% if(!projRef.isEmpty()){%>
                    <br><div  class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation')">Click to see Annotation Detail View</a></div><br>
                    <br>
                    <div id="associationsCurator" style="display:none;">

                        <%@ include file="phenominerDetails.jsp"%>
                        <%@ include file="../associationsCuratorForProject.jsp"%>
                    </div>
                    <div id="associationsStandard" style="display:block;">

                        <%@ include file="phenominer.jsp"%>
                        <%@ include file="../associationsForProject.jsp"%>

                    </div>
                    <%@ include file="../objectsAnnotatedForProject.jsp"%>
                    <br>
                    <%}%>
                    <% if(!pf2.isEmpty()){%>
                    <div class ="subTitle" id="subFiles">Submitted Files</div><br>
                    <%@ include file="projectFiles.jsp"%>
                    <br>
                    <br><div class ="subTitle" id="protocol">Protocols</div>
                    <%@ include file="protocol.jsp"%>
                    <%}%>
                    <br><div class="subTitle" id="Ext">External Resources</div><br>
                    <%@ include file="xdbs.jsp"%>

                </td>

            </tr>
        </table>
    </div>
</div>
<%--<% }%>--%>
<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>


<script type="text/javascript">
    openAll();
</script>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>

