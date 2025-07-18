<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 9:32 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<table  id="resultsTable" style="width:100%;z-index:999;" >
    <thead>
    <tr>
        <th title="Toggle Check All">
            <%if((ontologyAggregations!=null && ontologyAggregations.size()==1) || !searchBean.getSubCat().equals("")){%>
            <input type="checkbox" onclick="toggle(this)">
            <%}%>
        </th>
        <th>Category</th>
        <th>Term</th>
        <th>Annotations</th>
        <th>Accession Id</th>
        <th>Matched By</th>
    </tr>
    </thead>
    <tbody>

    <%
        for(SearchHit hit:searchHits){

            Map<String, Object> sourceMap=hit.getSourceAsMap();
            String url="/rgdweb/ontology/annot.html?acc_id="+sourceMap.get("term_acc");
            String subCat=sourceMap.get("subcat").toString();
            String  hitCategory=sourceMap.get("category").toString();
    %>

    <tr style="cursor: pointer" onclick="if (link) window.location.href='<%=url%>'">
        <td  class="<%=subCat%>" onmouseover="link=false;" onmouseout="link=true;">
            <%if((ontologyAggregations!=null && ontologyAggregations.size()==1) || !searchBean.getSubCat().equals("")){%>

            <input class="checkedObjects" name="checkedObjects" type="checkbox" value="<%=sourceMap.get("term_acc")%>" data-rgdids="<%=sourceMap.get("term_acc")%>" >

            <%}%>
        </td>
        <td><span class=<%=hitCategory%>><%=hitCategory%></span></td>
        <td   style="cursor: pointer;"><a href="<%=url%>"><%=sourceMap.get("term")%></a>
            <a href="/rgdweb/ontology/view.html?acc_id=<%=sourceMap.get("term_acc")%>" title="click to browse the term" alt="browse term">
                <img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
                <%
                    if(sourceMap.get("annotationsCount")!=null && Integer.parseInt(sourceMap.get("annotationsCount").toString())>0){%>
            &nbsp;<a href="<%=url%>"><img border="0" src="/rgdweb/images/icon-a.gif" title="Show <%=sourceMap.get("annotationsCount")%> annotated objects"></a>

            <%}if(sourceMap.get("pathwayDiagUrl")!=null){%>
            &nbsp;<a href="<%=sourceMap.get("pathwayDiagUrl")%>"><img border="0" src="/rgdweb/images/icon-d.gif" title="Pathway Diagram"></a>

            <%}%>
        </td>
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
