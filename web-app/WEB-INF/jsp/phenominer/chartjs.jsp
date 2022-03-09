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
            $scope.selectedMeasurement=  $scope.rootMeasurements[0];
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
                        url:  "https://rest.rgd.mcw.edu/rgdws/phenotype/phenominer/chart/<%=speciesTypeKey%>/" + $scope.selectedMeasurement.accId + ",<%=idsWithoutMM%>",
                    <% } else { %>
                        url: "https://rest.rgd.mcw.edu/rgdws/phenotype/phenominer/chart/<%=speciesTypeKey%>/<%=refRgdId%>/" + $scope.selectedMeasurement.accId + ",<%=idsWithoutMM%>",
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

                  //  $scope.selectedMeasurement=  rootMeasurements[0];


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


                var totalWidth = (xArray.length * 20);

                if (totalWidth < 700) {
                    totalWidth = 700;
                }
                if(totalWidth>1200){
                    totalWidth=1200
                }


                document.getElementById("myDiv").style.width=totalWidth;


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


            }

        }

    ]);
</script>