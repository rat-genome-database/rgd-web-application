<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% String pageTitle = " Phenominer Expected Ranges - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%--@ include file="/common/headerarea.jsp"--%>
<%@ include file="rgdHeader.jsp"%>


    <script src="/rgdweb/js/expectedRanges/jquery.min.js"></script>
    <!-- Bootstrap -->
    <link href="/rgdweb/css/expectedRanges/bootstrap.min.css" rel="stylesheet">
    <!--link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet"-->
    <script src="/rgdweb/js/expectedRanges/bootstrap.min.js"></script>
    <script src="/rgdweb/js/expectedRanges/range.js"></script>

    <link href="/rgdweb/css/expectedRanges/range.css" type="text/css" rel="stylesheet">



<div class="container-fluid" style="background-color:#fafafa;margin-top:1%">

    <div class="container-fluid" >

        <div class="panel panel-default">

            <div class="panel-body">

                <div style="float:right;background:linear-gradient(gainsboro, white);border:1px solid gainsboro; padding:5px"><strong><a href="home.html?trait=${model.traitOntId}#strains">Back to all strains</a></strong></div>

                <h3>Phenominer Expected Ranges</h3>
                <div style="width:40%;float:right;margin-right:10%;text-align: justify;border:1px solid gainsboro;padding:5px">
                    <strong>Analysis Description:</strong>
                    PhenoMiner's Expected Ranges result from a statistical meta-analysis of PhenoMiner data.  For each rat strain where four or more experiments exist for a single clinical measurement, a meta-analysis is performed using either a random- or fixed-effect model, based on the level of heterogeneity."Zhao et al, in preparation"
                </div>
                <div style="width:50%;">
                    <table class="table" style="width:90%">
                        <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Strain Group</td><td>

                    <form id="erStrainsSelectForm" action="strain.html">
                        <input type="hidden" name="trait" id="trait" value="${model.traitOntId}"/>
                        <input type="hidden" name="strainGroupId" id="strainGroupId" value="${model.strainGroupId}"/>
                        <select id="erStrainSelect" class="form-control form-control-sm " >
                            <c:forEach items="${model.strainObjects}" var="item">
                                <c:choose>
                                    <c:when test="${model.strainGroup==item.strainGroupName}">
                                        <option value="${item.strainGroupId}" selected>${item.strainGroupName}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${item.strainGroupId}">${item.strainGroupName}</option>
                                    </c:otherwise>
                                </c:choose>

                            </c:forEach>
                        </select>
                    </form>

                        </td></tr>
                        <c:if test="${model.trait!=null && model.trait!=''}"><tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c; ">Trait</td><td style="text-transform: capitalize">${model.trait}</td></c:if></tr>
                        <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Strains Type</td><td>Inbred </td></tr>
                    </table>

                </div>
                <!--hr>
                <div style="margin-left:70%;">Select Strain:
                    <form id="erStrainsSelectForm" action="strain.html">
                        <input type="hidden" name="trait" id="trait" value="${model.traitOntId}"/>
                        <input type="hidden" name="strainGroupId" id="strainGroupId" value="${model.strainGroupId}"/>
                        <select id="erStrainSelect" class="form-control form-control-sm " >
                            <!--c:forEach items="${model.strainObjects}" var="item">
                                <!--c:choose>
                                    <!--c:when test="${model.strainGroup==item.strainGroupName}">
                                        <option value="${item.strainGroupId}" selected>${item.strainGroupName}</option>
                                    <!--/c:when>
                                    <!--c:otherwise>
                                        <option value="${item.strainGroupId}">${item.strainGroupName}</option>
                                    <!--/c:otherwise>
                                <!--/c:choose>

                            <!--/c:forEach>
                        </select>
                    </form>
                </div>
                <h4 style="text-transform: capitalize;color:#24609c;">Strain ${model.strainGroup} -  ${model.traitTerm} Measurements</h4-->
                <c:if test="${model.damagingVariants.keySet()!=null && fn:length(model.damagingVariants.keySet())>0}">
                <div class="optionsHeading" >

                    Damaging Variants

                </div>

                <div class="panel-body" >
                    <table class="table table-sm table-hover table-striped" id="expectedRangesTable">
                        <thead><tr><th>Strain</th><th>Rnor_6.0</th><th>Rnor_5.0</th><th>RGSC_v3.4</th></tr></thead>
                        <tbody>
                        <c:forEach items="${model.damagingVariants.keySet()}" var="strain">
                                <tr>
                                    <td>${strain}</td>
                                    <c:if test="${model.damagingVariants.get(strain).get('Rnor_6.0').get('count') != null}">
                                    <td>Count: ${model.damagingVariants.get(strain).get("Rnor_6.0").get("count")} &nbsp;&nbsp; <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=${model.damagingVariants.get(strain).get("Rnor_6.0").get("rgdId")}&fmt=full&map=${model.damagingVariants.get(strain).get("Rnor_6.0").get("map")}">Full Report</a></span></td>
                                    </c:if>
                                    <c:if test="${model.damagingVariants.get(strain).get('Rnor_5.0').get('count') != null}">
                                    <td>Count: ${model.damagingVariants.get(strain).get("Rnor_5.0").get("count")} &nbsp;&nbsp; <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=${model.damagingVariants.get(strain).get("Rnor_5.0").get("rgdId")}&fmt=full&map=${model.damagingVariants.get(strain).get("Rnor_5.0").get("map")}">Full Report</a></span></td>
                                   </c:if>
                                    <c:if test="${model.damagingVariants.get(strain).get('RGSC_v3.4').get('count') != null}">
                                    <td>Count: ${model.damagingVariants.get(strain).get("RGSC_v3.4").get("count")} &nbsp;&nbsp; <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=${model.damagingVariants.get(strain).get("RGSC_v3.4").get("rgdId")}&fmt=full&map=${model.damagingVariants.get(strain).get("RGSC_v3.4").get("map")}">Full Report</a></span></td>
                                    </c:if>
                                </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                    </div>
                </c:if>

                <div>
                    <div>
                        <div class="optionsHeading">Options/Filters</div>

                        <table class="rangeOptionsTable" id="rangeOptionsTable">
                            <tr class="rangeOptionsRow">
                                <td class="rangeOptionsColumn">
                                   <h4>Phenotypes</h4>
                                    <c:choose>
                                        <c:when test="${fn:length(model.phenotypesMap)<=5}">
                                            <table>

                                                <c:forEach items="${model.phenotypesMap}" var="p">
                                                    <tr>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${model.initialPlotPhenotype==p.key}">
                                                                    <span style="text-transform: capitalize;"><input class="rangephenotypes" type="radio" name="phenotypes" value="${p.value}" checked>&nbsp;<a href="/rgdweb/ontology/annot.html?acc_id=${p.value}" >${p.key}</a></span>

                                                                </c:when>
                                                                <c:otherwise>

                                                            <span style="text-transform: capitalize;"><input class="rangephenotypes" type="radio" name="phenotypes" value="${p.value}">&nbsp;<a href="/rgdweb/ontology/annot.html?acc_id=${p.value}" >${p.key}</a></span>

                                                                </c:otherwise>
                                                            </c:choose>

                                                        </td>

                                                    </tr>
                                                </c:forEach>
                                            </table>
                                        </c:when>
                                        <c:otherwise>
                                            <div id="colm">
                                                <table>

                                                    <c:forEach items="${model.phenotypesMap}" var="p">
                                                        <tr>
                                                            <td>
                                                               <c:choose>
                                                                   <c:when test="${model.initialPlotPhenotype==p.key}">
                                                                        <span style="text-transform: capitalize;"><input class="rangephenotypes" type="radio" name="phenotypes" value="${p.value}" checked>&nbsp;<a href="/rgdweb/ontology/annot.html?acc_id=${p.value}" >${p.key}</a></span>

                                                                      
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                <span style="text-transform: capitalize;"><input class="rangephenotypes" type="radio" name="phenotypes" value="${p.value}">&nbsp;<a href="/rgdweb/ontology/annot.html?acc_id=${p.value}" >${p.key}</a></span>

                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>

                                                        </tr>
                                                    </c:forEach>
                                                </table>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                </td>
                                <td class="rangeOptionsColumn">
                                    <h4>Sex</h4>
                                    <table>
                                       <tr><td><input  type="checkbox"  class="rangesex" name="sex" value="Female"/>&nbsp;Female</td></tr>
                                        <tr><td><input type="checkbox" class="rangesex" name="sex" value="Male"/>&nbsp;Male</td></tr>
                                        <tr><td><input type="checkbox" class="rangesex" name="sex" value="Mixed"/>&nbsp;Mixed</td></tr>
                                     </table>
                                </td>
                                <td class="rangeOptionsColumn">
                                    <h4>Age</h4>
                                    <table>
                                        <tr><td><input type="checkbox" class="rangeage" name="age" value="0-79"/>&nbsp;0-79 days</td></tr>
                                        <tr><td><input type="checkbox" class="rangeage"  name="age" value="80-99"/>&nbsp;80-99 days</td></tr>
                                        <tr><td><input type="checkbox" class="rangeage" name="age" value="100-999"/>&nbsp;100-999</td></tr>
                                        <tr><td><input type="checkbox" class="rangeage"  name="age" value="0-999"/>&nbsp;Age All</td></tr>
                                    </table>
                                </td>
                                <td class="rangeOptionsColumn">
                                    <c:if test="${model.overAllMethods!=null && fn:length(model.overAllMethods)>0}">
                                        <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'erMethod')"/-->&nbsp;Methods(${fn:length(model.overAllMethods)})</h4>
                                        <table>
                                            <c:forEach items="${model.overAllMethods}" var="method">
                                                <tr><td><input type="checkbox"   class="form-check-input rangemethods" name="rangemethods" value="${fn:toLowerCase(method)}">&nbsp;&nbsp;${method}</td></tr>
                                            </c:forEach>
                                        </table>
                                    </c:if>
                                </td>
                                <td class="rangeOptionsColumn">
                                    <h4>Conditions</h4>

                                    <table>
                                        <tr><td><input type="checkbox"  class="form-check-input strainconditions" checked style="">&nbsp;&nbsp;Control Condition</td></tr>

                                    </table>
                                </td>
                            </tr>
                        </table>
                      </div>
                    </div>

                <div id="mainContent">
               <jsp:include page="rangeStrainContent.jsp"/>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="/common/footerarea.jsp"%>


