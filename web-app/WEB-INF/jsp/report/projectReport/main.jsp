<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>

<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>

  <% boolean includeMapping = true; %>
<%
    String title = "Projects";
    ProjectDAO pdao = new ProjectDAO();
//    String rgdidParam = request.getParameter("476081962");
    Reference obj = (Reference) request.getAttribute("reportObject");
//    List<Project> project = pdao.getProjectByRgdId(obj.getRgdId());
    String pageTitle = "RGD Project Report - " + obj.getTitle() + " - " + RgdContext.getLongSiteName(request);
//    String pageTitle = "RGD Project Report - " ;
    String headContent = "";
//    String pageDescription = "project report";
    String pageDescription = obj.getCitation()!=null ? obj.getCitation() : "";


    // handling of RETIRED/WITHDRAWN references: rgd id history is searched for an active rgd id that possibly
    // replaced this retired/withdrawn object
    RgdId refRgdId = managementDAO.getRgdId(obj.getRgdId());
    boolean isRefStatusNotActive = !refRgdId.getObjectStatus().equals("ACTIVE");
    Reference newRef = null; // gene that replaced the current one
    if( isRefStatusNotActive ) {
        int newRgdId = managementDAO.getActiveRgdIdFromHistory(obj.getRgdId());
        out.println("here");
        if( newRgdId>0 )
            out.println("in new rgdid>0 condition");
            newRef = referenceDAO.getReference(newRgdId);}

%>

<div id="top" ></div>
<%--<%--%>
<%--    ReferenceDAO test = new ReferenceDAO();--%>
<%--    List<Reference> p=test.getReferencesForObject(476081962);--%>
<%--%>--%>
<%--<%for(Project i:project){%>--%>
<%--<h2><%=i.getDesc()%></h2>--%>
<%--<%}%>--%>
<%--<% for (Reference i:p){%>--%>
<%--<h3>Reference:</h3><p><b><%=i.getTitle()%></b>.<%=i.getCitation()%></p>--%>
<%--<%}--%>
<%--%>--%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<script>
    let reportTitle = "reference";
</script>
<div id="page-container">

    <div id="left-side-wrap">
        <%@ include file="reportSidebar.jsp"%>
    </div>



    <div id="content-wrap">

<%@ include file="menu.jsp"%>


<% if (view.equals("2")) { %>

<% } else if (isRefStatusNotActive) { %>
    <br><br>The reference with citation <%=obj.getCitation()%> (RGD ID: <%=obj.getRgdId()%>) has been <%=refRgdId.getObjectStatus()%>. <br><br>
    <% if(newRef!=null ) { %>
      This reference has been replaced by the reference <a href="<%=edu.mcw.rgd.reporting.Link.ref(newRef.getRgdId())%>" title="click to see the gene report"><%=newRef.getCitation()%> (RGD ID: <%=newRef.getRgdId()%>)</a>.
     <br><br>
    <%}%>
<% } else { %>


<table width="95%" border="0">
    <tr>
        <td>
            <%@ include file="info.jsp"%>
            <%
                //exclude from the  pipelines
                if ( !obj.getReferenceType().equals("DIRECT DATA TRANSFER") ) { %>

            <div class ="subTitle" id="info">Submitter Information</div><br>
            <%@ include file="submittedInfo.jsp"%>
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
            <div class ="subTitle" id="subFiles">Submitted Files</div><br>
            <%@ include file="projectFiles.jsp"%>
            <br>
<%--            <br><div class ="subTitle" id="info">Submitter Information</div><br>--%>
<%--            <%@ include file="submittedInfo.jsp"%>--%>
            <br><div class ="subTitle" id="protocol">Protocols</div>
            <%
                List<ProjectFile> pf1= new ProjectFileDAO().getProjectFiles(obj.getRgdId());
            %>
            <br>
            <li><a href="<%=pf1.get(0).getProtocol()%>">Breeding Protocol for HS Rats</a></li>
            <br>
                <br><div  class="subTitle" id="additionalInformation">External Resources</div><br>

                <%@ include file="xdbs.jsp"%>
<%--                <%for(int z=0;z<50;z++){%>--%>
<%--            <%@ include file="xdbs.jsp"%>--%>
<%--            <%}%>--%>

<%--                <%@ include file="../nomen.jsp"%>--%>
<%--                <%@ include file="../curatorNotes.jsp"%>--%>
            <% } %>
        </td>
        <td>&nbsp;</td>
        <td valign="top">
           <%-- <%@ include file="links.jsp" %>--%>
            <br>
<%--            <%@ include file="../idInfo.jsp" %>--%>
        </td>
    </tr>
 </table>
    </div>
</div>
<% }%>
    <%@ include file="../reportFooter.jsp"%>
    <%@ include file="/common/footerarea.jsp"%>
<%!
    private int checkAnnotInList1(Annotation annotation, List<Annotation> objListAnnot) {

        for(Annotation a : objListAnnot){
            if(a.getAnnotatedObjectRgdId().equals(annotation.getAnnotatedObjectRgdId())){
                return 1;
            }
        }
        return 0;
    }
%>

<script type="text/javascript">
    openAll();
</script>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>

