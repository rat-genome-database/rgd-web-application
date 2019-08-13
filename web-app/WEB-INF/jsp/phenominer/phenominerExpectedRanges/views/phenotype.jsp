<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
            <div class="panel-body">
                <div style="float:right;background:linear-gradient(gainsboro, white);border:1px solid gainsboro; padding:5px"><strong><a href="home.html?trait=${model.traitOntId}">Back to all measurements</a></strong></div>
                <h3>PhenoMiner Expected Ranges</h3>
                    <div style="width:40%;float:right;margin-right:10%;text-align: justify;border:1px solid gainsboro;padding:5px">
                     <strong>Analysis Description:</strong>
                        PhenoMiner's Expected Ranges result from a statistical meta-analysis of PhenoMiner data.  For each rat strain where four or more experiments exist for a single clinical measurement, a meta-analysis is performed using either a random- or fixed-effect model, based on the level of heterogeneity."Zhao et al, in preparation"

                    </div>
                    <div style="width:50%;">
                    <table class="table" style="width:90%">
                    <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Clinical Measurement</td><td>

                      <c:set var="ranges" value="${model.records}"/>
                        <form id="erPhenotypesSelectForm" action="selectedMeasurement.html">
                            <input type="hidden" id="cmoId" name="cmo" value="${model.cmo}">
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
                    </td>
                    </tr>
                        <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Ontology Id</td><td>${model.cmo}</td></tr>
                        <tr><c:if test="${model.trait!=null && model.trait!=''}"><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c; ">Trait</td>
                            <td style="text-transform: capitalize">${model.trait}</td> </c:if></tr>


                    <tr><td style="background-color: #f2f2f2;font-weight: bold;color: #24609c;">Strains</td><td>Inbred </td></tr>
                    </table>

                 </div>

                <div class="optionsHeading"> <!--#9eb1ff;--><span>Options/Filters     Hello ${model.strainGroupMap}</span></div>

                <div>
                    <form id="er-options-form" method="post">
                        <input type="hidden"  name="cmo" value="${model.cmo}">
                        <input type="hidden"  name="trait" value="${model.traitOntId}">
                        <input type="hidden" id="phenotypestrains" name="phenotypestrains" value=""/>
                        <input type="hidden" id="phenotypeage" name="phenotypeage" value=""/>
                        <input type="hidden" id="phenotypesex" name="phenotypesex" value=""/>
                        <input type="hidden" id="phenotypemethods" name="phenotypemethods" value=""/>
                        <input type="hidden" name="options" value="true"/>
                        <input type="hidden" name="traitExists" value="true"/>


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
                                                  <c:set var="selected" value="false"/>
                                                <c:forEach items="${model.selectedStrains}" var="selStrain">
                                                     <c:if test="${selStrain==strain.value}">
                                                          <tr><td><input type="checkbox" class="form-check-input phenotypestrains er-options-checkbox"  value="${strain.value}" checked>&nbsp;&nbsp;${strain.key}</td></tr>
                                                          <c:set var="selected" value="true"/>
                                                      </c:if>
                                                 </c:forEach>
                                                  <c:if test="${selected=='false'}">

                                                          <tr><td><input type="checkbox" class="form-check-input phenotypestrains er-options-checkbox"  value="${strain.value}" >&nbsp;&nbsp;${strain.key}</td></tr>

                                                  </c:if>
                                              </c:forEach>
                                          </table>
                                      </div>
                                  </c:when>
                                  <c:otherwise>
                                      <div>
                                          <table>

                                              <c:forEach items="${model.strainGroupMap}" var="strain">
                                              <c:set var="selected" value="false"/>
                                              <c:forEach items="${model.selectedStrains}" var="selStrain">
                                                  <c:if test="${selStrain==strain.value}">
                                                  <tr><td><input type="checkbox" class="form-check-input phenotypestrains er-options-checkbox"  value="${strain.value}" checked>&nbsp;&nbsp;${strain.key}</td></tr>
                                                      <c:set var="selected" value="true"/>
                                                  </c:if>
                                              </c:forEach>
                                                  <c:if test="${selected=='false'}">

                                                      <tr><td><input type="checkbox" class="form-check-input phenotypestrains er-options-checkbox"  value="${strain.value}" >&nbsp;&nbsp;${strain.key}</td></tr>

                                                  </c:if>
                                              </c:forEach>

                                          </table>
                                      </div>
                                  </c:otherwise>
                              </c:choose>

                            </td>


                            <td  class="rangeOptionsColumn">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypeage')"/-->&nbsp;Age</h4>
                                <table>
                                  <tr><td>
                                      <c:set var="selected0to79" value="false"/>
                                      <c:forEach items="${model.selectedAge}" var="age1">
                                          <c:if test="${age1=='0-79'}">
                                            <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="0-79" checked>&nbsp;&nbsp;0-79 days
                                              <c:set var="selected0to79" value="true"/>
                                          </c:if>
                                      </c:forEach>
                                      <c:if test="${selected0to79=='false'}">
                                      <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="0-79">&nbsp;&nbsp;0-79 days
                                      </c:if>

                                   </td></tr>
                                    <tr><td>
                                        <c:set var="selected80to99" value="false"/>
                                        <c:forEach items="${model.selectedAge}" var="age2">
                                        <c:if test="${age2=='80-99'}">
                                            <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="80-99" checked>&nbsp;&nbsp;80-99 days
                                    <c:set var="selected80to99" value="true"/>
                                    </c:if>
                                    </c:forEach>
                                    <c:if test="${selected80to99=='false'}">
                                        <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="80-99">&nbsp;&nbsp;80-99 days
                                    </c:if>



                                    </td></tr>
                                    <tr><td>

                                        <c:set var="selected100to998" value="false"/>
                                        <c:forEach items="${model.selectedAge}" var="age3">
                                            <c:if test="${age3=='100-998'}">
                                                <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="100-998" checked>&nbsp;&nbsp;100-998 days
                                                <c:set var="selected100to998" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${selected100to998=='false'}">
                                            <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="100-998">&nbsp;&nbsp;100-998 days
                                        </c:if>

                                     </td></tr>
                                    <tr><td>
                                        <c:set var="selected0to999" value="false"/>
                                        <c:forEach items="${model.selectedAge}" var="age4">
                                            <c:if test="${age4=='0-999'}">
                                                <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="0-999" checked>&nbsp;&nbsp;0-999 days

                                                <c:set var="selected0to999" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${selected0to999=='false'}">
                                            <input type="checkbox"  class="form-check-input phenotypeage er-options-checkbox"  value="0-999">&nbsp;&nbsp;0-999 days

                                        </c:if>
                                    </td></tr>

                                </table>
                            </td>
                            <td class="rangeOptionsColumn">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypesex')"/-->&nbsp;Sex</h4>

                                <table>
                                    <tr><td>
                                        <c:set var="selectedFemale" value="false"/>
                                        <c:forEach items="${model.selectedSex}" var="sex1">
                                            <c:if test="${sex1=='Female'}">
                                                <input type="checkbox"  class="form-check-input phenotypesex er-options-checkbox" value="Female" checked>&nbsp;&nbsp;Female

                                                <c:set var="selectedFemale" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${selectedFemale=='false'}">
                                            <input type="checkbox"  class="form-check-input phenotypesex er-options-checkbox"  value="Female">&nbsp;&nbsp;Female

                                        </c:if>


                                    </td></tr>
                                    <tr>
                                        <td>
                                            <c:set var="selectedMale" value="false"/>
                                            <c:forEach items="${model.selectedSex}" var="sex2">
                                                <c:if test="${sex2=='Male'}">
                                                    <input type="checkbox"  class="form-check-input phenotypesex er-options-checkbox"  value="Male" checked>&nbsp;&nbsp;Male

                                                    <c:set var="selectedMale" value="true"/>
                                                </c:if>
                                            </c:forEach>
                                            <c:if test="${selectedMale=='false'}">
                                                <input type="checkbox"  class="form-check-input phenotypesex er-options-checkbox"  value="Male">&nbsp;&nbsp;Male

                                            </c:if>



                                        </td></tr>
                                    <tr><td>
                                        <c:set var="selectedMixed" value="false"/>
                                        <c:forEach items="${model.selectedSex}" var="sex3">
                                            <c:if test="${sex3=='Mixed'}">
                                                <input type="checkbox"  class="form-check-input phenotypesex er-options-checkbox"  value="Mixed" checked>&nbsp;&nbsp;Mixed
                                                <c:set var="selecteMixed" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${selectedMixed=='false'}">
                                            <input type="checkbox"  class="form-check-input phenotypesex er-options-checkbox"  value="Mixed">&nbsp;&nbsp;Mixed

                                        </c:if>




                                    </td></tr>
                                 </table>
                            </td>
                            <td class="rangeOptionsColumn">
                                <c:if test="${model.overAllMethods!=null && fn:length(model.overAllMethods)>0}">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'erMethod')"/-->&nbsp;Methods(${fn:length(model.overAllMethods)})</h4>
                                <table>

                                    <c:forEach items="${model.overAllMethods}" var="method">
                                        <c:set var="selectedMethod" value="false"/>
                                        <c:forEach items="${model. selectedMethods}" var="selMethod">
                                            <c:if test="${selMethod==fn:toLowerCase(method)}">
                                                <tr><td><input type="checkbox"   class="form-check-input phenotypemethods er-options-checkbox"  value="${fn:toLowerCase(method)}" checked>&nbsp;&nbsp;${method}</td></tr>
                                                <c:set var="selectedMethod" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${selectedMethod=='false'}">

                                            <tr><td><input type="checkbox"   class="form-check-input phenotypemethods er-options-checkbox"  value="${fn:toLowerCase(method)}">&nbsp;&nbsp;${method}</td></tr>

                                        </c:if>
                                    </c:forEach>

                                </table>
                                </c:if>
                            </td>


                            <td class="rangeOptionsColumn">
                                <h4><!--input class="form-check-input" type="checkbox" onclick="toggle(this, 'phenotypesex')"/-->&nbsp;Conditions</h4>

                                <table>
                                    <tr><td><input type="checkbox"  class="form-check-input phenotypeconditions er-options-checkbox" checked style="">&nbsp;&nbsp;Control Condition</td></tr>

                                </table>
                            </td>
                        </tr>

                    </table>
                    </form>
                </div>

                <div id="mainContent">
                    <jsp:include page="rangePhenotypeContent.jsp"/>
                </div>


           </div>
        </div>
     </div>
    <input type="hidden" name="normalRange" value="${model.normalRange}"/>
</div>
<%@ include file="/common/footerarea.jsp"%>


