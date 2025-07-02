<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="java.util.HashMap" %>

<html>


<script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>

  <script src="/rgdweb/js/jquery/jquery-ui-1.8.18.custom.min.js"></script>
  <script src="/rgdweb/js/jquery/jquery_combo_box.js"></script>


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
<script type="text/javascript" src="/rgdweb/js/sorttable.js" ></script>

<body>

<%
    //ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");

    HashMap<Integer,Object> resultSet = (HashMap<Integer,Object>) request.getAttribute("resultSet");

    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();
    HttpRequestFacade req= new HttpRequestFacade(request);
    int oKey = Integer.parseInt(req.getParameter("oKey"));

    List error = (List) request.getAttribute("error");
    if (error != null && error.size() > 0) {
        Iterator eit = error.iterator();
        while (eit.hasNext()) {
            String emsg = (String) eit.next();
            out.println("<br><br><div style='color: red; ' >" + emsg + "</div>");

        }
        return;
    }

    int speciesTypeKey= edu.mcw.rgd.datamodel.SpeciesType.getSpeciesTypeKeyForMap(Integer.parseInt(request.getParameter("mapKey")));

%>

<div style="padding-top:5px;padding-bottom:5px;"><%=SpeciesType.getTaxonomicName(speciesTypeKey)%></div>

<% if (resultSet.keySet().size()==0) { %>
    <br>
    <div style="font-size:20px; font-weight:700;"><%=resultSet.keySet().size()%> Genes in set</div>
<%  return;
 } %>


<table class="sorttable"  style="padding:5px; border-radius:10px; border:2px solid #41789E; background-color: #F8F8F8;" cellpadding=0 cellspacing=0 align="center" border="0" width="95%"><tr><td align="center" ><div id="gviewer"  style="margin-top:25px; margin-bottom:25px;" class="gviewer"></div><div id="zoomWrapper" class="zoom-pane"></div></td></tr><tr><td align="center"><div style="margin-bottom:25px" id="geneList"></div></td></tr></table>


<script>

        var gviewer = null;

             if (!gviewer) {
                 gviewer = new Gviewer("gviewer", window.screen.availHeight * .4, window.screen.availWidth * .8);

                 gviewer.imagePath = "/rgdweb/gviewer/images";
                 gviewer.exportURL = "/rgdweb/report/format.html";
                 gviewer.annotationTypes = new Array("gene");
                 gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
                 //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
                 gviewer.genomeBrowserName = "JBrowse";
                 gviewer.regionPadding=2;
                 gviewer.annotationPadding = 1;

                 species = <%=speciesTypeKey%>;
                 gviewer.loadBands("/rgdweb/gviewer/data/<%=req.getParameter("mapKey")%>" + "_ideo.xml");

                 gviewer.addZoomPane("zoomWrapper", 250, window.screen.availWidth * .8);
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

         Iterator it = resultSet.keySet().iterator();

         //for (String match: Utils.symbolSplit(om.getMappedAsString())) {
         //for (Integer rgdId: allObjects.keySet())) {
         while (it.hasNext()) {
             try {

             if (oKey == 1) {
                 Gene gene = (Gene)resultSet.get(it.next());

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
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
             }else if (oKey == 6) {
                 QTL qtl = (QTL)resultSet.get(it.next());

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
                 }

                 List<MapData> mdList = mdao.getMapData(qtl.getRgdId(),Integer.parseInt(assembly));

                 if (mdList.size() > 0) {
                     MapData md = mdList.get(0);

                     rec = new Record();
                     rec.append("<a onclick='geneList(" + qtl.getRgdId() + ")' href='javascript:void(0)'>" + qtl.getSymbol() + "</a>");
                     rec.append(md.getChromosome());
                     rec.append(md.getStartPos() + "");
                     rec.append(md.getStopPos() + "");
                     rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                     r.append(rec);
                 %>
                     gviewer.loadAnnotation(<%=md.getStartPos()%>,<%=md.getStopPos()%>,'Gene','<%=qtl.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.qtl(qtl.getRgdId())%>','<%=req.getParameter("qtlColor")%>','<%=md.getChromosome()%>');
                 <%
                 }

             } else if (oKey == 5) {
                 Strain strain = (Strain)resultSet.get(it.next());

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
                 }

                 List<MapData> mdList = mdao.getMapData(strain.getRgdId(),Integer.parseInt(assembly));

                 if (mdList.size() > 0) {
                     MapData md = mdList.get(0);

                     rec = new Record();
                     rec.append("<a onclick='geneList(" + strain.getRgdId() + ")' href='javascript:void(0)'>" + strain.getSymbol() + "</a>");
                     rec.append(md.getChromosome());
                     rec.append(md.getStartPos() + "");
                     rec.append(md.getStopPos() + "");
                     rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                     r.append(rec);
                 %>
                     gviewer.loadAnnotation(<%=md.getStartPos()%>,<%=md.getStopPos()%>,'Gene','<%=strain.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.qtl(strain.getRgdId())%>','<%=req.getParameter("qtlColor")%>','<%=md.getChromosome()%>');
                 <%
                 }

             }
             }catch (Exception e) {
                 e.printStackTrace();
                  //errors += match + " ";
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