<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% String pageTitle =  "Find Models";
    String pageDescription ="Find Models";
    String headContent = "";%>

<%@ include file="/common/headerarea.jsp"%>

<h1 style="text-align: center">Rat Models Results</h1>
<div class="jumbotron" style="height: 100px;padding-top: 10px">
<%@ include file="header.jsp"%>
</div>


<div class="container-fluid wrapper" style="border:1px solid gainsboro;">

<div class="container-fluid row">
    <div class="col-md-2" style="border-right: 1px solid gainsboro">
      <div class="container-fluid" style="background-color: dodgerblue; width:100%;color:white;font-size: medium;font-weight: bold">Filter by ...</div>
        <p>&nbsp;</p>
        <p><a onclick="searchByQualifier('${model.term}','${model.aspect}', 'all')" style="font-weight: bold;color:steelblue">All Results(${model.hitsCount})</a></p>

        <p style="font-weight: bold;color:steelblue">Models</p>
        <ul class="list-group">
        <c:forEach items="${model.aggregations.aspectAgg}" var="aspect">
        <c:if test="${model.aspect!='MODEL'}">
            <li class="list-group-item">

            <c:if test="${aspect.key=='D'}">
                <a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all')" style="cursor:hand;font-weight: bold;color:steelblue">Disease (${aspect.docCount})</a>
                <ul class="list-group">
                <c:forEach items="${model.aggregations.D}" var="dm">
                    <li class="list-group-item" style="padding: 0"><a  onclick="searchByQualifier('${model.term}','${aspect.key}', '${dm.key}')" style="cursor: hand;text-decoration: underline">${dm.key} (${dm.docCount})</a></li>
                </c:forEach>
                </ul>
            </c:if>

            <c:if test="${aspect.key=='N'}">
                <a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all')" style="cursor:hand;font-weight: bold;color:steelblue"> Phenotype (${aspect.docCount})</a>
                <ul class="list-group">
                    <c:forEach items="${model.aggregations.N}" var="pm">
                        <li class="list-group-item" style="padding: 0"><a  onclick="searchByQualifier('${model.term}','${aspect.key}', '${pm.key}')" style="cursor: hand;text-decoration: underline">${pm.key} (${pm.docCount})</a></li>
                    </c:forEach>
                </ul>
            </c:if>
                <c:if test="${aspect.key!='N' && aspect.key!='D'}">
                    <a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all')" style="cursor: hand;text-decoration: underline">
                    <c:if test="${aspect.key=='V'}">
                        Vertebrate Trait Ontology (${aspect.docCount})

                    </c:if>
                    <c:if test="${aspect.key=='B'}">
                        Neuro Behavioral Ontology (${aspect.docCount})

                    </c:if>
                        </a>

                </c:if>
            </li>
            </c:if>
            <c:if test="${model.aspect=='MODEL'}">
                <li class="list-group-item" style="padding: 0"><a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all', '${model.aspect}')" style="cursor: hand;text-decoration: underline;font-weight: bold;color:steelblue">
                    <c:if test="${aspect.key=='D'}">
                    Disease (${aspect.docCount})

                    </c:if>

                    <c:if test="${aspect.key=='N'}">
                        Phenotype (${aspect.docCount})

                    </c:if>
                    <c:if test="${aspect.key!='N' && aspect.key!='D'}">
                        ${aspect.key} (${aspect.docCount})

                    </c:if>
                </a>
                </li>
            </c:if>
            <!--href="findModels.html?qualifier=$-{qualifier.key}&models-search-term=$-{model.term}&models-aspect=$-{model.aspect}"-->
        </c:forEach>
        </ul>
        <p></p>
        <p style="font-weight: bold;color: steelblue">Strain Types</p>
        <ul class="list-group">
            <c:forEach items="${model.aggregations.typeAgg}" var="typeBkt">
                <li class="list-group-item" style="padding: 0">
                    <a  href="" onclick="searchByQualifier('${model.term}','${aspect.key}', 'all', '${model.aspect}', '${typeBkt.key}')">${typeBkt.key} (${typeBkt.docCount})</a></li>
            </c:forEach>
        </ul>
        <p></p>
        <p style="font-weight: bold;color: steelblue">Conditions</p>
        <ul class="list-group">
            <c:forEach items="${model.aggregations.conditionsAgg}" var="condition">
                <li class="list-group-item" style="padding: 0">
                    <a  href="" onclick="searchByQualifier('${model.term}','${aspect.key}', 'all', '${model.aspect}', '${typeBkt.key}','${condition.key}')">${condition.key} (${condition.docCount})</a></li>
            </c:forEach>
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
                 url= "findModels.html?qualifier="+qualifier+"&modelsSearchTerm="+term+"&models-aspect="+aspect;
          else url="findModels.html?qualifier="+qualifier+"&modelsSearchTerm="+term+"&models-aspect="+aspect+"&searchType=model";
        //   alert("URL: "+ url);
         if(strainType!=null && typeof strainType!='undefined')
             url=url+"&strainType="+strainType;
          if(condition!=null && typeof condition!='undefined')
              url=url+"&condition="+condition;
          $.get(url, function (data, status) {
              $contentDiv.autocomplete(data);
          })

      }

</script>