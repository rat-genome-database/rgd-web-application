<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 7/21/2025
  Time: 3:19 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<body>
<%
    StudySampleMetadataDAO dao = new StudySampleMetadataDAO();
    List<StudySampleMetadata>metadata = dao.getStudySampleMetadata(obj.getId());
    if(metadata!=null&&!metadata.isEmpty()){
%>
<hr>
<div id="sampleMetadata" class="subTitle"><h2>Sample Metadata</h2></div>
<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager sampleMetadataPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<div id="sampleMetadataTableDiv" class="annotation-detail">
<table>
    <tr>
        <th>geo_accession</th>
        <th>Tissue</th>
        <th>Strain</th>
        <th>Sex</th>
        <th>Computed Sex</th>
        <th>Age(in days)</th>
        <th>Life Stage</th>
        <th>Experimental_Conditions</th>
<%--        <th>Dose</th>--%>
<%--        <th>Duration</th>--%>
<%--        <th>Application Method</th>--%>
<%--        <th>Notes</th>--%>
    </tr>
    <%for(StudySampleMetadata data:metadata){%>
    <tr>
        <td><%=data.getGeoSampleAcc()!=null?data.getGeoSampleAcc():""%></td>
        <td><%=data.getTissue()!=null?data.getTissue():""%></td>
        <td><%=data.getStrain()!=null?data.getStrain():""%></td>
        <td><%=data.getSex()!=null?data.getSex():""%></td>
        <td><%=data.getComputedSex()!=null?data.getComputedSex():""%></td>
        <%
            Double lowBound = data.getAgeDaysFromDobLowBound();
            Double highBound = data.getAgeDaysFromDobHighBound();
            if(lowBound != null && highBound != null && lowBound.equals(highBound)){
        %>
        <td><%=lowBound.intValue()%></td>
        <%}else if(lowBound != null && highBound != null){%>
        <td><%=lowBound.intValue()%>-<%=highBound.intValue()%></td>
        <%}else{%>
        <td></td>
        <%}%>
        <td><%=data.getLifeStage()!=null?data.getLifeStage():""%></td>
        <td><%=data.getExperimentalConditions()!=null?data.getExperimentalConditions():""%></td>
<%--        new--%>
<%--        <td><%=data.getExperimentalConditions()!=null?data.getExperimentalConditions():""%></td>--%>
<%--        <td><%=data.getExperimentalConditions()!=null?data.getExperimentalConditions():""%></td>--%>
<%--        <td><%=data.getExperimentalConditions()!=null?data.getExperimentalConditions():""%></td>--%>
<%--        <td><%=data.getExperimentalConditions()!=null?data.getExperimentalConditions():""%></td>--%>
    </tr>
    <%}%>
</table>
<%}%>
</div>
</body>
</html>
