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
            // alert(selectedStrains +"\n"+ selectedMethods +"\n" + selectedConditions);
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
        <h3>${model.phenotype} - Expected Ranges</h3>

        <div class="panel panel-default">

            <div class="panel-body">
                <form id="erForm" action="selectedStrain.html" method="post">

                    <input type="hidden" name="cmo" value="${model.phenotypeAccId}"/>
                    <input type="hidden" name="selectedStrains" id="selectedStrains" value="">
                    <input type="hidden" name="selectedConditions" id="selectedConditions" value="">
                    <input type="hidden" name="selectedMethods" id="selectedMethods" value="">
                    <input type="hidden" name="selectedAge" id="selectedAge" value="">
                    <input type="hidden" name="selectedSex" id="selectedSex" value="">
                    <input type="hidden" name="phenotypeObject1" value="${model.phenotypeObject1}"/>
                    <table class="table" style="border: 1px solid white">
                        <caption style="background-color: #eeeeee;padding-left:10px;color:#24609c;font-weight: 100">Options</caption>
                        <tr>
                            <td style="border-right: 1px solid gainsboro">
                                <div style=";height:200px ;overflow: auto">
                                    <table>
                                        <caption >Strains</caption>
                                        <c:if test="${model.newPhenotypeObject1.ratStrainTerms==null}">
                                            <c:forEach items="${model.phenotypeObject1.ratStrainTerms}" var="item">
                                                <tr><td><span style="font-size: 12px">${item.term}</span></td></tr>
                                            </c:forEach>
                                        </c:if>
                                        <c:if test="${model.newPhenotypeObject1.ratStrainTerms!=null}">
                                            <c:forEach items="${model.newPhenotypeObject1.ratStrainTerms}" var="item">
                                                <tr><td><span style="font-size: 12px">${item.term}</span></td></tr>
                                            </c:forEach>
                                        </c:if>
                                    </table>
                                </div>
                            </td>
                            <td style="border-right: 1px solid gainsboro;">
                                <c:choose>
                                    <c:when test="${model.newPhenotypeObject1.strainGroupIdMap==null}">

                                        <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erStrainGroup')" checked>&nbsp;Strain_Group:
                                    </c:when>
                                    <c:otherwise>
                                        <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erStrainGroup')" >&nbsp;Strain_Group:
                                    </c:otherwise>
                                </c:choose>
                                <div style="height:200px;column-count: 3; -webkit-column-count: 3; -moz-column-count: 3;overflow: auto">

                                    <table>
                                        <c:choose>
                                            <c:when test="${model.newPhenotypeObject1.strainGroupIdMap==null}">

                                                <c:forEach items="${model.phenotypeObject1.strainGroupIdMap}" var="item">
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

                                                <c:forEach items="${model.phenotypeObject1.strainGroupIdMap}" var="item">
                                                    <c:set var="flag" value="false"/>
                                                    <c:forEach items="${model.newPhenotypeObject1.strainGroupIdMap}" var="selected">
                                                        <c:if test="${item.value==selected.value}">
                                                            <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${item.value}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${item.key}</span></td></tr>
                                                            <c:set var="flag" value="true"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <c:if test="${flag=='false'}">
                                                        <c:set var="flag1" value="false"/>
                                                        <c:forEach items="${model.newPhenotypeObject1.strainGroupIdMap}" var="selected">
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

                                    <c:choose>
                                        <c:when test="${model.newPhenotypeObject1.condtionTerms==null}">
                                            <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erCondition')" checked>&nbsp;Conditions</caption>

                                            <c:forEach items="${model.phenotypeObject1.condtionTerms}" var="condition">
                                                <c:if test="${model.selectedConditions!=null}">
                                                    <c:set var="selectedCondition" value="false"/>
                                                    <c:forEach items="${model.selectedConditions}" var="selected">

                                                        <c:if test="${selected==condition.accId}">

                                                            <tr><td><input type="checkbox" class="form-check-input erCondition" value="${condition.accId}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${condition.term}</span></td></tr>
                                                            <c:set var="selectedCondition" value="true"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <c:if test="${selectedCondition=='false'}">
                                                        <tr><td><input type="checkbox" class="form-check-input erCondition" value="${condition.accId}" >&nbsp;&nbsp;<span style="font-size: 12px">${condition.term}</span></td></tr>
                                                    </c:if>

                                                </c:if>
                                                <c:if test="${model.selectedConditions==null}">
                                                    <tr><td><input type="checkbox" class="form-check-input erCondition" value="${condition.accId}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${condition.term}</span></td></tr>
                                                </c:if>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erCondition')">&nbsp;Conditions</caption>
                                            <c:forEach items="${model.phenotypeObject1.condtionTerms}" var="condition">
                                                <c:set var="cFlag" value="false"/>
                                                <c:forEach items="${model.newPhenotypeObject1.condtionTerms}" var="selected">
                                                    <c:if test="${condition.accId==selected.accId}">
                                                        <tr><td><input type="checkbox" class="form-check-input erCondition" value="${condition.accId}" checked >&nbsp;&nbsp;<span style="font-size: 12px">${condition.term}</span></td></tr>
                                                        <c:set var="cFlag" value="true"/>
                                                    </c:if>
                                                </c:forEach>
                                                <c:if test="${cFlag=='false'}">
                                                    <tr><td><input type="checkbox" class="form-check-input erCondition" value="${condition.accId}" >&nbsp;&nbsp;<span style="font-size: 12px">${condition.term}</span></td></tr>
                                                </c:if>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>

                                </table>


                            </td>
                            <td style="border-right: 1px solid  gainsboro">
                                <table>

                                    <c:if test="${model.newPhenotypeObject1.methodTerms==null}">
                                        <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erMethod')" checked>&nbsp;Methods</caption>
                                        <c:forEach items="${model.phenotypeObject1.methodTerms}" var="method">
                                            <c:if test="${model.selectedMethods!=null}">
                                                <c:set var="selectedMethod" value="false"/>
                                                <c:forEach items="${model.selectedMethods}" var="selected">
                                                    <c:if test="${selected==method.accId}">
                                                        <tr><td><input type="checkbox" class="form-check-input erMethod" value="${method.accId}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${method.term}</span></td></tr>
                                                        <c:set var="selectedMethod" value="true"/>
                                                    </c:if>
                                                </c:forEach>
                                                <c:if test="${selectedMethod=='false'}">
                                                    <tr><td><input type="checkbox" class="form-check-input erMethod" value="${method.accId}" >&nbsp;&nbsp;<span style="font-size: 12px">${method.term}</span></td></tr>
                                                </c:if>

                                            </c:if>
                                            <c:if test="${model.selectedMethods==null}">
                                                <tr><td><input type="checkbox" class="form-check-input erMethod" value="${method.accId}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${method.term}</span></td></tr>
                                            </c:if>

                                        </c:forEach>
                                    </c:if>
                                    <c:if test="${model.newPhenotypeObject1.methodTerms!=null}">
                                        <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erMethod')">&nbsp;Methods</caption>

                                        <c:forEach items="${model.phenotypeObject1.methodTerms}" var="method">
                                            <c:set var="mflag" value="false"/>
                                            <c:forEach items="${model.newPhenotypeObject1.methodTerms}" var="selected">
                                                <c:if test="${selected.accId==method.accId}">
                                                    <tr><td><input type="checkbox" class="form-check-input erMethod" value="${method.accId}" checked>&nbsp;&nbsp;<span style="font-size: 12px">${method.term}</span></td></tr>
                                                    <c:set var="mflag" value="true"/>
                                                </c:if>
                                            </c:forEach>
                                            <c:if test="${mflag=='false'}">
                                                <tr><td><input type="checkbox" class="form-check-input erMethod" value="${method.accId}" >&nbsp;&nbsp;<span style="font-size: 12px">${method.term}</span></td></tr>
                                            </c:if>


                                        </c:forEach>
                                    </c:if>
                                </table>



                            </td>
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

                                        <c:forEach items="${model.phenotypeObject1.sex}" var="item">
                                            <tr><td><input type="checkbox" name="sex" class="form-check-input erSex" value="${item}" checked/>&nbsp;&nbsp;<span style="font-size: 12px">${item}</span></td></tr>
                                        </c:forEach>

                                    </c:if>
                                    <c:if test="${model.selectedSex!=null}">
                                        <caption> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erSex')" >&nbsp;Sex</caption>
                                        <c:forEach items="${model.phenotypeObject1.sex}" var="item">
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
                            <thead><tr><th>REC_ID</th><th>Strain Group</th><th>Measurement</th><th>Method</th><th>Sex</th><th>Age</th><th>Range Mean</th><th>Range SD</th><th>Range Low</th><th>Range High</th></tr></thead>
                            <tbody>
                            <c:forEach items="${model.records}" var="item">
                                <c:if test="${!item.strainGroupName.contains('normal')}">
                                    <tr><td>${item.id}</td>
                                        <td>${item.strainGroupName}</td>
                                        <td>${item.clinicalMeasurement}</td>
                                        <td></td>
                                        <td>${item.sex}</td>
                                        <td>${item.ageLowBound} - ${item.ageHighBound} days</td>
                                        <td>${item.groupValue}</td>
                                        <td>${item.groupSD}</td>
                                        <td>${item.groupLow}</td>
                                        <td>${item.groupHigh}</td>
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

