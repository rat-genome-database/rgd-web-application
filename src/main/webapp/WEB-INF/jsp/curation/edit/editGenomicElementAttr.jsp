<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String pageTitle = "Genomic Element Attribute";
    String headContent = "";
    String pageDescription = "";    
%>

<%@ include file="/common/headerarea.jsp"%>

<%
    GenomicElementAttr attr = (GenomicElementAttr) request.getAttribute("editObject");
    HttpRequestFacade req = (HttpRequestFacade) request.getAttribute("requestFacade");
    SimpleDateFormat sdf = new SimpleDateFormat("mm/dd/yyyy");
    FormUtility fu = new FormUtility();

    DisplayMapper dm = new DisplayMapper(req, error);

%>
<form action="editGenomicElementAttr.html" method="get">
<input type="hidden" name="rgdId" value="<%=attr.getRgdId()%>" />
<input type="hidden" name="key" value="<%=attr.getKey()%>" />
<input type="hidden" name="action" value="upd" />

<h1>Edit Attribute: <%=attr.getName()%></h1>

<table>
    <tr>
        <td valign="top">
            <table>
                <tr class="label">
                    <td>Name:</td>
                    <td><input type="text" name="name" size="50" value="<%=dm.out("name",attr.getName())%>"/></td>
                </tr>
                <tr class="label">
                    <td>Value:</td>
                    <td><input type="text" name="value" size="50" value="<%=dm.out("value",attr.toString())%>" /> </td>
                </tr>
                <tr>
                    <td><br><input type="submit" value="Update" size="10"/></td>
                </tr>
            </table>

        </td>
        <td>&nbsp;</td>
        <td valign="top" valign="center">
            <%@ include file="idInfo.jsp"%>
        </td>
    </tr>
</table>
</form>

<%@ include file="/common/footerarea.jsp"%>

