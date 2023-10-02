
<% if (!isNew) { %>

<%  
    SequenceDAO seqDAO = new SequenceDAO();
    List<Sequence> seqList = seqDAO.getObjectSequences(displayRgdId);
    String seqClone = "";
    if( !seqList.isEmpty() )
        seqClone = seqList.get(0).getSeqData();
%>

<form action="updateSequence.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="sequenceTable" border="0" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Sequence</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td class="label">Sequence:</td>
        <td><textarea rows="6" name="sequence" cols="50" ><%=seqClone%></textarea></td>
    </tr>
    </tbody>
</table>
</form>

<% } %>
