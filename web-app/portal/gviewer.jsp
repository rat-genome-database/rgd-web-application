





<script type="text/javascript" src="/rgdweb/gviewer/script/jkl-parsexml.js">
    // ================================================================
    //  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML
    //  Copyright 2005-2007 Kawasaki Yusuke <u-suke@kawa.net>
    //  http://www.kawa.net/works/js/jkl/parsexml.html
    // ================================================================
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/dhtmlwindow.js">
    /***********************************************
     * DHTML Window script- ï¿½ Dynamic Drive (http://www.dynamicdrive.com)
     * This notice MUST stay intact for legal use
     * Visit http://www.dynamicdrive.com/ for this script and 100s more.
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/util.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/gviewer.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/domain.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/contextMenu.js">
    /***********************************************
     * Context Menu script- ï¿½ Dynamic Drive (http://www.dynamicdrive.com)
     * This notice MUST stay intact for legal use
     * Visit http://www.dynamicdrive.com/ for this script and 100s more.
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/event.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/ZoomPane.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/gviewer/css/gviewer.css" />


    <div id="gviewer"  style="margin-top:25px; margin-bottom:25px;" class="gviewer"></div><div id="zoomWrapper" class="zoom-pane"></div>

<script>

    var gviewer = null;

    if (!gviewer) {
        gviewer = new Gviewer("gviewer", 250, 800);

        gviewer.imagePath = "/rgdweb/gviewer/images";
        gviewer.exportURL = "/rgdweb/report/format.html";
        gviewer.annotationTypes = new Array("gene");
        gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
        //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
        gviewer.genomeBrowserName = "JBrowse";
        gviewer.regionPadding=2;
        gviewer.annotationPadding = 1;

        species = 3;

        if (species == 3) {
            gviewer.loadBands("/rgdweb/gviewer/data/rgd_rat_ideo.xml");
        }else if (species == 1) {
            gviewer.loadBands("/rgdweb/gviewer/data/human_ideo.xml");
        }else {
            gviewer.loadBands("/rgdweb/gviewer/data/mouse_ideo.xml");
        }

        gviewer.addZoomPane("zoomWrapper", 250, 800);
    }else {
        gviewer.reset();
    }


    gviewer.loadAnnotation(154309426,154359138,'Gene','A2m','/rgdweb/report/gene/main.html?id=2004','','4');

    window.document.gviewer = gviewer;

    document.getElementById("geneList").innerHTML = "<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css?v=1'><table class=.gaTable width=800 /><tr class='headerRow' ><td  >Symbol</td><td  >Chromosome</td><td  >Start Position</td><td  >Stop Position</td><td  >Assembly</td></tr><tr class='evenRow' ><td  ><a onclick='geneList(2004)' href='javascript:void(0)'>A2m</a></td><td  >4</td><td  >154309426</td><td  >154359138</td><td  >Rnor_6.0</td></tr></table>";

    alert(window.parent)



</script>


