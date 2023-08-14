<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<style>
    #t{
        border:1px solid #ddd;
        border-radius:2px;
        width: 100%;
        text-align: center;
        font-size: 12px;
    }

    table tr td {
        padding-top: 10px;
        padding-bottom: 10px;
        padding-right: 15px;
    }
    #t th{
        background: rgb(246,248,249); /* Old browsers */
        background: -moz-linear-gradient(top, rgba(246,248,249,1) 0%, rgba(229,235,238,1) 50%, rgba(215,222,227,1) 51%, rgba(245,247,249,1) 100%); /* FF3.6-15 */
        background: -webkit-linear-gradient(top, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* Chrome10-25,Safari5.1-6 */
        background: linear-gradient(to bottom, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=0 );
    }
    #t td{
        max-width: 15px;
        min-width: 5px;
        padding: 10px;

    }
    #t  tr:nth-child(odd) {background-color: #f2f2f2}
    #t tr:hover {
        background-color: #daeffc;
    }

</style>

<%
    String pageHeader="View GEO Samples";
    String pageTitle="View GEO Samples";
    String headContent="View GEO Samples";
    String pageDescription = "View GEO Samples";
%>
<%@ include file="/common/headerarea.jsp"%>
<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>


<html>
<head>
    <title>View GEO Samples</title>
</head>
<body>

<h2>View GEO Samples</h2>

<a href="/rgdweb/curation/expression/experiments.html">View Geo Experiments</a><br><br>
<div class="container-fluid">
    <%
        Report report = (Report) request.getAttribute("report");

        HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
        strat.setTableProperties("class='sortable'");

        out.print(report.format(strat));
        %>

</div>
<br>
<div class="container-fluid">
    <%
        Report report2 = (Report) request.getAttribute("referenceReport");

        HTMLTableReportStrategy strat2 = new HTMLTableReportStrategy();
        strat2.setTableProperties("class='sortable'");

        out.print(report2.format(strat2));
    %>
</div>
</body>
</html>

<%@ include file="/common/footerarea.jsp"%>
