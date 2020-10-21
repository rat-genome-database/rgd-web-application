<%@ include file="../sectionHeader.jsp"%>
<%
    String forward = Utils.defaultString(obj.getForwardSeq());
    String reverse = Utils.defaultString(obj.getReverseSeq());
    String template = Utils.defaultString(obj.getTemplateSeq());
    int totalSeqLen = template.length() + forward.length() + reverse.length();
    if( totalSeqLen > 0 ) {
        String templateSeqFormatted = FormUtility.formatFasta(template);
%>
<%=ui.dynOpen("sequenceAssociation", "Sequence")%>
<table border="0">
    <tr><td>&nbsp;</td></tr>

    <% if (!forward.isEmpty()) { %>
    <tr>
        <td><b>Forward Primer</b></td>
        <td><%=forward%></td>
    </tr>
    <% } %>
    <% if (!reverse.isEmpty()) { %>
    <tr>
        <td><b>Reverse Primer</b></td>
        <td><%=reverse%></td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <% } %>
    <% if (!templateSeqFormatted.isEmpty()) { %>
    <tr>
        <td><b>Template</b></td>
        <td><pre><%=templateSeqFormatted%></pre></td>
    </tr>
    <% } %>

</table>

<%=ui.dynClose("sequenceAssociation")%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
