<%@ include file="../sectionHeader.jsp"%>
<%
    String forward = Utils.defaultString(obj.getForwardSeq());
    String reverse = Utils.defaultString(obj.getReverseSeq());
    String template = Utils.defaultString(obj.getTemplateSeq());
    int totalSeqLen = template.length() + forward.length() + reverse.length();
    if( totalSeqLen > 0 ) {
        String templateSeqFormatted = FormUtility.formatFasta(template);
%>
<%--<%=ui.dynOpen("sequenceAssociation", "Sequence")%>--%>
<div id="sequenceAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="sequenceAssociation">Sequence</div>
<table class="rgdSeqTable">
    <% if (!forward.isEmpty()) { %>
    <tr>
        <td class="label">Forward primer</td>
        <td><span class="rgdSeqInline"><%=forward%></span></td>
    </tr>
    <% } %>
    <% if (!reverse.isEmpty()) { %>
    <tr>
        <td class="label">Reverse primer</td>
        <td><span class="rgdSeqInline"><%=reverse%></span></td>
    </tr>
    <% } %>
    <% if (!templateSeqFormatted.isEmpty()) { %>
    <tr>
        <td class="label">Template</td>
        <%-- formatFasta already breaks the sequence every 64 bases with <br>, so this needs a
             monospace face and nothing else - <pre> was only ever here for the font --%>
        <td><div class="rgdSeqBlock"><%=templateSeqFormatted%></div></td>
    </tr>
    <% } %>
</table>
</div>
<%--<%=ui.dynClose("sequenceAssociation")%>--%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
