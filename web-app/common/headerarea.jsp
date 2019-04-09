<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedObject" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedTerm" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="keywords" content="<%=RgdContext.getLongSiteName(request)%>">
    <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE, NO-STORE, MUST-REVALIDATE">
    <meta name="author" content="RGD">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta http-equiv="Content-Script-Type" content="text/javascript" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Cache-Control" content="no-cache, must-revalidate, max-age=0, private" />
    <meta http-equiv="Expires" content="0" />
    <%
        if (!pageDescription.equals("")) {
    %>
    <meta name="description" content="<%=pageDescription%>" />
    <% } %>

    <%=headContent%>
    <title><%=pageTitle%></title>

    <link rel="stylesheet" href="/rgdweb/css/jquery/jquery-ui-1.8.18.custom.css">
    <link rel="SHORTCUT ICON" href="/favicon.ico" />
    <link rel="stylesheet" type="text/css" href="/rgdweb/common/modalDialog/subModal.css" />
    <link rel="stylesheet" type="text/css" href="/rgdweb/common/modalDialog/style.css" />
    <link href="/rgdweb/common/rgd_styles-3.css" rel="stylesheet" type="text/css" />

    <!-- adding link for OntoSolr (Pushkala) -->
    <link rel="stylesheet" href="/OntoSolr/files/jquery.autocomplete.css" type="text/css" />


    <script type="text/javascript" src="/rgdweb/common/modalDialog/common.js"></script>
    <script type="text/javascript" src="/rgdweb/common/modalDialog/subModal.js"></script>
    <script src="/rgdweb/js/jquery/jquery-1.7.1.min.js"></script>
    <script src="/rgdweb/js/jquery/jquery-ui-1.8.18.custom.min.js"></script>
    <script src="/rgdweb/js/jquery/jquery_combo_box.js"></script>

    <script src="https://www.google-analytics.com/urchin.js" type="text/javascript"></script>
    <script type="text/javascript">
        _uacct = "UA-2739107-2";
        urchinTracker();
    </script>

    <script type="text/javascript" src="/rgdweb/js/rgdHomeFunctions-3.js"></script>

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

<body  ng-cloak ng-app="rgdPage">
<%@ include file="/common/angularTopBodyInclude.jsp" %>




