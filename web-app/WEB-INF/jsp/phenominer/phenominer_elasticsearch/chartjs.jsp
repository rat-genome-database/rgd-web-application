<div class="chart-container" id = "chartDiv">
    <canvas id="resultChart" style="position: relative; height:80vh; width:80vw;"></canvas>

</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>

<script>
    $(function () {


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
                        labelString: 'Experiment Conditions',
                        fontSize: 14,
                        fontStyle: 'bold',
                        fontFamily: 'Calibri'
                    },


                    ticks:{
                        fontColor: "rgb(0,75,141)",
                        fontSize: 10,
                        autoSkip: false,
                        callback: function(t) {
                            var maxLabelLength = 40;
                            if (t.length > maxLabelLength) return t.substr(0, maxLabelLength-20) + '...';
                            else return t;

                        }
                    }
                }],
                yAxes: [{
                    id: 'delivery',
                    type: 'linear',
                    position: 'left',
                    ticks: {
                        beginAtZero: true
                    },
                    scaleLabel: {
                        display: true,
                        fontSize: 14,
                        fontStyle: 'bold',
                        fontFamily: 'Calibri'
                    }
                }, {
                    id: 'editing',
                    display: false,
                    type: 'linear',
                    position: 'right',
                    ticks: {
                        beginAtZero: true
                    },
                    scaleLabel: {
                        display: true,

                        fontSize: 14,
                        fontStyle: 'bold',
                        fontFamily: 'Calibri'
                    }
                }]
            },
            tooltips: {

                callbacks: {
                    title: function(tooltipItem) {
                        return this._data.labels[tooltipItem[0].index];
                    },
                    afterLabel: function(tooltipItem) {
                        var index = tooltipItem.index;
                        return index;
                    }

                }

            },

            hover: {
                mode: 'index',
                intersect: false
            },
            legend: {
                display: true
            }
        }
    });
    })
    function getRandomColor() {
        var letters = 'BCDEF'.split('');
        var color = '#';
        for (var i = 0; i < 6; i++ ) {
            color += letters[Math.floor(Math.random() * letters.length)];
        }
        return color;
    }



    function generateData() {

        var data=[];
        <c:forEach items="${plotData}" var="plot">
        data.push({
            label: "${plot.key}",
            data: ${plot.value},
            backgroundColor: getRandomColor(),
            borderColor:    getRandomColor(),
            borderWidth: 1
        });
        </c:forEach>




        return data;
    }


</script>