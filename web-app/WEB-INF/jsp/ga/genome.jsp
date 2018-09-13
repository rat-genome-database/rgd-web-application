<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>


<script type="text/javascript" src="/rgdweb/gviewer/script/jkl-parsexml.js">
// ================================================================
//  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML
//  Copyright 2005-2007 Kawasaki Yusuke <u-suke@kawa.net>
//  http://www.kawa.net/works/js/jkl/parsexml.html
// ================================================================
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/dhtmlwindow.js">
/***********************************************
* DHTML Window script- � Dynamic Drive (http://www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/util.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/gviewer.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/domain.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/contextMenu.js">
/***********************************************
* Context Menu script- � Dynamic Drive (http://www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/gviewer/script/event.js"></script>
<script type="text/javascript" src="/rgdweb/gviewer/script/ZoomPane.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/gviewer/css/gviewer.css" />
<script type="text/javascript" src="/rgdweb/js/sorttable.js" />


<html>
<body>

<%@ include file="gaHeader.jsp" %>
<%--@ include file="rgdHeader.jsp" --%>

<%@ include file="menuBar.jsp" %>


<%
    List error = (List) request.getAttribute("error");
    if (error.size() > 0) {
        Iterator eit = error.iterator();
        while (eit.hasNext()) {
            String emsg = (String) eit.next();
            out.println("<br><br><div style='color: red; ' >" + emsg + "</div>");

        }
        return;
    }

    System.out.println(om.getMapped().size());


%>

<% if (om.getMapped().size()==0) { %>
    <br>
    <div style="font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>
<%  return;
 } %>



<br><br>

<table class="sorttable"  style="border:2px solid #41789E; background-color: #F8F8F8;" cellpadding=0 cellspacing=0 align="center" border="0" width="95%"><tr><td align="center" ><div id="gviewer"  style="margin-top:25px; margin-bottom:25px;" class="gviewer"></div><div id="zoomWrapper" class="zoom-pane"></div></td></tr><tr><td align="center"><div style="margin-bottom:25px" id="geneList"></div></td></tr></table>


<script>

        var gviewer = null;

             if (!gviewer) {
                 gviewer = new Gviewer("gviewer", 250, 800);

                 gviewer.imagePath = "/rgdweb/gviewer/images";
                 gviewer.exportURL = "/rgdweb/report/format.html";
                 gviewer.annotationTypes = new Array("gene", "qtl","strain");
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

                 gviewer.addZoomPane("zoomWrapper", 250, 800);
             }else {
                 gviewer.reset();
             }


     <%
         MapDAO mdao = new MapDAO();

         String errors = "";
         Report r = new Report();
         Record rec = new Record();
         rec.append("Symbol");
         rec.append("Chromosome");
         rec.append("Start Position");
         rec.append("Stop Position");
         rec.append("Assembly");
         r.append(rec);

           for (String match: Utils.symbolSplit(om.getMappedAsString())) {
             try {
                 Gene gene = gdao.getGenesBySymbol(match, Integer.parseInt(req.getParameter("species")));

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(Integer.parseInt(req.getParameter("species"))).getKey() + "";
                 }

                 List<MapData> mdList = mdao.getMapData(gene.getRgdId(),Integer.parseInt(assembly));

                 if (mdList.size() > 0) {
                     MapData md = mdList.get(0);

                     rec = new Record();
                     rec.append("<a onclick='geneList(" + gene.getRgdId() + ")' href='javascript:void(0)'>" + gene.getSymbol() + "</a>");
                     rec.append(md.getChromosome());
                     rec.append(md.getStartPos() + "");
                     rec.append(md.getStopPos() + "");
                     rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                     r.append(rec);
                 %>
                     gviewer.loadAnnotation(<%=md.getStartPos()%>,<%=md.getStopPos()%>,'Gene','<%=gene.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.gene(gene.getRgdId())%>','<%=req.getParameter("geneColor")%>','<%=md.getChromosome()%>');
                 <%
                 }
             }catch (Exception e) {
                 e.printStackTrace();
                  errors += match + " ";
             }
         }

         if (!errors.equals("")) {
             out.print("alert('Genes (" + errors + ") not found');");
         }

        HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
        strat.setTableProperties("class=.gaTable width=800");
     %>

     document.getElementById("geneList").innerHTML = "<%=r.format(strat)%>";

  </script>


<br>

</body>
</html>