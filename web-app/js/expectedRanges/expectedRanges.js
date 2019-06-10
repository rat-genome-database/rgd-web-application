$(function () {
  
    $('.normalRadio').on('click', function () {
        var plotDiv=$('#rangeDiv');
     //   var html= plotDiv.html;
     //  console.log(html);
        plotDiv.html("");
        if(this.value=='Both'){ plotDiv.html(normalAll()); }
        if(this.value=='Male'){ plotDiv.html(normalMale());}
        if(this.value=='Female'){ plotDiv.html(normalFemale());}
        if(this.value==''){plotDiv.html(turnOffNormalRanges())}

    })
});
function normalAll(){
      var layout1 = {
        title: phenotype + ' - Expected Ranges',
        // showlegend:false
          yaxis:
              {
                  title:"<---------- "+yaxisTitle+" ---------->",
                  visible:true,
                  titlefont:{
                      family	:"Open Sans",
                      size	:	14,
                      color	:"#444"
                  }
              }
          ,

        shapes:[{
            'type':'line',
            'x0':-1,
            'y0':normalLow,
            'x1':x1,
            'y1':normalLow,
            'line':{
                'color':'red',
                'width':3,
                'dash':'dot'
            }
       },
           {
               'type':'line',
                'x0':-1,
                'y0':normalHigh,
                'x1':x1,
                'y1':normalHigh,
                'line':{
                    'color':'red',
                    'width':3,
                    'dash':'dot'
                }

            }]};
    Plotly.newPlot('rangeDiv', data, layout1);
}
function normalMale() {

    var layout1 = {
        title: phenotype + ' - Expected Ranges',
        // showlegend:false
        yaxis:
        {
            title:"<---------- "+yaxisTitle+" ---------->",
            visible:true,
            titlefont:{
                family	:"Open Sans",
                size	:	14,
                color	:"#444"
            },
            side	:"left"
        }
        ,
         shapes:[{
            'type':'line',
            'x0':-1,
            'y0':normalMaleLow,
            'x1':x1,
            'y1':normalMaleLow,
            'line':{
                'color':'blue',
                'width':3,
                'dash':'dot'
            }

        },
            {
                'type':'line',
                'x0':-1,
                'y0':normalMaleHigh,
                'x1':x1,
                'y1':normalMaleHigh,
                'line':{
                    'color':'blue',
                    'width':3,
                    'dash':'dot'
                }

            }]};
    Plotly.newPlot('rangeDiv', data, layout1);
  /*  Plotly.newPlot('jDiv', data, layout1);*/
}
function normalFemale() {
  
    var layout1 = {
        title: phenotype +' - Expected Ranges',
        yaxis:
        {
            title:"<---------- "+yaxisTitle+" ---------->",
            visible:true,
            titlefont:{
                family	:"Open Sans",
                size	:	14,
                color	:"#444"
            },
            side	:"left"
        }
        ,
        // showlegend:false

        shapes:[{
            'type':'line',
            'x0':-1,
            'y0':normalFemaleLow,
            'x1':x1,
            'y1':normalFemaleLow,
            'line':{
                'color':'fuchsia',
                'width':3,
                'dash':'dot'
            }

        },
            {
                'type':'line',
                'x0':-1,
                'y0':normalFemaleHigh,
                'x1':x1,
                'y1':normalFemaleHigh,
                'line':{
                    'color':'fuchsia',
                    'width':3,
                    'dash':'dot'
                }

            }]};
    Plotly.newPlot('rangeDiv', data, layout1);
  /*  Plotly.newPlot('jDiv', data, layout1);*/
}
function initialPlot(){

    var layout1 = {
        title: phenotype + ' - Expected Ranges',
        yaxis:
            {
                title:"<---------- "+yaxisTitle+" ---------->",
                visible:true,
                titlefont:{
                    family	:"Open Sans",
                    size	:	14,
                    color	:"#444"
                },
                side	:"left"
            }
       ,

         shapes:[{
         'type':'line',
         'x0':-1,
         'y0':normalLow,
         'x1':x1,
         'y1':normalLow,
         'line':{
         'color':'red',
         'width':3,
         'dash':'dot'
         }

         },
         {
         'type':'line',
         'x0':-1,
         'y0':normalHigh,
         'x1':x1,
         'y1':normalHigh,
         'line':{
         'color':'red',
         'width':3,
         'dash':'dot'
         }

         }]
    };
    Plotly.newPlot('rangeDiv', data, layout1);
  /*  Plotly.newPlot('jDiv', data, layout1);*/
}
function turnOffNormalRanges(){

    var layout1 = {
        title: phenotype + ' - Expected Ranges',
        yaxis:
        {
            title:"<---------- "+yaxisTitle+" ---------->",
            visible:true,
            titlefont:{
                family	:"Open Sans",
                size	:	14,
                color	:"#444"
            },
            side	:"left"
        }


      };
    Plotly.newPlot('rangeDiv', data, layout1);
  /*  Plotly.newPlot('jDiv', data, layout1);*/
}