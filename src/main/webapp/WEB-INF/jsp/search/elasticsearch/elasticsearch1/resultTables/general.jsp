<%@ page import="java.util.Objects" %><%--
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
        <%
            if(!RgdContext.isProduction()){%>
                <th>Matched By</th>
        <%}%>
    </tr>
    </thead>
    <tbody>

    <%
        for (SearchHit hit : searchHits) {
            Map<String, Object> sourceMap = hit.getSourceAsMap();

            String termAcc = (String) sourceMap.get("term_acc");
            String categoryValue = (String) sourceMap.get("category");
            String categoryLower = categoryValue != null ? categoryValue.toLowerCase() : "";
            String hitSpecies = sourceMap.get("species") != null ? sourceMap.get("species").toString() : "";
            String hitCategory = categoryValue != null ? categoryValue : "";

            String url;
            if ("expressed gene".equalsIgnoreCase(category) || "expressed gene".equalsIgnoreCase(categoryValue)) {
                url = "/rgdweb/report/gene/main.html?id=" + termAcc + "#rnaSeqExpression";
            } else if ("expression study".equalsIgnoreCase(category) || "expression study".equalsIgnoreCase(categoryValue)) {
                url = "/rgdweb/report/expressionStudy/main.html?id=" + termAcc;
            } else if("ontology".equalsIgnoreCase(category) || "ontology".equalsIgnoreCase(categoryValue)){
                url="/rgdweb/ontology/annot.html?acc_id="+termAcc;
            }else
            {
                url = "/rgdweb/report/" + categoryLower + "/main.html?id=" + termAcc;
            }

            String symbol = (String) sourceMap.get("symbol");
            String name = "";
            if (sourceMap.get("name") != null) name += sourceMap.get("name");
            if (sourceMap.get("title") != null) name += sourceMap.get("title");
            if (sourceMap.get("term") != null) name += sourceMap.get("term");
            String rsId = (String) sourceMap.get("rsId");
            Object annotationsCountObj = sourceMap.get("annotationsCount");
            Integer annotationsCount = annotationsCountObj != null ? Integer.parseInt(annotationsCountObj.toString()) : null;
            String pathwayDiagUrl = (String) sourceMap.get("pathwayDiagUrl");

            List<String> strainsCrossed = (List<String>) sourceMap.get("strainsCrossed");
            String crossedStrain = (strainsCrossed != null) ? strainsCrossed.stream().filter(Objects::nonNull).collect(Collectors.joining(";")) : "";
    %>

    <tr style="cursor: pointer" >
        <td class="<%=hitSpecies%>">
            <% if (!"All".equalsIgnoreCase(hitSpecies) && !hitSpecies.isEmpty() && speciesAggregations != null && speciesAggregations.size() != 1) { %>
            <i class="fa fa-star fa-lg" aria-hidden="true"></i>
            <% } %>
        </td>

        <td class="<%=hitSpecies%>"><%=hitSpecies%></td>
        <td>
            <%
                if(hitCategory.equalsIgnoreCase("ontology")){%>
            <span class="<%=hitCategory%>"><%=sourceMap.get("subcat")%></span>
                <%}else{%>
            <span class="<%=hitCategory%>"><%=hitCategory%></span>
                <%}%>

        </td>

        <td>
            <% if (symbol != null) { %><%=symbol%><% } %>
            <% if ("Strain".equalsIgnoreCase(hitCategory)) {
                if (sourceMap.get("sampleExists") != null) { %>
            <span style="color:red;font-size:20px;font-weight:bold" title="Can be analyzed in Variant Visualizer tool">
                    <img src="/rgdweb/images/VV_small.gif">
                </span>
            <%  }
                if (sourceMap.get("experimentRecordCount") != null && (int) sourceMap.get("experimentRecordCount") > 0) { %>
            <span style="color:blue;font-size:20px;font-weight:bold" title="Phenominer Data Available">
                    <img src="/rgdweb/images/PM_small.gif">
                </span>
            <%  }
            } %>
        </td>

        <td style="cursor: pointer;">
            <% if (!name.isEmpty()) { %>
            <a href="<%=url%>"><%=name%></a>
            <% }
                if ("Ontology".equalsIgnoreCase(hitCategory)) { %>
            <a href="/rgdweb/ontology/view.html?acc_id=<%=termAcc%>" title="click to browse the term">
                <img src="/rgdweb/common/images/tree.png" alt="term browser">
            </a>
            <% if (annotationsCount != null && annotationsCount > 0) { %>
            &nbsp;<a href="<%=url%>">
            <img src="/rgdweb/images/icon-a.gif" title="Show <%=annotationsCount%> annotated objects">
        </a>
            <% }
                if (pathwayDiagUrl != null) { %>
            &nbsp;<a href="<%=pathwayDiagUrl%>">
            <img src="/rgdweb/images/icon-d.gif" title="Pathway Diagram">
        </a>
            <% }
            } %>
        </td>

        <td><%=rsId != null ? rsId : ""%></td>
        <%@include file="mapDetails.jsp"%>
        <td><%=annotationsCount != null ? annotationsCount : ""%></td>
        <td><%=crossedStrain%></td>
        <td class="id"><%=termAcc%></td>

        <% if (!RgdContext.isProduction()) { %>
        <td class="highlight" onmouseover="link=false;" onmouseout="link=true;">
            <%@include file="../highlights.jsp"%>
        </td>
        <% } %>
    </tr>

    <% } // end for loop %>

    </tbody>
</table>