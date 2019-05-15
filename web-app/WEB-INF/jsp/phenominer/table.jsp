<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>

<meta name="referrer" content="no-referrer" />

<script src="https://d3js.org/d3.v4.min.js"></script>
<%

    HttpRequestFacade req = new HttpRequestFacade(request);
    Report report = (Report)request.getAttribute("report");
    HashMap<String,Term> termResolver =(HashMap<String,Term>) request.getAttribute("termResolver");
    HashMap<String,String> measurements = (HashMap<String,String>) request.getAttribute("measurements");
    HashMap<String,String> conditions = (HashMap<String,String>) request.getAttribute("conditions");
    HashMap<String,String> methods = (HashMap<String,String>) request.getAttribute("methods");
    HashMap<String,String> samples = (HashMap<String,String>) request.getAttribute("samples");
    LinkedHashMap<String,String> ageRanges = (LinkedHashMap<String,String>) request.getAttribute("ageRanges");
    Double minValue = (Double) request.getAttribute("minValue");
    Double maxValue = (Double) request.getAttribute("maxValue");
    String idsWithoutMM = (String) request.getAttribute("idsWithoutMM");
    LinkedHashMap<String,String> conditionSet = (LinkedHashMap<String,String>) request.getAttribute("conditionSet");
    Integer refRgdId = (Integer) request.getAttribute("refRgdId");

    int speciesTypeKey = 3;
    try {
        speciesTypeKey= Integer.parseInt(request.getParameter("species"));
    }catch(Exception e) {

    }

    String tableUrl = "/rgdweb/phenominer/table.html?species="+speciesTypeKey;
    String reqTerms = request.getParameter("terms");
    if( !Utils.isStringEmpty(reqTerms) ) {
        tableUrl += "&terms=" + reqTerms;
    }
    if( refRgdId!=0 ) {
        tableUrl += "&refRgdId="+refRgdId;
    }
%>

<%

    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>

<script>
    document.body.style.backgroundColor="white";
</script>

