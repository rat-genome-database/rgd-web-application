<html xmlns="http://www.w3.org/1999/xhtml">
<head>	
  <meta name="keywords" content="rat genome database,rat genome,rgd">
  <meta name="description" content="The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology." />
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<meta name="author" content="RGD">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><meta name="generator" content="WebGUI 7.9.16" /><meta http-equiv="Content-Script-Type" content="text/javascript" /><meta http-equiv="Content-Style-Type" content="text/css" /><script type="text/javascript">function getWebguiProperty (propName) {var props = new Array();props["extrasURL"] = "/extras/";props["pageURL"] = "http://rgd.mcw.edu/wg/home";props["firstDayOfWeek"] = "'0'";return props[propName];}</script><style type="text/css">
.firstColumn {

}
.secondColumn {
}
</style>

<link href="http://rgd.mcw.edu/wg/conference-watch?func=viewRss" rel="alternate" title="Conference Watch (RSS)" type="application/rss+xml" />
<link href="http://rgd.mcw.edu/wg/conference-watch?func=viewAtom" rel="alternate" title="Conference Watch (Atom)" type="application/atom+xml" />
<meta content="The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology." name="Description" />
<meta http-equiv="Cache-Control" content="must-revalidate" />

<title>RGD - Rat Genome Database</title>

<link rel="SHORTCUT ICON" href="/favicon.ico" />
<link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/common/modalDialog/subModal.css" />
<link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/common/modalDialog/style.css" />
<link href="http://rgd.mcw.edu/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" />
<!-- CSS for Tab Menu #4 -->
<link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/common/style/ddcolortabs.css" />


<script type="text/javascript" src="http://rgd.mcw.edu/common/modalDialog/common.js"></script>
<script type="text/javascript" src="http://rgd.mcw.edu/common/modalDialog/subModal.js"></script>
<script type="text/javascript" src="http://rgd.mcw.edu/common/js/poll.js"></script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-2739107-2";
urchinTracker();
</script>


<script type="text/javascript" src="http://rgd.mcw.edu/common/js/ddtabmenu.js">

/***********************************************
* DD Tab Menu script- © Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>

<script type="text/javascript" src="http://rgd.mcw.edu/common/js/rgdHomeFunctions-3.js">
</script>

	<%
		String idForAngular = request.getParameter("id");
		if (idForAngular == null) {
			idForAngular=request.getParameter("acc_id");
			if (idForAngular == null) {
				idForAngular="";
			}
		}
	%>

	<script>
		function getLoadedObject() {
			return <%=idForAngular%>;
		}
	</script>
	<link href="css/elasticsearch/elasticsearch.css" rel=stylesheet type="text/css">
	<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>
	<script type="text/javascript" src="http://code.angularjs.org/1.4.8/angular.js"></script>
	<script type="text/javascript" src="http://code.angularjs.org/1.4.8/angular-sanitize.js"></script>
	<script type="text/javascript" src="/rgdweb/my/my.js"></script>




	<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
	<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>
	<script type="text/javascript" src="/rgdweb/js/elasticsearch/elasticsearch.js"></script>
<style >

.lcdstyle{ /*Example CSS to create LCD countdown look*/
background-color:black;
color:yellow;
font: bold 18px MS Sans Serif;
padding: 3px;
}

.lcdstyle sup{ /*Example CSS to create LCD countdown look*/
font-size: 80%
}
	input[type=text], select{
		border:1px solid #ccc;
		border-radius:4px;
		-webkit-box-sizing: border-box;
		-moz-box-sizing: border-box;
		box-sizing: border-box;
	}
.ui-autocomplete { height: 200px; overflow-y: scroll; overflow-x: hidden;}
</style>




</head>

<body  ng-app="rgdPage">
<%@ include file="/common/angularTopBodyInclude.jsp" %>



<table class="wrapperTable" cellpadding="0" cellspacing="0" border="0">
<tr>
<td>
<div class="wrapper">

<div id="main">

<div id="headWrapper">
	<div class="top-bar">
<table width="100%" border="0" class="headerTable"> <tr><td align="left" style="color:white;">&nbsp;&nbsp;&nbsp;
</td><td align="right" style="color:white;"><a href="/tu">Help</a>&nbsp;|&nbsp;
	        <a href="http://rgd.mcw.edu/wg/home/rat-genome-database-publications">Publications</a>&nbsp;|&nbsp;
	        <a href="http://rgd.mcw.edu/wg/com-menu/poster_archive/">Poster Archive</a>&nbsp;|&nbsp;
		<a href="ftp://ftp.rgd.mcw.edu/pub">FTP Download</a>&nbsp;|&nbsp;
		<a href="http://rgd.mcw.edu/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
	        <a href="/contact/index.shtml">Contact Us</a>&nbsp;&nbsp;&nbsp;
</td>
	<td width="90">
		<input type="button" class="btn btn-info btn-sm"  value="{{username}}" ng-click="rgd.loadMyRgd($event)" style="background-color:#4584ED;"/>
	</td>

</tr></table>
	</div>
	<input type="hidden" id="speciesType" value="">
<table width="100%" border=0>
<tr><td colspan="8">

			<div>
			
<jsp:include page="WEB-INF/jsp/search/elasticsearch/searchBox.jsp"/>
			</div>


		
</td>
</tr>
<tr>
	<td>
	<table><tr><td>
       <a class="homeLink" href="http://rgd.mcw.edu/wg/home"><img border="0" src="http://rgd.mcw.edu/common/images/rgd_LOGO_blue_rgd.gif"></a>
       </td>
       </tr>
       </table>

