<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %><%
    String pageTitle = "Update Object Status";
    String headContent = "";
    String pageDescription = "";

    List statusList = new ArrayList();
    statusList.add("ACTIVE");
    statusList.add("RETIRED");
    statusList.add("WITHDRAWN");

    FormUtility fu = new FormUtility();
    
%>
<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js">
    /***********************************************
     * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
     * This notice must stay intact for legal use.
     * Visit http://www.dynamicdrive.com/ for full source code
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/js/lookup.js"></script>

<%@ include file="/common/headerarea.jsp" %>

<h1>Update Object Status</h1>
<form action="statusUpdate.html">
    <table border="0">
    <tr>
        <td>Select Status:&nbsp;</td>
        <td><%=fu.buildSelectList("objectStatus",statusList, "")%></td>
        <td>&nbsp;&nbsp;</td>
        <td>
            <table>
            <% for (int i=0; i< 10; i++) {%>
            <tr>
                <td><input id="rgdId<%=i%>" name="rgdId" type="text" size="9" value=""/>&nbsp;
                    <a href="javascript:lookup_render('rgdId<%=i%>')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
            </tr>
            <% } %>
            </table>                
        </td>
        <td>&nbsp;&nbsp;</td>
        <td>
            <input type="submit" value="APPLY" />
        </td>
    </tr>
    </table>
</form>

<%@ include file="/common/footerarea.jsp" %>