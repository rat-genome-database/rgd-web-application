<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 9:20 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
    <thead>
    <th title="Toggle Check All">
        <%if(searchBean.getSpecies().equals("") || speciesAggregations.size()==1){%>
        <input type="checkbox" onclick="toggle(this)">
        <%}%>
    </th>
    <th>Category</th>
    <th>Symbol</th>
    <th>Assembly</th>
    <th>Chromosome</th>
    <th>Start</th>
    <th>Stop</th>
    <th>Annotations</th>
    <th>RGD ID</th>
    <th>Matched By</th>
    </thead>
    <tbody>

    <%
        for(SearchHit hit:searchHits){

            Map<String, Object> sourceMap=hit.getSourceAsMap();
            String url="/rgdweb/report/"+sourceMap.get("category").toString().toLowerCase()+"/main.html?id="+sourceMap.get("term_acc");
            String hitSpecies=sourceMap.get("species").toString();
            String  hitCategory=sourceMap.get("category").toString();
            int xRecordCount=sourceMap.get("experimentRecordCount")!=null?Integer.parseInt(sourceMap.get("experimentRecordCount").toString()):0;
            int sampleExists=sourceMap.get("sampleExists")!=null?Integer.parseInt(sourceMap.get("sampleExists").toString()):0;;

    %>

    <tr style="cursor: pointer" onclick="if (link) window.location.href='<%=url%>'">
        <td  class="<%=hitSpecies%>" onmouseover="link=false;" onmouseout="link=true;">
            <%if(!searchBean.getSpecies().equals("") || speciesAggregations.size()==1) {%>
            <input class="checkedObjects" name="checkedObjects" type="checkbox" value="<%=sourceMap.get("term_acc")%>" data-count="<%=sourceMap.get("experimentRecordCount")%>" data-symbol="<%=sourceMap.get("symbol")%>" data-sampleExists="<%=sourceMap.get("sampleExists")%>">

            <%}%>
        </td>
        <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>
        <td><%=sourceMap.get("symbol")%></td>
        <%@include file="mapDetails.jsp"%>
        <td><%if(sourceMap.get("annotationsCount")!=null){%>
            <%=sourceMap.get("annotationsCount")%><%}%></td>
        <td class="id"><%=sourceMap.get("term_acc")%></td>
        <%if(!RgdContext.isProduction()){%>
        <td class="highlight" onmouseover="link=false;" onmouseout="link=true;">
            <%@include file="../highlights.jsp"%>
        </td>
        <%}%>

    </tr>

    <%}%>

    </tbody>
</table>