</td>
<td width=200 align="right"><a href="http://rgd.mcw.edu/wg/gerrc"><img src="http://rgd.mcw.edu/common/images/gerrc/GERRC-35.png" border=0/></a></td>
<td width=200 align="right"><a href="http://rgd.mcw.edu/wg/physgenknockouts"><img src="http://rgd.mcw.edu/common/images/knockOuts.jpg" border=0/></a></td>
<td width=200 align="center"><a href="http://pga.mcw.edu"><img src="http://rgd.mcw.edu/common/images/physGen_logo.gif" border=0/></a></td>
<td align="right">

      <div class="searchBorder">
      <table border=0 cellpadding=0 cellspacing=0 >
        <form method="post" action='/rgdweb/search/search.html' onSubmit="return verify(this);">
          <input type="hidden" name="type" value="nav" />
          <!--tr>
	    <td class="searchKeywordLabel">Keyword</td>
            <td class="atitle" align="right">                <input type=text name=term size=12 value="" onFocus="JavaScript:document.forms[0].term.value=''" class="searchKeywordSmall">
              </td>
            <td>
<input type="image" src="http://rgd.mcw.edu/common/images/searchGlass.gif" class="searchButtonSmall"/>
</td>
          </tr-->
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
<li><a href="http://rgd.mcw.edu/wg/data-menu" rel="ct2"><span>Data</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/tool-menu" rel="ct3"><span>Genome Tools</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/portals/" rel="ct4"><span>Diseases</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/physiology" rel="ct5"><span>Phenotypes & Models</span></a></li>
<li><a href="/rgdweb/models/allModels.html" rel="ct6"><span>GENETIC MODELS</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/home/pathway2" rel="ct7"><span>Pathways</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/com-menu" rel="ct8"><span>Community</span></a></li>
<li id="curation-top" style="visibility: hidden;"><a href="/curation" rel="ct9"><span>Curation Web</span></a></li>
</ul>
</div>
<div class="ddcolortabsline"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" /></div>

<!--<div style="width:100%; height:5px; font-size:1px; background-color: #2865a3">&nbsp;</div>-->

<DIV class="tabcontainer">

<div id="ct1" class="tabcontent">
<div id="subnav">
     <ul>
<li class="first"><a href="http://rgd.mcw.edu/wg/general-search" rel="ct2"><span>Search RGD</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/grants" rel="ct2"><span>Grant Resources</span></a></li>
<li><a href="http://rgd.mcw.edu/wg/citing-rgd" rel="ct2"><span>Citing RGD</span></a></li>
<li ><a href="http://rgd.mcw.edu/wg/about-us"  rel="ct1"><span>About Us</span></a></li>
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
     <li class="first"><a href="/fgb2/gbrowse/rgd_904/" rel="ct4"><span>Rat GBrowse</span></a></li>
     <li ><a href="http://bioneos.com/VCMap/" rel="ct1"><span>VCMap</span></a></li>
     <li><a href="/rgdweb/front/select.html" rel="ct9"><span>Variant Visualizer</span></a></li>
     <li><a href="/rgdweb/gTool/Gviewer.jsp" rel="ct3"><span>GViewer</span></a></li>
     <li><a href="/ACPHAPLOTYPER" rel="ct7"><span>ACP Haplotyper</span></a></li>
     <li><a href="/GENOMESCANNER" rel="ct7"><span>Genome Scanner</span></a></li>
     <li ><a href="/gbreport/gbrowser_error_conflicts.shtml" rel="ct3"><span>Genome Conflicts</span></a></li>
     <li><a href="http://ratmine.mcw.edu" rel="ct8"><span>RatMine</span></a></li>
     
</div>
</div>

<div id="ct4" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/rgdCuration/?module=portal&func=show&name=cancer" rel="ct1"><span>Cancer</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=cardio" rel="ct2"><span>Cardiovascular</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=diabetes" rel="ct2"><span>Diabetes</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=immune" rel="ct2"><span></span>Immune and Inflammatory</a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=nuro" rel="ct2"><span>Neurological</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=obesity" rel="ct2"><span>Obesity/Metabolic Syndrome</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=renal" rel="ct2"><span>Renal</span></a></li>
     <li><a href="/rgdCuration/?module=portal&func=show&name=respir" rel="ct2"><span>Respiratory</span></a></li>
     </ul>
</div>
</div>

<div id="ct5" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="http://rgd.mcw.edu/wg/phenotype-data13" rel="ct1"><span>Phenotypes</span></a></li>
     <li ><a href="http://rgd.mcw.edu/wg/strains-and-models2" rel="ct3"><span>Strains & Models</span></a></li>
     <li ><a href="/phenotypes" rel="ct3"><span>PhenoMiner Database</span></a></li>
     </ul>
</div>
</div>

<div id="ct6" class="tabcontent">
<div id="subnav">
</div>
</div>

<div id="ct7" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="http://rgd.mcw.edu/wg/home/pathway2/molecular-pathways2" rel="ct1"><span>Molecular Pathways</span></a></li>
     <li ><a href="http://rgd.mcw.edu/wg/home/pathway2/physiological-pathways" rel="ct1"><span>Physiological Pathways</span></a></li>
     </ul>
</div>
</div>


<div id="ct8" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/nomen/nomen.shtml" rel="ct1"><span>Nomenclature</span></a></li>
     <li ><a href="http://mailman.mcw.edu/mailman/listinfo/rat-forum" rel="ct1"><span>Rat Community Forum (RCF)</span></a></li>
     <li ><a href="/registration-entry.shtml" rel="ct2"><span>Submit Data</span></a></li>
     </ul>
