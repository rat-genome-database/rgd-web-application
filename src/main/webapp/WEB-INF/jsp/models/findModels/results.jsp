<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>--%>
<%--<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>--%>
<% String pageTitle =  "Find Models";
    String pageDescription ="Find Models";
    String headContent = "";%>

<%@ include file="/common/headerarea.jsp"%>
<%
    Map<String, List<? extends Terms.Bucket>> aggregations = (Map) request.getAttribute("aggregations");
    String aspect1 = (String) request.getAttribute("aspect");
    int hitsCount = (Integer) request.getAttribute("hitsCount");
%>
<h1 style="text-align: center">Rat Models Results</h1>
<div class="jumbotron" style="height: 200px;padding-top: 10px">
<%@ include file="header.jsp"%>
</div>

<div class="container-fluid wrapper" style="border:1px solid gainsboro;">

<div class="container-fluid row">
    <div class="col-md-2" style="border-right: 1px solid gainsboro">
      <div class="container-fluid" style="background-color: dodgerblue; width:100%;color:white;font-size: medium;font-weight: bold">Filter by ...</div>
        <p>&nbsp;</p>
        <p><a onclick="searchByQualifier('<%=term%>','<%=aspect1%>', 'all')" style="font-weight: bold;color:steelblue;cursor: hand">All Results(<%=hitsCount%>)</a></p>

        <p style="font-weight: bold;color:steelblue">Models</p>
        <ul class="list-group">
            <% for (Terms.Bucket aspect : aggregations.get("aspectAgg")) {
                if (!aspect1.equals("MODEL")){%>
            <li class="list-group-item">

                <%if (aspect.getKey().equals("D")) {%>
                <a  onclick="searchByQualifier('<%=term%>>','<%=aspect.getKey()%>', 'all')" style="cursor:hand;font-weight: bold;color:steelblue">Disease (<%=aspect.getDocCount()%>)</a>
                <ul class="list-group">
                    <%for (Terms.Bucket dm : aggregations.get("D")) {%>
                    <li class="list-group-item" style="padding: 0"><a href="" onclick="searchByQualifier('<%=term%>','<%=aspect.getKey()%>', '<%=dm.getKey()%>')" style="cursor: hand;text-decoration: underline"><%=dm.getKey()%> (<%=dm.getDocCount()%>)</a></li>
                    <% } %>
                </ul>
                <% }
                    if (aspect.getKey().equals("N")) {%>
                <a  onclick="searchByQualifier('<%=term%>','<%=aspect.getKey()%>', 'all')" style="cursor:hand;font-weight: bold;color:steelblue"> Phenotype (<%=aspect.getDocCount()%>)</a>
                <ul class="list-group">
                    <%for (Terms.Bucket pm : aggregations.get("N")) {%>
                    <li class="list-group-item" style="padding: 0"><a href="" onclick="searchByQualifier('<%=term%>','<%=aspect.getKey()%>', '<%=pm.getKey()%>')" style="cursor: hand;text-decoration: underline"><%=pm.getKey()%> (<%=pm.getDocCount()%>)</a></li>
                    <% } %>
                </ul>
                <% }
                    if (!aspect.getKey().equals("N") && !aspect.getKey().equals("D")) {%>
                    <a href="" onclick="searchByQualifier('<%=term%>','<%=aspect.getKey()%>', 'all')" style="cursor: hand;text-decoration: underline">
                        <% if (aspect.getKey().equals("V")) {%>
                        Vertebrate Trait Ontology (<%=aspect.getDocCount()%>)
                        <% }
                        if (aspect.getKey().equals("B"))%>
                        Neuro Behavioral Ontology (<%=aspect.getDocCount()%>)
                        <% } %>
                        </a>
                <% } %>
            </li>
            <% if (aspect1.equals("MODEL")) {%>
                <li class="list-group-item" style="padding: 0"><a href="" onclick="searchByQualifier('<%=term%>','<%=aspect.getKey()%>', 'all', '<%=aspect1%>')" style="cursor: hand;text-decoration: underline;font-weight: bold;color:steelblue">
                        <%if (aspect.getKey().equals("D")) {%>
                        Disease (<%=aspect.getDocCount()%>)
                        <% }
                        if (aspect.getKey().equals("N")) {%>
                        Phenotype (<%=aspect.getDocCount()%>)
                        <% }
                        if (!aspect.getKey().equals("D") && !aspect.getKey().equals("N")) {%>
                        <%=aspect.getKey()%> (<%=aspect.getDocCount()%>)
                        <% } %>

                </a>
                </li>
            <% } %>
            <% } // end for aspectAgg %>
        </ul>
        <p></p>
        <p style="font-weight: bold;color: steelblue">Strain Types</p>
        <ul class="list-group">
                <%for (Terms.Bucket typeBkt : aggregations.get("typeAgg")){%>
                <li class="list-group-item" style="padding: 0">
                    <a  href="" onclick="searchByQualifier('<%=term%>','', 'all', '<%=aspect1%>', '<%=typeBkt.getKey()%>')"><%=typeBkt.getKey()%> (<%=typeBkt.getDocCount()%>)</a></li>
            <% } %>
        </ul>
        <p></p>
        <p style="font-weight: bold;color: steelblue">Conditions</p>
        <ul class="list-group">
            <%for (Terms.Bucket condition : aggregations.get("conditionsAgg")) {%>
                <li class="list-group-item" style="padding: 0">
                    <a  href="" onclick="searchByQualifier('<%=term%>','', 'all', '<%=aspect1%>','', '<%=condition.getKey()%>')"><%=condition.getKey()%> (<%=condition.getDocCount()%>)</a></li>
            <% } %>
        </ul>
    </div>
    <div class="col-md-10" id="resultsTable">
        <%@include file="tableData.jsp"%>
    </div>
</div>
</div>

<script>

      function searchByQualifier(term, aspect, qualifier, searchType, strainType, condition) {

        var  $contentDiv=$('#resultsTable');
        var  $tmp=$contentDiv.html();
         var url;
          if(searchType!=="MODEL" || typeof searchType == 'undefined')
                 url= "findModels.html?qualifier="+qualifier.replaceAll(" ", "+")+"&modelsSearchTerm="+term.replaceAll(" ", "+")+"&models-aspect="+aspect;
          else url="findModels.html?qualifier="+qualifier.replaceAll(" ", "+")+"&modelsSearchTerm="+term.replaceAll(" ", "+")+"&models-aspect="+aspect+"&searchType=model";
         // alert("URL: "+ url);
         if(strainType!=null && typeof strainType!='undefined')
             url=url+"&strainType="+strainType;
          if(condition!=null && typeof condition!='undefined')
              url=url+"&condition="+condition.replaceAll(" ","+");
          console.log("URL:"+ url);
          $($contentDiv).load(url);
          // $.get(url, function (data, status) {
          //     $contentDiv.html(data);
          // })

      }

</script>