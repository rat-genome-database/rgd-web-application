<% if (rgdId>0) { %>

<%
    AssociationDAO aDao = new AssociationDAO();
    List associationList;
%>

<form action="updateCellLineAssociations.html" >
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
    associationList = aDao.getAssociationsForMasterRgdId(displayRgdId, "cellline_to_gene");

    String objectType="CellLine";
    String associationType="Gene";
    String objectKey="GENES";
%>
<%@ include file="associationData.jsp" %>

<%
    associationList = aDao.getAssociationsForMasterRgdId(displayRgdId, "cellline_to_strain");

    objectType="CellLine";
    associationType="Strain";
    objectKey="STRAINS";
    
%>
<%@ include file="associationData.jsp" %>

<%
    associationList = aDao.getReferenceAssociations(displayRgdId);

    objectType="";
    associationType="Reference";
    objectKey="REFERENCES";
    
%>
<%@ include file="associationData.jsp" %>

</table>
</form>

<% } %>