</div>
</div>

<div id="ct9" class="tabcontent">
<div id="subnav">

     <ul>
         <li class=first><a href="/rgdweb/curation/edit/editObject.html" rel="ct1"><span>Object Edit</span></a></li>
         <li><a href="http://pipelines.rgd.mcw.edu/rgdCuration/" rel="ct2"><span>Curation Tools</span></a></li>
         <li><a href="http://pipelines.rgd.mcw.edu/rgdweb/curation/nomen/nomenSearch.html" rel="ct3"><span>Nomenclature</span></a></li>
         <li><a href="http://pipelines.rgd.mcw.edu/rgdweb/score/board.jsp" rel="ct1"><span>Score Board</span></a></li>
         <li><a href="http://pipelines.rgd.mcw.edu/rgdweb/curation/pipeline/list.html" rel="ct4"><span>Pipeline Logs</span></a></li>
         <li><a href="http://pipelines.rgd.mcw.edu/rgdweb/curation/phenominer/home.html" rel="ct5"><span>Phenominer</span></a></li>
     </ul>
</div>
</div>



</DIV>
<!--end headwrapper -->
</div>

<script>
if (location.href.indexOf("http://rgd.mcw.edu") == -1 &&
	location.href.indexOf("http://www.rgd.mcw.edu") == -1 &&
    location.href.indexOf("osler") == -1 &&
    location.href.indexOf("horan") == -1 &&
	location.href.indexOf("owen") == -1 &&
	location.href.indexOf("hancock") == -1 &&
    location.href.indexOf("preview.rgd.mcw.edu") == -1) {
	
	document.getElementById("curation-top").style.visibility='visible';
}


ddtabmenu.definemenu("ddtabs4", getTabIndex()) //initialize Tab Menu
</script>

<table width=98%><tr><td align="right">
<div id="crumbTrail" style="margin-top: 10px;">
				<div id="nav3c19dabf4d34d34d34d34d34d34d34d35" class="nav crumbTrail">

<a name="idPBnav00000000000000001" id="idPBnav00000000000000001"></a>









<!--/nav3c19dabf4d34d34d34d34d34d34d34d35 /nav crumbTrail-->
</div>
			
			</div>
</td></tr></table>
	<div id="mainBody">
		<div id="contentArea" class="content-area">
			<div><a name="id68sKwDgf9cGH58-NZcU4lg" id="id68sKwDgf9cGH58-NZcU4lg"></a></div>







<table cellpadding="5" border=0 align="center">
<tr>
	<td colspan="3" align="left" valign="top">
		<!-- begin position 1 -->
		<div class="layoutColumnPadding">
		

		
			

			<div class="content"><script>
