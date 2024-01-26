<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<% String pageTitle = "Search Results - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<script type="text/javascript" src="/rgdweb/js/elasticsearch/elasticsearch.js"></script>
<script src="/rgdweb/js/elasticsearch/searchFilterTree.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/jstree.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/themes/default/style.min.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css" integrity="sha384-/Y6pD6FV/Vv2HJnA6t+vslU6fwYXjCFtcEpHbNJ0lyAFsXTsjBbfaDjzALeQsN6M" crossorigin="anonymous">
<style>
    em{
        background-color:yellow;
    }
</style>
<div class="container-fluid">
<div  style="width:100%;background-color:white">

    <div style=";background-color:white;">
        <input type="hidden" name="cat1" id="cat1" value="${model.cat1}">
        <input type="hidden" name="sp1" id = "sp1" value="${model.sp1}">
        <input type="hidden" name="filter" id = "filter" >
        <input type="hidden" name="subCat" id = "subCat" value="${model.searchBean.subCat}" >


        <c:choose>
            <c:when test="${fn:length(model.aggregations.species)==1}">
                <input type="hidden" id="species" name="species" value="${model.aggregations.species[0].key}"/>
            </c:when>
            <c:otherwise>
                <input type="hidden" id="species" name="species" value="${model.searchBean.species}"/>
            </c:otherwise>
        </c:choose>

        <c:if test="${model.totalHits>0}">
            <div class="views" style="float:right;">
               <c:if test="${model.cat1=='general' || model.cat1=='General'}">
                    <a href="/rgdweb/elasticResults.html?term=${model.term}&category=General&species="><span style="font-size: 15px;font-weight: bold;padding:10px"><i class="fa fa-arrow-left" aria-hidden="true" style="color:green"></i>&nbsp;Results Matrix </span></a>
                </c:if>
            </div>
        </c:if>

    </div>


    <div class="headContent" style="background-color: white">
        <h2 style="color:#24609c">RGD Search Results..</h2>
        <c:if test="${fn:toLowerCase(model.searchBean.category)!='general'}">
        <div style="float:right">

            <form action="elasticResults.html">
                <table>
                    <tr><td>
                <input type="hidden" name="category" value="${model.searchBean.category}"><strong>${model.searchBean.category} Search: </strong><input type="text" size=45 name="term" value="${model.term}" />
        </td>
                    <td><input type="image" src="/common/images/searchGlass.gif" class="searchButtonSmall"/></td>
                    </tr>
        </table>
            </form>
        </div>
        </c:if>
        <p>
            <c:if test="${model.totalHits == 10000}">
        <span style="font-weight: bold">Showing Top</span>
        </c:if>
            <strong style="color:blue">${model.totalHits}</strong> results found for term <strong style="color:blue">"${model.term}"</strong> in category "${model.searchBean.category}" in assembly <span style="font-weight: bold;color:blue">${model.defaultAssembly}</span>
        </p>

    </div>
    <hr>
<c:if test="${model.totalHits>0}">
    <div>
    <table id="contentTable" width="100%">
        <tr>
            <c:if test="${!model.cat1.equalsIgnoreCase('reference') && !model.searchBean.category.equalsIgnoreCase('reference')}">
        <td style="width:20%;">

                <div class="sidebarFilters"  style=";background-color: white;overflow: auto;overflow-y: hidden;">
                     <jsp:include page="facets/sidebar4.jsp"/>
                   </div>

        </td>
            </c:if>
         <td><div class="mainContent"   style=";background-color: white"><jsp:include page="content.jsp"/></div></td>
            <c:if test="${model.searchBean.category!='Variant'}">
         <td> <div class="sidebarTools"  style="background-color: white;padding-left:10px"><jsp:include page="toolsBar.jsp"/></div></td>
            </c:if>

    </tr>
    </table>
    </div>
    </c:if>
</div>
</div>
<%@ include file="/common/footerarea.jsp"%>
<script>
    $(function () {
        var $category= $("#searchCategory").val();
        var speciesBktsSize=$("#speciesBkts").val();
        var categoryBktsSize= $("#categoryBkts").val();
        var sampleExists=$('#sampleExists').val();
        $('#sampleCount').val(sampleExists);
        var xRecordCount=  $('#xRecordCount').val();
        $('#expRecordCount').val(xRecordCount);
        var categoryLowercae;
        if(typeof  $category != 'undefined')
        {
            categoryLowercae= $category.toLowerCase();}
        var objectType;
        if(speciesBktsSize==1 && categoryBktsSize==1){

            if(categoryLowercae!="reference" && categoryLowercae!='ontology'){
                objectType=categoryLowercae+"s";
            }else{
                objectType=categoryLowercae
            }

            var species=$('#species').val();

            var html=   initTools($category, species, objectType,$('#mapKey').val(),sampleExists);
            var  $toolsDiv=   $('#toolsBar');
            $toolsDiv.html("");
            $toolsDiv.html(html);

        }
    })
</script>