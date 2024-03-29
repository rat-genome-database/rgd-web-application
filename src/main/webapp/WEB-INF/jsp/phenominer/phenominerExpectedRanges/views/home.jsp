<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% String pageTitle = " Phenominer Expected Ranges - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<!-- Bootstrap CSS CDN -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<!-- Our Custom CSS -->
<link href="/rgdweb/css/expectedRanges/range.css" type="text/css" rel="stylesheet">
<!-- Bootstrap Js CDN -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

<script>
    $(document).ready(function () {

        $('#sidebarCollapse').on('click', function () {
            $('#sidebar').toggleClass('active');
        });

    });
</script>
<script>

    $(function () {
        $('#phenotypeTab').addClass('active')
        $('#phenotypes').addClass('active')
        $('#strainTab').removeClass('active')
        $('#strains').removeClass('active')
    })
    function switchView(view) {
        if(view=='phenotypeTab'){
            $('#strainTab').removeClass('active')
            $('#strains').removeClass('active')
            $('#phenotypeTab').addClass('active')
            $('#phenotypes').addClass('active')
        }else{
            $('#strainTab').addClass('active')
            $('#strains').addClass('active')
            $('#phenotypeTab').removeClass('active')
            $('#phenotypes').removeClass('active')
        }
    }
</script>
<div class="wrapper1">

    <!-- Sidebar -->
    <nav id="sidebar">
        <!-- Sidebar Header -->
        <div class="sidebar-header">
            <h3>Trait Ontology</h3></div>

        <ul class="list-unstyled components">
            <li><a href="home.html">All Traits</a></li>
            <c:forEach items="${model.facets}" var="t">
                <!--li><a href="home.html?trait=$--{t.value}"><span style="text-transform: capitalize">$-{t.key}</span></a></li-->
                <li><a href="home.html?trait=${t.key.accId}"><span style="text-transform: capitalize">${t.key.term}(${t.value})</span></a></li>
            </c:forEach>
            <!--li><a href="home.html?trait=pga">PGA</a></li-->
        </ul>

    </nav>

    <!-- Page Content -->
    <div class="container" style="margin-left:0">


        <button type="button" id="sidebarCollapse" class="btn btn-info navbar-btn">
            <i class="glyphicon glyphicon-align-left"></i>

        </button>


            <h3>PhenoMiner Expected Ranges <c:if test="${model.trait!=null}"> - <span style="color:deepskyblue;text-transform: capitalize">${model.trait}</span></c:if></h3>
            <ul class="nav nav-tabs">
                <li class="nav-item"><a class="nav-link" href="#phenotypes" role="tab" data-toggle="tab" id="phenotypeTab"><strong>Phenotypes with Expected Ranges</strong></a></li>
                <li class="nav-item"><a class="nav-link" href="#strains" role="tab" data-toggle="tab" id="strainTab"><strong>Strains</strong></a></li>
            </ul>
            <div class="tab-content">
                <!----Phenotypes TAB--->
                <h4 style="color:green">Total number of phenotypes <c:if test="${model.trait!=null}">of  ${model.trait}:</c:if> ${model.objectsSize}</h4>
                <div class="tab-pane active" id="phenotypes">

                    <table class="table table-striped table-hover expectedRangesTable" >
                                <thead>
                                <tr><th>Trait</th><th>Phenotype</th><th>Normal Range</th><th>Strains with <br>Expected Ranges</th><th>Strains with <br>Expected Range <br>of Sex Specified Samples</th><th>Strains with <br>Expected Ranges <br>of Age Specified Samples</th></tr>

                                </thead>
                                <tbody>
                                <c:forEach items="${model.traitSubtraitMap}" var="item">
                                    <c:choose>
                                    <c:when test="${!model.traitOntId.equalsIgnoreCase('pga') && model.traitOntId!=null}">

                                        <c:if test="${!item.key.term.equals('pga')}">
                                        <tr><td colspan="7" style="background: lightskyblue;text-align: center" ><span style="text-transform: capitalize;font-weight: bold">${item.key.term}</span></td></tr>
                                        </c:if>
                                    </c:when>
                                        <c:otherwise>
                                            <tr><td colspan="7" style="background: lightskyblue;text-align: center" ><span style="text-transform: capitalize;font-weight: bold">${item.key.term}</span></td></tr>

                                        </c:otherwise>

                                    </c:choose>
                                    <c:forEach items="${item.value}" var="i">
                                        <c:choose>
                                        <c:when test="${fn:length(i.traits)>0}">
                                            <c:set var="traitExists" value="true"/>
                                        </c:when>
                                            <c:otherwise>
                                                <c:set var="traitExists" value="false"/>
                                            </c:otherwise>
                                        </c:choose>

                                        <tr>
                                            <td><span style="text-transform: capitalize">
                                                <c:forEach items="${i.traits}" var="t">
                                                    ${t.term}<br>

                                                </c:forEach>
                                            </span></td>
                                            <td><span style="text-transform: capitalize"><a href="selectedMeasurement.html?cmo=${i.clinicalMeasurementOntId}&trait=${model.traitOntId}&traitExists=${traitExists}" style="cursor: hand;color:#006dba" title="Click to view measurement data">${i.clinicalMeasurement}</a></span></td>
                                            <td style="width:20%"><span style="color:green;font-weight: bold" title="Normal Range">${i.normalRange}</span></td>
                                            <td>${i.strainSpecifiedRecordCount}</td>
                                            <td>${i.sexSpecifiedRecordCount}</td>
                                            <td>${i.ageSpecifiedRecordCount}</td>
                                        </tr>
                                    </c:forEach>
                              </c:forEach>
                            </tbody>
                            </table>


                </div>
                <!----Strains TAB--->
                <div class="tab-pane" id="strains">


                    <table class="table expectedRangesTable">
                        <thead>
                        <tr><th>Strain Group</th><th>Phenotypes</th></tr>

                        </thead>
                        <tbody>
                        <c:forEach items="${model.strainObjects}" var="item">
                            <tr><td><a href="strain.html?strainGroupId=${item.strainGroupId}&trait=${model.traitOntId}">${item.strainGroupName}</a></td><td>${fn:length(item.cmoAccIds)}</td></tr>
                        </c:forEach>
                        </tbody>
                    </table>

                </div>


            </div>

        </div>
</div>


    <%@ include file="/common/footerarea.jsp"%>
