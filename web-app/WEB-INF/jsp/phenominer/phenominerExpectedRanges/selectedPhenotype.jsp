<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% String pageTitle = " Phenominer Expected Ranges - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%--@ include file="/common/headerarea.jsp"--%>
<%@ include file="rgdHeader.jsp"%>
<html>
<head>
<title>Phenominer Expected Ranges</title>

<script src="/rgdweb/js/expectedRanges/jquery.min.js"></script>

<!-- Bootstrap -->
<link href="/rgdweb/css/expectedRanges/bootstrap.min.css" rel="stylesheet">
    <!--link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet"-->
<script src="/rgdweb/js/expectedRanges/bootstrap.min.js"></script>
    <style>
        body{
            font-size: small;
            font-family: sans-serif;
        }
        #expectedRangesTable tbody tr td{
            font-size:small;

        }
        #expectedRangesTable thead tr th{
         /*   background-color: #24609c;
            color:white;*/
            font-size:small;
        }
    </style>
    <script>
        function optionsSubmit() {
            var erForm=  $('#erForm');
            var selectedStrains=   $('.erStrainGroup:checked').map(function () {
                return this.value;
            }).get().join(',');
            var selectedMethods=   $('.erMethod:checked').map(function () {
                return this.value;
            }).get().join(',');
            var selectedConditions=   $('.erCondtion:checked').map(function () {
                return this.value;
            }).get().join(',');

            var selectedAge=   $('.erAge:checked').map(function () {
                return this.value;
            }).get().join(',');
            var selectedSex=   $('.erSex:checked').map(function () {
                return this.value;
            }).get().join(',');
       //   alert( selectedMethods +"\n" + selectedConditions);
            $('#selectedStrains').val(selectedStrains);
            $("#selectedConditions").val(selectedConditions);
            $('#selectedMethods').val(selectedMethods);
            $('#selectedAge').val(selectedAge);
            $('#selectedSex').val(selectedSex);
        }

        function toggle(_this, groupClass){
            if(_this.checked){
                $('.'+groupClass).prop("checked", true);

            }

            else{
                $('.'+groupClass).prop("checked", false);
            }
        }
        $(function () {
           $("#erPhenotypesSelect").on('change', function () {
               var phenotype=this.value;
               $("#cmo").val(phenotype);
               $("#erPhenotypesSelectForm").submit();
           })
        })

    </script>
</head>
<body>

