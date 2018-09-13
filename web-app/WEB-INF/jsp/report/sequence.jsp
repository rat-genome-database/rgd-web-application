<%@ include file="sectionHeader.jsp"%>
<%
    // === OLD SEQUENCE CODE === to be retired eventually
    List<Sequence> seqList = sequenceDAO.getObjectSequences(obj.getRgdId());
    if (seqList.size() > 0) {
%>
<%=ui.dynOpen("sequenceAssociation", "Sequence")%>
<table border="0">
<%
    String forward;
    String reverse;
    String cloneSeq;
    String cloneSeqFormatted;

    for (Sequence seq: seqList) {
        if (seq.getForwardSeq() != null) {
            forward = seq.getForwardSeq();
        } else {
			forward = "";
		}

        if (seq.getReverseSeq() != null) {
            reverse = seq.getReverseSeq();
        } else {
			reverse = "";
		}

        if (seq.getCloneSeq() != null) {
            cloneSeq = seq.getCloneSeq();
        } else {
			cloneSeq = "";
		}

		cloneSeqFormatted = "";
		double value = (double)cloneSeq.length() / (double)60;
		int loops = (int) Math.ceil(value);

		for (int i=0; i< loops; i++) {

			int index=i*60;
			if ((i + 1) == loops) {
				cloneSeqFormatted += cloneSeq.substring(index) + "<br>";
			}else {
				cloneSeqFormatted += cloneSeq.substring(index, index + 60) + "<br>";
			}
		}
%>
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
    <% if (!cloneSeqFormatted.isEmpty()) { %>
    <tr>
        <td><b>Template</b></td>
        <td><pre><%=cloneSeqFormatted%></pre></td>
    </tr>
    <% } %>

<% } %>
</table>

<%=ui.dynClose("sequenceAssociation")%>

<% } %>


<%  // === NEW SEQUENCE CODE ===
    List<Sequence2> seqList2 = sequenceDAO.getObjectSequences2(obj.getRgdId());
    if (seqList2.size() > 0) {
%>
<%=ui.dynOpen("sequenceAssociation", "Sequence")%>
<table border="0">
    <%
        String cloneSeqFormatted;

        for (Sequence2 seq2: seqList2) {
            String cloneSeq = seq2.getSeqData();

            cloneSeqFormatted = "";
            double value = (double)cloneSeq.length() / (double)60;
            int loops = (int) Math.ceil(value);

            for (int i=0; i< loops; i++) {

                int index=i*60;
                if ((i + 1) == loops) {
                    cloneSeqFormatted += cloneSeq.substring(index) + "<br>";
                }else {
                    cloneSeqFormatted += cloneSeq.substring(index, index + 60) + "<br>";
                }
            }
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

<%=ui.dynClose("sequenceAssociation")%>

<% } %>

<%@ include file="sectionFooter.jsp"%>
