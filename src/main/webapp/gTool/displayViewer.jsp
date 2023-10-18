<%@ page contentType="text/html;charset=windows-1252"
         import="edu.mcw.rgd.dao.impl.GeneDAO,edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.QTLDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.MapData" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.List" %>


<%
    String pageTitle = "Web Genome Viewer - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.";

%>
<script type="text/javascript" src="/rgdweb/gviewer/script/jkl-parsexml.js">
// ================================================================
//  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML
//  Copyright 2005-2007 Kawasaki Yusuke <u-suke@kawa.net>
//  http://www.kawa.net/works/js/jkl/parsexml.html
// ================================================================
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/dhtmlwindow.js">
/***********************************************
* DHTML Window script- © Dynamic Drive (http://www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/util.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/gviewer.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/domain.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/contextMenu.js">
/***********************************************
* Context Menu script- © Dynamic Drive (http://www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/event.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/ZoomPane.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/gviewer/css/gviewer.css" />

<table  cellpadding=0 cellspacing=0 align="center" border="0" width="100%">
    <tr>
        <td align="center"><div id="gviewer" class="gviewer"></div><div id="zoomWrapper" class="zoom-pane"></div></td>
    </tr>
</table>



<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    String genes = req.getParameter("genes");
    String qtls = req.getParameter("qtls");
    String strains = req.getParameter("strains");
    String markers = req.getParameter("markers");

    String types= "";

    if (!genes.equals("")) {
        types += "'gene'";
    }

    if (!qtls.equals("")) {
        if (types.length()> 0) {
            types +=",";
        }
        types += "'qtl'";
    }

    if (!strains.equals("")) {
        if (types.length()> 0) {
            types +=",";
        }
        types += "'strain'";
    }

    if (!markers.equals("")) {
        if (types.length()> 0) {
            types +=",";
        }
        types += "'marker'";
    }


%>



<script>
var gviewer = null;

    if (!gviewer) {
        gviewer = new Gviewer("gviewer", <%=req.getParameter("height")%>, <%=req.getParameter("width")%> );

        gviewer.imagePath = "/rgdweb/gviewer/images";
        gviewer.exportURL = "/rgdweb/report/format.html";


        gviewer.annotationTypes = new Array(<%=types%>);

        gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
        //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
        gviewer.genomeBrowserName = "JBrowse";
        gviewer.regionPadding=2;
        gviewer.annotationPadding = 1;

        species = <%=req.getParameter("species")%>;

        if (species == 3) {
            gviewer.loadBands("/rgdweb/gviewer/data/rgd_rat_ideo.xml");
        }else if (species == 1) {
            gviewer.loadBands("/rgdweb/gviewer/data/human_ideo.xml");
        }else {
            gviewer.loadBands("/rgdweb/gviewer/data/mouse_ideo.xml");
       }

        gviewer.addZoomPane("zoomWrapper", <%=req.getParameter("height")%>, <%=req.getParameter("width")%>);
    }else {
        gviewer.reset();
    }
<%

    GeneDAO gdao = new GeneDAO();
    MapDAO mdao = new MapDAO();

    String errors = "";

      for (String match: Utils.symbolSplit(req.getParameter("genes"))) {
        try {
            Gene gene = gdao.getGenesBySymbol(match, Integer.parseInt(req.getParameter("species")));

            String assembly = req.getParameter("assembly");
            if (assembly.equals("")) {
                assembly = mdao.getPrimaryRefAssembly(Integer.parseInt(req.getParameter("species"))).getKey() + "";
            }

            List<MapData> mdList = mdao.getMapData(gene.getRgdId(),Integer.parseInt(assembly));

            if (mdList.size() > 0) {
                MapData md = mdList.get(0);
            %>
                gviewer.loadAnnotation(<%=md.getStartPos()%>,<%=md.getStopPos()%>,'Gene','<%=gene.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.gene(gene.getRgdId())%>','<%=req.getParameter("geneColor")%>','<%=md.getChromosome()%>');
            <%
            }
        }catch (Exception e) {
             errors += match + " ";
        }
    }

    if (!errors.equals("")) {
        out.print("alert('Genes (" + errors + ") not found');");
    }

    errors="";

    QTLDAO qdao = new QTLDAO();

    for (String match: Utils.symbolSplit(req.getParameter("qtls"))) {

        try {
            QTL qtl = qdao.getQTLBySymbol(match, Integer.parseInt(req.getParameter("species")));
            List<MapData> mdList = mdao.getMapData(qtl.getRgdId(),Integer.parseInt(req.getParameter("assembly")));

            if (mdList.size() > 0) {
                MapData md = mdList.get(0);
            %>
                gviewer.loadAnnotation(<%=md.getStartPos()%>,<%=md.getStopPos()%>,'qtl','<%=qtl.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.qtl(qtl.getRgdId())%>','<%=req.getParameter("qtlColor")%>','<%=md.getChromosome()%>');
            <%
            }
        }catch (Exception e) {
             errors += match + " ";
        }
    }

    if (!errors.equals("")) {
        out.print("alert('QTLs (" + errors + ") not found');");
    }


%>
</script>
