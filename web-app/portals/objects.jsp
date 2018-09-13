<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotController" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotController" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" type="text/css" href="/rgdweb/common/search.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/ontology.css">

<jsp:useBean id="bean2" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" />



<% try { %>}

<% String pageDescription = "Ontology Browser - Rat Genome Database";
   String headContent = "\n" +
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/jkl-parsexml.js\">\n"+
    "/***********************************************\n"+
    "*  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML\n"+
    "*  Copyright 2005-2007 Kawasaki Yusuke u-suke[AT]kawa.net\n"+
    "*  http://www.kawa.net/works/js/jkl/parsexml.html\n"+
    "************************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/dhtmlwindow.js\">\n"+
    "/***********************************************\n"+
    "* DHTML Window script- � Dynamic Drive (http://www.dynamicdrive.com)\n"+
    "* This notice MUST stay intact for legal use\n"+
    "* Visit http://www.dynamicdrive.com/ for this script and 100s more.\n"+
    "***********************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/util.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/gviewer.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/domain.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/contextMenu.js\">\n"+
    "/***********************************************\n"+
    "* Context Menu script- � Dynamic Drive (http://www.dynamicdrive.com)\n"+
    "* This notice MUST stay intact for legal use\n"+
    "* Visit http://www.dynamicdrive.com/ for this script and 100s more.\n"+
    "***********************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/event.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/ZoomPane.js\"></script>\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/gviewer/css/gviewer.css\">\n"+

    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/common/search.css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\">\n";

   String pageTitle = "Ontology Report - Rat Genome Database";
%>

<%@ include file="headerarea.jsp" %>

<%
    OntAnnotBean bean = new OntAnnotBean();
    OntAnnotController.loadAnnotations(bean, xdao, req.getParameter("term"), "3", "1", null, null, null, null,
            OntAnnotBean.MAX_ANNOT_COUNT);
    //session.setAttribute("bean", bean);
%>




<script>
// Sliding Menu Script
// copyright Stephen Chapman, 6th July 2005
// you may copy this code but please keep the copyright notice as well
var speed = .5;

var aDOM = 0, ieDOM = 0, nsDOM = 0; var stdDOM = document.getElementById;
if (stdDOM) aDOM = 1; else {ieDOM = document.all; if (ieDOM) aDOM = 1; else {
var nsDOM = ((navigator.appName.indexOf('Netscape') != -1)
&& (parseInt(navigator.appVersion) ==4)); if (nsDOM) aDOM = 1;}}
function xDOM(objectId, wS) {
if (stdDOM) return wS ? document.getElementById(objectId).style:
document.getElementById(objectId);
if (ieDOM) return wS ? document.all[objectId].style: document.all[objectId];
if (nsDOM) return document.layers[objectId];
}
function objWidth(objectID) {var obj = xDOM(objectID,0); if(obj.offsetWidth) return obj.offsetWidth; if (obj.clip) return obj.clip.width; return 0;}
function objHeight(objectID) {var obj = xDOM(objectID,0); if(obj.offsetHeight) return obj.offsetHeight; if (obj.clip) return obj.clip.height; return 0;}
function setObjVis(objectID,vis) {var objs = xDOM(objectID,1); objs.visibility = vis;}
function moveObjTo(objectID,x,y) {var objs = xDOM(objectID,1); objs.left = x; objs.top = y;}
function pageWidth() {return window.innerWidth != null? window.innerWidth: document.body != null? document.body.clientWidth:null;}
function pageHeight() {return window.innerHeight != null? window.innerHeight: document.body != null? document.body.clientHeight:null;}
function posLeft() {return typeof window.pageXOffset != 'undefined' ? window.pageXOffset: document.documentElement.scrollLeft? document.documentElement.scrollLeft: document.body.scrollLeft? document.body.scrollLeft:0;}
function posTop() {return typeof window.pageYOffset != 'undefined' ? window.pageYOffset: document.documentElement.scrollTop? document.documentElement.scrollTop: document.body.scrollTop? document.body.scrollTop:0;}
var xxx = 0; var yyy = 0; var dist = distX = distY = 0; var stepx = 2; var stepy = 0; var mn = 'smenu';
function distance(s,e) {return Math.abs(s-e)}
function direction(s,e) {return s>e?-1:1}
function rate(a,b) {return a<b?a/b:1}
function start() {xxx = -235; yyy = 10; var eX = 0; var eY = 100; dist = distX = distance(xxx,eX); distY = distance(yyy,eY); stepx *= -direction(xxx,eX) * rate(distX,distY); stepy *= direction(yyy,eY) * rate(distY,distX); moveit();
setObjVis(mn,'visible');}
function moveit() {var x = (posLeft()+xxx) + 'px'; var y = (posTop()+yyy) + 'px'; moveObjTo(mn,x,y);}
function mover() {if (dist > 0) {xxx += stepx; yyy += stepy; dist -= Math.abs(stepx);} moveit(); setTimeout('mover()',speed);
}
function slide() {dist = distX; stepx = -stepx; moveit(); setTimeout('mover()',speed*2);return false;}
window.onscroll = moveit;

