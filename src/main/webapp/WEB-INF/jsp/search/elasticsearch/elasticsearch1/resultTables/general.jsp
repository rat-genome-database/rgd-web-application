<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 11:39 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
    <thead>
    <tr>
    <th></th>
    <th>Species</th>
        <th>Category</th>
        <th>Symbol</th>
        <th>Name</th>
        <th>RsId</th>
        <th>Assembly</th>
        <th>Chromosome</th>
        <th>Start</th>
        <th>Stop</th>
        <th>Annotations</th>
        <th>Strains Crossed</th>
        <th>RGD ID</th>
        <th>Matched By</th>
    </tr>
    </thead>
    <tbody>

    <%
        for(SearchHit hit:searchHits){

            Map<String, Object> sourceMap=hit.getSourceAsMap();
            String url="/rgdweb/report/"+sourceMap.get("category").toString().toLowerCase()+"/main.html?id="+sourceMap.get("term_acc");
            String hitSpecies=sourceMap.get("species").toString();
            String  hitCategory=sourceMap.get("category").toString();
    %>

    <tr style="cursor: pointer" onclick="if (link) window.location.href='<%=url%>'">
            <td class="<%=hitSpecies%>">
                        <%if(hitSpecies!=null && !hitSpecies.equalsIgnoreCase("All")){
                                if(!hitSpecies.equals("") && (speciesAggregations!=null && speciesAggregations.size()!=1)){%>
                                    <i class="fa fa-star fa-lg" aria-hidden="true"></i>
                                <%}}%>
            </td>

            <td class="<%=hitSpecies%>">
                        <%if(hitSpecies!=null){%><%=hitSpecies%><%}%>
            </td>
        <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>
        <td><%=sourceMap.get("symbol")%></td>
        <td   style="cursor: pointer;"><a href="<%=url%>"><%=sourceMap.get("name")%></a></td>
        <td><%
            if(sourceMap.get("rsId")!=null){
        %><%=sourceMap.get("rsId")%><%}%></td>
        <%@include file="mapDetails.jsp"%>
        <td><%if(sourceMap.get("annotationsCount")!=null){%>
            <%=sourceMap.get("annotationsCount")%><%}%></td>
        <td><% if(sourceMap.get("strainsCrossed")!=null){
            List<String> strainsCrossed= (List<String>) sourceMap.get("strainsCrossed");
            String crossedStrain=strainsCrossed.stream().collect(Collectors.joining(";"));%>
            <%=crossedStrain%>
            <%}%>
        </td>
        <td class="id"><%=sourceMap.get("term_acc")%></td>
        <%if(!RgdContext.isProduction()){%>
        <td class="highlight" onmouseover="link=false;" onmouseout="link=true;">
            <%@include file="../highlights.jsp"%>
        </td>
        <%}%>
        <%--                    <!--td class="" >$-{hit.getScore()}</td-->--%>

    </tr>

    <%}%>

    </tbody>
</table>