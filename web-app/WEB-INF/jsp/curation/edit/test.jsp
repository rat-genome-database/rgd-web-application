<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="keywords" content="rat genome database,rat genome,rgd">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<meta name="description" content="The Rat Genome Database contains rat genomic data such as genes,sslps,qtls,strains,rhmap,sequences and tools such as vcmap,genome scanner, rhmap server,metagene,and hosts rat comunity forum.">

  <meta name="author" content="rgd">
 <link rel="SHORTCUT ICON" href="/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/common/modalDialog/subModal.css" />
<link rel="stylesheet" type="text/css" href="/common/modalDialog/style.css" />
<script type="text/javascript" src="/common/modalDialog/common.js"></script>
<script type="text/javascript" src="/common/modalDialog/subModal.js"></script>
<script type="text/javascript" src="/common/js/poll.js"></script>

<link href="/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" />

<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-2739107-2";
urchinTracker();
</script>
    <%@ include file="/common/googleAnalytics.jsp" %>

<script>
window.onload = initTrackLinks

function initTrackLinks() {
	var anchors=document.getElementsByTagName("a");
	for (i=0;i<anchors.length;i++) {
		if (anchors[i].href.indexOf("rgd.mcw.edu") == -1 && anchors[i].href.indexOf("rgdtest.mcw.edu") == -1 && anchors[i].href.indexOf("hastings.hmgc.mcw.edu") == -1 && anchors[i].href.indexOf("curation.hmgc.mcw.edu") == -1) {
			anchors[i].onclick=trackOutBoundLinks;
		}
	}
}

function trackOutBoundLinks(){
var thelink=this.href;
//if (thelink.indexOf(location.hostname) ==-1 ){
   //urchinTracker('outgoing:'+thelink+'');
   logLink(thelink);
   document.location.href=''+thelink+'';
   return false;;
//   }
}

function logLink( theLink) {

 //alert("about to log link " + theLink);
 var xmlhttp=false;
 try {
  xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
 } catch (e) {
  try {
   xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
  } catch (E) {
   xmlhttp = false;
  }
 }

if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
	try {
		xmlhttp = new XMLHttpRequest();
	} catch (e) {
		xmlhttp=false;
	}
}
if (!xmlhttp && window.createRequest) {
	try {
		xmlhttp = window.createRequest();
	} catch (e) {
		xmlhttp=false;
	}
}

 xmlhttp.open("GET", "/plf/plfRGD/?module=log&func=link&link=" + theLink,true);
 xmlhttp.onreadystatechange=function() {
  if (xmlhttp.readyState==4) {
    //alert(xmlhttp.responseText)
  }
 }

 xmlhttp.send(null)

}
</script>

<script type="text/javascript" src="/common/js/ddtabmenu.js">

