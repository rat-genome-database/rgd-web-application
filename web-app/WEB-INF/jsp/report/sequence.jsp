<%@ include file="sectionHeader.jsp"%>

<%
    List<Sequence> seqList = sequenceDAO.getObjectSequences(obj.getRgdId());
    if( seqList.size() > 0 ) {
%>
<%--<%=ui.dynOpen("sequenceAssociation", "Sequence")%>--%>
<div id="sequenceAssociationTableDiv" class="light-table-border">
<div class="sectionHeading" id="sequenceAssociation">Sequence</div>
<table border="0">
    <%
        for (Sequence seq2: seqList) {
            String cloneSeq = seq2.getSeqData();

            String cloneSeqFormatted = FormUtility.formatFasta(cloneSeq);
    %>
    <tr><td>&nbsp;</td></tr>

    <% if (!cloneSeqFormatted.isEmpty()) { %>
    <tr>
        <td><b>Template</b></td>
        <td><pre><%=cloneSeqFormatted%></pre></td>
    </tr>
    <% } %>

    <% } %>
</table>

<%--<%=ui.dynClose("sequenceAssociation")%>--%>
</div>
<% } %>

<%@ include file="sectionFooter.jsp"%>