<script>
    rgdModule.controller('phenoController', [
        '$scope','$http',


        function ($scope, $http) {

            var ctrl = this;

            //$scope.title = "Hello";
            $scope.portalGenes = [{"name": "a2m", "symbol": "A2m"}];
            $scope.records = {};
            $scope.measurements = {};
            $scope.samples = {};
            $scope.methods = "";
            $scope.conditions = {};
            $scope.ageRanges = {};
            $scope.minValue =<%=minValue%>;
            $scope.maxValue =<%=maxValue%>;
            $scope.sexOptions = ["All", "Male", "Female"];
            $scope.groupByOptions = ["Experiment", "Strain", "Condition", "Measurement Method", "Age", "Sex"];
            $scope.group = "";
            $scope.conditionSet = {};

            ctrl.selectedMeasurement = "";

            <%
            String mArr = "[";

            for (String key: measurements.keySet()) {
                if (mArr.length() > 5) {
                    mArr += ",";
                }

                mArr += "{\"accId\":\"" + key + "\",\"term\":\"" + termResolver.get(key).getTerm() + "\"}";
             }

             mArr += "]";
             %>
            $scope.rootMeasurements = <%=mArr%>;

            <%
            mArr = "[";

            for (String key: samples.keySet()) {
                if (mArr.length() > 5) {
                    mArr += ",";
                }
                mArr += "{\"accId\":\"" + key + "\",\"term\":\"" + termResolver.get(key).getTerm() + "\"}";
             }

             mArr += "]";
             %>
            $scope.rootSamples = <%=mArr%>;

            <%
            mArr = "[";

            for (String key: conditions.keySet()) {
                if (mArr.length() > 5) {
                    mArr += ",";
                }
                mArr += "{\"accId\":\"" + key + "\",\"term\":\"" + termResolver.get(key).getTerm() + "\"}";
             }

             mArr += "]";
             %>
            $scope.rootConditions = <%=mArr%>;

            <%
            mArr = "[";

            for (String key: methods.keySet()) {
                if (mArr.length() > 5) {
                    mArr += ",";
                }
                mArr += "{\"accId\":\"" + key + "\",\"term\":\"" + termResolver.get(key).getTerm() + "\"}";
             }

             mArr += "]";
             %>
            $scope.rootMethods = <%=mArr%>;

            $scope.checkboxModel = [true, false];


            //need to add the hostname here.

            var host = window.location.protocol + window.location.host;

            if (window.location.host.indexOf("localhost") > -1) {
                host= window.location.protocol + "//localhost:8080";
            } else if (window.location.host.indexOf("dev.rgd") > -1) {
                host= window.location.protocol + "//dev.rgd.mcw.edu";
            }else if (window.location.host.indexOf("pipelines.rgd") > -1) {
                host= window.location.protocol + "//pipelines.rgd.mcw.edu";
            }else {
                host=window.location.protocol + "//rest.rgd.mcw.edu";
            }

            ctrl.load = function () {
                $http({
                    method: 'GET',
                    //url: "https://dev.rgd.mcw.edu/rgdws/phenotype/phenominer/3/chart/RS%3A0000029%2CRS%3A0001860%2CRS%3A0001381%2CCMO%3A0000015",
                    <% if( refRgdId==0 ) { %>
                    url: host + "/rgdws/phenotype/phenominer/chart/<%=speciesTypeKey%>/" + $scope.selectedMeasurement.accId + ",<%=idsWithoutMM%>",
                    <% } else { %>
                    url: host + "/rgdws/phenotype/phenominer/chart/<%=speciesTypeKey%>/<%=refRgdId%>/" + $scope.selectedMeasurement.accId + ",<%=idsWithoutMM%>",
                    <% } %>
                }).then(function successCallback(response) {

                    $scope.records = response.data.records;
                    $scope.measurements = response.data.measurements;
                    $scope.conditions= response.data.conditions;
                    $scope.methods= response.data.methods;
                    $scope.samples= response.data.samples;
                    $scope.ageRanges= response.data.ageRanges[0];
                    $scope.minValue=response.data.valueRange.min;
                    $scope.maxValue=response.data.valueRange.max;
                    $scope.conditionSet=response.data.conditionSet;
                    $scope.methodMap=[];
                    $scope.colorMap={};
                    //$scope.conditionMap=response.data.conditionMap;

                    $scope.colors=["#96151D","#255992","#525453","#582256","#28472C","#B48F7A","#CCBE8D","#868A8B","#AA9653","#828C9E","#5D5842","#132E52"]




                    //alert(JSON.stringify($scope.methods));

                    for (rec in $scope.methods) {
                        //alert(JSON.stringify($scope.methods[rec].accId));
                        //alert(JSON.stringify($scope.methods[rec].term));
                        //alert("setting " + $scope.methods[rec].accId + " to " + $scope.methods[rec].term);
                        $scope.methodMap[$scope.methods[rec].accId]=$scope.methods[rec].term;
                    }



                    //alert(JSON.stringify($scope.records[0].measurementMethod.accId));

                    for (var index in $scope.conditionSet) {
                      //  alert($scope.conditionSet[index]);
                      //  alert($scope.conditionSet[index].length);

                        for (var y=0; y< $scope.conditionSet[index].length;y++ ) {
//                            alert($scope.conditionSet[index][y]);
                            //alert("setting contition - " + $scope.conditionSet[index][y] + " - " + $scope.colors[y] );
                            $scope.colorMap[$scope.conditionSet[index][y]] = $scope.colors[y];
                        }


                    }





                    ctrl.updateChart();


                }, function errorCallback(response) {
                    alert("response = " + response.data);
                });


            }

            ctrl.checkIt = function(accId, obj) {
                alert("check it " + accId);
                alert(obj.value);
            }

            ctrl.unCheckIt = function(accId) {
                alert("unCheckIt " + accId);
            }

            ctrl.updateChart = function () {

                    var xArray = new Array($scope.records.length);
                    var yArray = new Array($scope.records.length);
                    var eArray = new Array($scope.records.length);
                    var tArray = new Array($scope.records.length);
                    var term = $scope.selectedMeasurement.term;
                    var units = "";
                    var colorArray=new Array($scope.records.length);

                var spaceCount=0;

                    for (var i=0; i< $scope.records.length; i++) {

                        var value = parseFloat($scope.records[i].measurementValue);

                        var units = $scope.records[0].measurementUnits;
                        if (value < $scope.minValue || value > $scope.maxValue) {
                            continue;
                        }

                        if ($scope.sex != "All") {
                            if ($scope.records[i].sample.sex.toLowerCase() != $scope.sex.toLowerCase()) {
                                continue;
                            }
                        }

                        yArray[i] = $scope.records[i].measurementValue;
                        //colorArray[i]="#24609C";
                        colorArray[i]=$scope.colorMap[$scope.records[i].conditionDescription];

                        for (var j=0; j<$scope.samples.length; j++) {
                            if ($scope.samples[j].accId == $scope.records[i].sample.strainAccId) {
                                //alert("setting " + $scope.samples[j].term);
                                xArray[i] = $scope.samples[j].term;

                                var isFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
                                for (var k=0; k< spaceCount; k++) {
                                   // xArray[i] = xArray[i] + "&#8203;";

                                    if (isFirefox) {
                                        xArray[i] = xArray[i] + "\t";
                                    }else {
                                        xArray[i] = "\t" + xArray[i];
                                    }


                                }
                                spaceCount+=1;
                            }
                        }

                        eArray[i] = parseFloat($scope.records[i].measurementSem);


                        var hoverText="<b>Value:</b>&nbsp;" + yArray[i] + " " + $scope.records[i].measurementUnits;

                        hoverText += "&nbsp;&nbsp;&nbsp;<b>Sex:</b>&nbsp;" + $scope.records[i].sample.sex;
                        hoverText +=  "&nbsp;&nbsp;&nbsp;<b>Standard Deviation:</b> " + (Math.round(parseFloat($scope.records[i].measurementSD) * 1000) / 1000);
                        hoverText +=  "&nbsp;&nbsp;&nbsp;<b>Std Error of Mean</b>: " + (Math.round(parseFloat($scope.records[i].measurementSem) * 1000)/1000);

                        hoverText+="<br><b>Condition:</b>:&nbsp;" + $scope.records[i].conditionDescription;
                        hoverText+="<br><b>Method:</b>:&nbsp;" + $scope.methodMap[$scope.records[i].measurementMethod.accId];


                        tArray[i] = hoverText;
                    }

                    var trace1= {
                        x: xArray,
                        y: yArray,
                        text: tArray,
                        hoverinfo:'x+y',
                        //hoverinfo:'all',
                        showlegend:true,
                        opacity:1,

                        name:'', // must

                        error_y: {
                            type: 'data',
                            array: eArray,
                            visible: true
                        },
                        type: 'bar',
                        marker: {
                            color: colorArray
                        }
                    };

                    var data = [trace1];


                    var layout = {
                        //hovermode:"closest",
                        title: 'Conditions and Measurement Methods',
                        xaxis: {
                            //title: "hello world",
                            type:'data',
                            //hoverformat:'.2f',
                            tickangle: -15,
                            tickfont: {
                                //family: 'Old Standard TT, serif',
                                size: 10,
                                color: 'black'
                            },//ticktext: ["a","b","a","d","e","f"],
                            //tickvals: [1,1,1,1,1,1],
                        },
                        yaxis:{
                            title: term + " (" + units + ")",
                            zeroline:false,
                           // hoverformat:'.2f'
                        },
                        //barmode: 'group'
                    };


                var totalWidth = (xArray.length * 50);

                if (totalWidth < 700) {
                    totalWidth = 700;
                }


                document.getElementById("myDiv").style.width=totalWidth + "px";


             // Plotly.newPlot('myDiv', data,layout);


                var myPlot = document.getElementById('myDiv'),
                        hoverInfo = document.getElementById('hoverinfo'),
                        d3 = Plotly.d3,
                        N = xArray.length,
                        x = xArray,
                        y = yArray,
                        //y2 = d3.range(N).map( d3.random.normal() ),
                        data = data;

                Plotly.newPlot('myDiv', data, layout);

                myPlot.on('plotly_hover', function(data){
                            var xaxis = data.points[0].xaxis,
                                    yaxis = data.points[0].yaxis;
                            var infotext = data.points.map(function(d){

                                return d.data.text[d.pointNumber];
                                //return (d.data.name+': x= '+d.x+', y= '+d.y.toPrecision(3));
                            });

                            hoverInfo.innerHTML = infotext.join('<br/>');
                            hoverInfo.style.display = "block";
                        })
                        .on('plotly_unhover', function(data){
                            hoverInfo.innerHTML = '&nbsp;';
                            hoverInfo.style.display="none";
                        });

            }

        }

    ]);
