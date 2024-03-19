<%@ page import="java.util.ArrayList" %>
<% if (!isNew) { %>

<%
    AssociationDAO aDao = new AssociationDAO();
    List associationList = new ArrayList();
%>

<form action="updateProjectAssociations.html" >
    <input  type="hidden" name="rgdId" value="<%=rgdId%>"/>
    <table class="updateTile" width="600" cellspacing="0" border="0">
        <tr>
            <td style="background-color:#2865a3; color:white; font-weight:700;" width="10%">References</td>
            <td align="right" style="background-color:#2865a3; color:white; font-weight:700;">
                <input type="button" value="Update" onclick="makePOSTRequest(this.form)"/>
                <!--<input type="submit" value="update"/>-->
            </td>
        </tr>
        <tr><td></td><td><hr></td></tr>
        <%
            if (!isNew) {
                associationList = aDao.getReferenceAssociations(displayRgdId);
            }
            String objectType="";
            String associationType="Reference";
            String objectKey="REFERENCES";

        %>
        <%@ include file="associationDataForProject.jsp" %>

    </table>
</form>

<% } %>
