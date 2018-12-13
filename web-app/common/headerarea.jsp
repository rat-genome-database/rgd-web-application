<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedObject" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedTerm" %>


<%
    String resourcePath = "";
    if (request.getServerName().equals("localhost") && request.getServerPort() == 8080) {
        resourcePath= "https://dev.rgd.mcw.edu";
    }
%>


<% if (RgdContext.isChinchilla(request)) { %>
<%@include file="ngcheaderarea.jsp" %>
<%} else { %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="keywords" content="<%=RgdContext.getLongSiteName(request)%>">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE, NO-STORE, MUST-REVALIDATE">
<meta name="author" content="RGD">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><meta name="generator" content="WebGUI 7.9.16" /><meta http-equiv="Content-Script-Type" content="text/javascript" /><meta http-equiv="Content-Style-Type" content="text/css" /><script type="text/javascript">function getWebguiProperty (propName) {var props = new Array();props["extrasURL"] = "/extras/";props["pageURL"] = "/wg/template";props["firstDayOfWeek"] = "0";return props[propName];}</script><link href="/wg/layout.css" rel="stylesheet" type="text/css" /><!--page layout--><meta http-equiv="Pragma" content="no-cache" /><meta http-equiv="Cache-Control" content="no-cache, must-revalidate, max-age=0, private" /><meta http-equiv="Expires" content="0" />
  <%
        if (!pageDescription.equals("")) {
    %>
        <meta name="description" content="<%=pageDescription%>" />
    <% } %>

    <%=headContent%>
    <title><%=pageTitle%></title>

    <link rel="stylesheet" href="/rgdweb/css/jquery/jquery-ui-1.8.18.custom.css">
<link rel="SHORTCUT ICON" href="<%=resourcePath%>/favicon.ico" />
<link rel="stylesheet" type="text/css" href="<%=resourcePath%>/common/modalDialog/subModal.css" />
<link rel="stylesheet" type="text/css" href="<%=resourcePath%>/common/modalDialog/style.css" />
<link href="<%=resourcePath%>/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" />

    <!-- adding link for OntoSolr (Pushkala) -->
<link rel="stylesheet" href="/OntoSolr/files/jquery.autocomplete.css" type="text/css" />

<!-- CSS for Tab Menu #4 -->
<link rel="stylesheet" type="text/css" href="<%=resourcePath%>/common/style/ddcolortabs.css" />

<script type="text/javascript" src="<%=resourcePath%>/common/modalDialog/common.js"></script>
<script type="text/javascript" src="<%=resourcePath%>/common/modalDialog/subModal.js"></script>
<script type="text/javascript" src="<%=resourcePath%>/common/js/poll.js"></script>
    <script src="/rgdweb/js/jquery/jquery-1.7.1.min.js"></script>
    <script src="/rgdweb/js/jquery/jquery-ui-1.8.18.custom.min.js"></script>
    <script src="/rgdweb/js/jquery/jquery_combo_box.js"></script>

<script src="https://www.google-analytics.com/urchin.js" type="text/javascript"></script>
<script type="text/javascript">
_uacct = "UA-2739107-2";
urchinTracker();
</script>


<script type="text/javascript" src="<%=resourcePath%>/common/js/ddtabmenu.js">

/***********************************************
* DD Tab Menu script- � Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>
<script type="text/javascript" src="<%=resourcePath%>/common/js/rgdHomeFunctions-3.js"></script>

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
            return "<%=idForAngular%>";
        }
        function getGeneWatchAttributes() {
            //return ["Nomenclature Changes","New GO Annotation","New Disease Annotation","New Phenotype Annotation","New Pathway Annotation","New PubMed Reference","Altered Strains","New NCBI Transcript/Protein","New Protein Interaction","RefSeq Status Has Changed"];
            return <%= WatchedObject.getAllWatchedLabelsAsJSON()%>
        }
        function getTermWatchAttributes() {
            return <%= WatchedTerm.getAllWatchedLabelsAsJSON()%>
        }


    </script>

    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="/rgdweb/css/elasticsearch/elasticsearch.css">
    <link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>

    <script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular.js"></script>
    <script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular-sanitize.js"></script>
    <script type="text/javascript" src="/rgdweb/my/my.js?5"></script>


    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
    <script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>

    <script type="text/javascript" src="/rgdweb/js/elasticsearch/elasticsearchcommon.js"></script>


</head>

<body style="background-color:#E8E7E2"  ng-cloak ng-app="rgdPage">
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
                <a href="/wg/home/rat-genome-database-publications">Publications</a>&nbsp;|&nbsp;
                <a href="/wg/com-menu/poster_archive/">Poster Archive</a>&nbsp;|&nbsp;
            <a href="ftp://ftp.rgd.mcw.edu/pub">FTP Download</a>&nbsp;|&nbsp;
        <a href="http://rest.rgd.mcw.edu/rgdws/swagger-ui.html">REST API</a>&nbsp;|&nbsp;
        <a href="/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
                <a href="/contact/index.shtml">Contact Us</a>&nbsp;&nbsp;&nbsp;
    </td>

    <td width="90">
            <input type="button" class="btn btn-info btn-sm"  value="{{username}}" ng-click="rgd.loadMyRgd($event)" style="background-color:#4584ED;"/>
    </td>

</tr></table>
        </div>

<table width="100%" border=0>
    <tr><td colspan="8">
        <div id="app">
            <div id="test" style="width:100%;height:10px">

            </div>

            <div class="container-fluid" id="container" style="height:36px;background-color:#d6e5ff;">

                <div class="row" style=";margin-top:2px;margin-left:35%;width:100%">

                        <table>
                            <tr>

                                <td>
                                    <form name="elasticSearchForm" class="form-inline" action="/rgdweb/elasticResults.html" id="elasticearchForm" role="search" method="post">

                        <input type="hidden" name="log" value="true"/>
                        <input type="hidden" name="category" id="category" value="General"/>
                                <table><tr>
                                <!--td style="color:#24609c">Select Database:</td>
                                <td>
                                    <select id="category" class="searchgroup category" name="category" >
                                    <option >Gene</option>
                                    <option>QTL</option>
                                    <option>Strain</option>
                                    <option>SSLP</option>
                                    <option>Reference</option>
                                    <option>Ontology</option>
                                    <option selected>General</option>
                                </select>

                                </td-->
                                <td><input type=text class="searchgroup" id="term" name="term" size="50" placeholder="Enter Search Term..." value="${model.term}"/></td>
                                <td><input type="image" src="https://rgd.mcw.edu/common/images/searchGlass.gif" class="searchButtonSmall"/></td>
                                </tr>
                                </table>
                                    </form>
                                </td>

                                <td colspan="2"  align="center"><br><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></td>

                            </tr>
                            <!--tr>
                                <td>
                                    <div style="">
                                    <small id="termHelp" class="form-text text-muted" >
                                      <a href="javascript:document.searchForm.term.value='A2m';document.searchForm.submit();" >A2m</a>, <a href="javascript:document.searchForm.term.value='Hypertension';document.searchForm.submit();" >Hypertension</a>, <a href="javascript:document.searchForm.term.value='BN/Crl';document.searchForm.submit();" >BN/Crl</a>, <a href="javascript:document.searchForm.term.value='SHR.BN-(D13Arb5-Ren)/Ipcv';document.searchForm.submit();" >SHR.BN-(D13Arb5-Ren)/Ipcv</a>, <a href="javascript:document.searchForm.term.value='DOID:10763';document.searchForm.submit();" >DOID:10763</a>
                                    </small>
                                </div>
                                </td>
                            </tr-->
                        </table>



                </div>

                        </div>

        </div>




    </td></tr>
<tr>
	<td>
	<table><tr><td>
       <a class="homeLink" href="/wg/home"><img border="0" src="<%=resourcePath%>/common/images/rgd_LOGO_blue_rgd.gif"></a>
       </td>
       </tr>
       </table>

</td>
<td width=200 align="right"><a href="/wg/gerrc"><img src="<%=resourcePath%>/common/images/gerrc/GERRC-35.png" border=0/></a></td>
    <td width=200 align="center"><a href="http://alliancegenome.org"><img src="/common/images/alliance_logo.png" height="80" width="133" border=0/></a></td>

<td width=200 align="center"><a href="http://pga.mcw.edu"><img src="<%=resourcePath%>/common/images/physGen_logo.gif" border=0/></a></td>
<!--td align="right">

      <div class="searchBorder">
      <table border=0 cellpadding=0 cellspacing=0 >
        <form method="post" action='/rgdweb/search/search.html' onSubmit="return verify(this);">
          <input type="hidden" name="type" value="nav" />
          <tr>
	    <td class="searchKeywordLabel">Keyword</td>

            <td class="atitle" align="right">                <input type=text name=term size=12 value="" onFocus="JavaScript:document.forms[0].term.value=''" class="searchKeywordSmall">
              </td>
            <td>
<input type="image" src="<-%=resourcePath%>/common/images/searchGlass.gif" class="searchButtonSmall"/>
</td>
          </tr>
            <tr>
                <td colspan="2"  align="center"><br><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></td>
            </tr>

        </form>
      </table>
      </div>

</td-->
<td>&nbsp;&nbsp;</td>
</tr>
</table>

<div id="ddtabs4" class="ddcolortabs">
<ul>
<li class="current" style="margin-left: 1px"><a href="/"  rel="ct1"><span>Home</span></a></li>
<li><a href="/wg/data-menu" rel="ct2"><span>Data</span></a></li>
<li><a href="/wg/tool-menu" rel="ct3"><span>ANALYSIS & VISUALIZATION</span></a></li>
<li><a href="/wg/portals/" rel="ct4"><span>Diseases</span></a></li>
<li><a href="/wg/physiology" rel="ct5"><span>Phenotypes & Models</span></a></li>


<li><a href="/rgdweb/models/allModels.html" rel="ct6"><span>Genetic Models</span></a></li>

<li><a href="/wg/home/pathway2" rel="ct7"><span>Pathways</span></a></li>
<li><a href="/wg/com-menu" rel="ct8"><span>Community</span></a></li>
<li id="curation-top" style="visibility: hidden;"><a href="/curation" rel="ct9"><span>Curation Web</span></a></li>
</ul>
</div>
<div class="ddcolortabsline"><img src="<%=resourcePath%>/common/images/squareBullet.gif" /></div>

<!--<div style="width:100%; height:5px; font-size:1px; background-color: #2865a3">&nbsp;</div>-->

<DIV class="tabcontainer">

<div id="ct1" class="tabcontent">

<div id="subnav">
     <ul>
<li class="first"><a href="/wg/general-search" rel="ct2"><span>Search RGD</span></a></li>
<li><a href="/wg/grants" rel="ct2"><span>Grant Resources</span></a></li>
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
     <li ><a href="http://bioneos.com/VCMap/" rel="ct1"><span>VCMap</span></a></li>
     <li ><a href="/rgdweb/front/config.html" rel="ct1"><span>Variant Visualizer</span></a></li>

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
         <li class=first><a href="/rgdweb/portal/home.jsp?p=1" rel="ct1"><span>Aging</span></a></li>
     <li ><a href="/rgdweb/portal/home.jsp?p=2" rel="ct1"><span>Cancer</span></a></li>
     <li ><a href="/rgdweb/portal/home.jsp?p=3" rel="ct2"><span>Cardiovascular</span></a></li>
     <li><a href="/rgdweb/portal/home.jsp?p=4" rel="ct2"><span>Diabetes</span></a></li>
     <li><a href="/rgdweb/portal/home.jsp?p=5" rel="ct2"><span>Hematologic</span></a></li>
     <li><a href="/rgdweb/portal/home.jsp?p=6" rel="ct2"><span>Immune</span></a></li>
     <li><a href="/rgdweb/portal/home.jsp?p=7" rel="ct2"><span>Neurological</span></a></li>
     <li><a href="/rgdweb/portal/home.jsp?p=8" rel="ct2"><span>Obesity</span></a></li>
     <li><a href="/rgdweb/portal/home.jsp?p=8" rel="ct2"><span>Renal</span></a></li>
         <li><a href="/rgdweb/portal/home.jsp?p=8" rel="ct2"><span>Respitory</span></a></li>
         <li><a href="/rgdweb/portal/home.jsp?p=8" rel="ct2"><span>Sensory</span></a></li>
     </ul>
</div>
</div>

<div id="ct5" class="tabcontent">
<div id="subnav">
     <ul>
     <li class=first><a href="/wg/phenotype-data13" rel="ct1"><span>Phenotypes</span></a></li>

     <li ><a href="/wg/strains-and-models2" rel="ct3"><span>Strains & Models</span></a></li>
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
     <li class=first><a href="/wg/home/pathway2/molecular-pathways2" rel="ct1"><span>Molecular Pathways</span></a></li>
     <li ><a href="/wg/home/pathway2/physiological-pathways" rel="ct1"><span>Physiological Pathways</span></a></li>
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
         <li><a href="/rgdCuration/" rel="ct2"><span>Curation Tools</span></a></li>
         <li><a href="/rgdweb/curation/nomen/nomenSearch.html" rel="ct3"><span>Nomenclature</span></a></li>
         <li><a href="/rgdweb/score/board.jsp" rel="ct1"><span>Score Board</span></a></li>

         <li><a href="/rgdweb/curation/pipeline/list.html" rel="ct4"><span>Pipeline Logs</span></a></li>
         <li><a href="/rgdweb/curation/phenominer/home.html" rel="ct5"><span>Phenominer</span></a></li>

         <li><a href="/rgdweb/curation/edit/submittedStrains/editStrains.html" rel="ct6"><span>Submitted Strains</span></a></li>




     </ul>
</div>
</div>



</DIV>
<!--end headwrapper -->
</div>

<script>
if (location.href.indexOf("https://rgd.mcw.edu") == -1 &&
	location.href.indexOf("https://www.rgd.mcw.edu") == -1 &&
    location.href.indexOf("osler") == -1 &&
    location.href.indexOf("horan") == -1 &&
    location.href.indexOf("owen") == -1 &&
    location.href.indexOf("hancock") == -1 &&
    location.href.indexOf("preview.rgd.mcw.edu") == -1) {

	document.getElementById("curation-top").style.visibility='visible';
}


ddtabmenu.definemenu("ddtabs4", getTabIndex()) //initialize Tab Menu
</script>
<br><br>
	<div id="mainBody">
		<div id="contentArea" class="content-area">
			<div id="layout3f7342bad77460be364638b044032ac2" class="layout default">

<a name="idP3NCutd0YL42RjiwRAMqwg" id="idP3NCutd0YL42RjiwRAMqwg"></a>






<!-- begin position 1 -->
<div class="wg-content-position">
<% } %>

<%
    ArrayList error = (ArrayList) request.getAttribute("error");
    if (error != null) {
        Iterator errorIt = error.iterator();
        while (errorIt.hasNext()) {
            String err = (String) errorIt.next();
            out.println("<br><span style=\"color:red;\">" + err + "</span>");
        }
        out.println("<br>");
    }

    ArrayList status = (ArrayList) request.getAttribute("status");

    if (status !=null) {
        Iterator statusIt = status.iterator();
        while (statusIt.hasNext()) {
            String stat = (String) statusIt.next();
            out.println("<br><span style=\"color:blue;\">" + stat + "</span>");
        }
        out.println("<br><br>");
    }
%>
