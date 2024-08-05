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
    <meta name="referrer" content="origin">
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
    <link href="/rgdweb/common/rgd_styles-3.css?v=1" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="/rgdweb/OntoSolr/jquery.autocomplete.css" type="text/css" />
    <link rel="stylesheet" href="/rgdweb/css/webFeedback.css" type="text/css"/>

    <script type="text/javascript" src="/rgdweb/common/modalDialog/common.js"></script>
    <script type="text/javascript" src="/rgdweb/common/modalDialog/subModal.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/axios/1.1.3/axios.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <script src="/rgdweb/js/webFeedback.js" defer></script>

    <%@ include file="/common/googleAnalytics.jsp" %>

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
    <script>window.onunload = function () { };</script>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="/rgdweb/css/elasticsearch/elasticsearch.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>


    <script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular.js"></script>
    <script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular-sanitize.js"></script>
    <script type="text/javascript" src="/rgdweb/my/my.js?6"></script>


    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
    <script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>

    <script type="text/javascript" src="/rgdweb/js/elasticsearch/elasticsearchcommon.js"></script>
    <script src="https://accounts.google.com/gsi/client" async></script>

</head>

<style>
    a {
        color:#0C1D2E;
        olor:#073C66;
        text-decoration:underline;
        ont-weight:700;
    }
    .speciesCardOverlay {
        position:absolute;
        background-color:#2865a3;
        minWidth:63px;
        width:63px;
        height:63px;
        z-index:30;
        opacity:0;
    }
    .speciesCardOverlay:hover {
        opacity:.9;
        cursor:pointer;
        color:white;
    }
    .speciesIcon {
        border:1px solid black;
        padding:3px;
    }
    .g_id_signin > div > div:first-child{
        display: none;
    }
</style>

<link href="https://fonts.googleapis.com/css?family=Marcellus+SC|Merienda+One&display=swap" rel="stylesheet">


<body  ng-cloak ng-app="rgdPage"  data-spy="scroll" data-target=".navbar" data-offset="10" style="position: relative;">
<%@ include file="/common/angularTopBodyInclude.jsp" %>
<%@ include file="/common/helpFeedbackChat.jsp" %>