</script>

<style>
    #smenu {background-color:#2865A3; text-align:center; border:1px solid #000099; z-Index:111999; visibility:hidden; position:absolute; top:5px; left:-235px; width:260px;}
    #sleft {width:220px; float:left;}
    #sright {width:20px; float:right;}
    #sright a:link{text-decoration:none; color:#ffffff; font-size: 16px; font-weight:700; font-family:arial, helvetica, sans-serif;}
    #sright a:visited{text-decoration:none; color:#ffffff; font-size: 16px; font-weight:700; font-family:arial, helvetica, sans-serif;}
    #sright a:active{text-decoration:none; color:#ffffff; font-size: 16px; font-weight:700; font-family:arial, helvetica, sans-serif;}
    #sright a:hover{text-decoration:none; color:#ffffff; font-size: 16px; font-weight:700; font-family:arial, helvetica, sans-serif;}

</style>

<div id="smenu"><div id="sleft">
    <%@ include file="menu.jsp" %>
</div>
    <div id="sright">
        <a href="#" onclick="return slide();return false;"><br>M<br />E<br />N<br />U<br />
        &nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>
        &nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>
        </a>
    </div>
</div>

<script>start();</script>

<%
    Term oterm = xdao.getTerm(req.getParameter("term"));
%>

<div style="font-size:25px;"><%=oterm.getTerm()%></div>

<% if (oterm.getDefinition() != null) {%>
    <div style="font-size:10px;"><%=oterm.getDefinition()%></div>
<% } %>

<br>


<table width="100%">
    <tr>
        <td align="center">
            <div id="gviewer" class="gviewer"><c:if test="${bean.speciesTypeKey==0}">Please select species to view GViewer data.</c:if></div>
            <div id="zoomWrapper" class="zoom-pane"></div>
        </td>
    </tr>
</table>

<%@ include file="annotTable.jsp" %>



<%----------------- GVIEWER ------------%>
<script language="JavaScript1.2">
<c:if test="${bean.speciesTypeKey != 0}">
var gviewer = null;
onload= function() {

try {
    gviewer = new Gviewer("gviewer", 200, 750);
    gviewer.imagePath = "/rgdweb/gviewer/images";
    gviewer.exportURL = "/rgdweb/report/format.html";
    gviewer.annotationTypes = new Array("gene","qtl","strain");
    gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
    //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
    gviewer.enableAdd=true;
    gviewer.genomeBrowserName = "JBrowse";
    gviewer.regionPadding=2;
    gviewer.annotationPadding = 1;
    gviewer.loadBands("/rgdweb/gviewer/data/<%=bean.getSpeciesTypeKey()==3?"rgd_rat_ideo":bean.getSpeciesTypeKey()==2?"mouse_ideo":bean.getSpeciesTypeKey()==1?"human_ideo":""%>.xml");
    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?acc_id=<%=bean.getAccId()%>&species_type=<%=bean.getSpeciesTypeKey()%>&with_childs=<%=bean.isWithChildren()?1:0%>");
    gviewer.addZoomPane("zoomWrapper", 200, 750);
}catch (err) {

}

}
</c:if>

</script>

<% } catch (Exception e) {
    e.printStackTrace();

 } %>

<%@ include file="footerarea.jsp" %>