<table class="wrapperTable" cellpadding="0" cellspacing="0" border="0">
    <tr>
        <td>

            <div id="headWrapper">





                <div class="top-bar">
                    <table width="100%" border="0" class="headerTable" cellpadding="0" cellspacing="0">
                        <tr>
                            <td align="left" style="color:white;" rowspan="3" width="10">

                                <div ><a class="homeLink" href="/wg/home"><img style="border:3px solid #2865A3;" border="0" src="/rgdweb//common/images/rgd_logo.jpg"></a></div>

                            </td>

                            <td align="right" style="color:white;" valign="center" colspan="3">

                            <a href="/tu">Help</a>&nbsp;|&nbsp;
                            <a href="/wg/home/rgd_rat_community_videos/">Video Tutorials</a>&nbsp;|&nbsp;
                            <a href="/wg/com-menu/poster_archive/">News</a>&nbsp;|&nbsp;
                            <a href="/wg/home/rat-genome-database-publications">Publications</a>&nbsp;|&nbsp;

                            <a href="ftp://ftp.rgd.mcw.edu/pub">FTP Download</a>&nbsp;|&nbsp;
                            <a href="https://rest.rgd.mcw.edu/rgdws/swagger-ui.html">REST API</a>&nbsp;|&nbsp;
                            <a href="/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
                            <a href="/contact/index.shtml">Contact</a>&nbsp;&nbsp;&nbsp;

                            <input type="button" class="btn btn-info btn-sm"  value="{{username}}" ng-click="rgd.loadMyRgd($event)" style="background-color:#2B84C8;padding:1px 10px;font-size:12px;line-height:1.5;border-radius:3px"/>
                        </td>

                    </tr>

                    <tr>
                        <td colspan="2">



                            <div class="navbar">
                                <div class="dropdown">
                                    <button class="dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg'">Home
                                        <i class="fa fa-caret-down"></i>
                                    </button>

                                    <div class="dropdown-content">
                                        <a href="/wg/general-search/">Search RGD</a>
                                        <a href="/wg/grants/">Grant Resources</a>
                                        <a href="/wg/citing-rgd/">Citing RGD</a>
                                        <a href="/wg/about-us/">About Us</a>
                                        <a href="/contact/index.shtml">Contact Us</a>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/data-menu/'">Data
                                        <i class="fa fa-caret-down"></i>
                                    </button>

                                    <div class="dropdown-content">
                                        <a href="/rgdweb/search/genes.html?100">Genes</a>
                                        <a href="/rgdweb/search/qtls.html?100">QTLs</a>
                                        <a href="/rgdweb/search/strains.html?100">Strains</a>
                                        <a href="/rgdweb/search/markers.html?100">Markers</a>
                                        <a href="/rgdweb/report/genomeInformation/genomeInformation.html">Genome Information</a>
                                        <a href="/rgdweb/ontology/search.html">Ontologies</a>
                                        <a href="/rgdweb/search/cellLines.html">Cell Lines</a>
                                        <a href="/rgdweb/search/references.html?100">References</a>
                                        <a href="ftp://ftp.rgd.mcw.edu/pub/">FTP Download</a>
                                        <a href="/registration-entry.shtml">Submit Data</a>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/tool-menu/'">Analysis & Visualization
                                        <i class="fa fa-caret-down"></i>
                                    </button>

                                    <div class="dropdown-content">
                                        <a href="/jbrowse/">JBrowse (Genome Browser)</a>
                                        <a href="/rgdweb/front/config.html">Variant Visualizer</a>
                                        <a href="/rgdweb/cytoscape/query.html">InterViewer (Protein-Protein Interactions)</a>
                                        <a href="/rgdweb/phenominer/home.jsp">PhenoMiner (Quatitative Phenotypes)</a>
                                        <a href="/rgdweb/ga/start.jsp">Gene Annotator</a>
                                        <a href="/rgdweb/generator/list.html">OLGA (Gene List Generator)</a>
                                        <a href="http://ratmine.mcw.edu/ratmine/begin.do">RatMine</a>
                                        <a href="/rgdweb/gTool/Gviewer.jsp">GViewer (Genome Viewer)</a>
                                        <a href="/rgdweb/overgo/find.html">Overgo Probe Designer</a>
                                        <a href="/ACPHAPLOTYPER/">ACP Haplotyper</a>
                                        <a href="/GENOMESCANNER/">Genome Scanner</a>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/portals/'">Diseases
                                        <i class="fa fa-caret-down"></i>
                                    </button>

                                    <div class="dropdown-content">
                                        <a href="/rgdCuration/?module=portal&func=show&name=aging">Aging & Age-Related Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=cancer">Cancer</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=cardio">Cardiovascular Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=develop">Developmental Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=diabetes">Diabetes</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=blood">Hematologic Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=immune">Immune & Inflammatory Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=nuro">Neurological Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=obesity">Obesity & Metabolic Syndrome</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=renal">Renal Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=respir">Respiratory Disease</a>
                                        <a href="/rgdCuration/?module=portal&func=show&name=sensory">Sensory Organ Disease</a>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/physiology/'">Phenotypes & Models
                                        <i class="fa fa-caret-down"></i>
                                    </button>

                                    <div class="dropdown-content">
                                        <a href="/rgdweb/models/allModels.html">Genetic Models</a>
                                        <a href="/rgdweb/phenominer/home.jsp">PhenoMiner (Quantitative Phenotypes)</a>
                                        <a href="/rgdweb/phenominer/phenominerExpectedRanges/views/home.html">Expected Ranges (Quantitative Phenotype)</a>
                                        <a href="/rgdweb/pa/termCompare.html?term1=RS%3A0000457&term2=CMO%3A0000000&countType=rec&species=3">Phenominer Term Comparison</a>
                                        <a href="/wg/phenotype-data13/">Phenotypes</a>
                                        <a href="/wg/gerrc/">GERRC (Gene Editing Rat Resource Center)</a>
                                        <a href="/wg/physiology/additionalmodels/">Phenotypes in Other Animal Models</a>
                                        <a href="/wg/strain-maintenance/">Animal Husbandry</a>
                                        <a href="/wg/physiology/strain-medical-records/">Strain Medical Records</a>
                                        <a href="/wg/phylogenetics/">Phylogenetics</a>
                                        <a href="/wg/strain-availability/">Strain Availability</a>
                                        <a href="ftp://ftp.rgd.mcw.edu/pub/data_release/Hi-res_Rat_Calendars/">Calendar</a>
                                        <a href="/wg/physiology/rats101/">Rats 101</a>
                                        <a href="/wg/photos-and-images/community-submissions/">Community</a>
                                        <a href="/wg/photos-and-images/physgen-photo-archive2/">Photo Archive</a>
                                    </div>
                                </div>

                                <a href="/wg/home/pathway2/">Pathways</a>

                                <div class="dropdown">
                                    <button class="dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/com-menu/'">Community
                                        <i class="fa fa-caret-down"></i>
                                    </button>

                                    <div class="dropdown-content">
                                        <a href="http://mailman.mcw.edu/mailman/listinfo/rat-forum">Rat Community Forum</a>
                                        <a href="/wg/com-menu/directory-of-rat-laboratories2/">Directory of Rat Laboratories</a>
                                        <a href="/wg/home/rgd_rat_community_videos/">Video Tutorials</a>
                                        <a href="/wg/news2/">News</a>
                                        <a href="/wg/home/rat-genome-database-publications/">RGD Publications</a>
                                        <a href="/wg/com-menu/poster_archive/">RGD Poster Archive</a>
                                        <a href="/nomen/nomen.shtml">Nomenclature Guidelines</a>
                                        <a href="/wg/resource-links/">Resource Links</a>
                                        <a href="/wg/resource-links/laboratory-resources/">Laboratory Resources</a>
                                        <a href="/wg/resource-links/employment-resources/">Employment Resources</a>
                                    </div>
                                </div>
                            </div>





                        </td>

                        </tr>
                        <tr>
                        <td align="center" style="background-color:#2865A3;">
                            <div id="app" style="padding-top:10px;">

                                            <div class="container-fluid" id="container" tyle="background-color:#d6e5ff;padding-top:13px;padding-bottom:0px;">
                                                <div class="row">
                                                    <form  name="elasticSearchForm" class="form-inline" action="/rgdweb/elasticResults.html" id="elasticSearchForm" role="search" method="post">
                                                        <input type="hidden" name="log" value="true" />
                                                        <table border="0">
                                                            <tr>
                                                                <input type="hidden" name="category" id="category" value="General"/>
                                                                <td>
                                                                    <input style="height:20px;" type=text class="searchgroup" id="term" name=term size="40" placeholder="Enter Search Term..." value="" style="border:1px solid #2865A3">
                                                                </td>
                                                                <td>
                                                                    <!--<input type="image" src="/rgdweb/common/images/searchGlass.gif" class="searchButtonSmall"/>-->
                                                                    <input class="btn btn-info btn-sm" style="background-color:#2B84C8;padding:1px 10px;font-size:12px;line-height:1.5;border-radius:3px" type="submit" value="Search RGD"/>

                                                                </td>
                                                                <td colspan="2"  align="center"><br><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></td>
                                                            </tr>
                                                        </table>

                                                    </form>
                                                </div>
                                                </div>

                            </div>
                            </td>
                            <td>
                                <a href="https://www.facebook.com/pg/RatGenomeDatabase/posts/"><img src="/rgdweb/common/images/social/facebook-20.png"/></a>
                                <a href="https://twitter.com/ratgenome"><img src="/rgdweb/common/images/social/twitter-20.png"/></a>
                                <a href="https://www.linkedin.com/company/ratgenome/about/"><img src="/rgdweb/common/images/social/linkedin-20.png"/></a>
                                <a href="https://www.youtube.com/channel/UCMpex8AfXd_JSTH3DIxMGFw?view_as=subscriber"><img src="/rgdweb/common/images/social/youtube-20.png"/></a>

                        </td>
                    </tr>


                    </table>
                </div>

                <input type="hidden" id="speciesType" value="">




            </div>





            </DIV>
            <!--end headwrapper -->
            </div>

            <script>
                if (location.href.indexOf("") == -1 &&
                        location.href.indexOf("https://www.rgd.mcw.edu") == -1 &&
                        location.href.indexOf("osler") == -1 &&
                        location.href.indexOf("horan") == -1 &&
                        location.href.indexOf("owen") == -1 &&
                        location.href.indexOf("hancock") == -1 &&
                        location.href.indexOf("preview.rgd.mcw.edu") == -1) {

                    document.getElementById("curation-top").style.visibility='visible';
                }
            </script>

        </td></tr>
</table>


<div id="mainBody">
    <div id="contentArea" class="content-area">
        <table cellpadding="5" border=0 align="center" width="100%">
            <tr>
                <td colspan="3" align="left" valign="top">

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