function utmx_section(){}function utmx(){}
(function(){var k='1110218286',d=document,l=d.location,c=d.cookie;function f(n){
if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
d.write('<sc'+'ript src="'+
'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
+'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
+new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
'" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
</script></div>

			
		
			

			<div class="content"><div id="article0708505c4a59bf63e913bb26c69e12c6" class="article default">

<a name="idBwhQXEpZv2PpE7smxp4Sxg" id="idBwhQXEpZv2PpE7smxp4Sxg"></a>





<div class="articleContent">


	<div class="description">
		<p style="text-align: center;"><strong>RGD is discontinuing the use of the URL "ftp://rgd.mcw.edu" to access our FTP site. If you have automated processes or bookmarks that use this URL, please change them to use <a target="_self" title="Access the RGD FTP Download site" href="ftp://ftp.rgd.mcw.edu/pub/">ftp://ftp.rgd.mcw.edu/pub/</a>. We apologize for any inconvenience this may cause.</strong></p>
	<!--/description-->
	</div>




<!--/articlecontent-->
</div>



<div class="wg-clear"></div>

<!--/article0708505c4a59bf63e913bb26c69e12c6 /article default-->
</div>
</div>

			
		
			

			<div class="content"><div id="articlea55eac7db151b499602c926a8fbb79b6" class="article default">

<a name="idpV6sfbFRtJlgLJJqj7t5tg" id="idpV6sfbFRtJlgLJJqj7t5tg"></a>





<div class="articleContent">


	<div class="description">
		<table style="width: 95%;" border="0" cellpadding="0" cellspacing="0">
<tbody>
<tr>
<td>&nbsp;</td>
<td align="right">&nbsp;<a href="http://www.facebook.com/pages/Rat-Genome-Database/108897608483?v=wall" title="Find us on Facebook!"><img src="http://rgd.mcw.edu/common/images/Find_us_on_Facebook.png" alt="Find us on Facebook" align="right" border="1" height="35" width="101" /></a></td>
</tr>
<tr>
<td colspan="2">
</td>
</tr>
</tbody>
</table>
&nbsp;
	<!--/description-->
	</div>




<!--/articlecontent-->
</div>



<div class="wg-clear"></div>

<!--/articlea55eac7db151b499602c926a8fbb79b6 /article default-->
</div>
</div>

			
		
			

			<div class="content">				<table align="center" ><tr><td>
					<div style="float: left;">
					<div class="image_item" id="genes">
						<div class="icon"><a href="/rgdweb/search/genes.html?100" title="RGD"><img src="http://rgd.mcw.edu/common/images/gene_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="/rgdweb/search/genes.html?100" title="RGD">Genes</a></div>
						<div class="description">
							Map positions, functions and more
						</div>
					</div>

					<div class="image_item" id="ontologies">
						<div class="icon"><a href="/rgdweb/ontology/search.html" title="Rat Genome Database - Ontology Annotations"><img src="http://rgd.mcw.edu/common/images/function_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="/rgdweb/ontology/search.html" title="Rat Genome Database - Ontology Annotations">Function</a></div>
						<div class="description">
							Gene Ontology, Phenotype, Pathway info
						</div>
					</div>

					<div class="image_item" id="genome">
						<div class="icon"><a href="/jbrowse/?data=data_rgd5" title="Rat JBrowse Genome Browser"><img src="http://rgd.mcw.edu/common/images/genome_image2.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="/jbrowse/?data=data_rgd5" title="Rat JBrowse Genome Browser">Rat JBrowse</a></div>
						<div class="title"><a href="/fgb2/gbrowse/rgd_5/?source=rgd_5" title="Rat GBrowse Genome Browser">Rat GBrowse</a>
						</div>
					</div>

				</div>
				</td><td>
					<div style="float: right;">
					<div class="image_item" id="strains">
						<div class="icon"><a href="/rgdweb/search/strains.html?100" title="RGD Strains"><img src="http://rgd.mcw.edu/common/images/strain_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="/rgdweb/search/strains.html?100" title="RGD Strains">Strains</a></div>
						<div class="description">
							Search Strains
						</div>
					</div>

					<div class="image_item" id="diseases">
						<div class="icon"><a href="http://rgd.mcw.edu/wg/portals?100" title="Rat Genome Database - RGD Disease Portals"><img src="http://rgd.mcw.edu/common/images/disease_image2.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="http://rgd.mcw.edu/wg/portals?100" title="Rat Genome Database - RGD Disease Portals">Diseases</a></div>
						<div class="description">
							Genes, QTL & Strains related to Disease
						</div>
					</div>

					<div class="image_item" id="tools">
						<div class="icon"><a href="http://rgd.mcw.edu/wg/tool-menu?100" title="RGD"><img src="http://rgd.mcw.edu/common/images/snplotyper_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="mid-title"><a href="http://rgd.mcw.edu/wg/tool-menu?100" title="RGD">Genome Tools</a></div>
						<div class="description">
						Data mining, analysis and visualization
						</div>
					</div>

				</div>
				</td>
				<td valign="top">
<div style="float: right;">
					
					<div class="image_item" id="qtl">
						<div class="icon"><a href="/rgdweb/search/qtls.html?100" title="QTLs Query Form"><img src="http://rgd.mcw.edu/common/images/qtl_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="/rgdweb/search/qtls.html?100" title="QTLs Query Form">QTL</a></div>
						<div class="description">
							Phenotypes & Traits linked to the genome
						</div>
					</div>

					<div class="image_item" id="physiology">
						<div class="icon"><a href="http://rgd.mcw.edu/wg/physiology?100"><img src="http://rgd.mcw.edu/common/images/physiology_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="small-title"><a href="http://rgd.mcw.edu/wg/physiology?100">Phenotypes & Models</a></div>
						<div class="description">
						Phenotype data, Assays, Husbandry and more
						</div>
					</div>
					<div class="image_item" id="pathway">
						<div class="icon"><a href="http://rgd.mcw.edu/wg/home/pathway2?100"><img src="http://rgd.mcw.edu/common/images/pathway_image.jpg" height="50" width="100" border="0"/></a></div>
						<div class="title"><a href="http://rgd.mcw.edu/wg/home/pathway2?100">Pathways</a></div>
						<div class="description">
						Pathway reports and diagrams
						</div>
					</div>
				</div>


				</td>
            <td valign="top">
                <div style="float: right;">
                    <div class="image_item" id="graph">
                        <div class="icon"><a href="cytoscape/query.html" title="Graph Query Form"><img src="/rgdweb/images/cytoscape.png" height="50" width="100" border="0"></a> </div>
                        <div class="small-title"><a href="cytoscape/query.html" title="Graph Query Form">Graph Visuals</a></div>
                        <div class="description">
                            Cytoscape graph visuals of protein interactions.
                        </div>
                    </div>
                </div>
            </td>
            </tr>
				</table>	
</div>

			
		

		
		</div>
		<!-- end position 1 -->	
	</td>
</tr>
<tr>
	<td class="firstColumn" valign="top"  align="center" width="60%">
		<!-- begin position 2 -->
		<div class="layoutColumnPadding">
		

		
			

			<div class="content"><div class="strain-article">
<a name="idiktJiPQiLnH03nTgk29qTA" id="idiktJiPQiLnH03nTgk29qTA"></a>




	<div class="strain-article-title">Featured RGD Video Tutorials</div>







	<table border="0" cellpadding="10" cellspacing="0">
<tbody>
<tr>
<td><a style="text-align: center;" href="http://rgd.mcw.eduhttp://rgd.mcw.edu/wg/home/rgd_rat_community_videos/variant-visualizer-tutorial"><img style="border: 1px solid black;" src="http://rgd.mcw.edu/common/images/olgaplay.png" height="50" width="105" /></a></td>
<td>
<h4 style="font-size: 10px;"><a href="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/olga-object-list-generator-and-analyzer">OLGA- Object List Generator and Analyzer</a></h4>
<p>The purpose of OLGA is to build lists for rat genes, QTLs and strains. OLGA can also be used to query human and mouse genes and QTLs. Search for genomic data annotated to specific diseases, conditions and other queries. Multiple searches will allow you to refine your final result list to use for your own analysis or to send to another tool on the RGD website. This step-by-step instructional tutorial will walk you through the OLGA tool and explain terms in detail.</p>
</td>
</tr>
<tr>
<td><a href="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/other-videos-of-interest/outside-videos2/phenogen-informatics-genome/transcriptome-data-and-browser" title="PhenoGen Informatics Genome/Transcriptome Data and Browser hands-on workshop video" target="_self"><img style="border: 1px solid black;" src="http://rgd.mcw.edu/common/images/PG_workshop_video_Arrow_105x50.png" height="50" width="105" /></a></td>
<td>
<h4><a href="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/other-videos-of-interest/outside-videos2/phenogen-informatics-genome/transcriptome-data-and-browser" title="PhenoGen Informatics Genome/Transcriptome Data and Browser hands-on workshop video" target="_self">PhenoGen Informatics Genome/Transcriptome Data and Browser</a></h4>
<p>RGD has been providing links from our gene pages to the <strong>PhenoGen Informatics Genome/Transcriptome Data Browser</strong>, but there's a good chance you don't know all there is to know about the tool. Want more information about how to use it so you can get the most out of its data and functionality? This informative hands-on workshop video is just the tutorial to help you with that!</p>
</td>
</tr>
</tbody>
</table>
<table border="0" cellpadding="10" cellspacing="0">
<tbody>
<tr>
<td colspan="2"><img src="http://rgd.mcw.edu/common/images/shim.gif" height="1" width="1" /></td>
</tr>
<tr valign="middle">
<td colspan="2"><strong><a href="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/" title="RGD's Rat Community Videos page" target="_self">Click here</a></strong> to access RGD's <strong>Rat Community Videos</strong> page.&nbsp; This page includes all of the tutorial videos that RGD has produced, plus other videos of interest to rat researchers. </td>
</tr>
</tbody>
</table>



	
	







</div>
</div>

			
		
			

			<div class="content"><a name="idW2ED6uBIwfFmp2XZkc2zFQ" id="idW2ED6uBIwfFmp2XZkc2zFQ"></a>


<div class="bordered-article">
<div style="text-align:left;">
<a name="idoVx3I9wu8rslibAo3fFCLg" id="idoVx3I9wu8rslibAo3fFCLg"></a>




	<div class="bordered-article-title">&nbsp;Conference Watch</div>




	
	
	




	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://ascb.org/2015meeting/" 
>The 2015 ASCB Annual Meeting, San Diego Convention Center, San Diego, CA, USA - December 12-16, 2015; Abstract Deadline: August 5, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://keystonesymposia.org/index.cfm?e=web.Meeting.Program&meetingid=1372" 
>Keystone Symposia - Cytokine JAK-STAT Signaling in Immunity and Disease, Steamboat Springs, CO, USA - January 10-14, 2016; Abstract Deadline: October 20, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://www.keystonesymposia.org/index.cfm?e=web.Meeting.Program&meetingid=1371" 
>Keystone Symposia - Purinergic Signaling, Vancouver, British Columbia, Canada - January 24-28, 2016; Abstract Deadline: October 29, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://www.emedevents.com/conferenceview/united-states-of-america/california/san-diego/medical-conferences-2015/14th-cytokines-and-inflammation-28698" 
>Global Technology Community 14th Annual Cytokines & Inflammation Conference, San Diego, CA, USA - January 25-26, 2016; Abstract deadline: December 25, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://www.keystonesymposia.org/index.cfm?e=web.Meeting.Program&meetingid=1394" 
>Keystone Symposia - Genomics and Personalized Medicine, Fairmont Banff Springs, Banff, Alberta, Canada - February 7-11, 2016; Abstract Deadline: November 9, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://www.keystonesymposia.org/index.cfm?e=web.Meeting.Program&meetingid=1374" 
>Keystone Symposia - The Cancer Genome, Banff, Alberta, Canada - February 7-11, 2016; Abstract Deadline: November 9, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://keystonesymposia.org/index.cfm?e=web.Meeting.Program&meetingid=1368" 
>Keystone Symposia - G Protein-Coupled Receptors: Structure, Signaling and Drug Discovery, Keystone, CO, USA - February 21-25, 2016; Abstract Deadline: November 19, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://www.hugo-hgm.org/" 
>Human Genome Meeting - Translational Genomics, Hilton Americas, Houston, TX, USA - February 28-March 2, 2016; Abstract Deadline: November 20, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://registration.hinxton.wellcome.ac.uk/events/item.aspx?e=568" 
>Evolutionary Systems Biology: From Model Organisms to Human Disease, Wellcome Trust Genome Campus, Hinxton, Cambridge, UK - March 2-4, 2016; Abstract Deadline: January 19, 2016</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://www.toxicology.org/events/am/AM2016/index.asp" 
>Society of Toxicology 55th Annual Meeting, New Orleans Ernest N. Morial Convention Center, New Orleans, LA, USA - March 13-17, 2016; Abstract deadline: October 7, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://www.amia.org/jointsummits2016" 
>AMIA Joint Summits on Translational Science, Parc 55 Wyndham Hotel, San Francisco, CA, USA - March 21-24, 2016; Submission deadline: September 24, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://experimentalbiology.org/2016/Home.aspx" 
>Experimental Biology 2016, San Diego Convention Center, San Diego, CA, USA - April 2-6, 2016; Abstract deadline: November 5, 2015</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://www.embo-embl-symposia.org/symposia/2016/EES16-02/index.html" 
>EMBO/EMBL Symposium: Tumour Microenvironment and Signalling, EMBL Heidelberg, Germany - April 3-6, 2016; Abstract Deadline: January 10, 2016</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://www.isb-sib.ch/events/biocuration2016/" 
>9th International Biocuration Conference, Campus Biotech Geneva, Geneva, Switzerland - April 10-14, 2016; Abstract Deadline: February 1, 2016</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="https://meetings.cshl.edu/meetings.aspx?meet=GENOME&year=16" 
>The Biology of Genomes, Cold Spring Harbor, NY, USA - May 10-14, 2016; Abstract Deadline: February 19, 2016</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://www.genetics2016.org/mouse/index.shtml" 
>The Allied Genetics Conference - Mouse Genetics, Orlando, FL, USA - July 13-17, 2016; Abstract Deadline: March 23, 2016</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://www.genetics2016.org/peq/index.shtml" 
>The Allied Genetics Conference – Population, Evolutionary & Quantitative Genetics, Orlando, FL, USA, July 13-17, 2016; Abstract Deadline: March 23, 2016</a></td></tr></table>

	
	
		

<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top"><img src="http://rgd.mcw.edu/common/images/squareBullet.gif" class="bullet" /></td><td><a href="http://icbo.cgrb.oregonstate.edu/" 
>7th International Conference on Biomedical Ontology, Oregon State University, Corvallis, OR, USA – August 1-4, 2016; Submission Deadline: April 15, 2016 (paper), May 15, 2016 (poster)</a></td></tr></table>





</div>
</div>


</div>

			
		

		
		</div>
		<!-- end position 2 -->	
	</td>
	<td class="secondColumn"  valign="top" width="40%">
		<!-- begin position 3 -->
		<div class="layoutColumnPadding">
		

		
			

			<div class="content"><script type="text/javascript" src="http://rgd.mcw.edu/common/js/tabber.js"></script>
	<script type="text/javascript" src="http://rgd.mcw.edu/common/js/slideshow.js"></script>


<div id="slideshow">
<div class="controls" align="right">
<a id="previous" style="display:none;" href="javascript:previous()">&laquo; previous</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a id="start" style="display:none;" href="javascript:start()">slideshow</a><a id="stop" style="display:none;" href="javascript:stop()">stop</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a id="next" style="display:none;" href="javascript:next()">next &raquo;</a>
</center>
</div>			
		       <table  height=175 border=0 cellpadding=0 cellspacing=0>
<tr><td valign="top">

			<div class="items">

<!--____________________________________________________________________________________________-->


				<div class="item" id="mitohomeopthws">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									Mitochondria Homeostasis
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									Pathway Suite
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/NEW_gif_rot_sm.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>RGD releases a pathway suite for mitochondria homeostasis. Click here to explore this important system.</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/mitohomeopwsbanner.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>


<!--____________________________________________________________________________________________-->

				<div class="item" id="cytoscape">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									Cytoscape Gene-Disease
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									& Gene-Pathway Displays
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/shim.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>RGD announces Cytoscape format displays of gene-disease and gene-pathway relationships for miRNA target genes. Click here for more.</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/cytoscmirtargbanner2.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>

<!--____________________________________________________________________________________________-->

				<div class="item" id="mitoautodynampws">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									Mitochondrial Autophagy
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									and Dynamics Pathways
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/shim.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>RGD publishes pathway diagram pages for mitochondrial autophagy and dynamics. Click here to explore.</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/mitoautodynambanner2.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>

<!--____________________________________________________________________________________________-->




			<div class="item" id="aging">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									Aging and Age-Related
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									Disease Portal
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/NEW_gif_rot_sm.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>RGD's announces the release of our tenth disease portal, the Aging and Age-Related Disease Portal. Click here for details.</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/aging4banner_112x89.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>


<!--____________________________________________________________________________________________-->


				<div class="item" id="smpdbaip">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									New Pathway
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									Database Pipeline
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/shim.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>RGD releases the Small Molecule Pathway Database (SMPDB) Annotation Import Pipeline. Click here for details</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/smpdbaipbanner.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>

<!--____________________________________________________________________________________________-->


				<div class="item" id="GERRC_round5">
					<div class="ad-box-item2">
 					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									GERRC
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									Round&nbsp;5
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/shim.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>Applications are now being accepted by the MCW Gene Editing Rat Resource Center, round 5. Click here for more information.</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/RGERC-logo-130x123.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>


<!--____________________________________________________________________________________________-->

				<div class="item" id="mitproimppw">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									Mitochondrial Protein
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									Import Pathway
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/shim.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>RGD releases the mitochondrial protein import pathway. Click here to explore this complex system.</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/mitproimppwbanner.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>

<!--____________________________________________________________________________________________-->

				<div class="item" id="2016calendar">
					<div class="ad-box-item2">
					<table>
					<tr>
						<td>
						<table>
							<tr>
								<td class="title" colspan=2>
									RGD's&nbsp;2016&nbsp;Rat
								</td>
							</tr>
							<tr>
								<td class="title" valign="top">
									Calendar
								</td>
								<td>
									<img src="http://rgd.mcw.edu/common/images/NEW_gif_rot_sm.gif" />
								</td>
							</tr>
						</table>
							<font size=2><b>The high resolution PDF of RGD's 2016 Rat Calendar is now available on our ftp site.  Click here to download your copy!</b></font>

						</td>
						<td>
							<img src="http://rgd.mcw.edu/common/images/RGD_2016_Calendar_Cover_150x150.png" />
						</td>
					</tr>
					</table>
					</div>
				</div>



<script>




var myFunc = new Function("location.href='http://rgd.mcw.edu/wg/news2/11/30-rgd-releases-the-interactive-pathway-page-for-the-mitochondrial-protein-import-pathway';");
document.getElementById("mitproimppw").onclick=myFunc

var myFunc = new Function("location.href='http://rgd.mcw.eduhttp://rgd.mcw.edu/wg/news2/11/6-rgd-announces-the-small-molecule-pathway-database-smpdb-annotation-import-pipeline';");
document.getElementById("smpdbaip").onclick=myFunc

var myFunc = new Function("location.href='http://rgd.mcw.edu/wg/news2/12/07-rgd-publishes-a-pathway-suite-dedicated-to-mitochondria-homeostasis/mitohomeopws';");
document.getElementById("mitohomeopthws").onclick=myFunc

var myFunc = new Function("location.href='http://rgd.mcw.edu/wg/news2/10/19-rgd-releases-two-interactive-diagram-pages-for-the-mitochondrial-autophagy-and-mitochondria-dynamics-pathways-two-intimately-connected-networks/mitoautodynampws';");
document.getElementById("mitoautodynampws").onclick=myFunc

var myFunc = new Function("location.href='ftp://ftp.rgd.mcw.edu/pub/data_release/Hi-res_Rat_Calendars/Hi-Res_RGD_2016_Calendar.pdf';");
document.getElementById("2016calendar").onclick=myFunc

var myFunc = new Function("location.href='http://rgd.mcw.edu/wg/gerrc';");
document.getElementById("GERRC_round5").onclick=myFunc

var myFunc = new Function("location.href='http://rgd.mcw.edu/wg/news2/12/15-rgd-announces-the-release-of-the-aging-and-age-related-disease-portal';");
document.getElementById("aging").onclick=myFunc

var myFunc = new Function("location.href='http://rgd.mcw.edu/wg/news2/11/20-rgd-releases-cytoscape-charts-displaying-disease-relationships-of-mirna-target-genes';");
document.getElementById("cytoscape").onclick=myFunc

</script>

</div>

			
		
			

			<div class="content"><div class="bordered-article">

	<div class="bordered-article-title">&nbsp;Latest News</div>



<span class="verticalMenu">
<table>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/12/15-rgd-announces-the-release-of-the-aging-and-age-related-disease-portal">12/15 - RGD announces the release of the Aging and Age-Related Disease Portal</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/12/07-rgd-publishes-a-pathway-suite-dedicated-to-mitochondria-homeostasis">12/14 - RGD publishes a pathway suite dedicated to mitochondria homeostasis</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/11/30-rgd-releases-the-interactive-pathway-page-for-the-mitochondrial-protein-import-pathway">11/23 - RGD releases the interactive pathway page for the mitochondrial protein import pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/11/20-rgd-releases-cytoscape-charts-displaying-disease-relationships-of-mirna-target-genes">11/20 - RGD releases Cytoscape charts displaying disease and pathway relationships of miRNA target genes</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/11/6-rgd-announces-the-small-molecule-pathway-database-smpdb-annotation-import-pipeline">11/06 - RGD announces the Small Molecule Pathway Database (SMPDB) Annotation Import Pipeline</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/10/29-rgd-releases-new-olga-object-list-generator-and-analyzer-video-tutorial">10/29 - RGD releases new OLGA-Object List Generator and Analyzer Video Tutorial</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/10/29-rgd-members-featured-in-medical-college-of-wisconsin-promotional-video">10/28 - RGD members featured in Medical College of Wisconsin promotional video</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/10/19-rgd-releases-two-interactive-diagram-pages-for-the-mitochondrial-autophagy-and-mitochondria-dynamics-pathways-two-intimately-connected-networks">10/19 - RGD releases two interactive diagram pages for the mitochondrial autophagy and mitochondria dynamics pathways, two intimately connected networks</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/09/28-rgd-publishes-an-interactive-diagram-page-for-the-cardiolipin-metabolic-pathway">09/28 - RGD publishes an interactive diagram page for the cardiolipin metabolic pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/08/31-rgd-releases-four-interactive-diagram-pages-for-doxorubicin-drug-and-related-pathways-in-a-pathway-suite">08/31 - RGD releases four interactive diagram pages for doxorubicin drug and related pathways in a pathway suite</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/08/26-registration-is-now-open-for-the-2015-rat-genomics-and-models-meeting">08/26 - Registration is now open for the 2015 Rat Genomics and Models meeting</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/08/17-rgd-releases-the-dna-damage-response-pathway-suite">08/10 - RGD releases the DNA Damage Response pathway suite</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/07/30-rgd-publishes-the-s-adenosylmethionine-homeostasis-pathway-suite-network">07/30 - RGD publishes the S-adenosylmethionine Homeostasis Pathway Suite Network</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/07/27-rgd-releases-a-comprehensive-update-of-the-insulin-responsive-facilitative-sugar-transporter-mediated-glucose-transport-pathway">07/27 - RGD releases a comprehensive update of the insulin responsive facilitative sugar transporter mediated glucose transport pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/07/10-workshop-on-genome-resources-for-the-rat-community">07/10 - Announcing the Workshop on Genome Resources for the Rat Community</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/06/15-rgd-releases-an-updated-pathway-suite-network-for-gene-expression-and-regulation">06/15 - RGD releases an updated pathway suite network for gene expression and regulation</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/06/11-rgd-provides-new-files-comparing-genes-between-genome-assemblies-rn3.4-rn5-and-rn6">06/11 - RGD provides new files comparing genes between genome assemblies rn3.4, rn5 and rn6</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/06/09-rgd-releases-an-interactive-diagram-page-for-the-translation-pathway">06/09 - RGD releases an interactive diagram page for the translation pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/05/06-paper-describing-analysis-of-variation-data-for-40-strains-published-in-bmc-genomics">05/06 - Paper describing analysis of variation data for 40+ rat strains published in BMC Genomics</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/04/27-rgd-publishes-an-interactive-diagram-page-for-the-ribosome-biogenesis-pathway">04/27 - RGD publishes an interactive diagram page for the ribosome biogenesis pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/04/08-registration-is-now-open-for-the-rat-genetics-and-genomics-for-psychiatric-disorders-and-addiction-workshop">04/08 - Registration is now open for the Rat Genetics and Genomics for Psychiatric Disorders and Addiction Workshop</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/03/30-rgd-releases-an-updated-version-of-the-microrna-pathway-interactive-diagram">03/30 - RGD releases an updated version of the microRNA pathway interactive diagram</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/03/09-rgd-announces-the-publication-of-a-new-pathway-suite-network-for-gene-expression-and-regulation">03/09 - RGD announces the publication of a new pathway suite network for gene expression and regulation</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/02/26-rgd-publishes-an-interactive-diagram-page-for-the-mrna-nuclear-export-pathway">03/02 - RGD publishes an interactive diagram page for the mRNA nuclear export pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/02/24-rgd-announces-the-official-release-of-the-jbrowse-genome-browser">02/24 - RGD announces the official release of the JBrowse genome browser</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/02/09-rgd-releases-an-interactive-diagram-page-for-the-spliceosomal-pathway">02/09 - RGD releases an interactive diagram page for the spliceosomal pathway</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/01/21-rgd-s-latest-update-paper-published-in-nucleic-acids-research">01/21 - RGD's latest update paper published in Nucleic Acids Research</a>
	</td></tr>

	<tr><td>&nbsp;&nbsp;&nbsp;</td><td>
	<a  href="http://rgd.mcw.edu/wg/news2/01/05-rgd-publishes-a-new-interactive-diagram-for-the-rna-polymerase-iii-transcription-pathway">01/05 - RGD publishes a new interactive diagram for the RNA polymerase III transcription pathway</a>
	</td></tr>

</table>
</span>
</div></div>

			
		
			

			<div class="content"><script>
if(typeof(urchinTracker)!='function')document.write('<sc'+'ript src="'+
'http'+(document.location.protocol=='https:'?'s://ssl':'://www')+
'.google-analytics.com/urchin.js'+'"></sc'+'ript>')
</script>
<script>
_uacct = 'UA-2739107-3';
urchinTracker("/1110218286/test");
</script>

<!--script>
document.forms[0].term.focus();    
</script--></div>

			
		

		
		</div>
		<!-- end position 3 -->	
        &nbsp;
	</td>	
</tr>
</table>




		</div>
		<br>
 		<div class="bottom-bar" >
<table align=center class="headerTable"> <tr><td align="left" style="color:white;">
		<a href="/contact/index.shtml">Contact Us</a>&nbsp;|&nbsp;
		<a href="http://rgd.mcw.edu/wg/about-us">About Us</a>&nbsp;|&nbsp;
		<a href="http://rgd.mcw.edu/wg/jobs">Jobs at RGD</a>
</td></tr></table>
		</div>
	</div>
</div>

<!-- end page wrapper -->	
</div>
</td></tr>
</table>


<div id="copyright">
	<p>&copy; <a href="http://www.mcw.edu/bioinformatics.htm">Bioinformatics Program, HMGC</a> at the <a href="http://www.mcw.edu/">Medical
        College of Wisconsin</a></p>
	<p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="http://rgd.mcw.edu/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo">
<br><br><div class="loginBox">

	<form action="http://rgd.mcw.edu/wg/home" enctype="multipart/form-data" method="post" ><div class="formContents"><input type="hidden" name="webguiCsrfToken" value="Ud1TRZa5UgqmkXfVfmMo5w"  />
<input type="hidden" name="op" value="auth"  />
<input type="hidden" name="method" value="login"  />

	<table border="0" cellpadding="1" cellspacing="0">
	<tr>
		<td><input id="username_formId" type="text" name="username" value="" size="8" maxlength="255" class="loginBoxField" /></td>
		<td><input type="password" name="identifier" value="" size="8" id="identifier_formId" maxlength="35" class="loginBoxField" /></td>
		<td><input type="submit" value="login" class="loginBoxButton" /></td>
	</tr>
	<tr>
		<td><label for="username_formId">Username</label></td>
		<td><label for="identifier_formId">Password</label></td>
		<td></td>
	</tr>
	</table>             	
                        <a href="http://rgd.mcw.edu/wg/home?op=auth;method=createAccount">Click here to register.</a>
			</div></form>

 

</div>


</div>


<script language="javascript" src="http://rgd.mcw.edu/common/js/killerZebraStripes.js" type="text/javascript"></script>
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

<script type="text/javascript">
var uservoiceOptions = {
   /* required */
   key: 'rgd',
   host: 'rgd.uservoice.com',
   forum: '33675',
   showTab: true,
   /* optional */
   alignment: 'left',
   background_color:'#f00',
   text_color: 'white',
   hover_color: '#06C',
   lang: 'en'
};

function _loadUserVoice() {
   var s = document.createElement('script');
   s.setAttribute('type', 'text/javascript');
   s.setAttribute('src', ("https:" == document.location.protocol ? "https://" : "http://") + "cdn.uservoice.com/javascripts/widgets/tab.js");
   document.getElementsByTagName('head')[0].appendChild(s);
}
_loadSuper = window.onload;
window.onload = (typeof window.onload != 'function') ? _loadUserVoice : function() { _loadSuper(); _loadUserVoice(); };
</script>








</body>
</html>