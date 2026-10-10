<% if (!isNew) { %>
<%
        AssociationDAO aDao = new AssociationDAO();

    //*************TO DIPLAY SUBMITTED REFERENCES *************************//
        String refs= (String) request.getParameter("references");
    String ref= "";
    if(refs!=null && !refs.equals("")){
        if(!"null".equals(refs)){
            ref="Submitter provided reference: " +  refs;
        }
    }
    //*************************************************************//
%>
<p style="color:blue"><%=ref%></p>
<form action="updateStrainAssociations.html" >
<input  type="hidden" name="rgdId" value="<%=rgdId%>"/>
<input type="hidden" name="markerClass" value="strain2xxx">
<table class="updateTile" width="600" cellspacing="0" border="0">
<tr>
    <td style="background-color:#2865a3; color:white; font-weight:700;" width="10%">Associations</td>
    <td align="right" style="background-color:#2865a3; color:white; font-weight:700;">
        <input type="button" value="Update" onclick="makePOSTRequest(this.form)"/>
    </td>
</tr>
    <tr><td></td><td><hr></td></tr>
    <%
        List associationList = aDao.getQTLAssociationsForStrain(displayRgdId);
        String objectType="Strain";
        String associationType="QTL";
        String objectKey="QTLS";

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