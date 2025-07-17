<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 9:17 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
<thead>
<tr>
<th title="Toggle Check All">
    <%if(!searchBean.getSpecies().equals("") || (speciesAggregations!=null && speciesAggregations.size()==1)){%>
               <input type="checkbox" onclick="toggle(this)">
    <%}%>

</th>
<th>Category</th>
<th>Symbol</th>
<th>Name</th>
<th>Assembly</th>
<th>Chromosome</th>
<th>Start</th>
<th>Stop</th>
<th>Annotations</th>
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
    <td  class="<%=hitSpecies%>" onmouseover="link=false;" onmouseout="link=true;">
    <%if(!searchBean.getSpecies().equals("") || (speciesAggregations!=null && speciesAggregations.size()==1)) {%>
        <input class="checkedObjects" name="checkedObjects" type="checkbox" value="<%=sourceMap.get("term_acc")%>" data-rgdids="<%=sourceMap.get("term_acc")%>" >
        <%}%>
       </td>
    <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>
    <td><%=sourceMap.get("symbol")%></td>
    <td   style="cursor: pointer;"><a href="<%=url%>"><%=sourceMap.get("name")%></a></td>
    <%@include file="mapDetails.jsp"%>
    <td><%if(sourceMap.get("annotationsCount")!=null){%>
        <%=sourceMap.get("annotationsCount")%><%}%></td>
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