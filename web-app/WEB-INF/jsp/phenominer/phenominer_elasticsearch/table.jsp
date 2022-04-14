<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<meta name="referrer" content="no-referrer" />


<%

    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.bundle.min.js"></script>
<script src="/rgdweb/common/chartjs/chartjs-error-bars/Plugin.Errorbars.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

<div id="site-wrapper" style="position:relative; left:0px; top:00px;">

<div class="row" id="phenoController">

    <div class=" sidebar">
        <%@include file="sideBar.jsp"%>
    </div>
    <main role="main" class="col" id="results">
        <c:if test="${fn:length(selectedFilters)>0}">
        <span><strong>Remove Filters:</strong>
            <button class="btn btn-light btn-sm" value="all"><a href="/rgdweb/phenominer/table.html?terms=${terms}">All&nbsp;<i class="fa fa-times-circle" style="font-size:15px;color:red"></i></a></button>
        <c:forEach items="${selectedFilters}" var="termList">
            <c:forEach items="${termList.value}" var="filter">
                <button class="btn btn-light btn-sm " value="${filter}" onclick="removeFilter('${filter}')">${filter}&nbsp;<i class="fa fa-times-circle" style="font-size:15px;color:red" ></i></button>
            </c:forEach>
        </c:forEach>
</span>
        </c:if>
        <h3>${sr.hits.totalHits}</h3>
        <c:choose>
        <c:when test="${fn:length(sr.hits.hits)>0}">
        <c:choose>
        <c:when test="${plotData!=null}">
        <div>
            <div class="row" style="text-align: center">
                <c:forEach items="${legend}" var="color">

                    <div class="col-xs-1" style="width: 10px;height: 10px;background-color: ${color.value}"></div>
                    <div class="col-xs-1">&nbsp;${color.key}</div>&nbsp;

                </c:forEach>
            </div>
        </div>
        <%@include file="chartjs.jsp"%>
        </c:when>
            <c:otherwise>
                <h4 style="font-weight: bold;color:red">Please select the measurements of one unit group in the left filter pane to view the graph.</h4>
            </c:otherwise>
        </c:choose>
        <%@include file="phenominerChart.jsp"%>
        </c:when>
            <c:otherwise>
                <h4 style="font-weight: bold;color:red">No results found with selected filters. Please refine the filters.</h4>

            </c:otherwise>
        </c:choose>
    </main>
</div>
</div>



<%@ include file="/common/compactFooterArea.jsp"%>
