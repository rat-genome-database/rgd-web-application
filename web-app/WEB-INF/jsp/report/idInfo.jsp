<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>

    <%@ include file="sectionHeader.jsp"%>
<%
    RgdId id = managementDAO.getRgdId(obj.getRgdId());

    List speciesList = new ArrayList();
    speciesList.add("Rat");
    speciesList.add("Mouse");
    speciesList.add("Human");

    List statusList = new ArrayList();
    statusList.add("ACTIVE");
    statusList.add("RETIRED");
    statusList.add("WITHDRAWN");

%>


<table border="0" style="border: 1px solid black; background-color:#f9f9f9;" width="180">
    <input name="rgdId" type="hidden" value="<%=id.getRgdId()%>" />
    <tr>
        <td colspan="2" id="idInfoTitleBar"><span style="color:white; font-weight:700;"><%=RgdContext.getSiteName(request)%> Object Information</span></td>
    </tr>
    <tr>
        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=id.getRgdId()%></td>
    </tr>
    <tr>
        <td class="label">Created:</td>
        <td><%=id.getCreatedDate()%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Species:</td>
        <td><%=SpeciesType.getTaxonomicName(id.getSpeciesTypeKey())%></td>
    </tr>
    <tr>
        <td class="label">Last Modified:</td>
        <td><%=id.getLastModifiedDate()%></td>
    </tr>
    <tr>
        <td class="label">Status:</td>
        <td><%=id.getObjectStatus()%></td>
    </tr>
</table>

<%@ include file="sectionFooter.jsp"%>


