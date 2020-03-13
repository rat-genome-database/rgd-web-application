<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="header.jsp"%>

<div class="container-fluid wrapper" style="border:1px solid gainsboro;">

<div class="container-fluid row">
    <div class="col-md-2" style="border-right: 1px solid gainsboro">
      <div class="container-fluid" style="background-color: dodgerblue; width:100%;color:white;font-size: medium;font-weight: bold">Filter by Model Type</div>
        <p>&nbsp;</p>
        <p><a onclick="searchByQualifier('${model.term}','${model.aspect}', 'all')" style="cursor: hand;text-decoration: underline">All (${model.hitsCount})</a></p>
        <ul>
        <c:forEach items="${model.aggregations.aspectAgg}" var="aspect">
        <c:if test="${model.aspect!='MODEL'}">
            <li style="padding: 5px">

            <c:if test="${aspect.key=='D'}">
                <a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all')" style="cursor: hand;text-decoration: underline">Disease (${aspect.docCount})</a>
                <ul>
                <c:forEach items="${model.aggregations.D}" var="dm">
                    <li><a  onclick="searchByQualifier('${model.term}','${aspect.key}', '${dm.key}')" style="cursor: hand;text-decoration: underline">${dm.key} (${dm.docCount})</a></li>
                </c:forEach>
                </ul>
            </c:if>

            <c:if test="${aspect.key=='N'}">
                <a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all')" style="cursor: hand;text-decoration: underline"> Phenotype (${aspect.docCount})</a>
                <ul>
                    <c:forEach items="${model.aggregations.N}" var="pm">
                        <li><a  onclick="searchByQualifier('${model.term}','${aspect.key}', '${pm.key}')" style="cursor: hand;text-decoration: underline">${pm.key} (${pm.docCount})</a></li>
                    </c:forEach>
                </ul>
            </c:if>
                <c:if test="${aspect.key!='N' && aspect.key!='D'}">
                    <a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all')" style="cursor: hand;text-decoration: underline">${aspect.key} (${aspect.docCount})</a>
                    <ul>
                        <c:forEach items="${model.aggregations.N}" var="pm">
                            <li><a  onclick="searchByQualifier('${model.term}','${aspect.key}', '${pm.key}')" style="cursor: hand;text-decoration: underline">${pm.key} (${pm.docCount})</a></li>
                        </c:forEach>
                    </ul>
                </c:if>
            </li>
            </c:if>
            <c:if test="${model.aspect=='MODEL'}">
                <li style="padding: 5px"><a  onclick="searchByQualifier('${model.term}','${aspect.key}', 'all', '${model.aspect}')" style="cursor: hand;text-decoration: underline">
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
    </div>
    <div class="col-md-10" id="resultsTable">
        <%@include file="tableData.jsp"%>
    </div>
</div>
</div>
<script>

      function searchByQualifier(term, aspect, qualifier, searchType) {
        var  $contentDiv=$('#resultsTable');
        var  $tmp=$contentDiv.html();
         var url;
          if(searchType!="MODEL")
                 url= "findModels.html?qualifier="+qualifier+"&models-search-term="+term+"&models-aspect="+aspect;
          else url="findModels.html?qualifier="+qualifier+"&models-search-term="+term+"&models-aspect="+aspect+"&searchType=model";
          $.get(url, function (data, status) {
              $contentDiv.html(data);
          })

      }

</script>