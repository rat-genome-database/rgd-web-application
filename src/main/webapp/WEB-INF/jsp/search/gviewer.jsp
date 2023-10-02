<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: Jun 13, 2008
  Time: 10:43:43 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Genome Viewer";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
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

<%
    Report report = (Report) request.getAttribute("report");
    report.sort(report.getIndex("Chr"), Report.ASCENDING_SORT, true);

    SearchBean search = (SearchBean) request.getAttribute("searchBean");

    boolean showGviewer = true;
    Map m = MapManager.getInstance().getMap(search.getMap());
    if( m==null ) {
        out.println("GViewer error: no valid map specified: "+search.getMap());
        showGviewer = false;
    }
    else if (!m.getUnit().equals("bp")) {
        out.println("GViewer is currently only available for base pair maps.  You are currently using map " + m.getName());
        showGviewer = false;
    }

if( showGviewer ) {
    String baseMap = "/rgdweb/gviewer/data/rgd_rat_ideo.xml";

    if (search.getSpeciesType() == 1) {
        baseMap = "/rgdweb/gviewer/data/human_ideo.xml";
    } else if (search.getSpeciesType() == 2) {
        baseMap = "/rgdweb/gviewer/data/mouse_ideo.xml";
    }
%>

<div id="gviewer" class="gviewer"></div>
<div id="zoomWrapper" class="zoom-pane"></div>

<script>

window.onload= function() {
     var gviewer = new Gviewer("gviewer", 200, 750 );

     gviewer.imagePath = "/rgdweb/gviewer/images";
     gviewer.exportURL = "/rgdweb/report/format.html";
     gviewer.annotationTypes = new Array("gene","qtl","sslp");
    gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
     //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
     gviewer.genomeBrowserName = "JBrowse";
     gviewer.regionPadding=2;
     gviewer.annotationPadding = 1;

     var otype = "gene";

     if (location.href.indexOf("markers") != -1) {
        otype="sslp";
     }else if (location.href.indexOf("qtls") != -1) {
        otype="qtl";
     }

     //gviewer.annotationTypes = new Array(type);
     gviewer.loadBands("<%=baseMap%>");
     gviewer.loadAnnotations(location.href.replace("fmt=5","fmt=6"));
     gviewer.addZoomPane("zoomWrapper", 250, 750);
}
</script>
  <%
      HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
      strat.setTableProperties("width=800");
      out.println("<pre>" + report.format(strat) + "</pre>");

      } // end of 'if( showGviewer ) {'
  %>
<%@ include file="/common/footerarea.jsp"%>