</script>


<style>
    .conditionBox {
        overflow: auto;
        height: 100px;
        border: 2px solid gray;
    }

    .phenoBullet {
        height:10px;
        width:10px;
        background-color:#D7E4BD;

    }

    tr.oddRow td, tr.oddRow td {
        padding-top:1px;
        padding-left:5px;
        padding-bottom:1px;
    }

    tr.evenRow td, tr.evenRow td {
        background-color:#E2E2E2;
        padding-top:1px;
        padding-left:5px;
        padding-bottom:1px;
    }

    .hoverbox {
        background-color:white;
        width:95%;
        top:0%;
        left:0%;
        height:70px;
        margin-top:10px;
        margin-left:10px;
        padding-top:10px;
        background-color:#E2E2E2;
        padding-left:10px;
        padding-right:10px;
        position:fixed;
        z-index:1000;
        border: 2px solid black;
        display:none;
    }

    .styled-select select {
        background: transparent;
        border: none;
        font-size: 16px;
        padding: 5px; /* If you add too much padding here, the options won't show in IE */
        color:white;
    }

    .styled-select option {
        font-size:18px;
        color: black;
    }
    .green   { background-color: #255992; }

    .rounded {
        -webkit-border-radius: 5px;
        -moz-border-radius: 5px;
        border-radius: 5px;
        border:none;
    }



</style>

<%
    int format = 1;

    try {
        format = Integer.parseInt(request.getParameter("fmt"));
    }catch (Exception e) {
        //ignored
    }
%>

<div id="phenoController" ng-controller="phenoController as pheno">


<table cellpadding="0" cellspacing="0" border="0" style="padding-top:20px;">
    <tr>
        <td style = "color: #2865a3; font-size: 20px; font-weight:700;">PhenoMiner Database Result <a name="ViewChart">

        </a> </td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td><a href="#ViewDataTable">View data table</a></td>
        <td>&nbsp;|&nbsp;</td>
        <td><a href="<%=tableUrl%>&fmt=3">Download data table</a></td>
        <td>&nbsp;|&nbsp;</td>
        <% if (format==2) { %>
            <td><a href="<%=tableUrl%>&fmt=1">View compact data table</a></td>
        <% } else { %>
            <td><a href="<%=tableUrl%>&fmt=2">View expanded data table</a></td>
        <% } %>
        <td>&nbsp;&nbsp;&nbsp;</td>
        <td align="right" colspan="2"><input type="button" value="Edit Query" onClick="location.href='/rgdweb/phenominer/ontChoices.html?terms=<%=request.getParameter("terms")%>&species=<%=speciesTypeKey%>'"/></td>
        <td>&nbsp;&nbsp;&nbsp;</td>
        <td align="right" colspan="2"><input type="button" value="New Query" onClick="location.href='/rgdweb/phenominer/home.jsp?species=<%=speciesTypeKey%>'"/></td>
    </tr>
</table>

<hr>

<br>

    <table border="0" style="padding-bottom:10px;">
        <tr>
            <td style="font-size:20px;color:#2865A6;">Generate Chart For</td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td >
                <div class="styled-select green rounded">

                <select ng-init="selectedMeasurement = rootMeasurements[0]" ng-model="selectedMeasurement"
                             ng-options="measurement.term for measurement in rootMeasurements | orderBy: 'term'"
                             ng-change="pheno.load()">
                </select>
                </div>

            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;(Chart displayed below)</td>
        </tr>
    </table>

<table width="1000" border="2" cellspacing="0" >
    <tr>
        <td valign="top">
            <div style="height:200px; overflow-y:scroll;">

                <% if (speciesTypeKey==4) {%>
                <div style="padding:2px;font-weight:700; font-size:16px; color:#2865A6;">Chinchilla Sources</div><hr>
                <% } else { %>
                <div style="padding:2px;font-weight:700; font-size:16px; color:#2865A6;">Rat Strains</div><hr>
                <% } %>

            <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" ng-repeat="sample in samples"  >
                {{sample.term}}
            </div>
            </div>
        </td>
        <td valign="top">
            <div style="height:200px; overflow-y:scroll;">
            <div style="padding:2px;font-weight:700; font-size:16px; color:#2865A6;" >Measurement Methods</div><hr>
            <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" ng-repeat="method in methods">

               {{method.term}}
            </div>
            </div>
        </td>
        <td valign="top">
            <div style="height:200px; overflow-y:scroll;">
            <div  style="padding:2px;font-weight:700; font-size:16px; color:#2865A6;">Age</div><hr>
            <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" ng-repeat="ageRange in ageRanges">
                {{ageRange}}
            </div>
            </div>
        </td>
    </tr>

</table>


    <table width="1000" border="2" cellspacing="0" style="padding-top:8px;">
        <tr>
            <td valign="top">
                <div style="height:200px; overflow-y:scroll;">
            <div  style="padding:2px;font-weight:700; font-size:16px; color:#2865A6;">Experimental Conditions</div><hr>
        <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" ng-repeat="condition in conditionSet">

        <div ng-repeat="cond in condition" g-class-odd="'oddRow'" g-class-even="'evenRow'" style="margin-bottom:5px;">

           <span style="background-color:{{colors[$index]}};height:8px;border-radius:45px;margin-bottom:15px; margin-right:5px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="font-size:12px; font-weight:700; color:{{colors[$index]}};">{{ cond }}</span></li>

        </div>

    </div>
                </div>
            </td>
        </tr>
    </table>

    <br>
<table border="0" align="left">
    <tr>
        <td>
            Minimum Value: <input ng-model="minValue" ng-change="pheno.updateChart()" type="text"  size="5">
        </td>
        <td>&nbsp;&nbsp;</td>
        <td>
            Maximum Value: <input ng-model="maxValue" ng-change="pheno.updateChart()" type="text" size="5">
        </td>
        <td>&nbsp;&nbsp;</td>
        <td>
            Sex: <select ng-init="sex = sexOptions[0]"
                                 ng-model="sex"
                                 ng-options="sexOption for sexOption in sexOptions"
                                ng-change="pheno.updateChart()"
            >
            </select>
        </td>
    </tr>

</table>

<br><br>
<!-- Plotly.js -->
    <div class="hoverbox"  id="hoverinfo">&nbsp;</div>

    <table border="0">
        <tr>
            <td>
                <div id="myDiv" style="width: 450px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
            </td>
        </tr>
    </table>


<script>


</script>

    <div ng-init="pheno.load()"></div>

</div> <!-- end of angular block -->


<a name="ViewDataTable"></a>
<table>
    <tr>
        <td><b>Options:&nbsp;</b></td>
        <td><a href="#ViewChart">View chart</a></td>
        <td>&nbsp;|&nbsp;</td>
        <td><a href="<%=tableUrl%>&fmt=3">Download data table</a></td>
        <td>&nbsp;|&nbsp;</td>
        <% if (format==2) { %>
        <td><a href="<%=tableUrl%>&fmt=1">View compact data table</a></td>
        <% } else { %>
        <td><a href="<%=tableUrl%>&fmt=2">View expanded data table</a></td>
        <% } %>
    </tr>
</table>

<script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>
<%
    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties(" class='sortable' lign='center' ");
    out.print(strat.format(report));
%>

<%@ include file="/common/compactFooterArea.jsp"%>
