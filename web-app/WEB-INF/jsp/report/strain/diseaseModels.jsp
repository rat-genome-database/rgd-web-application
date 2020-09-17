
<%@ include file="../sectionHeader.jsp"%>

<%
    List<Annotation> annotList = annotationDAO.getAnnotations(obj.getRgdId());
    boolean foundOne=false;
    for (Annotation annot: annotList) {
        if (annot.getQualifier() != null && annot.getQualifier().equals("Model")) {
            foundOne=true;
        }
    }

    if (foundOne) {

%>



<%--<%=ui.dynOpen("diseaseModels", "Disease Models")%>--%>
<br>
<table>
    <tr>
        <td colspan="2"><b><%=obj.getSymbol()%> is a model for the following diseases.</b></td>
    </tr>
<%
    for (Annotation annot: annotList) {
        if (annot.getQualifier() != null && annot.getQualifier().equals("Model")) {
        %>
            <tr>
                <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="/rgdweb/ontology/annot.html?acc_id=<%=annot.getTermAcc()%>"><%=annot.getTerm()%></a></td>
             </tr>
        <%
        }

    }

%>
</table>
<br>
<%--<%=ui.dynClose("diseaseModels")%>--%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
