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
        #colm{
            height:200px;
            column-count: 3;
            -webkit-column-count: 3;
            -moz-column-count: 3;
            overflow: auto
        }
        #expectedRangesTable tbody tr td{
            font-size:small;

        }
        #expectedRangesTable thead tr th{
            /*   background-color: #24609c;
               color:white;*/
            font-size:small;
        }
        #expectedRangeOptionsTable tr td{
            font-size:12px;
        }
        #expectedRangesTable tr:hover{
            background-color: #daeffc;
        }

    </style>
    <script>
        function optionsSubmit() {
            var erForm=  $('#erPhenotypesSelectForm');
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
                $("#cmoId").val(phenotype);
                $("#erPhenotypesSelectForm").submit();
            })
        })

    </script>
</head>
<body>

<div style="margin-left:90%;margin-top:1%"><a href="#"><span class="glyphicon glyphicon-chevron-left" style="font-size: large"></span><strong><a href="home.html">Home</a></strong></a></div>
<div class="container-fluid" style="background-color:#fafafa;margin-top:1%">
    <div class="container-fluid" >
        <c:set var="ranges" value=""/>
        <c:choose>
            <c:when test="${model.newPhenotypeObject1!=null }">
                <c:set var="ranges" value="${model.newPhenotypeObject1.ranges}"/>
            </c:when>
            <c:otherwise>
                <c:set var="ranges" value="${model.phenotypeObject1.ranges}"/>
            </c:otherwise>
        </c:choose>

        <div style="float:right;">Select Phenotype:
            <form id="erPhenotypesSelectForm" action="selectedMeasurement.html">
                <input type="hidden" id="cmoId" name="cmoId" value="">
                <select id="erPhenotypesSelect" class="form-control form-control-sm "  style="z-index: 999">
                    <c:forEach items="${model.phenotypes}" var="item">
                        <c:choose>
                            <c:when test="${model.phenotypeObject1.clinicalMeasurement.equals(item.clinicalMeasurement)}">
                                <option value="${item.clinicalMeasurementOntId}" selected>${item.clinicalMeasurement}</option>
                            </c:when>
                            <c:otherwise>
                                <option value="${item.clinicalMeasurementOntId}">${item.clinicalMeasurement}</option>
                            </c:otherwise>
                        </c:choose>


                    </c:forEach>

                </select>
            </form>
        </div>
        <h3>${model.phenotype} - Expected Ranges</h3>

        <div class="panel panel-default">

            <div class="panel-body">
                <form id="erForm" action="selectedOptions.html" method="post">

                    <input type="hidden" name="cmo" value="${model.phenotypeObject1.clinicalMeasurementOntId}"/>
                    <input type="hidden" name="selectedStrains" id="selectedStrains" value="">
                    <input type="hidden" name="selectedConditions" id="selectedConditions" value="">
                    <input type="hidden" name="selectedMethods" id="selectedMethods" value="">
                    <input type="hidden" name="selectedAge" id="selectedAge" value="">
                    <input type="hidden" name="selectedSex" id="selectedSex" value="">
                    <input type="hidden" name="phenotypeObject1" value="${model.phenotypeObject1}"/>
                    <table class="table" id="expectedRangeOptionsTable" style="border: 1px solid white">
                        <caption style="background-color: #eeeeee;padding-left:10px;color:#24609c;font-weight: 100">Options</caption>
                        <tr>
                            <td style="border-right: 1px solid gainsboro;">

                                <h4> <input class="form-check-input" type="checkbox" onclick="toggle(this, 'erStrainGroup')" checked/>&nbsp;Strain_Groups(${fn:length(model.phenotypeObject1.strainGroupMap)})</h4>
                                <div id="colm">
                                    <c:choose>
                                    <c:when test="${model.newPhenotypeObject1==null}">
                                    <table>

                                        <c:forEach items="${model.phenotypeObject1.strainGroupMap}" var="strain">
                                            <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${strain.value}" checked>&nbsp;&nbsp;${strain.key}</td></tr>
                                        </c:forEach>

                                    </table>
                                    </c:when>
                                    <c:otherwise>
                                    <c:forEach items="${model.phenotypeObject1.strainGroupMap}" var="strain">
                                        <c:set var="selected" value="false"/>
                                    <c:forEach items="${model.newPhenotypeObject1.strainGroupMap}" var="s">
                                    <c:if test="${s.key.equal(strain.key)}">
                                        <c:set var="selected" value="true"/>
                                    </c:if>
                                    </c:forEach>
                                    <c:choose>
                                    <c:when test="${selected=='true'}">
                        <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${strain.value}" checked>&nbsp;&nbsp;${strain.key}</td></tr>
                        </c:when>
                        <c:otherwise>
                        <tr><td><input type="checkbox" class="form-check-input erStrainGroup" value="${strain.value}">&nbsp;&nbsp;${strain.key}</td></tr>
                        </c:otherwise>
                        </c:choose>

                        </c:forEach>
                        </c:otherwise>
                        </c:choose>

            </div>

            </td>

            <td style="border-right: 1px solid  gainsboro">
                <h4><input class="form-check-input" type="checkbox" onclick="toggle(this, 'erCondition')" checked/>&nbsp;Conditions(${fn:length(model.phenotypeObject1.overAllConditions)})</h4>
                <table>

                    <c:forEach items="${model.phenotypeObject1.overAllConditions}" var="condition">
                        <tr><td><input type="checkbox"  class="form-check-input erCondition"  checked>&nbsp;&nbsp;${condition}</td></tr>
                    </c:forEach>
                </table>
            </td>
            <c:if test="${model.phenotypeObject1.overAllMethods!=null}">
                <td style="border-right: 1px solid  gainsboro">
                    <h4><input class="form-check-input" type="checkbox" onclick="toggle(this, 'erMethod')" checked/>&nbsp;Methods(${fn:length(model.phenotypeObject1.overAllMethods)})</h4>
                    <table>
                        <c:forEach items="${model.phenotypeObject1.overAllMethods}" var="method">
                            <tr><td><input type="checkbox"  class="form-check-input erMethod" value="${fn:toLowerCase(method)}" checked>&nbsp;&nbsp;${method}</td></tr>
                        </c:forEach>
                    </table>
                </td>
            </c:if>
            <td style="border-right: 1px solid gainsboro">
                <h4><input class="form-check-input" type="checkbox" onclick="toggle(this, 'erAge')" checked/>&nbsp;Age</h4>
                <table>


                    <c:forEach items="${model.phenotypeObject1.age}" var="age">
                        <tr><td><input type="checkbox"  class="form-check-input erAge" value="${age}" checked>&nbsp;&nbsp;${age}</td></tr>
                    </c:forEach>
                </table>
            </td>
            <td>
                <h4><input class="form-check-input" type="checkbox" onclick="toggle(this, 'erSex')" checked/>&nbsp;Sex</h4>

                <table>

                    <c:forEach items="${model.phenotypeObject1.sex}" var="sex">
                        <tr><td><input type="checkbox"  class="form-check-input erSex" value="${sex}" checked>&nbsp;&nbsp;${sex}</td></tr>
                    </c:forEach>
                </table>
            </td>
            </tr>
            <tr>

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
        <c:when test="${fn:length(ranges)>0}">

            <div class="panel panel-default">

                <div class="panel-body">
                    <jsp:include page="plot.jsp"/>

                </div>
            </div>
            <div class="panel panel-default" >

                <div class="panel-body" >
                    <table class="table table-sm table-hover table-striped" id="expectedRangesTable">
                        <thead><tr><th>RANGE_ID</th><th>Strain Group</th><th>Strains</th><th>Measurement</th><th>Method</th><th>Conditions</th><th>Sex</th><th>Age</th><th>Range Mean</th><th>Range SD</th><th>Range Low</th><th>Range High</th><th>Phenominer</th></tr></thead>
                        <tbody>
                        <c:forEach items="${ranges}" var="item">
                            <!--c:if test="$--{!item.strainGroupName.contains('normal')}"-->
                            <c:set var="href" value="http://pipelines.rgd.mcw.edu/rgdweb/phenominer/table.html?species=3&terms="/>
                            <tr><td>${item.expectedRangeId}</td>
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
                                        <c:set var="href" value="${href}${s.getAccId()},"/>
                                        <a href="/rgdweb/ontology/annot.html?acc_id=${s.getAccId()}">${s.getTerm()}</a><br>
                                    </c:forEach>

                                </td>
                                <td>
                                    <c:set var="href" value="${href}${model.phenotypeObject1.clinicalMeasurementOntId},"/>
                                    <a href="/rgdweb/ontology/annot.html?acc_id=${model.phenotypeObject1.clinicalMeasurementOntId}">${item.clinicalMeasurement}</a></td>
                                <td>
                                    <c:forEach items="${item.methods}" var="m">
                                        <c:set var="href" value="${href}${m.getAccId()},"/>
                                        <a href="/rgdweb/ontology/annot.html?acc_id=${m.getAccId()}">${m.getTerm()}</a><br>
                                    </c:forEach>
                                </td>
                                <td>
                                    <c:forEach items="${item.conditions}" var="c">
                                        <c:set var="href" value="${href}${c.getAccId()},"/>
                                        <a href="/rgdweb/ontology/annot.html?acc_id=${c.getAccId()}">${c.getTerm()}</a><br>
                                    </c:forEach>
                                </td>
                                <td>${item.sex}</td>
                                <td>${item.ageLowBound} - ${item.ageHighBound} days</td>
                                <td>${item.rangeValue}</td>
                                <td>${item.rangeSD}</td>
                                <td>${item.rangeLow}</td>
                                <td>${item.rangeHigh}</td>
                                <td><a href="${href}" target="_blank"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                            </tr>
                            <!--/c:if-->
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

