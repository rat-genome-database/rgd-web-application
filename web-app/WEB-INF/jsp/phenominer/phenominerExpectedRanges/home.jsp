<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% String pageTitle = " Phenominer Expected Ranges - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<script src="/rgdweb/js/expectedRanges/jquery.min.js"></script>

<!-- Bootstrap -->
<link href="/rgdweb/css/expectedRanges/bootstrap.min.css" rel="stylesheet">
<script src="/rgdweb/js/expectedRanges/bootstrap.min.js"></script>
<style>
    #erHomePhenotypeTable tr th{
        font-size:small;
        text-align: center;
    }
</style>
<div class="container-fluid" style="background-color:#fafafa;">
    <div class="container" >
        <div style="float:right;">
            <label>Select Trait </label>
                <select class="form-control form-control-sm" id="traits">
                    <c:forEach items="${model.traitMap}" var="item">
                        <c:choose>
                            <c:when test="${item.key=='circulatory system trait'}">
                                <option value="${item.value}" selected>${item.key}</option>
                            </c:when>
                            <c:otherwise>
                                <option value="${item.value}">${item.key}</option>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </select>
           </div>
        <h3>Phenominer Expected Ranges</h3>
        <ul class="nav nav-tabs">
            <li class="active"><a href="#phenotypes" role="tab" data-toggle="tab"><strong>Phenotypes with Expected Ranges</strong></a></li>
            <li><a href="#strains" role="tab" data-toggle="tab"><strong>Strains</strong></a></li>
        </ul>
        <div class="tab-content">
            <!----Phenotypes TAB--->
            <div class="tab-pane active" id="phenotypes">
        <div class="panel panel-default">

            <div class="panel-body">
                <table class="table table-striped table-hover" id="erHomePhenotypeTable">
                    <thead>
                    <tr><th>Phenotype</th><th>Normal Range</th><th>No. of Strains with <br>Expected Ranges Records</th><th>No. of Strains with <br>Expected Range Records <br>of Sex Specified Samples</th><th>No. of Strains With <br>Expected Range Records <br>of Age Specified Samples</th></tr>

                    </thead>
                    <tbody>
                    <c:forEach items="${model.counts}" var="item">
                        <tr>
                            <td><a href="selectedPhenotype.html?cmo=${item.clinicalMeasurementId}"><span style="text-transform: capitalize">${item.phenotype}</span></a></td>
                            <td>${item.overall}</td>
                            <td style="text-align: center">${item.recordsCountByStrain}</td>
                            <td style="text-align: center">${item.recordsCountBySex}</td>
                            <td style="text-align: center">${item.recordsCountByAge}</td>
                        </tr>
                    </c:forEach>
                   </tbody>
                </table>
            </div>
        </div>
            </div>
            <!----Strains TAB--->
            <div class="tab-pane" id="strains">
                <div class="panel panel-default">

                    <div class="panel-body">
                        <!--h4>Data will be added soon...</h4-->
                        <table class="table">
                            <thead>
                            <tr><th>Strain Group</th><th>Phenotypes</th></tr>

                            </thead>
                            <tbody>
                            <c:forEach items="${model.strainObjects}" var="item">
                                <tr><td><a href="strain.html?strainGroupId=${item.strainGroupId}&cmoIds=${item.cmoAccIds}">${item.strainGroupName}</a></td><td>${fn:length(item.cmoAccIds)}</td></tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                </div>


        </div>
    </div>

</div>

<%@ include file="/common/footerarea.jsp"%>

