<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.MiRnaTargetDAO" %>
<%@ page import="edu.mcw.rgd.dao.spring.StringMapQuery" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%
  String title=request.getParameter("title");
  int geneRgdId=Integer.parseInt(request.getParameter("geneRgdId"));
  String aspect=request.getParameter("aspect");
%>
<!DOCTYPE html>
<html>
<head>
  <script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>

  <script src="/rgdweb/common/cytoscape.min.js"></script>

<style type="text/css">
#cy {
      height: 640px;
      width: 770px;
      border: solid 1px blue;
    }
.cy_circle {
      width:10px;
      height:10px;
      border-radius:50%;
      display:inline-block;
      border:1px solid #a1a1a1;
}
</style>

<script>

/**
 * detect IE
 * returns version of IE or false, if browser is not Internet Explorer
 */
function detectIE() {
    var ua = window.navigator.userAgent;

    // test values
    // IE 10
    //ua = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)';
    // IE 11
    //ua = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko';
    // IE 12 / Spartan
    //ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0';

    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
        // IE 10 or older => return version number
        return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }

    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
        // IE 11 => return version number
        var rv = ua.indexOf('rv:');
        return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }

    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
        // IE 12 => return version number
        return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }

    // other browser
    return false;
}

var cyIsHidden = true;
$(function() {
    $( '#cy' ).on( 'visibility', function() {
        var $element = $( this );
        var timer = setInterval( function() {
            if( $element.is( ':hidden' ) ) {
                cyIsHidden = true;
            } else { // show\n" +
                if( cyIsHidden ) {
                    cyRun();
                    cyIsHidden = false;
                }
            }
        }, 350 );
    }).trigger( 'visibility' );
});

// remove all selections
function cyDeselectAll() {
   cy.nodes().removeClass('faded').removeClass('active');
   cy.edges().style('line-color','#ddd');
}

// remove all selections and to reset the chart to original size
function cyReset() {
   cyDeselectAll();
   cy.reset().fit();
}

// show mirna target genes annotated to top-level pathways
function cyShowPathways() {
   window.location.assign('/rgdweb/ontology/cy.html?aspect=W&geneRgdId=<%=geneRgdId%>'
        +'&title=Gene+targets+with+annotations+to+main+pathways');
}

// show mirna target genes annotated to top-level diseases
function cyShowDiseases() {
   window.location.assign('/rgdweb/ontology/cy.html?aspect=D&geneRgdId=<%=geneRgdId%>'
        +'&title=Gene+targets+with+annotations+to+main+disease+categories')
}

</script>

</head>
<body>

<script>
    var cy;

function cyRun(){

cy = cytoscape({
 container: document.getElementById('cy'),

 style: cytoscape.stylesheet()
    .selector('node')
      .css({
        'content': 'data(name)'
      })
    .selector('.gene')
      .css({
        'background-color': 'red'
      })
    .selector('.W') // pathways
      .css({
        'background-color': 'green'
      })
    .selector('.D') // diseases
      .css({
        'background-color': 'dodgerblue'
      })
    .selector('.faded').css({
            'opacity' : 0.25,
            'text-opacity' : 0
      })
    .selector('.faded2').css({
     })
    .selector('.active').css({
            'shape' : 'rectangle',
            'border-width': 3,
            'border-color': 'purple'
      })
    .selector('edge')
      .css({
        //    'target-arrow-shape': 'triangle',
        'width': 4,
        //    'target-arrow-color': '#ddd',
        'line-color': '#ddd'
      })
    .selector('.highlighted')
      .css({
        'background-color': '#61bffc',
        'line-color': '#61bffc',
        //    'target-arrow-color': '#61bffc',
        //    'transition-property': 'background-color, line-color, target-arrow-color',
        'transition-property': 'background-color, line-color',
        'transition-duration': '0.5s'
      }),

<% // generate nodes and edges
    AnnotationDAO annotDAO = new AnnotationDAO();
    MiRnaTargetDAO mirnaDAO = new MiRnaTargetDAO();

    Map<Integer,String> geneRgdIdToSymbolMap;
    Map<String,String> terms = new HashMap<String,String>(); // top level disease terms

    StringBuilder buf = new StringBuilder();
    StringBuilder edges = new StringBuilder();
    int edge = 0;

    try {
        geneRgdIdToSymbolMap = mirnaDAO.getSymbolsForMiRnaTargets(geneRgdId, "confirmed");
    } catch (Exception e) {
        geneRgdIdToSymbolMap = Collections.EMPTY_MAP;
    }
    int genes = 0;
    for( Map.Entry<Integer,String> entry: geneRgdIdToSymbolMap.entrySet() ) {

        List<StringMapQuery.MapPair> topLevelTermsForGene;
        try {
            if( aspect.equals("D") ) { // disease ontology - get first level top terms
                topLevelTermsForGene = annotDAO.getAnnotatedTopLevelTerms(entry.getKey(), aspect);
            } else { // pathway ontology - get second level top terms
                topLevelTermsForGene = annotDAO.getAnnotatedTopLevel2Terms(entry.getKey(), aspect);
            }
        } catch(Exception e) {
            topLevelTermsForGene = Collections.EMPTY_LIST;
        }

        if( topLevelTermsForGene.isEmpty() ) {
            continue;
        }
        if( genes>0 ) buf.append(",");
        genes++;
        buf.append("{ data: { id: '").append(entry.getKey()).append("', name: '").append(entry.getValue()).append("' }, classes: 'gene' }\n");

        for( StringMapQuery.MapPair pair: topLevelTermsForGene ) {
            if( terms.put(pair.keyValue, pair.stringValue)==null ) {
                //System.out.println("GENE RGDID:"+entry.getKey()+" "+entry.getValue()+" "+pair.keyValue+" "+pair.stringValue);

                buf.append(",");
                buf.append("{ data: { id: '").append(pair.keyValue).append("', name: \"").append(pair.stringValue).append("\" }, classes: '").append(aspect).append("' }\n");
            }

            if( edge>0 ) edges.append(",");
            edge++;
            edges.append("{ data: { id: 'e").append(edge).append("', source: '").append(entry.getKey()).append("', target: '").append(pair.keyValue).append("' }}\n");
        }
    }
%>
    elements: {
        nodes: [
            <%=buf.toString()%>
        ],
        edges: [
            <%=edges.toString()%>
        ]
    },

    layout: {
        name: 'cose',
        animate             : true,   // Whether to animate while running the layout
        refresh             : 10,  // Number of iterations between consecutive screen positions update (0 -> only updated on the end)
        fit                 : true, // Whether to fit the network view after when done
        padding             : 30,   // Padding on fit, default 30
        boundingBox         : undefined, // Constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }
        componentSpacing    : 100, // Extra spacing between components in non-compound graphs
        nodeRepulsion       : 400000, // Node repulsion (non overlapping) multiplier
        nodeOverlap         : 10, // Node repulsion (overlapping) multiplier, default 10
        idealEdgeLength     : 10,// Ideal edge (non nested) length, default 10
        edgeElasticity      : 100, // Divisor to compute edge forces, default 100
        nestingFactor       : 5, // Nesting factor (multiplier) to compute ideal edge length for nested edges, default 5
        gravity             : 80, // Gravity force (constant)
        numIter             : 1000, // Maximum number of iterations to perform
        initialTemp         : 200, // Initial temperature (maximum node displacement)
        coolingFactor       : 0.95, // Cooling factor (how the temperature is reduced between consecutive iterations
        minTemp             : 1.0, // Lower temperature threshold (below this point the layout will end)

        ready: function(){}, // on layoutready
        stop: function(){cyReady(cy);} // on layoutstop
    },

    wheelSensitivity: 0.5
});
}