<div style="margin-left:90%;margin-top:1%"><a href="#"><span class="glyphicon glyphicon-chevron-left" style="font-size: large"></span><strong><a href="home.html">Home</a></strong></a></div>
<div class="container-fluid" style="background-color:#fafafa;margin-top:1%">
    <div class="container-fluid" >

        <div style="float:right;">Select Phenotype:
            <form id="erPhenotypesSelectForm" action="selectedPhenotype.html">
                <input type="hidden" id="cmo" name="cmo" value="">

            <select id="erPhenotypesSelect" class="form-control form-control-sm "  style="z-index: 999">
            <c:forEach items="${model.phenotypes}" var="item">
                ${model.phenotype}
                <c:choose>
                    <c:when test="${model.phenotype.equals(item.phenotype)}">
                        <option value="${item.clinicalMeasurementId}" selected>${item.phenotype}</option>
                    </c:when>
                    <c:otherwise>
                        <option value="${item.clinicalMeasurementId}">${item.phenotype}</option>
                    </c:otherwise>
                </c:choose>


            </c:forEach>

        </select>
            </form>
        </div>
        <h3 style="text-transform: capitalize">${model.phenotype} - Expected Ranges</h3>

        <div class="panel panel-default">

            <div class="panel-body">
                <form id="erForm" action="selectedStrain.html" method="post">

                    <input type="hidden" name="cmo" value="${model.phenotypeAccId}"/>
                    <input type="hidden" name="selectedStrains" id="selectedStrains" value="">
                    <input type="hidden" name="selectedConditions" id="selectedConditions" value="">
                    <input type="hidden" name="selectedMethods" id="selectedMethods" value="">
                    <input type="hidden" name="selectedAge" id="selectedAge" value="">
                    <input type="hidden" name="selectedSex" id="selectedSex" value="">
                   <input type="hidden" name="phenotypeObject" value="${model.phenotypeObject}"/>
                <table class="table" style="border: 1px solid white">
                    <caption style="background-color: #eeeeee;padding-left:10px;color:#24609c;font-weight: 100">Options</caption>
                    <tr>
                        <td style="border-right: 1px solid gainsboro">
                            <div style=";height:200px ;overflow: auto">
                                <table>
                                    <caption >Strains</caption>
                                    <c:if test="${model.newPhenotypeObject.ratStrainTerms==null}">
                                    <c:forEach items="${model.phenotypeObject.ratStrainTerms}" var="item">
                                        <tr><td><span style="font-size: 12px">${item.term}</span></td></tr>
                                    </c:forEach>
                                        </c:if>
                                    <c:if test="${model.newPhenotypeObject.ratStrainTerms!=null}">
                                        <c:forEach items="${model.newPhenotypeObject.ratStrainTerms}" var="item">
                                            <tr><td><span style="font-size: 12px">${item.term}</span></td></tr>
                                        </c:forEach>
                                    </c:if>
                                </table>
                            </div>
                        </td>
                        <td style="border-right: 1px solid gainsboro;">
                        <c:choose>
                        <c:when test="${model.newPhenotypeObject.strainGroupIdMap==null}">

                        <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erStrainGroup')" checked>&nbsp;Strain_Group:
                            </c:when>
                        <c:otherwise>
                            <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erStrainGroup')" >&nbsp;Strain_Group:
                        </c:otherwise>
                        </c:choose>
                            <div style="height:200px;column-count: 3; -webkit-column-count: 3; -moz-column-count: 3;overflow: auto">

                                <table>
                                    <c:choose>
                                        <c:when test="${model.newPhenotypeObject.strainGroupIdMap==null}">

                                             <c:forEach items="${model.phenotypeObject.strainGroupIdMap}" var="item">
                                                <c:if test="${model.selectedStrains!=null}">
                                                    <c:set var="selectedFlag" value="false"/>
                                                    <c:forEach items="${model.selectedStrains}" var="selected">
                                                        <c:if test="${selected==item.value}">
                                                     <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${item.value}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${item.key}</span></td></tr>
                                                            <c:set var="selectedFlag" value="true"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <c:if test="${selectedFlag=='false'}">
                                                        <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${item.value}" >&nbsp;&nbsp;<span style="font-size: 12px">${item.key}</span></td></tr>
                                                    </c:if>
                                                </c:if>
                                                 <c:if test="${model.selectedStrains==null}">
                                                     <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${item.value}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${item.key}</span></td></tr>
                                                 </c:if>
                                             </c:forEach>

                                         </c:when>
                                         <c:otherwise>

                                           <c:forEach items="${model.phenotypeObject.strainGroupIdMap}" var="item">
                                                 <c:set var="flag" value="false"/>
                                                 <c:forEach items="${model.newPhenotypeObject.strainGroupIdMap}" var="selected">
                                                    <c:if test="${item.value==selected.value}">
                                                       <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${item.value}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${item.key}</span></td></tr>
                                                        <c:set var="flag" value="true"/>
                                                      </c:if>
                                                 </c:forEach>
                                                 <c:if test="${flag=='false'}">
                                                     <c:set var="flag1" value="false"/>
                                                     <c:forEach items="${model.newPhenotypeObject.strainGroupIdMap}" var="selected">
                                                         <c:if test="${flag1=='false'}">
                                                         <c:if test="${item.value!=selected.value}">
                                                             <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${item.value}" >&nbsp;&nbsp;<span style="font-size: 12px">${item.key}</span></td></tr>
                                                             <c:set var="flag1" value="true"/>
                                                         </c:if>
                                                         </c:if>
                                                     </c:forEach>
                                                 </c:if>

                                            </c:forEach>

                                         </c:otherwise>
                                  </c:choose>
                                </table>
                        </div>
                        </td>

                        <td style="border-right: 1px solid  gainsboro">
                            <table>
                                <caption>Conditions</caption>
                                <tr>
                                   <td style="border-right: 1px solid gainsboro">
                                       <table>
                                           <tr><td><input type="checkbox" class="form-check-input erCondition"  checked >Control Condtion</td></tr>
                                       </table>

                                   </td>
                                    <td style="padding-left:10%">
                                        <table>

                                            <c:choose>
                                                <c:when test="${model.newPhenotypeObject.condtionTerms!=null}">
                                                    <c:forEach items="${model.newPhenotypeObject.condtionTerms}" var="condition">
                                                        <tr><td><span style="font-size: 12px">${condition.term}</span></td></tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach items="${model.phenotypeObject.condtionTerms}" var="condition">
                                                        <tr><td><span style="font-size: 12px">${condition.term}</span></td></tr>

                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>

                                        </table>
                                    </td>
                                </tr>
                            </table>




                        </td>
                        <c:if test="${model.phenotypeAccId!='CMO:0000072' && model.phenotypeAccId!='CMO:0000108' && model.phenotypeAccId!='CMO:0000075'
                        && model.phenotypeAccId!='CMO:0000074' && model.phenotypeAccId!='CMO:0000530' && model.phenotypeAccId!='CMO:0000071' && model.phenotypeAccId!='CMO:0000069'}">
                        <td style="border-right: 1px solid  gainsboro">
                            <table>
                                <caption>Methods</caption>

                                <tr>
                                    <td style="border-right: 1px solid gainsboro;padding-right:10px">
                                        <c:set value="false" var="vascular"/>
                                        <c:set value="false" var="tail"/>
                                        <c:set value="false" var="mixed"/>
                                        <table>
                                            <c:choose>
                                                <c:when test="${fn:length(model.selectedMethods)>0}">

                                                    <c:forEach items="${model.selectedMethods}" var="method">
                                                        <c:set var="methodLc" value="${fn:toLowerCase(method)}"/>
                                                        <c:if test="${methodLc.equals('vascular') && vascular=='false'}">
                                                            <c:set var="vascular" value="true"/>
                                                        </c:if>
                                                        <c:if test="${methodLc.equals('tail') && tail=='false'}">
                                                            <c:set var="tail" value="true"/>
                                                        </c:if>
                                                        <c:if test="${methodLc.contains('mixed') &&  mixed =='false'}">
                                                            <c:set var="mixed" value="true"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <c:choose>
                                                        <c:when test="${vascular=='true'}">
                                                            <tr><td><input type="checkbox" class="form-check-input erMethod" value="vascular" checked >&nbsp;&nbsp;Vascular </td></tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <tr><td><input type="checkbox" class="form-check-input erMethod" value="vascular" >&nbsp;&nbsp;Vascular </td></tr>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <c:choose>
                                                        <c:when test="${tail=='true'}">
                                                            <tr><td><input type="checkbox" class="form-check-input erMethod" value="tail" checked >&nbsp;&nbsp;Tail Cuff </td></tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <tr><td><input type="checkbox" class="form-check-input erMethod" value="tail" >&nbsp;&nbsp;Tail Cuff</td></tr>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:choose>
                                                        <c:when test="${mixed=='true'}">
                                                            <tr><td><input type="checkbox" class="form-check-input erMethod" value="mixed" checked >&nbsp;&nbsp;Mixed </td></tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <tr><td><input type="checkbox" class="form-check-input erMethod" value="mixed" >&nbsp;&nbsp;Mixed</td></tr>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr><td><input type="checkbox" class="form-check-input erMethod" value="vascular" checked >&nbsp;&nbsp;Vascular </td></tr>
                                                    <tr><td><input type="checkbox" class="form-check-input erMethod" value="tail" checked >&nbsp;&nbsp;Tail Cuff </td></tr>
                                                    <tr><td><input type="checkbox" class="form-check-input erMethod" value="mixed" checked >&nbsp;&nbsp;Mixed </td></tr>


                                                </c:otherwise>
                                            </c:choose>

                                        </table>

                                    </td>

                                </tr>
                            </table>

                        </td>
                        </c:if>
                        <td style="border-right: 1px solid gainsboro">

                            <table>

                                <c:if test="${model.selectedAge==null || fn:length(model.selectedAge)==0}">
                                    <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erAge')" checked>&nbsp;Age</caption>
                                    <c:forEach items="${model.age}" var="item">
                                        <tr><td><input type="checkbox" class="form-check-input erAge" name="age" value="${item}" checked/>&nbsp;&nbsp;<span style="font-size: 12px">${item} days</span></td></tr>
                                    </c:forEach>

                                </c:if>
                                <c:if test="${model.selectedAge!=null && fn:length(model.selectedAge)>0}">
                                    <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erAge')" >&nbsp;Age</caption>
                                    <c:forEach items="${model.age}" var="item">
                                        <c:set var="ageFlag" value="false"/>
                                        <c:forEach items="${model.selectedAge}" var="selected">

                                        <c:if test="${item==selected}">
                                        <tr><td><input type="checkbox" class="form-check-input erAge" name="age" value="${item}" checked/>&nbsp;&nbsp;<span style="font-size: 12px">${item} days</span></td></tr>
                                            <c:set var="ageFlag" value="true"/>
                                        </c:if>
                                        </c:forEach>

                                        <c:if test="${ageFlag=='false'}">
                                            <tr><td><input type="checkbox" class="form-check-input erAge" name="age" value="${item}" />&nbsp;&nbsp;<span style="font-size: 12px">${item} days</span></td></tr>
                                        </c:if>

                                    </c:forEach>
                                </c:if>
                            </table>
                           </td>
                        <td>
                            <table>

                             <c:if test="${model.selectedSex==null}">
                                 <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erSex')" checked>&nbsp;Sex</caption>

                                 <c:forEach items="${model.phenotypeObject.sex}" var="item">
                                     <tr><td><input type="checkbox" name="sex" class="form-check-input erSex" value="${item}" checked/>&nbsp;&nbsp;<span style="font-size: 12px">${item}</span></td></tr>
                                 </c:forEach>

                             </c:if>
                                <c:if test="${model.selectedSex!=null}">
                                    <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erSex')" >&nbsp;Sex</caption>
                                    <c:forEach items="${model.phenotypeObject.sex}" var="item">
                                        <c:set var="gFlag" value="false"/>
                                        <c:forEach items="${model.selectedSex}" var="selected">

                                            <c:if test="${item.equalsIgnoreCase(selected)}">
                                                <tr><td><input type="checkbox" name="sex" class="form-check-input erSex" value="${item}" checked/>&nbsp;&nbsp;<span style="font-size: 12px">${item}</span></td></tr>
                                                <c:set var="gFlag" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                            <c:if test="${gFlag=='false'}">
                                                <tr><td><input type="checkbox" name="sex" class="form-check-input erSex" value="${item}"/>&nbsp;&nbsp;<span style="font-size: 12px">${item}</span></td></tr>
                                            </c:if>


                                    </c:forEach>
                                </c:if>
                            </table>
                       </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><button type="submit" onclick="optionsSubmit()">Submit</button> </td>
                    </tr>
                </table>
                </form>

                </div>
            </div>

        <c:choose>
            <c:when test="${fn:length(model.records)>0}">

                <div class="panel panel-default">

                    <div class="panel-body">
                        <jsp:include page="plot.jsp"/>

                    </div>
                </div>
                <div class="panel panel-default" >

                    <div class="panel-body" >
                        <table class="table table-sm table-hover table-striped" id="expectedRangesTable">
                            <thead><tr><th>REC_ID</th><th>Strain Group</th><th>Measurement</th><th>Method</th><th>Sex</th><th>Age</th><th>Range Mean</th><th>Range SD</th><th>Range Low</th><th>Range High</th><th>Range Units</th></tr></thead>
                            <tbody>
                            <c:forEach items="${model.records}" var="item">
                                <c:if test="${!item.strainGroupName.contains('normal')}">
                                    <tr><td>${item.id}</td>
                                        <td>${item.strainGroupName}</td>
                                        <td>${item.clinicalMeasurement}</td>
                                        <td>
                                         <c:forEach items="${item.measurementMethodTerms}" var="m">
                                             <c:choose>
                                                 <c:when test="${m.equals('measurement method')}">
                                                    Mixed Methods
                                                 </c:when>
                                                 <c:otherwise>
                                                     ${m}<br> 
                                                 </c:otherwise>
                                             </c:choose>

                                         </c:forEach>
                                        </td>
                                        <td>${item.sex}</td>
                                        <td>${item.ageLowBound} - ${item.ageHighBound} days</td>
                                        <td>${item.groupValue}</td>
                                        <td>${item.groupSD}</td>
                                        <td>${item.groupLow}</td>
                                        <td>${item.groupHigh}</td>
                                        <td>${item.units}</td>
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

        </div>
    </div>
<%@ include file="/common/footerarea.jsp"%>
</body>
</html>

