<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<link href="/rgdweb/css/expectedRanges/range.css" type="text/css" rel="stylesheet">

 <c:set var="ranges" value="${model.ranges}"/>


<c:choose>
    <c:when test="${fn:length(ranges)>0}">

        <div class="panel panel-default">

            <div class="panel-body">
                <input type="hidden" id="units" value="${model.units}"
                <jsp:include page="plot.jsp"/>

            </div>
        </div>
        <div>
            <div class="optionsHeading" >
                ${model.strainGroup} - ${model.traitTerm} Measurement Data
            </div>
            <div class="panel-body" >
                <table class="table table-sm table-hover table-striped" id="expectedRangesTable">
                    <thead><tr><th>Range Name</th><th>Strains</th><th>Measurement</th><th>Method</th><th>Conditions</th><th>Sex</th><th>Age</th><th>Range Mean</th><th>Range SD</th><th>Range Low</th><th>Range High</th><th>Units</th><th>Experiment Records of the range</th></tr></thead>
                    <tbody>
                    <c:forEach items="${ranges}" var="item">
                        <c:if test="${!item.strainGroupName.contains('normal')}">
                        <c:set var="href" value="/rgdweb/phenominer/table.html?species=3&terms="/>
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${fn:containsIgnoreCase(item.strainGroupName, 'NormalStrain' )}" >
                                        NormalStrain_${item.sex}_${item.ageLowBound} - ${item.ageHighBound}days
                                    </c:when>
                                    <c:otherwise>
                                        ${item.expectedRangeName}
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td>



                                <c:forEach items="${item.strains}" var="s">
                                    <c:if test="${s.getAccId()!=null && s.getAccId()!=''}">
                                        <c:set var="href" value="${href}${s.getAccId()},"/>
                                    </c:if>

                                    <a href="/rgdweb/ontology/annot.html?acc_id=${s.getAccId()}">${s.getTerm()}</a><br>
                                </c:forEach>

                            </td>
                            <td>
                                <c:if test="${item.clinicalMeasurementOntId!=null && item.clinicalMeasurementOntId!=''}">
                                <c:set var="href" value="${href}${item.clinicalMeasurementOntId},"/>
                                </c:if>
                                <a href="/rgdweb/ontology/annot.html?acc_id=${item.clinicalMeasurementOntId}">${item.clinicalMeasurement}</a></td>
                            <td>
                                <c:forEach items="${item.methods}" var="m">
                                    <c:if test="${m.getAccId()!=null && m.getAccId()!=''}">
                                    <c:set var="href" value="${href}${m.getAccId()},"/>
                                    </c:if>
                                    <a href="/rgdweb/ontology/annot.html?acc_id=${m.getAccId()}">${m.getTerm()}</a><br>
                                </c:forEach>
                            </td>
                            <td>
                                <c:forEach items="${item.conditions}" var="c">
                                    <c:if test="${c.getAccId()!=null && c.getAccId()!=''}">
                                    <c:set var="href" value="${href}${c.getAccId()},"/>
                                    </c:if>
                                    <a href="/rgdweb/ontology/annot.html?acc_id=${c.getAccId()}">${c.getTerm()}</a><br>
                                </c:forEach>
                            </td>
                            <td>${item.sex}</td>
                            <td>${item.ageLowBound} - ${item.ageHighBound} days</td>
                            <td>${item.rangeValue}</td>
                            <td>${item.rangeSD}</td>
                            <td>${item.rangeLow}</td>
                            <td>${item.rangeHigh}</td>
                            <td>${item.units}</td>
                            <td><a href="${href}" target="_blank"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                        </tr>
                        </c:if>
                    </c:forEach>
                    </tbody>
                </table>

            </div>
        </div>
    </c:when>
    <c:otherwise>
        <div class="panel panel-default">

            <div class="panel-body">
                <span style="color:red"><h4>0 records found for selected options for "${model.phenotype}". Please select different options or different phenotype.</h4></span>

            </div>
        </div>
    </c:otherwise>
</c:choose>