function cyReady(cy) {

    // when selecting a node, select its neighbors and unselect the rest
    cy.on('tap', 'node', function(e) {
        var node = e.cyTarget;

        // toggle node active state
        if(node.hasClass('active')) {
            node.removeClass('active');

            // deactivate edges for the node becoming inactive
            node.connectedEdges().style('line-color','#ddd');
        } else {
            node.addClass('active');
        }

        var neighborhood = null;
        var selectedNodes = cy.$('node.active');
        for( var si=0; si<selectedNodes.length; si++ ) {
            var selNode = selectedNodes[si];
            var sss = selNode.neighborhood().add(selNode);
            if( neighborhood==null ) {
                neighborhood = sss;
            } else {
                neighborhood = neighborhood.add(sss);
            }
        }

        cy.batch(function(){
            cy.elements().addClass('faded');
            if(neighborhood!=null) {
                neighborhood.removeClass('faded');

                //var bxx = 50*Math.sqrt(neighborhood.length)/2;
                //node.lock();
                //neighborhood.layout({name: 'cose', animate:true, randomize:false, initialTemp: 30, refresh:1, coolingFactor: 0.75
                //    ,boundingBox:{x1:node.position().x-bxx, y1:node.position().y-bxx, x2:node.position().x+bxx, y2:node.position().y+bxx}
                //});
                //node.unlock();

                // activate edges for the node becoming active
                selectedNodes.connectedEdges().style('line-color', 'brown');
            }
        });
    });

    cy.on('tap', function(e) {
        if (e.cyTarget === cy) {
            cyDeselectAll(); // resets all selections
        }
    });

    cy.on('mouseover', 'node', function(e) {
        var node = e.cyTarget;
        if(node.hasClass('faded')) {
            node.removeClass('faded');
            node.addClass('faded2');
        }
    });

    cy.on('mouseout', 'node', function(e) {
        var node = e.cyTarget;
        if(node.hasClass('faded2')) {
            node.removeClass('faded2');
            if(!node.hasClass('active')) {
                node.addClass('faded');
            }
        }
    });

    // keep the font size fixed
    cy.on('zoom', function () {
        var dim = 12/ cy.zoom();
        cy.$('node').css({
            'width':dim, //keeps its original node size
            'height':dim,  //keeps its original node size
            'font-size':dim //redraw correctly only on node selection
        });
    });
}
</script>


<table style="width:100%">

<tr><td><b style="font-size:115%;"><%=title%></b></td></tr>

<tr><td><div id="cy">
</div></td></tr>

<tr><td>Legend:
  <div class="cy_circle" style="background-color:red"></div> - genes &nbsp; &nbsp;

<% if(aspect.equals("D") ) { %>
  <div class="cy_circle" style="background-color:dodgerBlue"></div> - main disease categories &nbsp;
<% } else { %>
  <div class="cy_circle" style="background-color:green"></div> - main pathways &nbsp;
<% } %>

<div style='padding-right:10px;float:right;'>
  <button onClick="cyReset();" title="reset selections and reset chart to original size">Reset Chart</button>

<% if(aspect.equals("D") ) { %>
  <button onClick="cyShowPathways();" title="show pathways instead of diseases" style="font-weight: bold;color:green">Show Pathways</button>
<% } else { %>
  <button onClick="cyShowDiseases();" title="show diseases instead of pathways" style="font-weight: bold;color:dodgerBlue">Show Diseases</button>
<% } %>
</div>

<div>
  <br>Click gene/disease/pathway circles to create subselections
  <br>Click outside of gene/disease/pathway circles to reset selections
  <br>Use mouse wheel to zoom in and out
</div>

</td></tr>

</table>
</body>
</html>
