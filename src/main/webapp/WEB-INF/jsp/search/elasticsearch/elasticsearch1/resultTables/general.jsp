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
            String url="";
            if(category.equalsIgnoreCase("Expressed Gene")){
                url+="/rgdweb/report/gene/main.html?id=" + sourceMap.get("term_acc")+"#rnaSeqExpression";
            }else
            if(category.equalsIgnoreCase("Expression Study")){
                url+="/rgdweb/report/expressionStudy/main.html?id=" + sourceMap.get("term_acc")+"#rnaSeqExpression";
            }else
            {
                url += "/rgdweb/report/"+sourceMap.get("category").toString().toLowerCase()+"/main.html?id=" + sourceMap.get("term_acc");
            }
            String hitSpecies=sourceMap.get("species")!=null?sourceMap.get("species").toString():"";
            String  hitCategory=sourceMap.get("category")!=null?sourceMap.get("category").toString():"";
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
        <td><%if(sourceMap.get("symbol")!=null){%>
            <%=sourceMap.get("symbol")%>
            <%}if(hitCategory.equalsIgnoreCase("Strain")){%>
            <%
                if(sourceMap.get("sampleExists")!=null){%>
            <span style="color:red;font-size:20px;font-weight:bold" title='Can be analyzed in Variant Visulizer tool'>
                <img src="/rgdweb/images/VV_small.gif" ></span>
            <%}if(sourceMap.get("experimentRecordCount")!=null && (int) sourceMap.get("experimentRecordCount")>0){%>
            <span style="color:blue;font-size:20px;font-weight:bold" title='Phenominer Data Available'><img src="/rgdweb/images/PM_small.gif" ></span>
            <%}%>
               <% }
            %>
        </td>
        <td   style="cursor: pointer;">
            <%String name="";
                if(sourceMap.get("name")!=null){
                    name+=sourceMap.get("name");
                }
                if(sourceMap.get("title")!=null){
                    name+=sourceMap.get("title");
                }
                if(sourceMap.get("term")!=null){
                    name+=sourceMap.get("term");
                }
                if(!name.equals("")){
            %>
            <a href="<%=url%>"><%=name%></a>
            <%}if(hitCategory.equalsIgnoreCase("Ontology")){%>
            <a href="/rgdweb/ontology/view.html?acc_id=<%=sourceMap.get("term_acc")%>" title="click to browse the term" alt="browse term">
                <img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
            <%if(sourceMap.get("annotationsCount")!=null && Integer.parseInt(sourceMap.get("annotationsCount").toString())>0){%>
            &nbsp;<a href="<%=url%>"><img border="0" src="/rgdweb/images/icon-a.gif" title="Show <%=sourceMap.get("annotationsCount")%> annotated objects"></a>

            <%}if(sourceMap.get("pathwayDiagUrl")!=null){%>
            &nbsp;<a href="<%=sourceMap.get("pathwayDiagUrl")%>"><img border="0" src="/rgdweb/images/icon-d.gif" title="Pathway Diagram"></a>

            <%}}%>
        </td>
        <td><%if(sourceMap.get("rsId")!=null){
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