/***********************************************
* DD Tab Menu script- � Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>

<script type="text/javascript" src="/common/js/rgdHomeFunctions-2.js">
</script>


<!-- CSS for Tab Menu #4 -->
<link rel="stylesheet" type="text/css" href="/common/style/ddcolortabs.css" />


<meta name="generator" content="WebGUI 7.4.8" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta http-equiv="Content-Style-Type" content="text/css" />
<script type="text/javascript">
function getWebguiProperty (propName) {
var props = new Array();
props["extrasURL"] = "/extras/";
props["pageURL"] = "/wg/home/rgd_rat_community_videos";
return props[propName];
}
</script>
<link href="/extras/contextMenu/contextMenu.css" rel="stylesheet" type="text/css" />
<script src="/extras/contextMenu/contextMenu.js" type="text/javascript"></script>


<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache, must-revalidate, max-age=0, private" />
<meta http-equiv="Expires" content="0" />

	<title>Rat Genome Database - RGD Rat Community Videos</title>

</head>




<body>

<table class="wrapperTable" cellpadding="0" cellspacing="0" border="0">
<tr>

<td>
<div class="wrapper">

<div id="main">

<div id="headWrapper">
	<div class="top-bar">
<table width="100% border="1" class="headerTable"> <tr><td align="left" style="color:white;">&nbsp;&nbsp;&nbsp;
</td><td align="right" style="color:white;"><a href="/tu">Help</a>&nbsp;|&nbsp;
		<a href="ftp://ftp.rgd.mcw.edu/pub">FTP Download</a>&nbsp;|&nbsp;

		<a href="/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
				<a href="/contact/index.shtml">Contact Us</a>&nbsp;&nbsp;&nbsp;
</td></tr></table>
	</div>

<table width="100%" border=0>
<tr>
	<td>
	<table><tr><td>

       <a class="homeLink" href="/wg/home"><img border="0" src="/common/images/rgd_LOGO_blue_rgd.gif"></a>
       </td>
       </tr>
       </table>

</td>
<td width=250 align="right"><a href="http://pga.mcw.edu"><img src="/common/images/physGen_logo.gif" border=0/></a></td>
<td align="right">

      <div class="searchBorder">
      <table border=0 cellpadding=0 cellspacing=0 >

        <form method="post" action='/rgdweb/search/search.html' onSubmit="return verify(this);">
          <input type="hidden" name="type" value="nav" />
          <tr>
	    <td class="searchKeywordLabel">Keyword</td>
            <td class="atitle" align="right">                <input type=text name=term size=12 value="" onFocus="JavaScript:document.forms[0].term.value=''" class="searchKeywordSmall">
              </td>
            <td>
<input type="image" src="/common/images/searchGlass.gif" class="searchButtonSmall"/>
</td>
          </tr>

        </form>
      </table>
      </div>
</td>
<td>&nbsp;&nbsp;</td>
</tr>
</table>

<div id="ddtabs4" class="ddcolortabs">
<ul>
<li class="current" style="margin-left: 1px"><a href="/"  rel="ct1"><span>Home</span></a></li>
<li><a href="/wg/data-menu" rel="ct2"><span>Data</span></a></li>

<li><a href="/wg/tool-menu" rel="ct3"><span>Genome Tools</span></a></li>
<li><a href="/wg/portals/" rel="ct4"><span>Diseases</span></a></li>
<li><a href="/wg/physiology" rel="ct5"><span>Phenotypes & Models</span></a></li>
<li><a href="/wg/com-menu" rel="ct6"><span>Community</span></a></li>
<li id="curation-top" style="visibility: hidden;"><a href="/curation" rel="ct6"><span>Curation Web</span></a></li>
</ul>
</div>
<div class="ddcolortabsline"><img src="/common/images/squareBullet.gif" /></div>

<!--<div style="width:100%; height:5px; font-size:1px; background-color: #2865a3">&nbsp;</div>-->

<DIV class="tabcontainer">

<div id="ct1" class="tabcontent">
<div id="subnav">
     <ul>
<li class="first"><a href="/wg/general-search" rel="ct2"><span>Search RGD</span></a></li>
<li><a href="/wg/grants" rel="ct2"><span>Grant Resources</span></a></li>
<li><a href="/RGDUpdate.doc" rel="ct2"><span>RGD Update</span></a></li>
<li><a href="/wg/citing-rgd" rel="ct2"><span>Citing RGD</span></a></li>
<li ><a href="/wg/about-us"  rel="ct1"><span>About Us</span></a></li>
<li><a href="/contact/index.shtml" rel="ct2"><span>Contact Us</span></a></li>

     </ul>
</div>
</div>

<div id="ct2" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/rgdweb/search/genes.html?100" rel="ct1"><span>Genes</span></a></li>
     <li><a href="/rgdweb/search/qtls.html?100" rel="ct2"><span>QTLs</span></a></li>
     <li><a href="/rgdweb/search/strains.html?100" rel="ct3"><span>Strains</span></a></li>

     <li><a href="/rgdweb/search/markers.html?100" rel="ct4"><span>Markers</span></a></li>
     <li><a href="/maps" rel="ct3"><span>Maps</span></a></li>
     <li><a href="/rgdweb/ontology/search.html" rel="ct5"><span>Ontologies</span></a></li>
     <li><a href="/sequences" rel="ct6"><span>Sequences</span></a></li>
     <li><a href="/rgdweb/search/references.html?100" rel="ct7"><span>References</span></a></li>

     <li><a href="ftp://ftp.rgd.mcw.edu/pub/" rel="ct7"><span>FTP Download</span></a></li>
     <li><a href="/registration-entry.shtml" rel="ct7"><span>Submit Data</span></a></li>
     </ul>
</div>
</div>

<div id="ct3" class="tabcontent">
<div id="subnav">
     <ul>
     <li class="first"><a href="/fgb2/gbrowse/rgd_5/" rel="ct4"><span>Rat GBrowse</span></a></li>

     <li ><a href="/VCMAP" rel="ct1"><span>VCMap</span></a></li>
     <li ><a href="http://snplotyper.mcw.edu" rel="ct1"><span>SNPlotyper</span></a></li>
     <li><a href="http://biomart.mcw.edu/" rel="ct2"><span>BioMart</span></a></li>
     <li><a href="/rgdweb/gTool/Gviewer.jsp" rel="ct3"><span>GViewer</span></a></li>
     <li><a href="/ACPHAPLOTYPER" rel="ct7"><span>ACP Haplotyper</span></a></li>
     <li><a href="/GENOMESCANNER" rel="ct7"><span>Genome Scanner</span></a></li>

     <li ><a href="/gbreport/gbrowser_error_conflicts.shtml" rel="ct3"><span>Genome Conflicts</span></a></li>
     <li><a href="/wg/tool-menu" rel="ct8"><span>More Tools...</span></a></li>
</div>
</div>

<div id="ct4" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/rgdCuration/?module=portal&func=show&name=cardio" rel="ct1"><span>Cardiovascular Disease Portal</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=nuro" rel="ct2"><span>Neurological Disease Portal</span></a></li>

     <li><a href="/rgdCuration/?module=portal&func=show&name=obesity" rel="ct2"><span>Obesity/Metabolic Syndrome Portal</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=cancer" rel="ct2"><span>Cancer Portal</span></a></li>
     </ul>
</div>
</div>

<div id="ct5" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/wg/phenotype-data13" rel="ct1"><span>Phenotypes</span></a></li>

     <li ><a href="/wg/strains-and-models2" rel="ct3"><span>Strains & Models</span></a></li>
     </ul>
</div>
</div>

<div id="ct6" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/nomen/nomen.shtml" rel="ct1"><span>Nomenclature</span></a></li>
     <li ><a href="http://gray.hmgc.mcw.edu/mailman/listinfo/rat-forum" rel="ct1"><span>Rat Community Forum (RCF)</span></a></li>
     <li ><a href="/registration-entry.shtml" rel="ct2"><span>Submit Data</span></a></li>
     </ul>
</div>
</div>

<div id="ct7" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/nomen/nomen.shtml" rel="ct1"><span>Phenotypes</span></a></li>

     <li ><a href="http://gray.hmgc.mcw.edu/mailman/listinfo/rat-forum" rel="ct1"><span>Models</span></a></li>
     <li ><a href="Strain" rel="ct2"><span>Strain Search</span></a></li>
     </ul>
</div>
</div>



</DIV>

<!--end headwrapper -->
</div>

<script>
if (location.href.indexOf("rgd.mcw.edu") == -1 &&
    location.href.indexOf("preview.rgd.mcw.edu") == -1 &&
    location.href.indexOf("owen") == -1 &&
    location.href.indexOf("hancock") == -1) {

	document.getElementById("curation-top").style.visibility='visible';
}


ddtabmenu.definemenu("ddtabs4", getTabIndex()) //initialize Tab Menu
</script>

<table width=98%><tr><td align="right">
<div id="crumbTrail" style="margin-top: 10px;">



<span class="crumbTrail">

<a class="crumbTrail"
    href="/wg/home">Home</a>
    &gt;

<a class="crumbTrail"
    href="/wg/home/rgd_rat_community_videos">RGD Rat Community Videos</a>



</span>
			</div>
</td></tr></table>
	<div id="mainBody">
		<div id="contentArea" class="content-area">
			<style type="text/css">
.firstColumn {
  float: left;
  width: 95%;
}
.endFloat {
 clear: both;
}
</style>


<div><a name="idJm8kv11F0bVSEUEptxaxEA" id="idJm8kv11F0bVSEUEptxaxEA"></a></div>



  <h2>RGD Rat Community Videos</h2>




<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">





	<div class="content"><div class="bordered-article">

<a name="idlmNiD2NP0pGi0bdaWhueeQ" id="idlmNiD2NP0pGi0bdaWhueeQ"></a>




	<div class="bordered-article-title">RGD Videos</div>







	<table align="left" border="0" cellpadding="5" cellspacing="20"><tbody><tr><td>&nbsp;<a href="/wg/home/rgd_rat_community_videos/getting-started-with-gbrowse" title="Getting Started with GBrowse Video Tutorial"><img src="/common/images/IntroToGB1_wArrow_105x53.PNG" alt="Getting Started with GBrowse Tutorial Video Page" align="middle" border="1" width="105" height="53" /></a></td><td><h4>Intro to GBrowse #1:&nbsp; Getting Started with GBrowse</h4><p>You keep hearing
people talk about "Genome Browsers" but you've never used one and
you're not quite sure where to start.&nbsp; Click
this icon for a quick look at how to get started with GBrowse, RGD&rsquo;s <b>Rat Genome
Browser</b>.&nbsp;</p></td></tr><tr style="background-color: #ffffff"><td><a href="/wg/home/rgd_rat_community_videos/snplotyper_tutorial" title="SNPlotyper Tutorial Video"><img src="/common/images/SNPlotyper_video_link3.PNG" alt="SNPlotyper Tutorial Video" align="middle" border="1" width="105" height="70" /></a> <br /></td><td><h4>Finding Polymorphic Rat SNPs Using RGD's SNPlotyper Tool</h4><p>Click this icon to access a short video tutorial demonstrating how to use the prototype of RGD's updated <b>SNPlotyper </b>tool to identify polymorphic markers between rat strains.</p></td></tr><tr style="background-color: #ffffff"><td>&nbsp;<a href="/wg/home/rgd_rat_community_videos/gviewer_tutorial/" title="GViewer Tutorial Video Page"><img src="/common/images/GViewerTutorial_105x67.png" align="middle" border="1" width="105" height="67" /></a></td><td><h4>When it Comes to the Rat Genome, Bigger is Better <br /></h4><p>RGD's <b>GViewer</b> is an interactive tool which allows users to view genomic features such as genes and QTLs in the context of the entire genome.&nbsp; Click this icon to access a short video tutorial on how to get started with the GViewer. </p></td></tr><tr style="background-color: #ffffff"><td>&nbsp;<a href="/wg/home/rgd_rat_community_videos/pathway_diagram_tutorial" title="Interactive Pathway Diagram Tutorial Video Page"><img src="/common/images/PathwayDiag_105x62.PNG" alt="Pathway diagram with arrow" border="1" width="105" height="62" /></a></td><td><h4>It's Easy to Get Lost on the Biological Superhighway.&nbsp; Thankfully, we Brought a Map. </h4><p>Biological pathways are complex networks made up of a wide variety of components interacting in many different ways.&nbsp; Click this icon to access a short video tutorial which demonstrates how RGD&rsquo;s <b>Interactive Pathway Diagrams</b> can help you explore and understand these important intermolecular networks.</p></td></tr><tr style="background-color: #ffffff"><td>&nbsp;<a href="/wg/home/rgd_rat_community_videos/disease_portal_tutorial/" title="Disease Portal Tutorial Video Page"><img src="/common/images/DP5_Cancer_105x67.PNG" alt="Cancer Portal with arrow" align="middle" border="1" width="105" height="67" /></a></td><td><h4>Some Prefer Blue Jeans...RGD Prefers Disease Genes <br /></h4><p>RGD's <b>Disease Portals</b> consolidate data for each of a variety of disease areas, including Neurological Diseases, Cardivascular Diseases, Obesity/Metabolic Syndrome and Urogenital/Breast Cancer, into one integrated unit.&nbsp; Click this icon to view a brief video detailing how you can use these portals to explore data related to these important areas of research.</p></td></tr></tbody></table>














</div></div>





	<div class="content"><div class="bordered-article">

<a name="idC-9P2qWB8iqDGMd5KmE4Tw" id="idC-9P2qWB8iqDGMd5KmE4Tw"></a>




	<div class="bordered-article-title">OpenHelix Video</div>







	<table border="0" cellpadding="5" cellspacing="20"><tbody><tr><td><a href="http://www.openhelix.com/rgd" title="OpenHelix Video Tutorial:  RGD Overview"><img src="/common/images/OpenHelixRGD_arrow_105x51.PNG" alt="OpenHelix Video Tutorial about RGD" width="105" align="middle" border="1" height="51" /></a> <br /></td><td><h4>Introduction to the Rat Genome Database</h4>A free online tutorial about
RGD is now available on the <b>OpenHelix</b> website. &nbsp;Click this icon to watch the video or download
slides and hands-on exercises. <br /></td></tr></tbody></table>













</div></div>





	<div class="content"><div class="bordered-article">

<a name="id3D0t4cZZM2hlysNGMYjKiQ" id="id3D0t4cZZM2hlysNGMYjKiQ"></a>




	<div class="bordered-article-title">Other Videos of Interest</div>






	<table border="0" cellpadding="5" cellspacing="20"><tbody><tr><td><a href="/wg/home/rgd_rat_community_videos/sleeping-beauty-mutagenesis" title="Sleeping Beauty Mutagenesis Video Page"><img src="/common/images/OpenHelixRGD_arrow_105x51.PNG" width="105" align="middle" border="1" height="70" /></a> <br /></td><td><h4>Sleeping Beauty Invades Rat's Genome <br /></h4><p>This video gives a brief overview of the technique of introducing germline mutations into the rat genome using <b>Sleeping Beauty transposons</b>. In addition, information is given about the availability of rat knockout strains and of detailed phenotype data for those strains. </p></td></tr></tbody></table>















</div></div>





</div></div>
<!-- end position 1 -->



<div class="endFloat">&nbsp;</div>



		</div>
		<br>
 		<div class="bottom-bar" >

<table align=center class="headerTable"> <tr><td align="left" style="color:white;">
		<a href="/contact/index.shtml">Contact Us</a>&nbsp;|&nbsp;
		<a href="/wg/about-us">About Us</a>&nbsp;|&nbsp;
		<a href="/wg/jobs">Jobs at RGD</a>
</td></tr></table>
		</div>
	</div>

</div>

<!-- end page wrapper -->
</div>
</td></tr>
</table>


<div id="copyright">
	<p>&copy; <a href="http://hmgc.mcw.edu/bp">Bioinformatics Program, HMGC</a> at the <a href="http://www.mcw.edu/">Medical
        College of Wisconsin</a></p>
	<p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo">

<br><br><div class="loginBox">
		Hello <a href="/wg/home/rgd_rat_community_videos?op=auth;method=displayAccount">Admin</a>.
                          <a href="/wg/home/rgd_rat_community_videos?op=auth;method=logout">Click here to log out.</a>
</div>

</div>


<script language="javascript" src="/common/js/killerZebraStripes.js" type="text/javascript"></script>

<script>
var arr = document.getElementsByTagName("table");
for (i=0; i< arr.length; i++) {
	if (arr[i].className == "striped-table") {
		if (!arr[i].id) {
			arr[i].id = "striped-table-" + i;
		}
		stripeTables(arr[i].id);
      }
}
</script>



</body>
</html>
