<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Genome Viewer";
    String headContent = "";
    String pageDescription = "";
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
<html>
<body>


<table class="sorttable"  style="border:2px solid #41789E; background-color: #F8F8F8;" cellpadding=0 cellspacing=0 align="center" border="0" width="95%">
    <tr>
        <td align="center" >
            <div id="gviewer"  style="margin-top:25px; margin-bottom:25px;" class="gviewer">
            </div><div id="zoomWrapper" class="zoom-pane"></div></td></tr><tr><td align="center">
            <div style="margin-bottom:25px" id="geneList"></div>
        </td>
    </tr>
</table>


<script>
// window.onload=function () {
var annotationType;
<%
String oKey= request.getParameter("oKey");
 if(oKey.equals("3")){%>
annotationType="sslp";
<% }%>
<% if(oKey.equals("5")){%>
annotationType="strain";
<%  }%>
<%   if(oKey.equals("6")){%>
annotationType="qtl";
<%  }%>
<%   if(oKey.equals("7")){%>
annotationType="variant";
<%   }%>
      var gviewer = null;
        if(!gviewer){

      gviewer = new Gviewer("gviewer", 250, 800);

      gviewer.imagePath = "/rgdweb/gviewer/images";
      gviewer.exportURL = "/rgdweb/report/format.html";
      gviewer.annotationTypes = new Array(annotationType);
      gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
      //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
      gviewer.genomeBrowserName = "JBrowse";
      gviewer.regionPadding=2;
      gviewer.annotationPadding = 1;

      species = <%=request.getParameter("species")%>;

      if (species == 3) {
          console.log(species);
          gviewer.loadBands("/rgdweb/gviewer/data/rgd_rat_ideo.xml");
      }else if (species == 1) {
          gviewer.loadBands("/rgdweb/gviewer/data/human_ideo.xml");
      }else {
          gviewer.loadBands("/rgdweb/gviewer/data/mouse_ideo.xml");
      }

      gviewer.addZoomPane("zoomWrapper", 250, 800);

 }else{
     gviewer.reset();
 }



    <%
        MapDAO mdao = new MapDAO();

        String errors = "";
        Report r = (Report) request.getAttribute("report");

//start,end,type,label,link,color,chrNumber
            try {
               List<Integer> rgdids= (List<Integer>)request.getAttribute("rgdIdsList");
               int mapKey= Integer.parseInt(request.getParameter("mapKey"));
               List<MapData> mapDatas= (List<MapData>) request.getAttribute("mapDataList");

               if(oKey.equals("5")){
               StrainDAO sdao= new StrainDAO();
                for(MapData m: mapDatas){
                Strain s= sdao.getStrain(m.getRgdId());
                if(m.getChromosome()!=null && m.getStartPos()!=null && m.getStopPos()!=null && m.getMapKey()!=null){
                %>

    gviewer.loadAnnotation(<%=m.getStartPos()%>,<%=m.getStopPos()%>,'strain','<%=s.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.strain(m.getRgdId())%>','','<%=m.getChromosome()%>');
    <%}}
    }
     if(oKey.equals("3")){
               SSLPDAO sslpDao= new SSLPDAO();
                for(MapData m: mapDatas){
                SSLP sslp= sslpDao.getSSLP(m.getRgdId());
                if(m.getChromosome()!=null && m.getStartPos()!=null && m.getStopPos()!=null && m.getMapKey()!=null){
                %>

      gviewer.loadAnnotation(<%=m.getStartPos()%>,<%=m.getStopPos()%>,'sslp','<%=sslp.getName()%>','<%=edu.mcw.rgd.reporting.Link.marker(m.getRgdId())%>','','<%=m.getChromosome()%>');
      <%}}
      }
       if(oKey.equals("6")){
               QTLDAO qdao= new QTLDAO();
                for(MapData m: mapDatas){
                QTL q= qdao.getQTL(m.getRgdId());
                if(m.getChromosome()!=null && m.getStartPos()!=null && m.getStopPos()!=null && m.getMapKey()!=null){
                %>

      gviewer.loadAnnotation(<%=m.getStartPos()%>,<%=m.getStopPos()%>,'qtl','<%=q.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.qtl(m.getRgdId())%>','','<%=m.getChromosome()%>');
      <%}}
      }
      if(oKey.equals("7")){
               VariantInfoDAO vdao= new VariantInfoDAO();
                for(MapData m: mapDatas){
               VariantInfo v= vdao.getVariant(m.getRgdId());
                if(m.getChromosome()!=null && m.getStartPos()!=null && m.getStopPos()!=null && m.getMapKey()!=null){
                %>

      gviewer.loadAnnotation(<%=m.getStartPos()%>,<%=m.getStopPos()%>,'variant','<%=v.getSymbol()%>','<%=edu.mcw.rgd.reporting.Link.variant(m.getRgdId())%>','','<%=m.getChromosome()%>');
      <%}}
      }
      }

    catch (Exception e) {
        e.printStackTrace();

    }


    if (!errors.equals("")) {
    out.print("alert('Strains (" + errors + ") not found');");
    }

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class=.gaTable width=800");
    if(r!=null){
    %>

   document.getElementById("geneList").innerHTML = "<%=r.format(strat)%>";
      <%}%>
// }

</script>



<br>

</body>
</html>