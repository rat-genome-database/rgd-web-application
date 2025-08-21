<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 9:34 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
    <thead>
    <tr>
        <th title="Toggle Check All">
            <%if(searchBean.getSpecies().equals("") || (speciesAggregations!=null && speciesAggregations.size()==1)){%>
            <input type="checkbox" onclick="toggle(this)">
            <%}%>
        </th>
        <th>Category</th>
        <th>Title</th>
        <th>Citation</th>
        <th>Authors</th>
        <th>RGD ID</th>
        <%if(!RgdContext.isProduction()){%>
        <th>Matched By</th>
        <%}%>
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
        <%--    <td class="<%=sourceMap.get("species")%>">--%>
        <%--                <%if(hitSpecies!=null && !hitSpecies.equalsIgnoreCase("All")){--%>
        <%--                        if(hitSpecies.equals("") && speciesAggregations.size()!=1){%>--%>
        <%--                            <i class="fa fa-star fa-lg" aria-hidden="true"></i>--%>
        <%--                        <%}}%>--%>
        <%--    </td>--%>

        <%--    <td class="<%=sourceMap.get("species")%>">--%>
        <%--                <%if(hitSpecies!=null && !hitSpecies.equalsIgnoreCase("All")){--%>
        <%--                    if(hitSpecies.equals("") && speciesAggregations.size()!=1){%>--%>
        <%--                        <%=hitSpecies%>--%>
        <%--                <%}}%>--%>
        <%--    </td>--%>
        <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>

        <td   style="cursor: pointer;"><a href="<%=url%>"><%=sourceMap.get("title")%></a></td>
        <td>
          <%=sourceMap.get("citation")%>
<%--                                    <c:if test="${!model.searchBean.category.equalsIgnoreCase('general')}">--%>
<%--                                        ${f:format(hit.getSourceAsMap().citation,t )} </span>--%>
<%--                                    </c:if>--%>
                                </td>
                                <td><%
                                    if(sourceMap.get("author")!=null){
                                %>
                                    <%=String.join(" | ", ((List<String>) sourceMap.get("author")))%>
<%--                                    <c:if test="${!model.searchBean.category.equalsIgnoreCase('general')}">--%>
<%--                                        ${f:format(hit.getSourceAsMap().author, t )}--%>
<%--                                    </c:if>--%>

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