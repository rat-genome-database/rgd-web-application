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
    String title = "References";

    Reference obj = (Reference) request.getAttribute("reportObject");
    String pageTitle = "RGD Reference Report - " + obj.getTitle() + " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = obj.getCitation()!=null ? obj.getCitation() : "";


    // handling of RETIRED/WITHDRAWN references: rgd id history is searched for an active rgd id that possibly
    // replaced this retired/withdrawn object
    RgdId refRgdId = managementDAO.getRgdId(obj.getRgdId());
    boolean isRefStatusNotActive = !refRgdId.getObjectStatus().equals("ACTIVE");
    Reference newRef = null; // gene that replaced the current one
    if( isRefStatusNotActive ) {
        int newRgdId = managementDAO.getActiveRgdIdFromHistory(obj.getRgdId());

        if( newRgdId>0 )
            newRef = referenceDAO.getReference(newRgdId);
    }

%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<script>
    let reportTitle = "reference";
</script>
<div id="page-container">

    <div id="left-side-wrap">
        <%@ include file="../reportSidebar.jsp"%>
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

                <br><div  style="color:#2865a3; font-size: 16px; font-weight: 700; font-style: italic; "id="annotation">Annotation</div><br>

                <%@ include file="../associations.jsp"%>

                <%@ include file="../objectsAnnotated.jsp"%>

                <br><div  class="subTitle" id="additionalInformation">Additional Information</div><br>

                <%@ include file="xdbs.jsp"%>
                <%@ include file="../nomen.jsp"%>
                <%@ include file="../curatorNotes.jsp"%>
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


<script type="text/javascript">
    openAll();
    //alert("done expanding");
</script>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>

