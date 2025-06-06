<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.search.elasticsearch1.model.SearchBean" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<% SearchBean searchBean= (SearchBean) request.getAttribute("searchBean");
    String searchTermTrimmed=searchBean.getTerm();

    String pageTitle = searchTermTrimmed+" - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>



<div class="container-fluid" style="background-color:#fafafa;">
    <div style=";background-color:white;margin-right:0.5%;">
        <h2>Search Results for.."<span style="color:#24609c"><%=searchTermTrimmed%></span>"<c:if test="${model.totalHits>0}"><span style="margin-left:65%"><a href="elasticResults.html?category=general&term=${model.term}&species=&viewall=true" style="font-weight: bold"><i class="fa fa-table" aria-hidden="true"></i>
&nbsp;View All</a></span></c:if></h2>

    </div>

    <div class="container" >
        <div class="panel panel-default boxed">

            <div class="panel-body">

                <p><strong>${model.totalHits}</strong> results found for <span style="font-weight: bold;color:#24609c">"${model.term}"</span>.</p>
                <c:if test="${model.totalHits>0}">
                    <div class="row-fluid" style="margin-top:10px">
                        <!--div  class="col-sm-2 sidenav" style="border-right:1px solid gainsboro;background-color:#fafafa">

                            <table class="table" style="width:100%">
                                <thead><tr><td colspan="2">Summary</td></tr></thead>
                                <tr><td>Term: </td> <td style="text-align: right">$--{model.term} </td>  </tr>
                                <tr><td>Category:</td> <td style="text-align: right">$--{model.category} </td></tr>
                                <tr><td>Total Hits:</td> <td style="text-align: right">$--{model.totalHits} </td> </tr>
                            </table>
                        </div-->
                        <div class="col-sm-12 text-left" >
                            <div>
                                <c:if test="${model.matrixResultsExists==1}">
                                    <table class="table">
                                        <caption style="text-align: center">Results Matrix</caption>
                                        <thead>
                                        <tr style="background-color:#f0f5f5">
                                            <td></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Rat&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Rat Results" style="font-weight: bold">Rat</a></td>
                                            <td><a href="elasticResults.html?term=${model.term}&species=Mouse&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Mouse Results" style="font-weight: bold"> Mouse</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Human&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Human Results" style="font-weight: bold">Human</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Chinchilla&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Chinchilla Results" style="font-weight: bold">Chinchilla</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Bonobo&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Bonobo Results" style="font-weight: bold">Bonobo</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Dog&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Dog Results" style="font-weight: bold">Dog</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Squirrel&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Squirrel Results" style="font-weight: bold">Squirrel</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Pig&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Pig Results" style="font-weight: bold">Pig</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Green%20Monkey&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Green Monkey Results" style="font-weight: bold">Green Monkey</a></td>
                                            <td ><a href="elasticResults.html?term=${model.term}&species=Naked%20Mole-Rat&category=General&viewall=true&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title="View All Naked Mole-rat Results" style="font-weight: bold">Naked Mole-rat</a></td>

                                            <td ><a href="elasticResults.html?category=general&term=${model.term}&species=&viewall=true" title="View results for all species" style="font-weight: bold">All</a></td>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach items="${model.speciesCatArray}" var="row">
                                            <tr>
                                                <c:set var="url" value=""/>
                                                <c:set value="true" var="first"/>
                                                <c:set value="" var="category"/>

                                                <c:forEach items="${row}" var="column" varStatus="loop">
                                                    <c:set var="species" value=""/>
                                                    <c:if test="${loop.index==1}">
                                                        <c:set var="species" value="Rat"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==2}">
                                                        <c:set var="species" value="Mouse"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==3}">
                                                        <c:set var="species" value="Human"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==4}">
                                                        <c:set var="species" value="Chinchilla"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==5}">
                                                        <c:set var="species" value="Bonobo"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==6}">
                                                        <c:set var="species" value="Dog"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==7}">
                                                        <c:set var="species" value="Squirrel"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==8}">
                                                        <c:set var="species" value="Pig"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==9}">
                                                        <c:set var="species" value="Green Monkey"/>
                                                    </c:if>
                                                    <c:if test="${loop.index==10}">
                                                        <c:set var="species" value="Naked Mole-Rat"/>
                                                    </c:if>
                                                    <c:choose>
                                                        <c:when test="${first==true}">
                                                            <td style="text-align: left;background-color:#f0f5f5;font-weight: bold">${column}</td>
                                                            <c:set var="first" value="false"/>
                                                            <c:set var="category" value="${column}"/>


                                                        </c:when>
                                                        <c:otherwise>
                                                            <td class="matrix" style="text-align: center;font-weight:bold">
                                                                <c:if test="${column!='-'}">
                                                                    <c:if test="${column!=1}">
                                                                        <a href="elasticResults.html?term=${model.term}&category=${category}&species=${species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" title='View All  ${species} ${category}'>
                                                                                ${column}</a>
                                                                    </c:if>
                                                                    <c:if test="${column==1}">
                                                                        <a href="elasticResults.html?term=${model.term}&category=${category}&species=${species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}&redirect=true" title='View All ${species} ${category}'>
                                                                                ${column}</a>
                                                                    </c:if>
                                                                </c:if>
                                                                <c:if test="${column=='-'}">
                                                                    <span style='color:red;font-weight:bold'>${column}</span>
                                                                </c:if>
                                                            </td>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:forEach>

                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </c:if>
                                <div style="background-color:#fafafa" class="ontologyCategories" >
                                    <table class="table">

                                        <c:forEach items="${model.aggregations.category}" var="item">

                                            <c:if test="${item.key=='Ontology'}">
                                                <c:if test="${item.docCount>0}">
                                                    <caption style="text-align: center;cursor: pointer">Ontology Terms (${item.docCount})</caption>
                                                    <c:forEach items="${model.aggregations.ontology}" var="ontBkt">
                                                        <c:if test="${ontBkt.docCount!=1}">
                                                            <tr><td><a href="elasticResults.html?term=${model.term}&category=Ontology&subCat=${ontBkt.key}&species=${model.sb.species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" class="cat filter" style="font-weight: bold">${ontBkt.key}</a></td><td style="text-align: right"><a href="elasticResults.html?term=${model.term}&category=Ontology&subCat=${ontBkt.key}&species=${model.sb.species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" class="cat filter" style="font-weight: bold">${ontBkt.docCount}</a></td></tr>
                                                        </c:if>
                                                        <c:if test="${ontBkt.docCount==1}">
                                                            <tr><td ><a href="elasticResults.html?term=${model.term}&category=Ontology&subCat=${ontBkt.key}&species=${model.sb.species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}&redirect=true" class="cat filter" style="font-weight: bold">${ontBkt.key}</a></td><td style="text-align: right"><a href="elasticResults.html?term=${model.term}&category=Ontology&subCat=${ontBkt.key}&species=${model.sb.species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}&redirect=true" class="cat filter" style="font-weight: bold" >${ontBkt.docCount}</a></td></tr>
                                                        </c:if>
                                                    </c:forEach>

                                                </c:if>
                                            </c:if>
                                        </c:forEach>
                                    </table>
                                </div>
                                <div style="background-color:#fafafa" class="reference" >
                                    <table class="table">

                                        <c:forEach items="${model.aggregations.category}" var="item">
                                            <c:if test="${item.key=='Reference'}">
                                                <c:if test="${item.docCount>0}">
                                                    <caption style="text-align: center">References</caption>
                                                    <tr><td ><a href="elasticResults.html?term=${model.term}&category=${item.key}&species=${model.species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}" class="cat filter" style="font-weight: bold">${item.key}</a></td><td style="text-align: right"><a href ='elasticResults.html?term=${model.term}&category=${item.key}&species=${model.species}&cat1=${model.cat1}&sp1=${model.sp1}&postCount=${model.postCount}' style="font-weight: bold">${item.docCount}</a></td></tr>
                                                </c:if>
                                            </c:if>
                                        </c:forEach>
                                    </table>
                                </div>

                            </div>
                            <!--div class="col-sm-5 text-left" id="graph">
                                <div id="containerChart0" style="min-width: 400px; height: 400px; margin: 0 auto"></div>
                                <div id="containerChart1" style="min-width: 400px; height: 400px; margin: 0 auto"></div>
                            </div-->
                        </div>

                    </div>
                </c:if>
            </div>


        </div>
    </div>
    <%@ include file="/common/footerarea.jsp"%>
</div>
