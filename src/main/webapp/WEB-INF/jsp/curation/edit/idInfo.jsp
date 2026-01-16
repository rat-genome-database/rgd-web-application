<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>

<% if (!isNew) { %>

<%
    RGDManagementDAO dao = new RGDManagementDAO();
    RgdId id = dao.getRgdId(rgdId);

    List speciesList = Arrays.asList("Rat", "Mouse", "Human", "Chinchilla", "Bonobo", "Dog", "Squirrel", "Pig");
    List statusList = Arrays.asList("ACTIVE", "RETIRED", "WITHDRAWN", "PRIVATE");
%>

<form action="updateID.html">
    <input name="rgdId" type="hidden" value="<%=id.getRgdId()%>" />
<table border="0" style="border: 1px solid black; background-color:#f9f9f9;" width="200">
    <tr>
        <td colspan="2" style="background-color:#2865a3;"><span style="color:white; font-weight:700;">Object Information</span></td>
    </tr>
    <tr>
        <td class="label">Rgd Id:</td>
        <td><a href="<%=Link.it(id.getRgdId(), id.getObjectKey())%>"><%=id.getRgdId()%></a></td>
    </tr>
    <tr>
        <td class="label">Created:</td>
        <td><%=id.getCreatedDate()%></td>
    </tr>
    <tr>
        <td class="label">Species Type:</td>
        <td><%=fu.buildSelectList("speciesType",speciesList, dm.out("speciesType", SpeciesType.getCommonName(id.getSpeciesTypeKey())))%></td>
    </tr>
    <tr>
        <td class="label">Last Modified:</td>
        <td><%=id.getLastModifiedDate()%></td>
    </tr>
    <tr>
        <td class="label">Status:</td>
        <td><%=fu.buildSelectList("objectStatus",statusList, dm.out("objectStatus",id.getObjectStatus()))%></td>
    </tr>
        <tr>
            <td colspan="2"><hr></td>
        </tr>
    
        <tr  align="right"><td colspan="3"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td></tr>
</table>
</form>

<% } %>