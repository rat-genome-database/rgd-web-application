<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% String pageTitle = " Phenominer Expected Ranges - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%--@include file="/common/headerarea.jsp"--%>
<%@ include file="rgdHeader.jsp"%>

    <script src="/rgdweb/js/expectedRanges/jquery.min.js"></script>

    <!-- Bootstrap -->
    <link href="/rgdweb/css/expectedRanges/bootstrap.min.css" rel="stylesheet">
    <script src="/rgdweb/js/expectedRanges/bootstrap.min.js"></script>
    <script src="/rgdweb/js/expectedRanges/rangePhenotype.js"></script>
    <link href="/rgdweb/css/expectedRanges/range.css" type="text/css" rel="stylesheet">


<div class="container-fluid" style="background-color:#fafafa;margin-top:1%">
    <div class="container-fluid" >
        <div class="panel panel-default">
            <div class="panel-body " >
                <div style="float:right;background:linear-gradient(gainsboro, white);border:1px solid gainsboro; padding:5px"><strong><a href="home.html?trait=${model.traitOntId}">Back to all measurements</a></strong></div>
                <h3>Phenominer Expected Ranges</h3>
                <div style="width:40%;float:right;margin-right:10%;text-align: justify;border:1px solid gainsboro;padding:5px">
                 <strong>Analysis Description:</strong> Meta-analysis is the statistical procedure for combining data from multiple studies. When the treatment effect (or effect size) is consistent from one study to the next, meta-analysis can be used to identify this common effect. When the effect varies from one study to the next, meta-analysis may be used to identify the reason for the variation.
                </div>
                <div style="width:50%;">
                <table class="table" style="width:90%">
                <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Clinical Measurement</td><td>

          <c:set var="ranges" value="${model.records}"/>
            <form id="erPhenotypesSelectForm" action="selectedMeasurement.html">
                <input type="hidden" id="cmoId" name="cmoId" value="${model.cmo}">
                <input type="hidden" id="trait" name="trait" value="${model.traitOntId}">
                      <select id="erPhenotypesSelect" class="form-control form-control-sm " style="z-index: 999">
                    <c:forEach items="${model.phenotypes}" var="item">
                        <c:choose>
                            <c:when test="${model.phenotype.equals(item.clinicalMeasurement)}">
                                <option value="${item.clinicalMeasurementOntId}" selected>${item.clinicalMeasurement}</option>
                            </c:when>
                            <c:otherwise>
                                <option value="${item.clinicalMeasurementOntId}">${item.clinicalMeasurement}</option>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                </select>
            </form>

                </td></tr>
                 <c:if test="${model.trait!=null && model.trait!=''}"><tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c; ">Trait</td><td style="text-transform: capitalize">${model.trait}</td></c:if></tr>
                <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Strains</td><td>Inbred </td></tr>
                </table>

        </div>



        <!--h4 style="text-transform: capitalize;color:#24609c;">$--{model.phenotype} <!--c:if test="$-{model.trait!=null}"> - $-{model.trait}<!--/c:if> - Inbred Strains</h4-->


            <div class="optionsHeading"> <!--#9eb1ff;--><span>Options/Filters</span></div>
                <table class="table rangeOptionsTable" id="expectedRangeOptionsTable">
                        <!--caption style="background-color: #eeeeee;padding-left:10px;color:#24609c;font-weight: 100">Options/Filters</caption-->
                        <tr class="rangeOptionsRow">
                            <td class="rangeOptionsColumn" >

                                <h4> <!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypestrains')"/-->&nbsp;Strain_Groups(${fn:length(model.strainGroupMap)})</h4>
                              <c:choose>
                                  <c:when test="${fn:length(model.strainGroupMap)>6}">
                                      <div id="colm">
                                          <table>

                                              <c:forEach items="${model.strainGroupMap}" var="strain">
                                                  <tr><td><input type="checkbox" class="form-check-input phenotypestrains" name="phenotypestrains" value="${strain.value}" >&nbsp;&nbsp;${strain.key}</td></tr>
                                              </c:forEach>

                                          </table>
                                      </div>
                                  </c:when>
                                  <c:otherwise>
                                      <div>
                                          <table>

                                              <c:forEach items="${model.strainGroupMap}" var="strain">
                                                  <tr><td><input type="checkbox" class="form-check-input phenotypestrains" name="phenotypestrains" value="${strain.value}" >&nbsp;&nbsp;${strain.key}</td></tr>
                                              </c:forEach>

                                          </table>
                                      </div>
                                  </c:otherwise>
                              </c:choose>

                            </td>


                            <td  class="rangeOptionsColumn">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypeage')"/-->&nbsp;Age</h4>
                                <table>
                                  <tr><td><input type="checkbox"  class="form-check-input phenotypeage" name="phenotypeage" value="0-79">&nbsp;&nbsp;0-79 days</td></tr>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypeage" name="phenotypeage" value="80-99">&nbsp;&nbsp;80-99 days</td></tr>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypeage" name="phenotypeage" value="100-999">&nbsp;&nbsp;100-999 days</td></tr>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypeage" name="phenotypeage" value="0-999">&nbsp;&nbsp;0-999 days</td></tr>

                                </table>
                            </td>
                            <td class="rangeOptionsColumn">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypesex')"/-->&nbsp;Sex</h4>

                                <table>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypesex" name="phenotypesex" value="Female">&nbsp;&nbsp;Female</td></tr>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypesex" name="phenotypesex" value="Male">&nbsp;&nbsp;Male</td></tr>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypesex"  name="phenotypesex"value="Mixed">&nbsp;&nbsp;Mixed</td></tr>
                                 </table>
                            </td>
                            <td class="rangeOptionsColumn">
                                <c:if test="${model.overAllMethods!=null && fn:length(model.overAllMethods)>0}">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'erMethod')"/-->&nbsp;Methods(${fn:length(model.overAllMethods)})</h4>
                                <table>
                                    <c:forEach items="${model.overAllMethods}" var="method">
                                        <tr><td><input type="checkbox"   class="form-check-input phenotypemethods" name="phenotypemethods" value="${fn:toLowerCase(method)}">&nbsp;&nbsp;${method}</td></tr>
                                    </c:forEach>
                                </table>
                                </c:if>
                            </td>


                            <td class="rangeOptionsColumn">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypesex')"/-->&nbsp;Conditions</h4>

                                <table>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypeconditions" checked style="">&nbsp;&nbsp;Control Condition</td></tr>

                                </table>
                            </td>
                        </tr>

                    </table>



        <div id="mainContent">
            <jsp:include page="rangePhenotypeContent.jsp"/>
        </div>


    </div>
</div>
    </div>
</div>
<%@ include file="/common/footerarea.jsp"%>


