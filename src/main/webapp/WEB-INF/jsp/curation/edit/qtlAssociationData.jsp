<% if (!isNew) { %>

<%
    AssociationDAO aDao = new AssociationDAO();
    List associationList = new ArrayList();
%>

<form action="updateQTLAssociations.html" >
<input  type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table class="updateTile" width="600" cellspacing="0" border="0">
<tr>
    <td style="background-color:#2865a3; color:white; font-weight:700;" width="10%">Associations</td>
    <td align="right" style="background-color:#2865a3; color:white; font-weight:700;">
        <input type="button" value="Update" onclick="makePOSTRequest(this.form)"/>
        <!--<input type="submit" value="update"/>-->
    </td>
</tr>
<tr><td></td><td><hr></td></tr>

<%
    if (!isNew) {
        associationList = aDao.getGeneAssociationsByQTL(displayRgdId);
    }
    String objectType="QTL";
    String associationType="Gene";
    String objectKey="GENES";

%>
<%@ include file="associationData.jsp" %>

<%
    if (!isNew) {
        associationList = aDao.getStrainAssociationsForQTL(displayRgdId);
    }
    objectType="QTL";
    associationType="Strain";
    objectKey="STRAINS";
    
%>
<%@ include file="associationData.jsp" %>

<%
    if (!isNew) {
        associationList = aDao.getReferenceAssociations(displayRgdId);
    }
    objectType="";
    associationType="Reference";
    objectKey="REFERENCES";
    
%>
<%@ include file="associationData.jsp" %>

</table>
</form>

<% } %>
