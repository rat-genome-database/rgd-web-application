
function jsonFunction(){
    var cy;
    var cyJson;
    var eles;


    var mywindow = window.open();
    mywindow.document.write('<title>Network JSON</title><br />' +
        '<body>' +
        '<div style="border-bottom: 1px blue"><p style="font-weight: bold;font-size:20px">Report' +
        '<span><button style="border-radius:10px;margin:4px 2px;font-size:16px;text-align:center;border:none;background-color:lightsteelblue" onclick="window.print()" value="Print" name="Print">Print</button>' +
        '</span><span><button style="border-radius:10px;margin:4px 2px;font-size:16px;text-align:center;border:none;background-color:lightsteelblue" onclick="onsave()">Save</button></span></p></div>' +
        '<div>' );
    $("#cy").cytoscape(function(){
        cy= this;
        eles=cy.elements();
        cyJson= eles.json();
        $.each(cyJson, function(index, value){

             mywindow.document.write(value + '<br>');
        });

    });

       // mywindow.document.write(cyJson);

    mywindow.document.write('</div></body>');
    mywindow.document.close();
    mywindow.focus();
    //  mywindow.print();
    //  mywindow.close();
}
function reportFunction(){
    var cy;
    var cypng;
    $("#cy").cytoscape(function(){
        cy= this;
        cypng= cy.png();
    });
    var table= document.getElementById("dTable");
    var stattab= document.getElementById("stattab");
    var nodeTable = document.getElementById("nodetab");
    var mywindow = window.open();
    mywindow.document.write('<title>Report</title>' +
        '<body style="background-color:#555">' +
        '<div id="container" style="width:98%;background-color:white; margin-left:1%">' +
        '<img src="/rgdweb/common/images/rgd_LOGO_small.gif" alt="RGD" style="margin-left:20px">' +
        '<div style="border-bottom: 1px blue;margin-left:20px"><p style="font-weight: bold;font-size:20px">Report' +
        '<span><button style="border-radius:10px;margin:4px 2px;font-size:16px;text-align:center;border:none;background-color:lightsteelblue;cursor:pointer" onclick="window.print()" value="Print" name="Print">Print</button>' +
        '</span><!--span><button style="border-radius:10px;margin:4px 2px;font-size:16px;text-align:center;border:none;background-color:lightsteelblue" onclick="onsave()">Save</button></span--></p></div>' +
        '<div style="width:90%;margin-left:20px"><img style="border:1px dotted grey" style="width:50%;height:40%" src=\"'+ cypng + '\"></div>' +
        '<h4 style="margin-left:20px">Network Statistics</h4>' +
        '<div style="background-color:white;border:1px solid darkgrey;width:20%;height:10%;margin-left:20px;padding:15px">'+stattab.innerHTML +'</div>' +
        '<h4 style="margin-left:20px">Network [Interactions] Table</h4>' +
        '<div style="border:1px blue"><table style="width=100%;border:1px solid grey;margin-top:20px;margin-left:20px;font-size:12px;">' +
        ' <tr style="background-color: #cce6ff;"><th>Interactor A</th><th>Uniprot ID A</th><th>Gene A</th><th>Interaction Type</th><th>Interactor B</th><th>Uniprot_ID B</th><th>Gene B</th></tr>');

        for(var i= 0,row;row=table.rows[i] ;i++){
            if(i%2==0){
             mywindow.document.write('<tr style="background-color:#ccc">');
            }else{
                mywindow.document.write('<tr style="background-color:white">');
            }
               for(var j= 0, col;col=row.cells[j]; j++){
            mywindow.document.write('<td style="align-content: center">' + col.innerHTML + '</td>')
        }
        mywindow.document.write('</tr>')
    }
    mywindow.document.write ('</table></div>' +
      /*  '<h4 style="margin-left:20px">Node [Paricipants] Table</h4>' +
        '<div id="nodeTable" style="margin-left:20px">' + nodeTable.innerHTML+'</div>' +*/
        '</div></body>');
    mywindow.document.close();
    mywindow.focus();
    //  mywindow.print();
    //   mywindow.close();
   
}
function pngFunction() {

    var cy;
    var cypng;
    $("#cy").cytoscape(function () {
        cy = this;
        cypng = cy.png();
    });

    var mywindow = window.open();
    mywindow.document.write('<title>Print Network PNG</title><br />' +
        '<body>' +
        '<img src="/rgdweb/common/images/rgd_LOGO_small.gif" alt="RGD">' +
        '<div style="border-bottom: 1px blue"><p style="font-weight: bold;font-size:20px">Network Image' +
        '<span><button style="border-radius:10px;margin:4px 2px;font-size:16px;text-align:center;border:none;background-color:lightsteelblue" onclick="window.print()" value="Print" name="Print">Print</button>' +
        '</span><!--span><button style="border-radius:10px;margin:4px 2px;font-size:16px;text-align:center;border:none;background-color:lightsteelblue" onclick="onsave()">Save</button></span--></p></div>' +
        '<div><img style="border:1px dotted grey" src=\"' + cypng + '\"></div>' );
    mywindow.document.close();
    mywindow.focus();
//  mywindow.print();
//   mywindow.close();
}


