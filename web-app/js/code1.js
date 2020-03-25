$(function() {
    var cy = cytoscape({
        container: document.getElementById("cy"),
        boxSelectionEnabled: false,
        style: [
            {
              selector:'core',
                css:{
                    "selection-box-color":"#AAD8FF",
                    "selection-box-border-color":"#8BB0D0","selection-box-opacity":"0.5"
                }
            },
            {


                selector: 'node',

                css: {
                    'height': 60,
                    'width': 60,
                    'background-color':'data(nodeColor)',
                    'label': 'data(name)',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'font-size': '12px',
                    'color': 'black',
                    'overlap':'false',
                    "overlay-padding":"6px","z-index":"10"
                }
            },


            {
                selector: 'edge',
                css: {

                    'line-color':'data(typeColor)',
                    'edge-text-rotation': 'autorotate',
                    'font-size': '12px',
                    directed:true,
                    padding:10
                }
            },

            {
                selector: 'node.active',
                css: {
                    "shape": "cirlce",
                    "border-width": "6px",
                   "border-color": "darkorange",
                    "border-opacity": "0.5",
                    "background-color": "data(nodeColor)",
                    'label': 'data(name)',
                    'font-size': '20px',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'text-outline-color': '#555',
                    'text-outline-width': 3,
                    'text-background-opacity': 1,
                    'text-background-color': '#555',
                    'text-background-shape': 'roundrectangle',
                    'text-border-color': '#000',
                    'text-border-opacity': 1,
                    'color': '#fff',
                    'width': 50,
                    'height': 50
                }
            },
            {
                selector: 'edge.active',
                css: {"line-color": "data[typeColor]", 'width': '6px'}
            },
            {
                selector: '.faded',
                css: {'opacity': 0.25, 'text-opacity': 0}
            },

            {
                selector: 'edge.typeOn',
                css: {'line-color': 'data(typeColor)', 'width': 6 }
            },
            {
                selector: 'node.Q',
                css: {'background-color': 'yellow', 'shape': 'cirlce', 'border-width': '20px', 'border-color': 'data(nodeColor)', 'width':100, 'height':100, 'border-opacity':0.4, 'text-background-color':'yellow'}
            },
            {
                selector: 'node.hover',
                css: {
                    'background-color': '#ff9999',
                    'width': 60,
                    'height':60,
                    'shape': 'circle',
                    'border-width': '10px',
                    'border-color': 'dodgerblue',
                    'label': 'data(name)',
                    'font-size': '20px',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'text-outline-color': '#555',
                    'text-outline-width': 3,
                    'text-background-opacity': 1,
                    'text-background-color': '#555',
                    'text-background-shape': 'roundrectangle',
                    'text-border-color': '#000',
                    'text-border-opacity': 1,
                    'color': '#fff',
                    'border-opacity': 0.4

                }
            },
            {
                selector: 'edge.hover',
                css: {'width': '6px'}
            },
            {
                selector: 'node.common',
                css: {'background-color': 'data(nodeColor)', 'line-color': 'yellow', 'width':80, 'height':80, 'text-background-color':'#555', 'font-size':30}
            },

            {
              selector:'edge.common',
                css:{'line-color': 'data(typeColor)','width':5}
            },
            {
                selector: 'edge.highlight',
                css: {'line-color': 'data(typeColor)', 'width': 5}
            },
            {
                selector: 'node.highlight',
                css: {'background-color': 'data(nodeColor)', 'width':80, 'height':80, 'label': 'data(name)',
                    'font-size': '20px',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'text-outline-color': '#555',
                    'text-outline-width': 3,
                    'text-background-opacity': 1,
                    'text-background-color': '#555',
                    'text-background-shape': 'roundrectangle',
                    'text-border-color': '#000',
                    'text-border-opacity': 1,
                    'color': '#fff'}
            },
            {
                selector: 'edge.highlightN',
                css: {'line-color': 'data(typeColor)', 'width': 6}
            },
            {
                selector: 'node.highlightN',
                css: {

                    'background-color': 'data(nodeColor)', 'width':50, 'height':50, 'label': 'data(name)',
                    'font-size': '20px',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'text-outline-color': '#555',
                    'text-outline-width': 3,
                    'text-background-opacity': 1,
                    'text-background-color': '#555',
                    'text-background-shape': 'roundrectangle',
                    'text-border-color': '#000',
                    'text-border-opacity': 1,
                    'color': '#fff'}
            },
            {
                selector:'node.highlightNspecial',
                css:{

                   // 'background-color': 'data(nodeColor)',  /*'border-color': '#00ffcc', 'border-width':'6',*/ 'width':100, 'height':100, 'label': 'data(name)',
                   'overlay-color':'#99ff99',
                    'overlay-padding':60,
                   'overlay-opacity':0.3,
                    'width':80, 'height':80,
                    'font-size': '20px',
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'text-outline-color': '#555',
                    'text-outline-width': 3,
                    'text-background-opacity': 1,
                    'text-background-color': '#555',
                    'text-background-shape': 'roundrectangle',
                    'text-border-color': '#000',
                    'text-border-opacity': 1,
                    'color': '#fff'
                }
            }


        ],
        elements: {
            nodes: nodesList,
            edges: edgesList
        },
        position: {
            x: 100,
            y: 100
        },
        layout: {
            name: 'cose',
            nodeSpacing: 5,
         //   animate: true,
            randomize:true,
            overlap:false,
         //   maxSimulationTime: 1500,
            ready: function () {},
            stop: function () {}
        },
        pixelRatio: 'auto'

    });
    cy.navigator({
        container: false // can be a HTML or jQuery element or jQuery selector
        , viewLiveFramerate: 0 // set false to update graph pan only on drag end; set 0 to do it instantly; set a number (frames per second) to update not more than N times per second
        , thumbnailEventFramerate: 30 // max thumbnail's updates per second triggered by graph updates
        , thumbnailLiveFramerate: false // max thumbnail's updates per second. Set false to disable
        , dblClickDelay: 200 // milliseconds
        , removeCustomContainer: true // destroy the container specified by user on plugin destroy
        , rerenderDelay: 100 // ms
    });
    $("#cy").cytoscapePanzoom({
        zoomFactor: 0.05, // zoom factor per zoom tick
        zoomDelay: 45, // how many ms between zoom ticks
        minZoom: 0.1, // min zoom level
        maxZoom: 10, // max zoom level
        fitPadding: 50, // padding when fitting
        panSpeed: 10, // how many ms in between pan ticks
        panDistance: 10, // max pan distance per tick
        panDragAreaSize: 75, // the length of the pan drag box in which the vector for panning is calculated (bigger = finer control of pan speed and direction)
        panMinPercentSpeed: 0.25, // the slowest speed we can pan by (as a percent of panSpeed)
        panInactiveArea: 8, // radius of inactive area in pan drag box
        panIndicatorMinOpacity: 0.5, // min opacity of pan indicator (the draggable nib); scales from this to 1.0
        autodisableForMobile: true, // disable the panzoom completely for mobile (since we don't really need it with gestures like pinch to zoom)
        // icon class names
        sliderHandleIcon: 'fa fa-minus',
        zoomInIcon: 'fa fa-plus',
        zoomOutIcon: 'fa fa-minus',
        resetIcon: 'fa fa-expand'
    });
  /*  $("#cy").cytoscapeNavigator({
        container: false,
        viewLiveFramerate: 0,
        thumbnailEventFramerate: 30,
        thumbnailLiveFramerate: false,
        dblClickDelay: 200

    });*/
   
  /* var eles= cy.elements().nodes();
    $.each(eles, function () {
        var dc=cy.$().dc({root: this}).degree;
        var btwn=cy.$().bc().betweennessNormalized(this);
        if(btwn>0){
            this.css({'width':(btwn*100) + 70,"height": (btwn*100)+70});
        //   this.style("width", (btwn*100) + 70).style("height", (btwn*100)+70);
        }
    });
*/
  /*  $("#cy").cytoscape(function () {
        var bcList= cy.elements().nodes().map(function (ele) {
            var dc=cy.$().dc({root: ele}).degree;
            var btwn=cy.$().bc().betweennessNormalized(ele);
            //   console.log(dc + "||" + btwn);
            //    if(dc<100)
            //   ele.style("width", 500*btwn+ dc+30).style("height", 500*btwn + dc+30);
            // else
            //   ele.style("width", 10*btwn+(dc/20)).style("height",10*btwn+(dc/20));
            return dc;
        });
        //    var maxbtwn=Math.max.apply(null, bcList);
        var maxDegree= Math.max.apply(null, bcList);
        // console.log(maxbtwn);
        console.log(maxDegree);
   });*/
   
    /* cy.on('tap', 'edge', function(){
     try{
     window.open(this.data('href'));

     }catch(e){
     window.location.href=this.data('href');
     }
     });*/


   
    cy.nodes().forEach(function (n) {
        var g = n.data('id');
    //    var gUrl = n.data('href');
        var uUrl = n.data('uniprotUrl');
        var speciesTypeKey= n.data('speciesTypeKey');
        var geneSymbolCount= n.data('geneSymbolCount');
        var gUrl;
       if(geneSymbolCount>1) {
           gUrl = "/rgdweb/search/genes.html?term=" + g + "&speciesType=" + speciesTypeKey;

       }else {
           gUrl=n.data('href0');
       }
        
        n.qtip({
            content: [
                {
                    name: g+' (Uniprot ID)',
                    url: uUrl
                },
                {
                    name: 'Gene Report',
                    url: gUrl
                }
            ].map(function (link) {
                return '<a target="_blank" href="' + link.url + '">' + link.name + '</a>';
            }).join('<br />\n'),
            position: {
                my: 'top center',
                at: 'bottom center'

            },
            style: {
                classes: 'qtip-bootstrap',
                tip: {
                    width: 16,
                    height: 8
                }
            }
        });

    });
  
    cy.on('tap', 'node', function () {
        window.location.href="#textDiv";
        var div = document.getElementById("textDiv");
        var hrefCount= this.data('hrefCount');
        var geneSymbolCount= this.data('geneSymbolCount');
        var innerhtml="<p style='font-weight: bold;text-decoration: underline'>Node:</p>" +
            "<table class=\"details\" style='font-size: 12px;border:1px solid lightgrey;border-radius:10px;background-color:#cce6ff'>" +
            "<tr><td style='font-weight: bold'>ObjectType:</td><td>Protein</td></tr>" +
            "<tr><td style='font-weight: bold'>Uniprot ID</td><td>" + "<a href=\"" + this.data('uniprotUrl') + "\">" + this.data('id') + "</a></td></tr>" +
            "<tr><td style='font-weight: bold'>Species:</td><td>" + this.data('species') + "</td></tr><tr><td style='font-weight: bold'>Gene: </td><td>" ;

        var first=true;

        for(var i=0; i<geneSymbolCount;i++){
            var gene="gene" + i;

            if(first==true){
                innerhtml=innerhtml+this.data(gene);
                first=false;
            }else{
                innerhtml=innerhtml  + ", "+ this.data(gene) ;
            }

        }
        innerhtml=innerhtml+ "</td></tr>";
        innerhtml=innerhtml+  "<tr><td style='font-weight: bold'>Description: </td><td>" + this.data('description') + "</td></tr></table>";
        div.innerHTML = innerhtml;
    });

   

    cy.on('tap', 'edge', function () {
        var imexCount= this.data('imexcount');
        var pubmedCount= this.data('pubmedcount');
        var intAcCount=this.data('intAccount');
        var sourcedbCount=this.data('sourcedbcount');
        var otherIdCount= this.data('othercount');
        window.location.href="#textDiv";
        var div = document.getElementById("textDiv");
        var innerhtml="<p style='font-weight: bold;text-decoration: underline'>Edge Details</p>" +
            "<table class=\"details\" style='font-size: 12px;border:1px solid lightgrey;border-radius:10px;background-color:#cce6ff'>" +
            "<tr><td  style='font-weight: bold'>Type</td>  <td>Interaction</td> </tr>" +
            "<tr><td  style='font-weight: bold'>Name:</td><td>" + this.data('name') + "</td> </tr>" +
            "<tr><td  style='font-weight: bold'>Interaction Type</td> <td>" + this.data('description') + "<a href=" + this.data('ontUrl') + " target=\"_blank\" title=\"Ontology Lookup\">" + "<img src=\"/rgdweb/common/images/tree.png\">" + "</a></td></tr>" +
            "<tr><td  style='font-weight: bold'>Source DB</td>";
        for(var i=0;i<sourcedbCount;i++){
            var attNameDb= "sourcedb" + i ;
          innerhtml= innerhtml+ "<td>" + this.data(attNameDb)+ "<br>";
        //    alert(this.data(attNameDb));
        }
        innerhtml=innerhtml+ "</td></tr>" +
            "<tr><td  style='font-weight: bold'>IMEX ID</td>"  ;
        for(var j=0; j<imexCount;j++){
            var attNameIM="imex" + j;
            innerhtml=innerhtml+"<td><a href=" + this.data('imexUrl') + this.data(attNameIM) + " target=\"_blank\">" + this.data(attNameIM) + "</a>";

        }
        innerhtml=innerhtml+"</td></tr>" +
            "<tr><td  style='font-weight: bold'>Interaction AC</td>" ;
        for(var k=0;k<intAcCount;k++){
            var attNameIntAc= "intAc" + k;
            innerhtml=innerhtml+"<td><a href=" + this.data('imexUrl') + this.data(attNameIntAc) + " target=\"_blank\">" + this.data(attNameIntAc) + "</a>";

        }
        innerhtml=innerhtml+"</td></tr>" +
            "<tr><td  style='font-weight: bold'>PUBMED ID</td>" ;
        for(var l=0;l<pubmedCount;l++){
            var attNamePubmed= "pubmed" +l;
            innerhtml=innerhtml+"<td><a href=" + this.data('pubmedUrl') + "?term=" + this.data(attNamePubmed) + " target=\"_blank\">" + this.data(attNamePubmed) + "</a>";
        }
        innerhtml=innerhtml+ "</td></tr>" +
            "<tr><td  style='font-weight: bold'>Other IDs</td>";
        for(var m=0;m<otherIdCount;m++){
            var attNameOther="other"+ m;
            innerhtml=innerhtml+"<td>" + this.data(attNameOther);
        }
        innerhtml=innerhtml+"</td></tr></table>";
        div.innerHTML=innerhtml;

    });


   cy.on('tap', 'node', function () {
        var nodes = this;

        var eles= cy.elements().filter('.active');
        cy.elements().addClass('faded');
        eles.removeClass('faded');

        if (nodes.hasClass('active')) {
            nodes.removeClass('active');
             nodes.connectedEdges().removeClass('active');
        } else {
            nodes.removeClass('faded');
            nodes.neighborhood().removeClass('faded');
            nodes.addClass('active');
            nodes.neighborhood().addClass('active');

        }

    });

    cy.on('tap', function (e) {
        if (e.cyTarget == cy){
            removeAll();
        }
    });
    function removeAll(){
        cy.elements().removeClass('faded').removeClass('active').removeClass('highlight').removeClass('highlightN').removeClass('H').removeClass('M').removeClass('R').removeClass('typeOn').removeClass('Q').removeClass('common');
        cy.elements().removeClass('highlightNspecial');
        cy.elements().removeStyle();
        $("input[name='species']").prop('checked', true);
        $("input[name='intType']").prop('checked', false);
        $("input[name='query']").prop('checked', false);
        $("input[name='common']").prop('checked', false);
        $(".noderow").removeClass('selected');
        $(".netrow").removeClass('selected');

    }
    cy.on('mouseover', 'node', function () {
        var eles = cy.elements();
        var nodes = this;
        if(nodes.hasClass("common")){
            nodes.style("width", 200).style("height", 200);
        }
        nodes.toggleClass("hover");
        nodes.connectedEdges().addClass("hover");

    });
    cy.on('mouseout', 'node', function () {
        var nodes= this;
        if(nodes.hasClass("common")){
            nodes.style("width", 100).style("height", 100);
        }
        this.removeClass("hover");
        this.connectedEdges().removeClass("hover");
    });

   
    var $dParams = $('#controls');
    var $rButton = $('<button class="btn-default" style="border-radius: 10px;border:1px solid grey">' + "Remove Selected Node" + '</button>');
    var $sButton = $('<button class="btn-default" style="border-radius: 10px;border:1px solid grey">' + "Restore" + '</button>');
    var $p = $('<p></p>');
    var $label = $('<label class="label-default" style="font-weight: bold">' + "Layout   :     " + '</label>');
    $dParams.append($rButton);
    $dParams.append($sButton);
    $rButton.on('click', function () {
        $("#cy").cytoscape(function () {
            var cy = this;
            var nodes = cy.nodes().filter(':selected');
            var edges = nodes.connectedEdges();
            nodes.remove();
            $sButton.on('click', function () {
                $("#cy").cytoscape(function () {
                    nodes.restore();
                    edges.restore();
                });
            });
        });

    });

  
    var selected = cy.collection();
    $(".netrow").click(function () {
        cy.elements().removeClass('faded').removeClass('active').removeClass('highlightN').removeClass('H').removeClass('M').removeClass('R').removeClass('typeOn').removeClass('Q').removeClass('common');
       //cy.elements().removeStyle();
        //  $(this).addClass("selected").siblings().removeClass("selected");
        if($(this).hasClass("selected")){
            $(this).removeClass("selected");
        }else {
            $(this).addClass("selected");
        }
        var $s = $(this).find(".src").html().trim();
        var $t = $(this).find(".t").html();
        var $type= $(this).find(".type").html();
        $("#cy").cytoscape(function () {
            var cy = this;
            //    var edges= cy.edges().filter('[target="'+ $t + '"]','[source="'+ $src + '"]');
            //   var edges= cy.edges('[target=\"'+ $t + '\"],[source=\"'+ $src + '\"]');
            var name = $s + "-->" + $t;
            var edges = cy.edges().filter('[source="' + $s + '"][target=\"' + $t + '\"][description=\"' + $type + '\"]');
            if (edges.hasClass('highlight')) {
                edges.removeClass('highlight').removeClass('faded');
                edges.neighborhood().removeClass('faded');
                //    edges.connectedNodes().removeClass('highlight').removeClass('faded');
            } else {
                edges.addClass('highlight');
                edges.connectedNodes().addClass('highlight');

            }
            var eles = cy.elements();
            var selected = eles.filter('.highlight');
            eles.addClass('faded');
            if (selected.neighborhood() != null) {
                selected.removeClass('faded');
                selected.connectedNodes().removeClass('faded');
            }
            //  alert($src +"  : " + $t);
        });
    });
   

    $(".noderow").click(function () {
        cy.elements().removeClass('faded').removeClass('active').removeClass('highlight').removeClass('H').removeClass('M').removeClass('R').removeClass('typeOn').removeClass('Q').removeClass('common');
       // cy.elements().removeStyle();
        if($(this).hasClass("selected")){
            $(this).removeClass("selected");
        }else {
            $(this).addClass("selected");
        }
        var $id = $(this).find(".id").html().trim();

        $("#cy").cytoscape(function () {
            var cy = this;

            var nodes = cy.nodes().filter('[id="' + $id + '"]');

          //  var eles= cy.elements().filter('.highlightN');
            var eles= cy.elements().filter('.highlightNspecial');
            var fadedNodes= cy.elements().filter(".faded");
            cy.elements().addClass('faded');
            if(nodes.hasClass('highlightNspecial')){
                eles.removeClass('faded');
                eles.neighborhood().removeClass('faded');
                nodes.removeClass('highlightNspecial');
                nodes.neighborhood().removeClass('highlightN');
                nodes.addClass('faded');
                nodes.connectedEdges().addClass('faded');

            }else{

                nodes.removeClass('faded');
                eles.removeClass('faded');
                eles.neighborhood().removeClass('faded');
                nodes.addClass('highlightNspecial');
                nodes.neighborhood().addClass('highlightN');
                nodes.neighborhood().removeClass('faded');
            }
        });
    });


    var $config = $('.grp1');
    var $typeUL = $('<ul style="list-style-type: none"></ul>');
    var types = typeMapJson;
    $.each(types, function (index, value) {
        $typeUL.append($('<li><input type="checkbox" name="intType" value=\'' + index + '\'>' + index + '</li>'))
    });
    $config.append($typeUL);

$("input[name='intType']").click(function(){
    var clas=this.value;
    var prop= $(this).prop("checked")==true;
  //  alert(this.value.toString())
    $.each(types, function (index, value) {
        if (index ==clas) {
            var color = value;
            $("#cy").cytoscape(function () {
                var cy = this;

            /*    cy.elements().removeClass('faded').removeClass('active').removeClass('highlight').removeClass('H').removeClass('M').removeClass('R').removeClass('Q').removeClass('common');
                $("input[name='species']").prop('checked', false);
                $("input[name='query']").prop('checked', false);
                $("input[name='common']").prop('checked', false);
                $(".noderow").removeClass('selected');
                $(".netrow").removeClass('selected');*/


                var edges = cy.edges().filter('[typeColor="' + color + '"]');
                cy.elements().addClass('faded');
                var typeOnEdges=  cy.elements().filter('.typeOn');
                typeOnEdges.removeClass('faded');
                typeOnEdges.connectedNodes().removeClass('faded');
                if(prop){
                    edges.addClass('typeOn');
                  //  edges.connectedNodes().style('border-color', color).style('border-width', 5).style('shape', 'circle').style('text-background-color', color);
                    edges.connectedNodes().addClass('typeOn');
                    edges.removeClass('faded');
                    edges.connectedNodes().removeClass('faded');
                 }else{
                    edges.removeClass('typeOn');
                  //  edges.connectedNodes().removeStyle('border-color', color).removeStyle('border-wdith', 2).removeStyle('shape','square').removeStyle('text-background-color', color);
                    edges.connectedNodes().removeClass('typeOn');
                }

            });
        }
    });


});

    var $config1 = $('.species');
    var $uls = $('<ul id="speciesul" style="list-style: none;"></ul>');
    var $lir = $('<li style="padding:0"><input type="checkbox" name="species" value="Rat" checked="checked">' + "Rat" + '</li>');
    var $lim = $('<li><input type="checkbox" name="species" value="Mouse" checked="checked">' + "Mouse" + '</li>');
    var $lih = $('<li><input type="checkbox" name="species" value="Human" checked="checked">' + "Human" + '</li>');
    var $lid = $('<li><input type="checkbox" name="species" value="Dog" checked="checked">' + "Dog" + '</li>');
    var $lip = $('<li><input type="checkbox" name="species" value="Pig" checked="checked">' + "Pig" + '</li>');


    $uls.append($lir);
    $uls.append($lim);
    $uls.append($lih);
    $uls.append($lid);
    $uls.append($lip);
    $config1.append($uls);
    $("input[name='species']").click(function(){
        var _this= this;
        var clas= this.value.toString().toLowerCase();
        var prop= $(this).prop("checked")==true;
        $("#cy").cytoscape(function () {
                var cy = this;
           /*     cy.elements().removeClass('faded').removeClass('active').removeClass('highlight').removeClass('typeOn').removeClass('Q').removeClass('common');
              //  cy.elements().removeStyle();
                $("input[name='intType']").prop('checked', false);
                $("input[name='query']").prop('checked', false);
                $("input[name='common']").prop('checked', false);
                $(".noderow").removeClass('selected');
                $(".netrow").removeClass('selected');*/
                var elesRat= cy.nodes().filter('.rat');
                var elesMouse=cy.nodes().filter('.mouse');
                var elesHuman=cy.nodes().filter('.human');
            var elesDog=cy.nodes().filter('.dog');
            var elesPig=cy.nodes().filter('.pig');
                var elesfaded=cy.nodes().filter('.faded');

                cy.elements().addClass('faded');
                elesRat.removeClass('faded');
                elesMouse.removeClass('faded');
                elesHuman.removeClass('faded');
            elesDog.removeClass('faded');
            elesPig.removeClass('faded');
                elesfaded.addClass('faded');

                   var nodes = cy.nodes().filter('.' + clas);
                if(prop){
                    nodes.removeClass('faded');
               }else{
                     nodes.addClass('faded');
                }
           });
    });

    var $configc = $('.commonint');
    var $ulc = $('<ul id="common"></ul>');
    var $lic = $('<li style=list-style-type:none><input type="checkbox" value="common" name="common">Common Interactors</li>');
    $ulc.append($lic);
    $configc.append($ulc);
    $("input[name='common']").click(function(){
        var _this=this;
        var checked= $(this).prop("checked")==true;
        $("#cy").cytoscape(function () {
            var cy = this;
            var commonNode = [];
            if(checked){
                removeAll();
                $(_this).prop("checked", true);
           /* var dfs =*/ cy.elements().dfs({
                roots: 'node',
                visit: function (i, depth) {
              //          console.log('visit: ' + i + "||" + this.id() + "Depth:" + depth);
               //        console.log("Degree Centrality: " + cy.$().dc({root:this}).degree);
                //       console.log("Betweennes: " + cy.$().bc().betweenness(this));
                  //   console.log("ClosenessCentrality: " + cy.$().cc({root: this}));
                    if (this.degree() >= 2) {
                        if (this.parallelEdges()) {
                            var v = this.neighborhood().connectedNodes();
                            // console.log(v.length);
                            // console.log(this.id());
                            if (v.length > 2) {
                              commonNode.push(this);
                               // callCommon(this);
                            }
                        }

                    }
                }
            });

            callCommon(commonNode);
        }
            else{
                cy.elements().removeClass('common').removeClass("faded");

            }
        });

    });

    function callCommon(nodes) {
       var eles = cy.elements();

       eles.addClass('faded');

      $.each(nodes, function (i, node) {
          console.log(nodes[i].data('id') + " other nodes ");
          $.each(nodes, function(j){
              if(nodes[j]!=node){
                  //  console.log(nodes[j].data("id"));
                  var edges= cy.elements().filter('[source="' + node.data("id") + '"][target="' + nodes[j].data("id") + '"]');
                   $.each(edges, function () {
                      // console.log(this.data("name"));
                       if(this.hasClass("common")){
                           this.removeClass("common");
                           this.connectedNodes().removeClass("common");
                       }else{
                           this.removeClass('faded');
                           this.addClass("common");
                           this.connectedNodes().removeClass("faded");
                           this.connectedNodes().addClass('common');
                       }

                   });
              }

          });
        });

    }
    var $configq = $('.q');
    var $ulq = $('<ul id="query" style="list-style-type:none"></ul>');
    var $liq= $('<li><input type=checkbox name="query" value="query">' + "Queried Objects" + '</li>');
    $ulq.append($liq);
    $configq.append($ulq);
    $("input[name='query']").click(function(){
        var _this=this;
        var checked= $(this).prop("checked")==true;
        var list = terms;
            $("#cy").cytoscape(function () {
                var cy = this;
                var nodes = cy.nodes();
               if(checked){
                   removeAll();
                   $(_this).prop("checked", true);
                    $.each(list, function (index, value) {
                        var str = value.toUpperCase();
                        $.each(nodes, function (index, node) {
                            var geneCount = this.data('geneSymbolCount');
                            for (var i = 0; i <= geneCount; i++) {
                            var str1= node.data('name').toLowerCase();
                                var str2= "(" + str.toLowerCase() +")";
                            if (node.data('id') == str || node.data('gene'+ i) == str || str1.indexOf(str2)!=-1) {
                                node.addClass('Q');
                            }
                        }
                        });
                    });
                }else{
                   nodes.removeClass("Q");
                }
            });
    });

    var $configl = $('.layout');
    var $ull = $('<ul id="radio"></ul>');
    var $lil1= $('<li><input type="radio" name="layout" value="cose" checked="checked">' + "cose" + '</li>');
    var $lil2= $('<li><input type="radio" name="layout" value="circle">' + "circle" + '</li>');
    var $lil3= $('<li><input type="radio" name="layout" value="grid">' + "grid" + '</li>');
    var $lil4= $('<li><input type="radio" name="layout" value="cola" >' + "cola" + '</li>');
    var $lil5= $('<li><input type="radio" name="layout" value="breadthfirst" >' + "breadthfirst" + '</li>');
   // var $lil6= $('<li><input type="radio" name="layout" value="springy">' + "springy" + '</a></li>');
    $ull.append($lil1);
    $ull.append($lil2);
    $ull.append($lil3);
    $ull.append($lil4);
    $ull.append($lil5);
  //  $ull.append($lil6);
    var options;
    $configl.append($ull);
    $("input[type='radio']").click(function(){
        var radioValue=$("input[name='layout']:checked").val();
        if(radioValue){
          //  alert("you selected: " + radioValue);
            options = {
                name: radioValue,
                nodeSpacing: 5
              //  directed:true,
              //  padding:10,
             //   edgeLengthVal: 45,
              //  animate: true,
             //   randomize: false,
             //   maxSimulationTime: 1500
            };
            var layout = makeLayout();
            var running = false;
            cy.on('layoutstart', function () {
                var running = true;
            }).on('layoutstop', function () {

            });
            layout.run();
        }

    });
    function makeLayout(opts) {
        options.randomize = false;
        for (var i in opts) {
            options[i] = opts[i];
        }
        return cy.makeLayout(options);
    }
 

 /*   var configG=$("#controls");
    var $ulG = $('<ul id="radio"></ul>');
    var $liG1= $('<li><input type="radio" name="remove" value="remove">' + "Remove Selected Node" + '</li>');
    var $liG2= $('<li><input type="radio" name="remove" value="restore">' + "Restore" + '</li>');
    $ulG.append($liG1);
    $ulG.append($liG2);
    configG.append($ulG);

    $("input[name='remove']").on('click', function () {
        var radioValue = $("input[name='remove']:checked").val();
        if (radioValue){
            $("#cy").cytoscape(function () {
                var cy = this;
                var nodes = cy.nodes().filter(':selected');
                var edges = nodes.connectedEdges();
                if(radioValue=='remove'){
                    nodes.remove();
                }else {
                           nodes.restore();
                           edges.restore();
                }
            });
    }
    });*/


 /*   var configNStat= $('#nodeStat');
    var $table= $("<table id='statTable'></table>");
    var $thRow= $("<th>Node</th><th>Degree Centrality</th><th>Betweenness Centrality</th><th>Closness Centrality</th>");
    $table.append($thRow);
    var commonNode = [];
    var dfs = cy.elements().dfs({
        roots: 'node',
        visit: function (i, depth) {
            var dc=cy.$().dc({root: this}).degree;
            var btwn=cy.$().bc().betweennessNormalized(this);
      //      var closeness=cy.$().cc({root: this});
            var id= this.id();
            //     console.log('visit: ' + i + "||" + this.id() + "Depth:" + depth);
            //      console.log("Degree Centrality: " + cy.$().dc({root: this}).degree);
            //      console.log("Betweennes: " + cy.$().bc().betweenness(this));
            //      console.log("ClosenessCentrality: " + cy.$().cc({root: this}));
            var $tr=$("<tr><td>" + id+ "</td><td style='text-align:center'>" + dc+ "</td><td>" + btwn + "</td></tr>");
            $table.append($tr);
            if (this.degree() >= 2) {
                if (this.parallelEdges()) {
                    var v = this.neighborhood().connectedNodes();
                    // console.log(v.length);
                    // console.log(this.id());
                    if (v.length > 2) {
                        commonNode.push(this);
                        // callCommon(this);
                    }
                }
            }
        }
    });
    configNStat.append($table);*/

/*************************************************************************************************************/

});
