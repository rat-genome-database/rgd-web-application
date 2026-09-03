<%@ include file="sectionHeader.jsp"%>

<%
    List<Sequence> seqList = sequenceDAO.getObjectSequences(obj.getRgdId());
    if( seqList.size() > 0 ) {
%>
<%--<%=ui.dynOpen("sequenceAssociation", "Sequence")%>--%>
<div id="sequenceAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="sequenceAssociation">Sequence</div>
<table class="rgdSeqTable">
    <%
        for (Sequence seq2: seqList) {
            String cloneSeq = seq2.getSeqData();

            String cloneSeqFormatted = FormUtility.formatFasta(cloneSeq);

            if (!cloneSeqFormatted.isEmpty()) {
    %>
    <tr>
        <td class="label">Template</td>
        <%-- formatFasta already breaks the sequence every 64 bases with <br>, so this needs a
             monospace face and nothing else - <pre> was only ever here for the font --%>
        <td><div class="rgdSeqBlock"><%=cloneSeqFormatted%></div></td>
    </tr>
    <% } } %>
</table>

<%--<%=ui.dynClose("sequenceAssociation")%>--%>
</div>
<% } %>

<%@ include file="sectionFooter.jsp"%>
