
<div class="chart-container" id = "chartDiv" style="margin-top:2%" >
    <canvas id="resultChart" style="position: relative; height:200px; width:80vw;"></canvas>

</div>

<script>

        var ctx = document.getElementById("resultChart");
        var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ${labels},
            datasets: generateData()
        },
        options: {
            responsive: true,
            scaleShowValues: true,
            scales: {
                xAxes: [{
                    gridLines: {
                        color: "rgba(0, 0, 0, 0)"
                    },
                    scaleLabel: {
                        display: true,
                        labelString: '<------Experiment Conditions------>',
                        fontSize: 14,
                        fontStyle: 'bold',
                        fontFamily: 'Calibri'
                    },
                    ticks:{
                      /*  fontColor: "rgb(0,75,141)",
                        fontSize: 10,*/
                      display:false,
                        autoSkip: false,
                      /*  callback: function(t) {
                            var maxLabelLength = 40;
                            if (t.length > maxLabelLength) return t.substr(0, maxLabelLength-20) + '...';
                            else return t;

                        }*/
                    }
                }],
                yAxes: [{
                    type: 'linear',
                    position: 'left',
                    ticks: {
                        beginAtZero: true
                    },
                    scaleLabel: {
                        display: true,
                        labelString:' ${yaxisLabel} ',
                        fontSize: 14,
                        fontStyle: 'bold',
                        fontFamily: 'Calibri'
                    }
                }]
            },
            tooltips: {

                callbacks: {
                    label: function(tooltipItem, all) {
                        return all.datasets[tooltipItem.datasetIndex].label
                            + ': ' + tooltipItem.yLabel.toLocaleString()
                            + (all.datasets[tooltipItem.datasetIndex].errorBars[tooltipItem.label].plus ? ' ± ' + all.datasets[tooltipItem.datasetIndex].errorBars[tooltipItem.label].plus.toLocaleString() : '');
                    },

                    afterLabel: function(tooltipItem) {
                        var index = tooltipItem.index;
                        return getDetails(index);
                    }
                }

            },

            hover: {
                mode: 'index',
                intersect: false
            },
            legend: {
                display: false
            }
            ,
            plugins: {
                chartJsPluginErrorBars: {
                    color: 'black',
                }
            }
        }
        });

        function updateChart() {
            var rowLength=document.getElementById("mytable").rows.length;
            var sortedValues=[];
            for(var i=1;i<rowLength;i++){
                var value= document.getElementById("mytable").rows[i].cells.item(14).innerHTML;
                //console.log(value);
                sortedValues.push(value);
            }
            arrayLabel = ${labels}
                <c:forEach items="${plotData}" var="plot">
                arrayData = ${plot.value}
                    </c:forEach>
                    arrayColors=${backgroundColor}
                    arrayErrorBars=${errorBars}
                        arrayOfObj = arrayLabel.map(function(d, i) {
                            return {
                                label: d,
                                data: arrayData[i] || 0,
                                bgColor:arrayColors[i],
                                errorBars:arrayErrorBars[d]
                            };
                        });

            /*   sortedArrayOfObj = arrayOfObj.sort(function(a, b) {
                   return b.data - a.data;
               });
           */
            sortedArrayOfObj=sortByValues(sortedValues, arrayOfObj);
            newArrayLabel = [];
            newArrayData = [];
            newArrayBackgroundColor = [];
            newErrorBars={};
            var data=[];
            sortedArrayOfObj.forEach(function(d){
                newArrayLabel.push(d.label);
                newArrayData.push(d.data);
                newArrayBackgroundColor.push(d.bgColor);
                newErrorBars[d.label]=arrayErrorBars[d.label]

            });


            myChart.data.labels=newArrayLabel;

            data.push({
                label:"Value",
                data: newArrayData ,
                backgroundColor:newArrayBackgroundColor,
                errorBars:newErrorBars,
                borderWidth: 1
            });

            myChart.data.datasets=data;
            myChart.update();
            document.getElementById("chartDiv").style.display = "block";
            document.getElementById("resultChart").style.display = "block";
        }



        function sortByValues(sortedValues, arrayOfObj) {
            var sortedObjArray=[];
            for(var i=0;i<sortedValues.length;i++){
                for(var j=0;j<arrayOfObj.length;j++){
                    if(arrayOfObj[j].data==sortedValues[i]){
                        sortedObjArray.push(arrayOfObj[j])
                    }
                }
            }
            return sortedObjArray;
        }

    function getRandomColor() {
        var letters = 'BCDEF'.split('');
        var color = '#';
        for (var i = 0; i < 6; i++ ) {
            color += letters[Math.floor(Math.random() * letters.length)];
        }
        return color;
    }
        function getDetails(index) {
            var table = document.getElementById('mytable');
            var j = 0;
            var detail = [];
            var rowLength = table.rows.length;
            var avgIndex = table.rows.item(0).cells.length;
            for (i = 1; i < rowLength; i++) {
                if (table.rows.item(i).style.display !== 'none') {
                    if (j === index) {
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(value!='' && label!='Value' && (label=='SEM' || label=='SD'))
                            detail.push(label + ':' + value) ;
                        }
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(label=='Units'  )
                                detail.push(label + ':' + value) ;
                        }
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(value!='' && label!='Value' && label!='SEM' && label!='SD' && label!='Study ID' && label!='Study' && label!='Units' )
                                detail.push(label + ':' + value) ;
                        }
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(label=='Study ID' || label=='Study' )
                                detail.push(label + ':' + value) ;
                        }
                    }
                    j++;
                }
            }
            return detail;
        }
    function generateData() {
        var data=[];
        errorBars=${errorBars}
        <c:forEach items="${plotData}" var="plot">
        data.push({
            label: "${plot.key}",
            data: ${plot.value},
            errorBars: ${errorBars},
            backgroundColor: ${backgroundColor},
            borderWidth: 1,
            borderColor:"gray"
        });

        </c:forEach>
        return data;
    }
</script>