<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style type="text/css">
    #sortBy, #pageNumber, #pageSize{
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
            <td><input type="hidden" value="all" id="objectAssembly"/></td>
            <td><input type="hidden" id="objectSearch" value="${model.objectSearch}"/></td>

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