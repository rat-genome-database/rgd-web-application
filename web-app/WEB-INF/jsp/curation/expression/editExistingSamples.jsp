<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="java.util.Objects" %>
<%
    String pageHeader="Edit Samples";
    String pageTitle="Edit Samples";
    String headContent="";
    String pageDescription = "Edit Samples";
    List<Sample> samples = (List<Sample>) request.getAttribute("samples");
%>
<%@ include file="/common/headerarea.jsp"%>
<table class="table table-striped">

    <form action="editSamples.html" method="POST">

        <tr>
            <td align="left"><input type="submit" value="Load Samples"/></td>
        </tr>
        <tr>
            <th>Sample ID: </th>
            <th>Strain ID: </th>
            <th>Cell Type ID: </th>
            <th>Cell Line ID: </th>
            <th>Tissue ID: </th>
            <th>GEO Sample:</th>
            <th>Sex: </th>
            <th>Age (in days) Low: </th>
            <th>Age (in days) High: </th>
            <th>Life Stage:</th>
        </tr>
        <%  int cnt = 0;
            for (Sample s : samples){ %>
        <tr>
            <td><input name="sample<%=cnt%>" value="<%=s.getId()%>" readonly></td>
            <td><input name="strain<%=cnt%>" value="<%=s.getStrainAccId()%>"></td>
            <td><input name="cellType<%=cnt%>" value="<%=Objects.toString(s.getCellTypeAccId(),"")%>"></td>
            <td><input name="cellLine<%=cnt%>" value="<%=Objects.toString(s.getCellLineId(),"")%>"></td>
            <td><input name="tissue<%=cnt%>" value="<%=Objects.toString(s.getTissueAccId(),"")%>"></td>
            <td><input name="geoAcc<%=cnt%>" value="<%=Objects.toString(s.getGeoSampleAcc(),"")%>"></td>
            <td><input name="sex<%=cnt%>" value="<%=Objects.toString(s.getSex(),"")%>"></td>
            <td><input name="ageLow<%=cnt%>" value="<%=Objects.toString(s.getAgeDaysFromLowBound(),"")%>"></td>
            <td><input name="ageHigh<%=cnt%>" value="<%=Objects.toString(s.getAgeDaysFromHighBound(),"")%>"></td>
            <td><input name="lifeStage<%=cnt%>" value="<%=Objects.toString(s.getLifeStage(),"")%>"></td>
        </tr>
        <% cnt++;} %>
        <input type="hidden" id="count" name="count" value="<%=cnt%>" />
    </form>
</table>
<%@ include file="/common/footerarea.jsp"%>