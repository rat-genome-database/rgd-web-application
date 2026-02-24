<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="org.elasticsearch.action.search.SearchResponse" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<meta name="referrer" content="no-referrer" />


<%

    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>

<script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>
<!--script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script-->

<script src="/rgdweb/common/chartjs/chartjs-error-bars/Plugin.Errorbars.js"></script>
<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous"/>
<script>
    var hits=${fn:length(sr.hits.hits)};
    <c:if test="${plotData!=null}">
    var plotData=${plotData}
        </c:if>
    $(function () {
        if(hits==0){
            $('#phenominerModal').modal('show');

        }
        if(typeof plotData=='undefined'){
            $('#phenominer-noplot-modal').modal('show');
        }
    })

</script>
<script src="/rgdweb/common/jquery.tabletoCSV.js"> </script>
<%
    SearchResponse sr= (SearchResponse) request.getAttribute("sr");
%>
<div id="site-wrapper" style="position:relative; left:0px; top:00px;">

<div class="row" id="phenoController">


    <!-- Modal -->
    <div class="modal fade" id="phenominerModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header alert alert-danger">
                    <h5 class="modal-title" id="exampleModalLabel">0 Results</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <h4 >0 results found with selected filters. Please refine the filters. Redirecting to initial search..</h4>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <a href="/rgdweb/phenominer/table.html?terms=${terms}&species=${species}"><button type="button" class="btn btn-primary" id="zeroResultButton">Ok</button></a>
                </div>
            </div>
        </div>
    </div>
    <!--div class="modal fade" id="phenominer-noplot-modal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header alert alert-danger">
                    <h5 class="modal-title" id="phenominer-noplot-modal-Label">Alert!!</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <h4 >Please select the measurements of one unit group in the left filter pane to view the graph</h4>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div-->
    <div class=" sidebar">
        <%@include file="sideBar.jsp"%>
    </div>
    <main role="main" class="col" id="results" style="width: 50%">

        <div class="row">
            <div class="col-sm-5">
                <h3>PhenoMiner Database Results (<%=sr.getHits().getTotalHits().value%>&nbsp;results)</h3>
            </div>
            <div class="col-xs-2">
                <button class="btn btn-primary"><a href="/rgdweb/phenominer/ontChoices.html?terms=${terms}&species=${species}" style="text-decoration: none;color:white">Edit Query</a></button>&nbsp;
            </div>
            <div class="col-xs-2">
                <input class="btn  btn-primary"  type="button" value="New Query" onclick="sessionStorage.clear();location.href='/rgdweb/phenominer/ontChoices.html?species=${species}'">&nbsp;
            </div>
            <div class="col-xs-2">
                <button class="btn btn-primary"><a href="download.html?fmt=3&terms=${terms}&species=${species}" style="text-decoration: none;color:white">Download all records</a></button>
            </div>
            <c:if test="${facetSearch=='true'}">
                <div class="col-xs-2">
                    &nbsp;<button class="btn btn-primary" onclick="downloadSelected()"><a href="" style="text-decoration: none;color:white">Download table view records</a></button>
                </div>
            </c:if>
        </div>
        <hr>
        <c:if test="${fn:length(selectedFilters)>0}">
        <span><strong style="color:black">Remove Filters:</strong>
            <button class="btn btn-light btn-sm" value="all"><a href="/rgdweb/phenominer/table.html?terms=${terms}&refRgdId=${refRgdId}&species=${species}">All&nbsp;<i class="fa fa-times-circle" style="font-size:15px;color:red"></i></a></button>
            <c:if test="${fn:length(sr.hits.hits)>0}">
            <c:forEach items="${selectedFilters}" var="termList">
            <c:forEach items="${termList.value}" var="filter">
                <button class="btn btn-light btn-lg " value="${filter}" onclick="removeFilter('${filter}', '${termList.key}')">${filter}&nbsp;<i class="fa fa-times-circle" style="font-size:15px;color:red" ></i></button>
            </c:forEach>
        </c:forEach>
            </c:if>
</span>
        </c:if>

        <c:choose>
        <c:when test="${fn:length(sr.hits.hits)>0}">
        <c:choose>
        <c:when test="${plotData!=null}">

            <%@include file="legend.jsp"%>

        <%@include file="chartjs.jsp"%>
        </c:when>
            <c:otherwise>
                <div>
               <span style="color:blue;font-weight: bold">How to display a graph</span>

                    <button type="button" class="btn btn-light btn-sm" data-container="body" data-trigger="hover click" data-toggle="popover" data-placement="bottom" data-popover-content="#popover-graph-help" title="Graph Display Help" style="background-color: transparent">
                        <span style="text-decoration:underline"><i class="fas fa-question-circle" style="color: blue;font-size: large"></i></span>
                    </button>
                    <div style="display: none" id="popover-graph-help">
                        <div class="popover-body">
                           <p> Please select the measurements of same unit in the left filter pane to view the graph.</p>
                        </div>
                    </div>
                <!--h4 style="font-weight: bold;color:red">Please select the measurements of one unit group in the left filter pane to view the graph.</h4-->
                </div>
            </c:otherwise>
        </c:choose>
        <%@include file="phenominerChart.jsp"%>
        </c:when>
            <c:otherwise>
                <!--h4 style="font-weight: bold;color:red">No results found with selected filters. Please refine the filters.</h4-->

            </c:otherwise>
        </c:choose>
    </main>

</div>
</div>

<script>
    $("#colorBy").on("change",function () {
      $('input[name="colorBy"]').val($(this).val());
    //    alert($(this).val());
        $('#phenominerReportForm').submit();
    })

</script>

<%@ include file="/common/compactFooterArea.jsp"%>
