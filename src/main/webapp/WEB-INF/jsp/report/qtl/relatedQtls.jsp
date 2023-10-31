<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ include file="../sectionHeader.jsp"%>


<%
    Map<Integer, String> relQtls = associationDAO.getQtlToQtlAssociations(obj.getKey());
    if (relQtls!=null && relQtls.size()>0) {
%>
<%--<%=ui.dynOpen("relQtls", "Related QTLs")%>--%>
<div class="light-table-border">
<div class="sectionHeading" id="relatedQTLs">Related QTLs</div>
<%
    Set<Integer> relQtlKeys = relQtls.keySet();
%>
<br>
<table border="1" cellpadding="4" cellspacing="0">

    <tr>
        <td>Related QTL</td>
        <td>Description</td>
        <td>Reference</td>
    </tr>
    <%
        for(int keys: relQtlKeys){
            String[] relQTLdetails = relQtls.get(keys).split("\\|\\|",-1);
    %>

    <tr>
        <td valign="top"><a href="<%=Link.it(keys)%>"><%=relQTLdetails[4]%></a></td>
        <td><%=relQTLdetails[1]%></td>
        <td><a href="<%=Link.it(relQTLdetails[2])%>">RGD:<%=relQTLdetails[2]%></a></td>
    </tr>
    <%
        }
    %>
</table>
<br>
</div>
<%--<%=ui.dynClose("relQtls")%>--%>
<% } %>
<%@ include file="../sectionFooter.jsp"%>
