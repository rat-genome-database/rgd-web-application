<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style type="text/css">
    #assembly, #sortBy, #pageNumber, #pageSize{
        border:solid 1px lightgrey;
        -webkit-border-radius:2px;
        -moz-border-radius:2px;
        border-radius:2px;
        padding:2px;
    }
</style>
<div style="float:right">


    <table>
        <tr>
            <td><input type="hidden" value="${model.defaultAssembly}" id="objectAssembly"/></td>
            <!--c:if test="$-{model.objectSearch=='true'}"-->
            <td>
                <form  id="assemblyForm" action="elasticResults.html" method="post">
                <input type="hidden" name="category" value="${model.searchBean.category}">
                 <input type="hidden" name="species" value="${model.searchBean.species}"/>

                    <input type="hidden" name="currentPage" value="1">
                    <input type="hidden" name="term" id="term" value="${model.term}"/>
                    <input type="hidden" name="type" id = "type" >

                    <input type="hidden" name="subCat" value="${model.searchBean.subCat}">
                    <input type="hidden" name="start" id="start" value="${model.searchBean.start}"/>

                    <input type="hidden" name="stop" id="stop" value="${model.searchBean.stop}">
                    <input type="hidden" name="chr" id="chr" value="${model.searchBean.chr}"/>

                    <input type="hidden" name="size" value="50">
                    <input type="hidden" name="objectSearch" id="objectSearch" value="${model.objectSearch}"/>

                    <label for="assembly" style="font-size:x-small;font-weight: bold">Assembly:</label><br>
                    <select  id="assembly" name="assembly" >

                        <option selected value="${model.defaultAssembly}">${model.defaultAssembly}</option>

                        <c:forEach items="${model.assemblyMaps}" var="map">
                            <c:if test="${map.key!=6 && map.key!=7 && map.key!=8 && map.key!=19 && map.key!=21 && map.key!=36}">
                                <c:if test="${map.description!=model.defaultAssembly}">
                                        <option value="${map.description}">${map.name}</option>
                                </c:if>
                            </c:if>
                        </c:forEach>
                        <c:if test="${model.defaultAssembly!='all'}">
                            <option value="all">all</option>
                        </c:if>
                    </select>

                    </form>


            </td>
            <!--/c:if-->
            <c:if test="${model.objectSearch!='true'}">
            <!--td>
                <c:if test="${model.searchBean.species!=null && model.searchBean.species!='' && model.defaultAssembly!=null}">
                    <label for="assembly" style="font-size:x-small;font-weight: bold">Assembly:</label><br>
                    <select class="assembly" id="assembly" onchange="assembly('change',this.value)">
                    <c:forEach items="${model.assemblyMaps}" var="map">
                        <c:if test="${map.key!=6 && map.key!=7 && map.key!=8 && map.key!=19 && map.key!=21 && map.key!=36}">
                        <c:choose>
                            <c:when test="${map.description==model.defaultAssembly}">
                                <option selected="selected" value="${map.description}">${map.name}</option>
                            </c:when>
                            <c:otherwise>
                                <option value="${map.description}">${map.name}</option>
                            </c:otherwise>

                        </c:choose>

                        </c:if>
                    </c:forEach>
                        <c:if test="${model.defaultAssembly==null || model.defaultAssembly==''}">
                        <option value="selected">None</option>
                        </c:if>
                </select>
                </c:if>
            </td-->
            </c:if>
            <td>&nbsp;</td>

            <td>
                <c:choose>
                    <c:when test="${!model.searchBean.category.equalsIgnoreCase('general')  && !model.searchBean.category.equalsIgnoreCase('Ontology') && !model.searchBean.category.equalsIgnoreCase('Reference') && !model.searchBean.category.equalsIgnoreCase('Variant')}">
                        <label for="sortBy" style="font-size:x-small;font-weight: bold">Sort By</label><br>
                        <select class="sortSelect" id="sortBy" onchange="sortFunction('change',this.value)" >
                        <option selected="selected" value="0">Relevance</option>
                        <option value="1">Symbol - ASC</option>
                        <option value="2">Symbol - DESC</option>
                        <!--option value="3">Chromosome - ASC</option>
                    <option value="4">Chromosome - DESC</option>
                        <option value="5">Start Position - ASC</option>
                    <option value="6">Start Position - DESC</option>
                        <option value="7">Stop Position - ASC</option>
                    <option value="8">Stop Position - DESC</option-->
                    </select>
                    </c:when>
                    <c:otherwise>
                        <c:if test="${model.searchBean.category.equalsIgnoreCase('general')}">
                            <label for="sortBy" style="font-size:x-small;font-weight: bold">Sort By</label><br><select class="sortSelect" id="sortBy" onchange="sortFunction('change',this.value)" >
                            <option selected="selected" value="0">Relevance</option>
                            <option value="1">Symbol - ASC</option>
                            <option value="2">Symbol - DESC</option>
                            <!--option value="3">Chromosome - ASC</option>
                        <option value="4">Chromosome - DESC</option>
                            <option value="5">Start Position - ASC</option>
                        <option value="6">Start Position - DESC</option>
                            <option value="7">Stop Position - ASC</option>
                        <option value="8">Stop Position - DESC</option-->
                        </select>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </td>

            <td>
                <label for="pageNumber" style="font-size:x-small;font-weight: bold">Go To Page:</label><br><input type="text" class="" id="pageNumber" name="currentPage" value="1" size="5" >
            </td>

            <td>
                &nbsp;<br>
                <span class=""><button type="submit" id="pagebtn" onclick="submitFunction('click')" style="background-color: #00b38f;color:white;font-weight: bold;">Go!</button></span></td>

            <td>

                <label for="pageSize" style="font-size:10px;font-weight: bold">View Results</label><br>
                <select class="pageSize" id="pageSize" name="pageSize" onchange="pagesizeFunction('change', 'pageSize', this.value)">
                <option   value="10">10</option>
                <option value="20">20</option>
                <option value="30">30</option>
                <option  value="40">40</option>
                <option selected="selected" value="50">50</option>
                <option   value="100">100</option>
                <option   value="500">500</option>
                <option   value="1000">1000</option>
                <!--option  value="9999">All Rows</option-->

            </select>
            </td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>
                Page <span id="currentPage">${model.searchBean.currentPage}</span> of <span id="totalPages"> ${model.totalPages}</span> <br>

                <button id="prev" onclick="prevFunction('click', 'prev')">&#10094;</button>
                <button id="next" onclick="nextFunction('click','next', '${model.searchBean.currentPage}', '${model.totalPages}', $('#pageSize').find('option:selected'))">&#10095;</button>
            </td>
        </tr>
    </table>
</div>