<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 5/20/2025
  Time: 2:11 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<body>
<style>
    .label {
        font-size:14px;
    }
    .labelValue{
        font-size: 14px;
    }
    .subTitle{
        font-style: normal;
    }
</style>
<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr>
        <td class="label">Study&nbsp;ID:</td>
        <td class="labelValue"><%=obj.getId()%></td>
    </tr>
    <tr>
        <td class="label">Study&nbsp;Name:</td>
        <td class="labelValue"><%=obj.getName()%></td>
    </tr>
    <%if(obj.getSource()!=null&&!obj.getSource().isEmpty()){%>
    <tr>
        <td class="label">Study&nbsp;Source:</td>
        <td class="labelValue"><%=obj.getSource()%></td>
    </tr>
    <%}%>
    <%if(obj.getType()!=null&&!obj.getType().isEmpty()){%>
    <tr>
        <td class="label">Study&nbsp;Type:</td>
        <td class="labelValue"><%=obj.getType()%></td>
    </tr>
    <%}%>
    <%if(obj.getDataType()!=null&&!obj.getDataType().isEmpty()){%>
    <tr>
        <td class="label">Data&nbsp;Type:</td>
        <td class="labelValue"><%=obj.getDataType()%></td>
    </tr>
    <%}%>
    <%if(obj.getGeoSeriesAcc()!=null&&!obj.getGeoSeriesAcc().isEmpty()){%>
    <tr>
        <td class="label">Geo&nbsp;Series&nbsp;Acc:</td>
        <td class="labelValue"><%=obj.getGeoSeriesAcc()%></td>
    </tr>
    <%}%>
</table>
<%if(obj.getRefRgdIds()!=null && !obj.getRefRgdIds().isEmpty()){ %>
<hr>
<div id="references" class="subTitle"><h2>Associated References</h2></div>
<%
    for (Integer refRgdId : obj.getRefRgdIds()) {
        Reference reference = referenceDAO.getReferenceByRgdId(refRgdId);
        if (reference != null) {
            List<XdbId> pmIds = xdbDAO.getXdbIdsByRgdId(2, refRgdId);
            String pmId = "";
            if (pmIds.size() > 0) {
                pmId = pmIds.get(0).getAccId();
            }
%>
<p><b><%=reference.getTitle()%></b>.<br><%=reference.getCitation() %>
    <% if(pmIds.size()>0){%>
    PMID: <a class="mylink" href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmId%>"><%=pmId%></a>,
    <%}%>
    RGD ID: <a class="mylink" href="/rgdweb/report/reference/main.html?id=<%=refRgdId%>"><%=refRgdId%></a>
</p>
<%
        }
    }
%>
<%}%>
</body>
</html>
