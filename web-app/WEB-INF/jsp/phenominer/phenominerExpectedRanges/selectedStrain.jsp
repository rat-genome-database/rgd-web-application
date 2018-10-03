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
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <script src="/rgdweb/js/expectedRanges/jquery.min.js"></script>

    <!-- Bootstrap -->
    <link href="/rgdweb/css/expectedRanges/bootstrap.min.css" rel="stylesheet">
    <!--link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet"-->
    <script src="/rgdweb/js/expectedRanges/bootstrap.min.js"></script>
</head>
<body>
    <div style="margin-left:90%;margin-top:1%"><a href="#"><span class="glyphicon glyphicon-chevron-left" style="font-size: large"></span><strong><a href="home.html">Home</a></strong></a></div>
    <div class="container-fluid" style="background-color:#fafafa;margin-top:1%">
        <div class="container-fluid" >

            <div style="float:right;">Select Strain Group:
                <form id="erStrainsSelectForm" action="selectedStrain.html">
                    <input type="hidden" id="cmo" name="cmo" value="">
                    <select id="erPhenotypesSelect" class="form-control form-control-sm "  style="z-index: 999">
                        <option>ACI</option>
                        <option>BN</option>

                    </select>
                </form>
            </div>
            <h3>${model.strainObject.strainGroupName} - Phenotype Expected Ranges</h3>

            <div class="panel panel-default">

                <div class="panel-body">
                    <table>
                        <caption>Options</caption>
                        <tr>
                            <td>
                                <table>
                                    <caption>Phenotypes</caption>
                                    <c:forEach items="${model.strainObject.phenotypeNameAccIdMap}" var="item">
                                        <tr><td><input type="checkbox" value="${item.key}">${item.value}</td></tr>
                                    </c:forEach>
                                </table>
                            </td>
                        </tr>
                    </table>

                    </div>
                </div>
            <div class="panel panel-default">

                <div class="panel-body">
                   <div id="rangeDiv"></div>
                </div>
            </div>
            <div class="panel panel-default">

                <div class="panel-body">
                    <table class="table table-stripped">
                        <thead><tr><th>REC_ID</th><th>Expected Range Name</th><th>Strain Group Name</th><th>Sex</th><th>Age Low</th><th>Age High</th><th>Group Value</th><th>Group SD</th><th>Group Low</th><th>Group High</th></tr></thead>
                       <tbody>
                        <c:forEach items="${model.strainObject.records}" var="item">
                          <tr>
                              <td>${item.id}</td>
                              <td>${item.expectedRangeName}</td>
                              <td>${item.strainGroupName}</td>
                              <td>${item.sex}</td>
                              <td>${item.ageLowBound}</td>
                              <td>${item.ageHighBound}</td>
                              <td>${item.groupValue}</td>
                              <td>${item.groupSD}</td>
                              <td>${item.groupLow}</td>
                              <td>${item.groupHigh}</td>
                          </tr>
                        </c:forEach>
                       </tbody>
                    </table>
                </div>
            </div>
            </div>
        </div>
    <script>
        var data=${model.plotData};
        var layout = {
            title: '${model.strainObject.strainGroupName}  - Phenotypes Expected Ranges'

            // showlegend:false

        };
        Plotly.newPlot('rangeDiv', data, layout);
    </script>
    </body>

</html>