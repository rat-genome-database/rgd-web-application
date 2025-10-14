<%@ page import="java.util.HashMap" %><%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 9:22 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
    <thead>
    <tr>
        <th title="Toggle Check All">
<%--            <%if(searchBean.getSpecies().equals("") || speciesAggregations.size()==1){%>--%>
<%--            <input type="checkbox" onclick="toggle(this)">--%>
<%--            <%}%>--%>
        </th>
        <th>Category</th>
        <th>Name</th>
        <th>RsId</th>
        <th>Assembly</th>
        <th>Chromosome</th>
        <th>Start</th>
        <th>Stop</th>
        <th>RGD ID</th>
        <th>Matched By</th>
    </tr>
    </thead>
    <tbody>

    <%
        for(SearchHit hit:searchHits){

            Map<String, Object> sourceMap=hit.getSourceAsMap();
            String url="";
            if(sourceMap.get("variantCategory")!=null && sourceMap.get("variantCategory").toString().equalsIgnoreCase("Phenotypic Variant") ){
                url+="/rgdweb/report/rgdvariant/main.html?id="+sourceMap.get("term_acc");
            }else url+=
                    "/rgdweb/report/"+sourceMap.get("category").toString().toLowerCase()+"/main.html?id="+sourceMap.get("term_acc");

            String hitSpecies=sourceMap.get("species").toString();
            String  hitCategory=sourceMap.get("category").toString();

        List<Map<String, Object>> mapData= (List<Map<String, Object>>) sourceMap.get("mapDataList");
       Map<String, Object> matchedMap=new HashMap<>();
        for(Map map:mapData){
            if(map.get("map").toString().equalsIgnoreCase(searchBean.getAssembly())){
                matchedMap=map;
            }
        }

    %>

    <tr style="cursor: pointer" onclick="if (link) window.location.href='<%=url%>'">
        <td  class="<%=hitSpecies%>" onmouseover="link=false;" onmouseout="link=true;">
<%--            <%if(!searchBean.getSpecies().equals("") || speciesAggregations.size()==1) {%>--%>

<%--            <input class="checkedObjects" name="checkedObjects" type="checkbox" value="<%=sourceMap.get("term_acc")%>" data-rgdids="<%=sourceMap.get("term_acc")%>" >--%>

<%--            <%}%>--%>
        </td>
        <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>
        <td>
            <b>(<%=matchedMap.get("map")%>)</b>&nbsp;<%=matchedMap.get("chromosome")%><b>:</b>&nbsp;<%=matchedMap.get("startPos")%>-<%=matchedMap.get("stopPos")%><%=sourceMap.get("refNuc")!=null?sourceMap.get("refNuc"):""%>><%=sourceMap.get("varNuc")!=null?sourceMap.get("varNuc"):""%></td>
        <td><%
            if(sourceMap.get("rsId")!=null){
        %><%=sourceMap.get("rsId")%><%}%></td>
        <%@include file="mapDetails.jsp"%>

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