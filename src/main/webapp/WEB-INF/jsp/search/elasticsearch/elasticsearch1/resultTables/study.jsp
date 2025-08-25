<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 9:25 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
    <thead>
    <tr>
        <th>Category</th>
        <th>Name</th>
        <th>Study ID</th>
        <th>Geo Series Acc</th>
        <th>Matched By</th>
    </tr>
    </thead>
    <tbody>

    <%
        for(SearchHit hit:searchHits){

            Map<String, Object> sourceMap=hit.getSourceAsMap();
            String url="/rgdweb/report/expressionStudy/main.html?id="+sourceMap.get("term_acc");
            String hitSpecies=sourceMap.get("species").toString();
            String  hitCategory=sourceMap.get("category").toString();
    %>

    <tr style="cursor: pointer" onclick="if (link) window.location.href='<%=url%>'">

        <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>
        <td   style="cursor: pointer;"><a href="<%=url%>"><%=sourceMap.get("name")%></a></td>

        <td class="id"><%=sourceMap.get("term_acc")%></td>
        <td>
            <%if(sourceMap.get("geoSeriesAcc")!=null){%>
               <%=sourceMap.get("geoSeriesAcc")%>
            <%}%>
        </td>
        <%if(!RgdContext.isProduction()){%>
        <td class="highlight" onmouseover="link=false;" onmouseout="link=true;">
            <%@include file="../highlights.jsp"%>
        </td>
        <%}%>

    </tr>

    <%}%>

    </tbody>
</table>