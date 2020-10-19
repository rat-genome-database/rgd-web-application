<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>

<% boolean includeMapping = true;
    String title = "Cell Lines";
    CellLine obj = (CellLine) request.getAttribute("reportObject");
    String objectType="cellLine";
    String displayName=obj.getSymbol();

    String pageTitle = obj.getSymbol() + " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = pageTitle;
%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>
    <div id="content-wrap">


<%@ include file="menu.jsp"%>

<table width="95%" border="0">
    <tr>
        <td>
        <%@ include file="info.jsp"%>

            <div class ="subTitle" id="references">References</div>
        <%@ include file="../references.jsp"%>
        <%@ include file="../pubMedReferences.jsp"%>


            <br><div  class="subTitle" id = "additionalInformation">Additional Information</div><br>

        <%@ include file="../xdbs.jsp"%>
        <%@ include file="../curatorNotes.jsp"%>

    </td>
    <td>&nbsp;</td>
    <td valign="top">
<%--        <%@ include file="../idInfo.jsp" %>--%>
    </td>
    </tr>
 </table>
</div>
</div>

<footer id="footer">
    <%@ include file="../reportFooter.jsp"%>
    <%@ include file="/common/footerarea.jsp"%>
</footer>


<script src="/rgdweb/js/reportPages/geneReport.js"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js"> </script>