

<div id="<%=ontId%>Select" class="roundSelect">
<table align="center" >
<tr>
    <td >Enter a <%=ontName%> Term or Browse the Ontology Tree<br><br></td>
</tr>
<tr>
    <td colspan="2">
        <input type="text" id = "<%=ontId%>_term" name="<%=ontId%>_term" size="50" value="" onblur="lostFocus('<%=ontId%>')">
        <input type="hidden" id="<%=ontId%>_acc_id" name="<%=ontId%>_acc_id" value=""/>
        <a href="" id="<%=ontId%>_popup" style="olor:white;">Browse Ontology Tree</a>
    </td>
</tr>
<tr>
    <td colspan="2" align="center"><br> <input type="button" value="Continue" onClick="submitTerm()"/></td>
</tr>
</table>
</div>
