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

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<%@ include file="menu.jsp"%>

<table width="95%" border="0">
    <tr>
        <td>
        <%@ include file="info.jsp"%>

        <br><div  class="subTitle">References</div><br>

        <%@ include file="../references.jsp"%>
        <%@ include file="../pubMedReferences.jsp"%>

        <br>
        <div class="subTitle">Additional Information</div>
        <br>
        <%@ include file="../xdbs.jsp"%>
        <%@ include file="../curatorNotes.jsp"%>

    </td>
    <td>&nbsp;</td>
    <td valign="top">
        <%@ include file="../idInfo.jsp" %>
    </td>
    </tr>
 </table>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>