<script>
    function googleSignIn(creds) {
        var resp = fetch("/rgdweb/my/account.html", {
            method: "POST",
            body: JSON.stringify({
                credential: creds.credential
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        }).then((response) => response.json())
            .then((json) => {
                document.getElementById("setUser").click();
            });



    }
</script>

<input style="display:none;" id="setUser" type="button" ng-click="rgd.setUser()" value="click"/>

<table class="wrapperTable" cellpadding="0" cellspacing="0" border="0">
    <tr>
        <td>

            <div id="headWrapper">

                <div class="top-bar">
                    <table width="100%" border="0" class="headerTable" cellpadding="0" cellspacing="0">
                        <tr>
                            <td align="left" style="color:white;" rowspan="3" width="10">

                                <div ><a class="homeLink" href="/wg/home"><img style="border:3px solid #2865A3;" border="0" src="/rgdweb/common/images/rgd_logo.jpg"></a></div>

                            </td>


                            <td align="right" style="color:white;" valign="center" colspan="3">
                                <table>
                                    <tr>
                                        <td>
                                            <a href="/wg/registration-entry/">Submit Data</a>&nbsp;|&nbsp;
                                            <a href="/wg/help3">Help</a>&nbsp;|&nbsp;
                                            <a href="/wg/home/rgd_rat_community_videos/">Video Tutorials</a>&nbsp;|&nbsp;
                                            <a href="/wg/news2/">News</a>&nbsp;|&nbsp;
                                            <a href="/wg/home/rat-genome-database-publications">Publications</a>&nbsp;|&nbsp;

                                            <a href="https://download.rgd.mcw.edu">Download</a>&nbsp;|&nbsp;
                                            <a href="https://rest.rgd.mcw.edu/rgdws/swagger-ui/index.html">REST API</a>&nbsp;|&nbsp;
                                            <a href="/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
                                            <a href="/rgdweb/contact/contactus.html">Contact</a>&nbsp;&nbsp;&nbsp;

                                        </td>
                                        <td>
                                        <div class="GoogleLoginButtonContainer">

                                            <div id="signIn">
                                            <div style="display:none;" id="g_id_onload"
                                                 data-client_id="833037398765-po85dgcbuttu1b1lco2tivl6eaid3471.apps.googleusercontent.com"
                                                 data-auto_prompt="false"
                                                 data-auto_select="true"
                                                 data-callback="googleSignIn"
                                            >
                                            </div>

                                            <div class="g_id_signin"
                                                 data-type="standard"
                                                 data-shape="rectangular"
                                                 data-theme="outline"
                                                 data-text="signin_with"
                                                 data-size="small"
                                                 data-logo_alignment="left">
                                            </div>
                                            </div>
                                            <div id="manageSubs" style="display:none;">
                                                <input  type="button" class="btn btn-info btn-sm"  value="Manage Subscriptions" ng-click="rgd.loadMyRgd($event)" style="background-color:#2B84C8;padding:1px 10px;font-size:12px;line-height:1.5;border-radius:3px"/>
                                            </div>
                                        </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div class="rgd-navbar">
                                    <div class="rgd-dropdown">
                                        <button class="rgd-dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg'">Home
                                            <i class="fa fa-caret-down"></i>
                                        </button>

                                        <div class="rgd-dropdown-content">
                                            <a href="/rgdweb/search/searchByPosition.html">Search RGD</a><!---RGDD-1856 New Search By Position added -->
                                            <a href="/wg/grants/">Grant Resources</a>
                                            <a href="/wg/citing-rgd/">Citing RGD</a>
                                            <a href="/wg/about-us/">About Us</a>
                                            <a href="/rgdweb/contact/contactus.html">Contact Us</a>
                                        </div>
                                    </div>
                                    <div class="rgd-dropdown">
                                        <button class="rgd-dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/data-menu/'">Data
                                            <i class="fa fa-caret-down"></i>
                                        </button>

                                        <div class="rgd-dropdown-content">
                                            <a href="/rgdweb/search/genes.html?100">Genes</a>
                                            <a href="/rgdweb/search/variants.html">Variants</a>
                                            <a href="/rgdweb/projects/project.html">Community Projects</a>
                                            <a href="/rgdweb/search/qtls.html?100">QTLs</a>
                                            <a href="/rgdweb/search/strains.html?100">Strains</a>
                                            <a href="/rgdweb/search/markers.html?100">Markers</a>
                                            <a href="/rgdweb/report/genomeInformation/genomeInformation.html">Genome Information</a>
                                            <a href="/rgdweb/ontology/search.html">Ontologies</a>
                                            <a href="/rgdweb/search/cellLines.html">Cell Lines</a>
                                            <a href="/rgdweb/search/references.html?100">References</a>
                                            <a href="https://download.rgd.mcw.edu">Download</a>
                                            <a href="/wg/registration-entry/">Submit Data</a>
                                        </div>
                                    </div>
                                    <div class="rgd-dropdown">
                                        <button class="rgd-dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/tool-menu/'">Analysis & Visualization
                                            <i class="fa fa-caret-down"></i>
                                        </button>

                                        <div class="rgd-dropdown-content">
                                            <a href="<%=RgdContext.getSolrUrl("solr")%>" >OntoMate (Literature Search)</a>
                                            <a href="/rgdweb/jbrowse2/listing.jsp">JBrowse (Genome Browser)</a>
                                            <a href="/vcmap">Synteny Browser (VCMap)</a>
                                            <a href="/rgdweb/front/config.html">Variant Visualizer</a>

                                            <a href="/rgdweb/enrichment/start.html">Multi-Ontology Enrichment (MOET)</a>
                                            <a href="/rgdweb/ortholog/start.html">Gene-Ortholog Location Finder (GOLF)</a>
                                            <a href="/rgdweb/cytoscape/query.html">InterViewer (Protein-Protein Interactions)</a>
                                            <a href="/rgdweb/phenominer/ontChoices.html?species=3">PhenoMiner (Quatitative Phenotypes)</a>
                                            <a href="/rgdweb/ga/start.jsp">Gene Annotator</a>
                                            <a href="/rgdweb/generator/list.html">OLGA (Gene List Generator)</a>
                                            <a href="https://www.alliancegenome.org/bluegenes/alliancemine">AllianceMine</a>
                                            <a href="/rgdweb/gTool/Gviewer.jsp">GViewer (Genome Viewer)</a>
                                        </div>
                                    </div>
                                    <div class="rgd-dropdown">
                                        <button class="rgd-dropbtn" style="cursor:pointer" onclick="javascript:location.href='/rgdweb/portal/index.jsp'">Diseases
                                            <i class="fa fa-caret-down"></i>
                                        </button>
                                        <div class="rgd-dropdown-content">
                                            <a href="/rgdweb/portal/home.jsp?p=1">Aging & Age-Related Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=2">Cancer & Neoplastic Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=3">Cardiovascular Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=14">Coronavirus Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=12">Developmental Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=4">Diabetes</a>
                                            <a href="/rgdweb/portal/home.jsp?p=5">Hematologic Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=6">Immune & Inflammatory Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=15">Infectious Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=13">Liver Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=7">Neurological Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=8">Obesity & Metabolic Syndrome</a>
                                            <a href="/rgdweb/portal/home.jsp?p=9">Renal Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=10">Respiratory Disease</a>
                                            <a href="/rgdweb/portal/home.jsp?p=11">Sensory Organ Disease</a>
                                        </div>

                                    </div>
                                    <div class="rgd-dropdown">
                                        <button class="rgd-dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/physiology/'">Phenotypes & Models
                                            <i class="fa fa-caret-down"></i>
                                        </button>

                                        <div class="rgd-dropdown-content">
                                            <a href="/rgdweb/models/findModels.html">Find Models&nbsp;&nbsp;&nbsp;<span style="font-weight: bold;color:red">new</span></a>
                                            <a href="/rgdweb/models/allModels.html">Genetic Models</a>
                                            <a href="/wg/autism-rat-model-resource/">Autism Models</a>
                                            <a href="/rgdweb/phenominer/ontChoices.html?species=3">Rat PhenoMiner (Quantitative Phenotypes)</a>
                                            <a href="/rgdweb/phenominer/ontChoices.html?species=4">Chinchilla PhenoMiner</a>
                                            <a href="/rgdweb/phenominer/phenominerExpectedRanges/views/home.html">Expected Ranges (Quantitative Phenotype)</a>
                                            <a href="/rgdweb/pa/termCompare.html?term1=RS%3A0000457&term2=CMO%3A0000000&countType=rec&species=3">PhenoMiner Term Comparison</a>
                                            <a href="/rgdweb/hrdp_panel.html">Hybrid Rat Diversity Panel</a>
                                            <a href="/wg/phenotype-data13/">Phenotypes</a>
                                            <a href="/wg/physiology/additionalmodels/">Phenotypes in Other Animal Models</a>
                                            <a href="/wg/strain-maintenance/">Animal Husbandry</a>
                                            <a href="/wg/physiology/strain-medical-records/">Strain Medical Records</a>
                                            <a href="/wg/phylogenetics/">Phylogenetics</a>
                                            <a href="/wg/strain-availability/">Strain Availability</a>
                                            <a href="https://download.rgd.mcw.edu/pub/data_release/Hi-res_Rat_Calendars/">Calendar</a>
                                            <a href="/wg/physiology/rats101/">Rats 101</a>
                                            <a href="/wg/photos-and-images/community-submissions/">Submissions</a>
                                            <a href="/wg/photos-and-images/physgen-photo-archive2/">Photo Archive</a>
                                        </div>
                                    </div>

                                    <a href="/wg/home/pathway2/">Pathways</a>

                                    <div class="rgd-dropdown">
                                        <button class="rgd-dropbtn" style="cursor:pointer" onclick="javascript:location.href='/wg/com-menu/'">Community
                                            <i class="fa fa-caret-down"></i>
                                        </button>

                                        <div class="rgd-dropdown-content">
                                            <a href="http://mailman.mcw.edu/mailman/listinfo/rat-forum">Rat Community Forum</a>
                                            <a href="/wg/com-menu/directory-of-rat-laboratories2/">Directory of Rat Laboratories</a>
                                            <a href="/wg/home/rgd_rat_community_videos/">Video Tutorials</a>
                                            <a href="/wg/news2/">News</a>
                                            <a href="/wg/home/rat-genome-database-publications/">RGD Publications</a>
                                            <a href="/wg/com-menu/poster_archive/">RGD Presentations Archive</a>
                                            <a href="/wg/nomenclature-guidelines/">Nomenclature Guidelines</a>
                                            <a href="/wg/resource-links/">Resource Links</a>
                                            <a href="/wg/resource-links/laboratory-resources/">Laboratory Resources</a>
                                            <a href="/wg/resource-links/employment-resources/">Employment Resources</a>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td >
                                <%@include file="../WEB-INF/jsp/search/elasticsearch/searchBox.jsp"%>
                            </td>
                            <td>
                                            <a href="https://www.facebook.com/pg/RatGenomeDatabase/posts/"><img src="/rgdweb/common/images/social/facebook-20.png"/></a>
                                            <a href="https://twitter.com/ratgenome"><img src="/rgdweb/common/images/social/twitter-20.png"/></a>
                                            <a href="https://www.linkedin.com/company/rat-genome-database"><img src="/rgdweb/common/images/social/linkedin-20.png"/></a>
                                            <a href="https://www.youtube.com/channel/UCMpex8AfXd_JSTH3DIxMGFw?view_as=subscriber"><img src="/rgdweb/common/images/social/youtube-20.png"/></a>
                                            <a href="https://github.com/rat-genome-database"><img src="/rgdweb/common/images/GitHub_Logo_White-20.png"/></a>
                                            <a href="https://github.com/rat-genome-database"><img src="/rgdweb/common/images/blueSky.png"/></a>
                                            <a href="https://github.com/rat-genome-database"><img src="/rgdweb/common/images/mastadon.png"/></a>

                                <!--
-->
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

        </td>
    </tr>
    <tr>
        <link href="https://fonts.googleapis.com/css?family=Source+Code+Pro&display=swap" rel="stylesheet">
        <td colspan=1 align="right" width="100%">

        </td>
    </tr>
</table>

    <%
    ArrayList error = (ArrayList) request.getAttribute("error");
    if (error != null) {
        Iterator errorIt = error.iterator();
        while (errorIt.hasNext()) {
            String err = (String) errorIt.next();
            out.println("<br><span style=\"color:red;font-size:20px;\">&nbsp;&nbsp;&nbsp;&nbsp;" + err + "</span>");
        out.println("<br>");
        }
    }
    ArrayList status = (ArrayList) request.getAttribute("status");
    if (status !=null) {
        Iterator statusIt = status.iterator();
        while (statusIt.hasNext()) {
            String stat = (String) statusIt.next();
            out.println("<br><span style=\"color:blue;font-size:20px;\">&nbsp;&nbsp;&nbsp;&nbsp;" + stat + "</span>");
        out.println("<br>");
        }
    }
%>


<div id="mainBody">
    <div id="contentArea" class="content-area">
        <table cellpadding="5" border=0 align="center" width="100%">
            <tr>
                <td colspan="3" align="left" valign="top">