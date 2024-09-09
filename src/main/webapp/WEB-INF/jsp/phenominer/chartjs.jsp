<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    #chartjs-tooltip{
        background: rgba(0, 0, 0, 0.7);


    }
   table tr td, table tr th{
        color:white;
    }
</style>
<div style="color: blueviolet; font-weight: bold">Table "column sort"  updates the order of the bars in the chart.</div>

<div class="chart-container container" id = "chartDiv" style="margin-top:2%" >

    <canvas id="resultChart" style="position: relative; ; width:80vw;"></canvas>

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
                      /*  labelString: '',*/
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
                        var details="";
                        var phenotype="";
                        if (tooltipModel.dataPoints.length) {
                            var index=tooltipModel.dataPoints[0].index;
                            details=getDetails(index);
                            phenotype=getPhenotype(index);
                        }


                        let innerHtml = '<thead>';
                        titleLines.forEach(function(title) {
                            innerHtml += '<tr><th>' + title + '&nbsp;<br><span style="text-decoration:underline;"> '+phenotype+ '</span></th></tr>';

                        });
                        innerHtml += '</thead><tbody>';

                        bodyLines.forEach(function(body, i) {
                            const colors = tooltipModel.labelColors[i];
                            let style = 'background:' + colors.backgroundColor;
                            style += '; border-color:' + colors.borderColor;
                            style += '; border-width: 2px';
                            const span = '<span style="' + style + '"></span>';
                            innerHtml += '<tr><td>' + span + body + '</td></tr>';

                            for(var item=0;item<details.length;item++)
                                innerHtml += '<tr><td >' +details[item] + '</td></tr>';
                            innerHtml += '</tbody>';
                        });



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
            },
                callbacks: {
                    label: function(tooltipItem, all) {
                        if(tooltipItem.datasetIndex==0){
                        var label1= all.datasets[tooltipItem.datasetIndex].label
                            + ': ' + tooltipItem.yLabel.toLocaleString()
                          //  + (all.datasets[tooltipItem.datasetIndex].errorBars[tooltipItem.label].plus ?  '\u00B1' + all.datasets[tooltipItem.datasetIndex].errorBars[tooltipItem.label].plus.toLocaleString() : '');


                            return label1;
                        }
                    else
                            var label2=all.datasets[tooltipItem.datasetIndex].label  + ': ' + tooltipItem.yLabel.toLocaleString();
                            return label2;

                    }
                }
            },
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
            var cellLength=  document.getElementById("mytable").rows[0].cells.length
            var recordIdIndex=0;
            for(var j=0;j<cellLength;j++){
               var cellText= document.getElementById("mytable").rows[0].cells[j].innerHTML;
                if(cellText.includes( "Record ID")){
                    recordIdIndex=j;
                }
            }
            for(var i=0;i<rowLength;i++){
                var value= document.getElementById("mytable").rows[i].cells.item(10-missedColumnCount).innerHTML;
               var recordId= document.getElementById("mytable").rows[i].cells.item(recordIdIndex).innerHTML;
              //      console.log(recordId)
                var valueObj={}
                    valueObj.id=recordId;
                    valueObj.value=value;
                //console.log(value);
          //      if(!sortedValues.includes(value))

             //   sortedValues.push(value);
                sortedValues.push(valueObj);
            }
       //     console.log("sortedValues:"+ sortedValues)
            sampleDataLength=${fn:length(sampleData)}
            sampleData=${sampleDataJson}
            arrayLabel = ${labels}
                <c:forEach items="${plotData}" var="plot">
                arrayData = ${plot.value}
                    </c:forEach>
                    arrayColors=${backgroundColor}
                    arrayErrorBars=${errorBars}
                        arrayRecordIds=${recordIds}
                        arrayOfObj = arrayLabel.map(function(d, i) {
                          //  console.log(sampleData[i])
                            var individualData=[];
                            for(var s=0;s<sampleDataLength;s++){
                             /*   sampleData[s].forEach(function (a) {
                                    console.log("HELLO:"+a);
                                })*/
                             var array=sampleData[s];
                             individualData.push(array[i])
                            }
                     //   console.log("INDIVIDUAL DATA:"+i+":"+individualData)
                            return {
                                label: d,
                                data: arrayData[i] || 0,
                                bgColor:arrayColors[i],
                                errorBars:arrayErrorBars[d],
                               individuals:individualData,
                                recordId:arrayRecordIds[i]
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
            newArrayIndividuals=[];
            var data=[];
            var j=0;
            sortedArrayOfObj.forEach(function(d){
                newArrayLabel.push(d.label);
                newArrayData.push(d.data);
                newArrayBackgroundColor.push(d.bgColor);
                newErrorBars[d.label]=arrayErrorBars[d.label]
                newArrayIndividuals[j]=(d.individuals);
                j++;
            });
          //  for(var k=0;k<newArrayIndividuals.length;k++)
         //   console.log("newArrayIndividuals:"+ k+":"+ newArrayIndividuals[k]);
            myChart.data.labels=newArrayLabel;

            data.push({
                label:"Value",
                data: newArrayData ,
                backgroundColor:newArrayBackgroundColor,
                errorBars:newErrorBars,
                borderWidth: 1,
                borderColor:"gray"
            });
            var counter=0;
            if(newArrayIndividuals.length>0) {
                for(var p=0;p<sampleDataLength;p++) {
                    var sortedArray = [];
                    for (var q = 0; q < newArrayIndividuals.length; q++) {
                        var array = newArrayIndividuals[q];
                        if(typeof array!='undefined')
                        sortedArray.push(array[p])
                    }
                    data.push({
                        label: "Individual Sample Value - " + counter,
                        data: sortedArray,
                        type: "scatter",
                        backgroundColor: "red",
                        showLine: false


                    });
                    counter++;
                }

            }
           // console.log("DATA:"+ JSON.stringify(data))

            myChart.data.datasets=data;
            myChart.update();
            document.getElementById("chartDiv").style.display = "block";
            document.getElementById("resultChart").style.display = "block";
        }



        function sortByValues(sortedValues, arrayOfObj) {
            var sortedObjArray=[];
            var loadedPositions=[];
            for(var j=0;j<arrayOfObj.length;j++){
            for(var i=0;i<sortedValues.length;i++){

                //    if(arrayOfObj[j].data==sortedValues[i] && arrayOfObj[j].data!=0) {
                if(arrayOfObj[j].data==sortedValues[i].value && arrayOfObj[j].recordId==sortedValues[i].id) {
                        if (!loadedPositions.includes(i)) {
                            sortedObjArray[i] = arrayOfObj[j];
                            loadedPositions.push(i)
                            break;
                    }
                    }
                }

            }

            /*    for (var j = 0; j < arrayOfObj.length; j++) {
                    if (arrayOfObj[j].data == 0) {
                        sortedObjArray.push(arrayOfObj[j])
                    }

            }*/
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
        function getPhenotype(index) {
            var table = document.getElementById('mytable');
            var j = 0;
            var rowLength = table.rows.length;
            var avgIndex = table.rows.item(0).cells.length;
            for (i = 1; i < rowLength; i++) {
                if (table.rows.item(i).style.display !== 'none') {
                    if (j === index) {
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(label=='Phenotype'  )
                                return value;
                        }

                    }
                    j++;
                }
            }
            return detail;
        }
        function getDetails(index) {
            //console.log("index:"+index)
            var table = document.getElementById('mytable');
            var j = 0;
            var detail = [];
            var rowLength = table.rows.length; // no. of rows
            var avgIndex = table.rows.item(0).cells.length; // no. of cells
            i=index+1;

       //     for (i = 1; i < rowLength; i++) { // iterating rows excluding header row
           //     if (table.rows.item(i).style.display !== 'none') {
           //         if (j == index) {

                        for(k = 1;k < avgIndex;k++){ // iterating over cells
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(value!='' && label!='Value' && (label=='SEM' || label=='SD'))
                            detail.push(label + ':&nbsp;' + value) ;
                        }
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(label=='Units'  )
                                detail.push(label + ':&nbsp;' + value) ;
                        }
                       /* for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(label=='Phenotype'  )
                                detail.push(label + ':<strong style="text-decoration:underline ">' + value+'</strong>') ;
                        }*/
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(value!='' && label!='Value' && label!='SEM' && label!='SD' && label!='Study ID' && label!='Study' && label!='Units' && label!='Phenotype' )
                                detail.push(label + ':&nbsp;' + value) ;
                        }
                        for(k = 1;k < avgIndex;k++){
                            var label = table.rows.item(0).cells.item(k).innerText;
                            var value = table.rows.item(i).cells.item(k).innerText;
                            if(label=='Study ID' || label=='Study' )
                                detail.push(label + ':&nbsp;' + value) ;
                        }
                //    }
               //     j++;
             //   }
          //  }
            return detail;
        }
    function generateData() {
        var data=[];
        errorBars=${errorBars}
        <!--c:forEach items="$-{plotData}" var="plot"-->
        data.push({
            label: "Value",
            data: ${plotData.Value},
            errorBars: ${errorBars},
            backgroundColor: ${backgroundColor},
            fill:false,
            borderWidth: 1,
            borderColor:"gray",
            stack:"stack 1"
        });
       <c:if test="${fn:length(sampleData)>0}">
        <c:set var="i" value="0"/>
        <c:forEach items="${sampleData}" var="d">
        data.push({
           label: "Individual Sample Value - "+${i},
            data: ${d.value},
            type: "scatter",
            backgroundColor:"red",
            showLine: false


        });
        <c:set var="i" value="${i+1}"/>
        </c:forEach>
        </c:if>
        <!--/c:forEach-->
        return data;
    }
</script>