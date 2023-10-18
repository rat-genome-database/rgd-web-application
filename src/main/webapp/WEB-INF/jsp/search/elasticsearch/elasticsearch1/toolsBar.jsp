<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <div style="background-color: white;padding-top:50px">

            <!--p style="font-weight: bold">RGD Tools</p>
            <p style="font-size: x-small">Analyze selected <strong style="color:blue">$--{model.category}s</strong> with RGD Tools.</p-->

            <input type="hidden" id="speciesBkts" value="${fn:length(model.aggregations.species)}"/>
            <input type="hidden" id="categoryBkts" value="${fn:length(model.aggregations.category)}"/>
            <div id="toolsBar">

                <c:if test="${model.searchBean.category=='Reference' || (model.searchBean.category=='Ontology' && fn:length(model.aggregations.ontology)==1)}">
                    <c:set var="objectType" value=""/>
                    <c:choose>
                        <c:when test="${model.searchBean.category=='Reference' || model.searchBean.category=='Ontology'}">
                            <c:set var="objectType" value="${fn:toLowerCase(model.searchBean.category)}"/>
                        </c:when>

                    </c:choose>


                    <p style='font-weight: bold'>RGD Tools</p>

                    <p style='font-size: x-small'>Analyze selected <strong style='color:blue'>${model.searchBean.category}</strong> with RGD Tools.</p>
                    <p>
                        <div class="tooltips">
                        <a onclick="toolSubmit(this,$('#species').val(),'excel', '${objectType}')"  style="cursor: pointer"><img  class="boxedTools toolicon" src="/rgdweb/common/images/excel_small.png" /></a>
                    <span class="tooltiptext" style="font-size: x-small">Allows user to download the selected objects in EXCEL. </span>&nbsp;
                        <a onclick="toolSubmit(this,$('#species').val(),${objectType})" target="_blank" style="cursor: pointer; font-size: 11px">Excel Download</a>
                </div>
                    </p>

                </c:if>
            </div>



</div>