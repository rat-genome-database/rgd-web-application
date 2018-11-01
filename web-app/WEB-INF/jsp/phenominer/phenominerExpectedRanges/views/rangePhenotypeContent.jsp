<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ranges" value="${model.records}"/>

<c:choose>
    <c:when test="${fn:length(ranges)>0}">

        <div class="panel panel-default">

            <div class="panel-body">
                <jsp:include page="plot.jsp"/>

            </div>
        </div>
        <div>
            <div class="optionsHeading">
               ${model.phenotype}  - Measurement Data
            </div>
            <div>
                <table class="table table-sm table-hover table-striped" id="expectedRangesTable">
                    <thead><tr><th>Range Name</th><th>Strain Group</th><th>Strains</th><th>Method</th><th>Conditions</th><th>Sex</th><th>Age</th><th>Range Mean</th><th>Range SD</th><th>Range Low</th><th>Range High</th><th>Units</th><th>Studies within the Range</th></tr></thead>
                    <tbody>
                    <c:forEach items="${ranges}" var="item">
                        <c:if test="${!item.strainGroupName.contains('Normal')}">
                        <c:set var="href" value="/rgdweb/phenominer/table.html?species=3&terms="/>
                        <tr>
                            <td>
                                <c:set var="rangeName" value="${item.strainGroupName}"/>

                                    <c:if test="${(item.ageLowBound==0 && item.ageHighBound<999) || (item.ageLowBound!=0 && item.ageHighBound<=999)}">
                                        <c:set var="rangeName" value="${rangeName}_${item.ageLowBound}-${item.ageHighBound}"/>
                                    </c:if>
                                <c:if test="${!item.sex.equals('Mixed')}">
                                    <c:set var="rangeName" value="${rangeName}_${item.sex}"/>
                                </c:if>
                                <c:if test="${item.expectedRangeName.contains('vascular') }">
                                    <c:set var="rangeName" value="${rangeName}_vascular"/>
                                </c:if>
                                <c:if test="${item.expectedRangeName.contains('tail')}">
                                    <c:set var="rangeName" value="${rangeName}_tail"/>
                                </c:if>
                            ${rangeName}
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${fn:containsIgnoreCase(item.strainGroupName, 'NormalStrain' )}" >
                                        NormalStrain_${item.sex}_${item.ageLowBound} - ${item.ageHighBound}days
                                    </c:when>
                                    <c:otherwise>
                                        ${item.strainGroupName}
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
                            <!--td>
                                <!--c:if test="$-{model.cmo!=null && model.cmo!=''}">
                                <!--c:set var="href" value="$-{href}$-{model.cmo},"/>
                                <!--/c:if>
                                <a href="/rgdweb/ontology/annot.html?acc_id=$-{model.cmo}">$-{model.phenotype}</a></td-->
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
                            <td><a href="${href}${model.cmo}" target="_blank"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
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
