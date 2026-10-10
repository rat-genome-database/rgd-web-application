<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.Sequence" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%
    String pageTitle = "Sequence Edit";
    String headContent = "";
    String pageDescription = "";
    
%>

<%@ include file="/common/headerarea.jsp"%>

<%
    Sequence seq = (Sequence) request.getAttribute("editObject");
    HttpRequestFacade req = (HttpRequestFacade) request.getAttribute("requestFacade");
    SimpleDateFormat sdf = new SimpleDateFormat("mm/dd/yyyy");
    FormUtility fu = new FormUtility();
    DisplayMapper dm = new DisplayMapper(req, error);

%>
<h1>Edit Sequence: RGDID:<%=seq.getRgdId()%></h1>


<form action="editSequence.html" method="get">
<input type="hidden" name="rgdId" value="<%=seq.getRgdId()%>" />
<input type="hidden" name="key" value="<%=seq.getSeqKey()%>" />
<input type="hidden" name="action" value="upd" />

<table>
    <tr>
        <td valign="top">
            <table >
                <tr>
                    <td class="label">Key:</td>
                    <td><%=seq.getSeqKey()%></td>
                </tr>
                <tr>
                    <td class="label">Clone Sequence:</td>
                    <td><textarea rows="6" cols="45" name="cloneSeq"><%=dm.out("cloneSeq",seq.getCloneSeq())%></textarea></td>
                </tr>
                <tr>
                    <td><br><input type="submit" value="Update" size="10"/></td>
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

<%@ include file="/common/footerarea.jsp"%>

