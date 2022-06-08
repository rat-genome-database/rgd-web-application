<style>
    #chartjs-tooltip{
        background: rgba(0, 0, 0, 0.7);


    }
   table tr td, table tr th{
        color:white;
    }
</style>
<div class="chart-container" id = "chartDiv" style="margin-top:2%" >
    <canvas id="resultChart" style="position: relative; height:400px; width:80vw;"></canvas>

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
                      display:true,
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
            tooltips:{
                enabled:false,
                custom:function (tooltipModel) {
                    var tooltipEl = document.getElementById('chartjs-tooltip');

                    // Create element on first render
                    if (!tooltipEl) {
                        tooltipEl = document.createElement('div');
                        tooltipEl.id = 'chartjs-tooltip';
                        tooltipEl.innerHTML = '<table></table>';
                        document.body.appendChild(tooltipEl);
                    }

                    // Hide if no tooltip
                  //  const tooltipModel = context.tooltip;
                    if (tooltipModel.opacity === 0) {
                        tooltipEl.style.opacity = 0;
                        return;
                    }

                    // Set caret Position
                    tooltipEl.classList.remove('above', 'below', 'no-transform');
                    if (tooltipModel.yAlign) {
                        tooltipEl.classList.add(tooltipModel.yAlign);
                    } else {
                        tooltipEl.classList.add('no-transform');
                    }

                    function getBody(bodyItem) {
                        return bodyItem.lines ;
                    }

                    // Set Text
                    if (tooltipModel.body) {
                        const titleLines = tooltipModel.title || [];
                        const bodyLines = tooltipModel.body.map(getBody);

                        let innerHtml = '<thead>';

                        titleLines.forEach(function(title) {
                            innerHtml += '<tr><th>' + title + '</th></tr>';
                        });
                        innerHtml += '</thead><tbody>';

                        bodyLines.forEach(function(body, i) {
                            const colors = tooltipModel.labelColors[i];
                            let style = 'background:' + colors.backgroundColor;
                            style += '; border-color:' + colors.borderColor;
                            style += '; border-width: 2px';
                            const span = '<span style="' + style + '"></span>';
                            innerHtml += '<tr><td>' + span + body + '</td></tr>';
                            var details=getDetails(i);
                            for(var item=0;item<details.length;item++)
                                innerHtml += '<tr><td >' +details[item] + '</td></tr>';
                        });

                        innerHtml += '</tbody>';

                        let tableRoot = tooltipEl.querySelector('table');
                        tableRoot.innerHTML = innerHtml;
                    }

                    const position = this._chart.canvas.getBoundingClientRect();
                  //  const bodyFont = Chart.helpers.toFont(tooltipModel.options.bodyFont);

                    // Display, position, and set styles for font
                    tooltipEl.style.opacity = 1;
                    tooltipEl.style.position = 'absolute';
                    tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
                    tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
                    tooltipEl.style.fontFamily = tooltipModel._bodyFontFamily;
                    tooltipEl.style.fontSize = tooltipModel.bodyFontSize + 'px';
                    tooltipEl.style.fontStyle = tooltipModel._bodyFontStyle;
                    tooltipEl.style.padding = tooltipModel.yPadding + 'px ' + tooltipModel.xPadding + 'px';
                    tooltipEl.style.pointerEvents = 'none';
            }},
      /*      tooltips: {
                yAlign:'top',
                callbacks: {
                    label: function(tooltipItem, all) {
                        return all.datasets[tooltipItem.datasetIndex].label
                            + ': ' + tooltipItem.yLabel.toLocaleString()
                            + (all.datasets[tooltipItem.datasetIndex].errorBars[tooltipItem.label].plus ?  '\u00B1' + all.datasets[tooltipItem.datasetIndex].errorBars[tooltipItem.label].plus.toLocaleString() : '');
                    },

                    afterLabel: function(tooltipItem) {
                        var index = tooltipItem.index;
                        return getDetails(index);
                    }
                }

            },*/

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

            },
            layout: {
                padding: {
                    bottom: 100 , //set that fits the best
                    top:10
                }
            }
        }
        });

        function updateChart() {
            var rowLength=document.getElementById("mytable").rows.length;
            var sortedValues=[];
            for(var i=1;i<rowLength;i++){
                var value= document.getElementById("mytable").rows[i].cells.item(10-missedColumnCount).innerHTML;
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
                borderWidth: 1,
                borderColor:"gray"
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