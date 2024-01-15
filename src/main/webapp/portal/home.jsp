<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %><%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: 10/19/2016
  Time: 9:04 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%

    String filter = "";
    String title = "";
    int portal = Integer.parseInt(request.getParameter("p"));
    String species=request.getParameter("species");
    if (species == null) {
        species="3";
    }
    int speciesTypeKey = Integer.parseInt(species);

    switch (portal) {
        case 1:
            title = "Aging & Age-Related Disease";
            //filter = "RDO:9000433";
            filter = "DOID:9007801";
            break;
        case 2:
            title = "Cancer & Neoplastic Disease";
            //filter = "RDO:0005309";
            filter = "DOID:14566";
            break;
        case 3:
            title = "Cardiovascular Disease";
            //filter = "RDO:0005134";
            filter = "DOID:1287";
            break;
        case 4:
            title = "Diabetes Disease";
            //filter = "RDO:0000249";
            filter = "DOID:9351";
            break;
        case 5:
            title = "Hematologic Disease";
            //filter = "RDO:0003591";
            filter = "DOID:74";
            break;
        case 6:
            title = "Immune & Inflammatory Disease";
            //filter = "RDO:9001566";
            filter = "DOID:9003859";
            break;
        case 7:
            title = "Neurological Disease";
            //filter = "RDO:0001228";
            filter = "DOID:863";
            break;
        case 8:
            title = "Obesity & Metabolic Syndrome";
            //filter = "RDO:0006123";
            filter = "DOID:9008231";
            break;
        case 9:
            title = "Renal Disease";
            //filter = "RDO:0000692";
            filter = "DOID:557";
            break;
        case 10:
            title = "Respiratory Disease";
            //filter = "RDO:0003158";
            filter = "DOID:1579";
            break;
        case 11:
            title = "Sensory Organ Disease";
            //filter = "RDO:9001567";
            filter = "DOID:0050155";
            break;
        case 12:
            title = "Developmental Disease";
            //filter = "RDO:9001567";
            filter = "DOID:9008582";
            break;
        case 13:
            title = "Liver Disease";
            //filter = "RDO:9001567";
            filter = "DOID:409";
            break;
        case 14:
            title = "Coronavirus Disease";
            //filter = "RDO:9001567";
            filter = "DOID:0080599";
            break;
        case 15:
            title = "Infectious Disease";
            //filter = "RDO:9001567";
            filter = "DOID:0050117";
            break;
    }


    try {
%>

<%
    String pageTitle = title + " Portal - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Welcome to the " + title + " Portal - Rat Genome Database";

%>

<%@ include file="/common/headerarea.jsp"%>

<script>
    function loading(ms) {
    }

</script>

<!-- Modal -->
<div class="modal fade" id="loadingModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" style="background-color: rgba(0,0,0,0.4);" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-body" style="background-color: rgba(0,0,0,0.4);">

                <span style="color:white;font-weight:700;font-size:30px;">Loading...&nbsp;&nbsp;&nbsp;</span>
                <div class="spinner-border text-primary" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div class="spinner-border text-secondary" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div class="spinner-border text-success" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div class="spinner-border text-danger" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div class="spinner-border text-warning" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div class="spinner-border text-info" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <!--
                <div class="spinner-border text-light" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div class="spinner-border text-dark" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                -->
            </div>
        </div>
    </div>
</div>

<style>
    body {
        font-family: verdana;
    }

    .even {
        background-color:#f6f6f6;
    }

    .odd {
        ackground-color:green;
    }

    .speciesButton {
        cursor: pointer;
        border:3px solid white;
    }

    .speciesButton:hover {
        border:3px solid #8E0026;
    }

    .countTitle {
        font-weight:700;
        font-family:Helvetica;
    }

    .countTable {
        border-top: 1px solid black;
        padding-left:10px;
        padding-right:10px;
    }

    .diseasePortalButton {
        color:white;
        width:210px;
        text-align:center;
        padding-top: 8px;
        padding-bottom: 8px;
        font-size:18px;
        border-radius:8px;
        float:left;
        margin-left:5px;
        margin-bottom:5px;
        margin-top:20px;
        height:50px;
        cursor: pointer;
        font-family:Helvetica;
        border: 0px solid white;

    }
    .diseasePortalButton:hover {
        idth:180px;
        eight:100px;
        ont-size:24px;
        border: 2px solid #8E0026;
    }

    .diseasePortalListBox {
        width:250px;
        height:400px;
        border:1px solid black;
        margin-left:20px;
        overflow-y: scroll;
        font-family:Helvetica;
    }
    .diseasePortalListBoxTitle {
        margin-left:20px;
        font-weight:700;
        margin-top:10px;
        font-family:Helvetica;
    }

    .dnavCount {
        font-size:20px;
        padding-left:8px;
    }

</style>

<script>

    var gviewer = null;

    rgdModule.controller('portalController', [
        '$scope','$http','$q',


        function ($scope, $http, $q) {

            var ctrl = this;

            $scope.wsHost = ""
            $scope.olgaHost = "https://dev.rgd.mcw.edu"
            //$scope.wsHost = "http://localhost:8080"

            $scope.wsHost = window.location.protocol + window.location.host;
            if (window.location.host.indexOf('localhost') > -1) {
                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';
                $scope.olgaHost = $scope.wsHost;
//                $scope.wsHost= window.location.protocol + '//localhost:8080';
//                $scope.olgaHost = $scope.wsHost;
            } else if (window.location.host.indexOf('dev.rgd') > -1) {
                $scope.wsHost= window.location.protocol + '//pipelines.rgd.mcw.edu';
                $scope.olgaHost = $scope.wsHost;
            }else if (window.location.host.indexOf('test.rgd') > -1) {
                $scope.wsHost= window.location.protocol + '//test.rgd.mcw.edu';
                $scope.olgaHost = $scope.wsHost;
            }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
                $scope.wsHost= window.location.protocol + '//pipelines.rgd.mcw.edu';
                $scope.olgaHost = $scope.wsHost;
            }else {
                $scope.wsHost=window.location.protocol + '//rest.rgd.mcw.edu';
                $scope.olgaHost = "https://rgd.mcw.edu";
            }


            $scope.title = "<%=title%>";
            $scope.subTitle = "";

            $scope.thisCtrl = ctrl;
            $scope.currentTermAcc='<%=filter%>'
            $scope.currentTerm="";
            $scope.rootTermAcc='<%=filter%>';
            $scope.rootTerm='';
            $scope.urlString="";

            //$scope.portalGenes=[{"name":"a2m", "symbol":"A2m"}];
            $scope.portalGenes=[];
            $scope.portalGenesLen="";
            //$scope.portalQTLs=[{"name":"a2m", "symbol":"BP100"}];
            $scope.portalQTLs=[];
            $scope.portalQTLsLen="";
            //$scope.portalStrains=[{"name":"a2m", "symbol":"SS/JR"}];
            $scope.portalStrains=[];
            $scope.portalStrainsLen="";
            //$scope.portalVariants=[{"name":"a2m", "symbol":"331223"}];
            //$scope.portalVariantsLen="";

            $scope.speciesTypeKey = "<%=speciesTypeKey%>";
            $scope.mapKey = "<%=MapManager.getInstance().getReferenceAssembly(Integer.parseInt(species)).getKey()%>";
            $scope.speciesCommonName = "<%=SpeciesType.getTaxonomicName(speciesTypeKey)%> (<%=SpeciesType.getCommonName(speciesTypeKey)%>)";
            $scope.ontology ="";
            $scope.ontologyId="";
            $scope.objectCounts={};
            $scope.previousOntId=[];
            $scope.previousTerm=[];
            $scope.previousOnt=[];
            $scope.gviewer=null;
            $scope.geneCanceler;
            $scope.qtlCanceler;
            $scope.strainCancelor;


            $scope.portalLinks=[];
            $scope.portalLinks["DOID:9007801"] = {};
            $scope.portalLinks["DOID:9007801"].tools = "/wg/portals/aging-disease-portal-tools/";
            $scope.portalLinks["DOID:9007801"].links = "/wg/portals/aging-disease-portal-related-links/";
            $scope.portalLinks["DOID:9007801"].models = "/wg/portals/aging-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:14566"] = {};
            $scope.portalLinks["DOID:14566"].tools = "/wg/cancer_portal_tools/";
            $scope.portalLinks["DOID:14566"].links = "/wg/cancer_portal_related_links/";
            $scope.portalLinks["DOID:14566"].models = "/wg/cancer_portal_models/";

            $scope.portalLinks["DOID:1287"] = {};
            $scope.portalLinks["DOID:1287"].tools = "/wg/cardio_portal_tools/";
            $scope.portalLinks["DOID:1287"].links = "/wg/cardio_portal_related_links/";
            $scope.portalLinks["DOID:1287"].models = "/wg/cardiovascular-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:9351"] = {};
            $scope.portalLinks["DOID:9351"].tools = "/wg/diabetes_portal_tools/";
            $scope.portalLinks["DOID:9351"].links = "/wg/diabetes_portal_related_links/";
            $scope.portalLinks["DOID:9351"].models = "/wg/diabetes_portal_models/";

            $scope.portalLinks["DOID:74"] = {};
            $scope.portalLinks["DOID:74"].tools = "/wg/portals/hematologic-disease-portal-tools/";
            $scope.portalLinks["DOID:74"].links = "/wg/portals/hematologic-disease-portal-related-links/";
            $scope.portalLinks["DOID:74"].models = "/wg/portals/hematologic-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:9003859"] = {};
            $scope.portalLinks["DOID:9003859"].tools = "/wg/home/immune-inflammatory_portal_tools/";
            $scope.portalLinks["DOID:9003859"].links = "/wg/home/immune-inflammatory_portal_related_links/";
            $scope.portalLinks["DOID:9003859"].models = "/wg/home/immune-inflammatory_portal_models/";

            $scope.portalLinks["DOID:863"] = {};
            $scope.portalLinks["DOID:863"].tools = "/wg/nuro_portal_tools/";
            $scope.portalLinks["DOID:863"].links = "/wg/nuro_related_links/";
            $scope.portalLinks["DOID:863"].models = "/wg/nuro_rat_strain_models/";

            $scope.portalLinks["DOID:9008231"] = {};
            $scope.portalLinks["DOID:9008231"].tools = "/wg/obesity_portal_tools/";
            $scope.portalLinks["DOID:9008231"].links = "/wg/obesity_portal_related_links/";
            $scope.portalLinks["DOID:9008231"].models = "/wg/obesity-metabolic-syndrome-rat-strain-models/";

            $scope.portalLinks["DOID:557"] = {};
            $scope.portalLinks["DOID:557"].tools = "/wg/portals/renal-disease-portal-tools/";
            $scope.portalLinks["DOID:557"].links = "/wg/portals/renal-disease-portal-related-links/";
            $scope.portalLinks["DOID:557"].models = "/wg/portals/renal-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:1579"] = {};
            $scope.portalLinks["DOID:1579"].tools = "/wg/respiratory_portal_tools/";
            $scope.portalLinks["DOID:1579"].links = "/wg/respiratory_portal_related_links/";
            $scope.portalLinks["DOID:1579"].models = "/wg/respiratory_portal_models/";

            $scope.portalLinks["DOID:0050155"] = {};
            $scope.portalLinks["DOID:0050155"].tools = "/wg/portals/sensory-organ-disease-portal-tools/";
            $scope.portalLinks["DOID:0050155"].links = "/wg/portals/sensory-organ-disease-portal-related-links/";
            $scope.portalLinks["DOID:0050155"].models = "/wg/portals/sensory-organ-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:9008582"] = {};
            $scope.portalLinks["DOID:9008582"].tools = "/wg/portals/developmental-disease-portal-tools/";
            $scope.portalLinks["DOID:9008582"].links = "/wg/portals/developmental-disease-portal-related-links/";
            $scope.portalLinks["DOID:9008582"].models = "/wg/portals/developmental-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:409"] = {};
            $scope.portalLinks["DOID:409"].tools = "/wg/portals/liver-disease-portal-tools/";
            $scope.portalLinks["DOID:409"].links = "/wg/portals/liver-disease-portal-related-links/";
            $scope.portalLinks["DOID:409"].models = "/wg/portals/liver-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:0080599"] = {};
            $scope.portalLinks["DOID:0080599"].tools = "/wg/portals/covid-19-disease-portal-tools/";
            $scope.portalLinks["DOID:0080599"].links = "/wg/portals/covid-19-disease-portal-related-links/";
            $scope.portalLinks["DOID:0080599"].models = "/wg/portals/covid-19-disease-portal-rat-strain-models/";

            $scope.portalLinks["DOID:0050117"] = {};
            $scope.portalLinks["DOID:0050117"].tools = "/wg/portals/infectious-disease-portal-tools/";
            $scope.portalLinks["DOID:0050117"].links = "/wg/portals/infectious-disease-portal-related-links/";
            $scope.portalLinks["DOID:0050117"].models = "/wg/portals/infectious-disease-portal-rat-strain-models/";

            ctrl.updateCounts = function (ontId, filter) {
                $scope.ontologyId = ontId;
                $http({
                    method: 'GET',
                    url: $scope.wsHost + "/rgdws/stats/term/" + ontId + "/" + filter,
                }).then(function successCallback(response) {
                    $scope.objectCounts = response.data;

                }, function errorCallback(response) {
                    alert("update counts response = " + response.data);
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });


            }

            ctrl.browserBack = function() {
                this.browse($scope.previousOntId.pop(), $scope.previousOnt.pop(),$scope.ontology,$scope.previousTerm.pop(),1);
            }

            ctrl.updateAll = function (ont, ontId) {
                //alert("in update all");
                ctrl.resetGViewer();

                ctrl.updateCounts(ontId,$scope.rootTermAcc);
                ctrl.update(1,ontId);
                ctrl.update(6,ontId);
                ctrl.update(5,ontId);
            }

            ctrl.browse = function (ontId, ont, term, back) {

                //alert("in browse");
                var ontologyCodes = ontologyCodes = ["d","ph","bp","pw","hp","c","vt","cm","ec"];

                document.getElementById("speciesButton" + $scope.speciesTypeKey).style.borderColor = "#8E0026";


                for (var i=0; i< ontologyCodes.length; i++) {
                    document.getElementById(ontologyCodes[i]).style.height = "65px";
                    document.getElementById(ontologyCodes[i]).style.borderBottomLeftRadius = "8px";
                    document.getElementById(ontologyCodes[i]).style.borderBottomRightRadius = "8px";
                    document.getElementById(ontologyCodes[i]).style.border = "0px solid #FFFF00";
                }
                if (!back) {
                    $scope.previousOntId.push($scope.ontologyId);
                    $scope.previousOnt.push($scope.ontology);
                    $scope.previousTerm.push($scope.currentTerm);
                }

                if (ont != null) {
                    $scope.ontology = ont;
                }

                $scope.onttologyId = ontId;


                document.getElementById($scope.ontology).style.height = "80px";
                document.getElementById($scope.ontology).style.borderBottomLeftRadius = "40px";
                document.getElementById($scope.ontology).style.borderBottomRightRadius = "40px";

                document.getElementById($scope.ontology).style.border = "4px solid #F7BB43";

                $.ajax({url: "/rgdweb/ontology/view.html?pv=1&mode=popup&filter=<%=filter%>&acc_id=" + ontId, success: function(result){
                    $("#browser").html(result);
                    //alert(result);
                }});

                $scope.currentTerm=term;
                $scope.currentTermAcc=ontId;

                ctrl.updateAll(ont, ontId)


            }


            ctrl.updateSpecies = function (speciesType, map, commonName) {
                //alert("in update species");

                /*
                alert($scope.portalGenes);

                if ($scope.portalGenes.loading) {
                    alert($scope.portalGenes.loading);
                }

                 */

                $("#loadingModal").modal("show");
                setTimeout(function () { $("#loadingModal").modal("hide");}, 1000);

                for (var i=1; i< 8; i++) {
                    document.getElementById("speciesButton" + i).style.border = "3px solid white";
                }
                document.getElementById("speciesButton9").style.border = "3px solid white";
                document.getElementById("speciesButton13").style.border = "3px solid white";
                document.getElementById("speciesButton14").style.border = "3px solid white";

                document.getElementById("speciesButton" + speciesType).style.border = "3px solid #8E0026";

                $scope.speciesTypeKey = speciesType;
                $scope.mapKey=map;
                $scope.speciesCommonName = commonName;

                //ctrl.updateAll($scope.ont,$scope.currentTermAcc);


                if ($scope.objectCounts["annotated_object_count|" + speciesType + "|1|1"] > 0) {
                    ctrl.update(1, $scope.currentTermAcc);
                } else {
                    ctrl.clear(1);
                }
                if ($scope.objectCounts["annotated_object_count|" + speciesType + "|6|1"] > 0) {
                    ctrl.update(6, $scope.currentTermAcc);
                }else {
                    ctrl.clear(6);
                }
                if ($scope.objectCounts["annotated_object_count|" + speciesType + "|5|1"] > 0) {
                    ctrl.update(5, $scope.currentTermAcc);
                }else {
                    ctrl.clear(5);

                }

                ctrl.resetGViewer();

            }

            ctrl.clear = function (objectKey) {
                //alert("in clear");


                if (objectKey==1) {
                    if ($scope.geneCanceler) {
                        $scope.geneCanceler.resolve("canceled");
                    }
                    $scope.geneCanceler = $q.defer();
                    timeout=$scope.geneCanceler.promise;

                    //document.getElementById("gviewer").innerHTML="";


                }else if (objectKey==5) {
                    if ($scope.qtlCanceler) {
                        $scope.qtlCanceler.resolve("canceled");
                    }
                    $scope.qtlCanceler = $q.defer();
                    timeout=$scope.qtlCanceler.promise;
                    //document.getElementById("gviewer").innerHTML="";

                }else if (objectKey==6) {
                    if ($scope.strainCanceler) {
                        $scope.strainCanceler.resolve("canceled");
                    }
                    $scope.strainCanceler = $q.defer();
                    timeout=$scope.strainCanceler.promise;
                    //document.getElementById("gviewer").innerHTML="";

                }



                if (objectKey ==1) {

                    if ($scope.geneCanceler) {
                        $scope.geneCanceler.resolve("canceled");
                    }
                    $scope.geneCanceler = $q.defer();
                    timeout=$scope.geneCanceler.promise;


                    $scope.portalGenes = {};
                    $scope.portalGenesLen = 0;
                }else if (objectKey==6) {
                    if ($scope.strainCanceler) {
                        $scope.strainCanceler.resolve("canceled");
                    }
                    $scope.strainCanceler = $q.defer();
                    timeout=$scope.strainCanceler.promise;
                    $scope.portalQTLs={};
                    $scope.portalQTLsLen=0;
                }else if (objectKey==5) {
                    if ($scope.qtlCanceler) {
                        $scope.qtlCanceler.resolve("canceled");
                    }
                    $scope.qtlCanceler = $q.defer();
                    timeout=$scope.qtlCanceler.promise;

                    $scope.portalStrains={};
                    $scope.portalStrainsLen=0;
                }

            }


            ctrl.downloadGenes = function() {

                //alert("in download genes");
                var ids="";
                var first = 1;
                for(var key in $scope.portalGenes) {

                    if (first) {
                        ids += $scope.portalGenes[key].rgdId;
                        first=0;
                    }else {
                        ids += "," + $scope.portalGenes[key].rgdId;

                    }

                }

                var form = document.getElementById("download");
                download.action="downloadGenes.jsp";
                download.method="POST"
                download.ids.value=ids;
                download.species.value=$scope.speciesTypeKey;
                download.submit();

            }

            ctrl.downloadQTL = function() {
                var ids="";
                var first = 1;
                for(var key in $scope.portalQTLs) {

                    if (first) {
                        ids += $scope.portalQTLs[key].rgdId;
                        first=0;
                    }else {
                        ids += "," + $scope.portalQTLs[key].rgdId;

                    }

                }

                var form = document.getElementById("download");
                download.action="downloadQTL.jsp";
                download.method="POST"
                download.ids.value=ids;
                download.species.value=$scope.speciesTypeKey;
                download.submit();


            }
            ctrl.downloadStrains = function() {
                var ids="";
                var first = 1;
                for(var key in $scope.portalStrains) {

                    if (first) {
                        ids += $scope.portalStrains[key].rgdId;
                        first=0;
                    }else {
                        ids += "," + $scope.portalStrains[key].rgdId;

                    }

                }

                var form = document.getElementById("download");
                download.action="downloadStrains.jsp";
                download.method="POST"
                download.ids.value=ids;
                download.species.value=$scope.speciesTypeKey;
                download.submit();

            }

            ctrl.resetGViewer = function() {

                if (gviewer) {
                    gviewer.reset();
                }

                document.getElementById("gviewer").innerHTML="";
                document.getElementById("zoomWrapper").innerHTML="";

            }


            ctrl.buildGViewer = function() {

                ctrl.resetGViewer();

                var species = $scope.speciesTypeKey;
                var jbrowseUrl;
                switch (species) {
                    case "1":
                        jbrowseUrl = "/jbrowse/?data=data_hg38&tracks=ARGD_curated_genes";
                        break;
                    case "2":
                        jbrowseUrl = "/jbrowse/?data=data_mm38&tracks=ARGD_curated_genes";
                        break;
                    case "3":
                        jbrowseUrl = "/jbrowse/?data=data_rn7_2&tracks=ARGD_curated_genes";
                        break;
                    case "5":
                        jbrowseUrl = "/jbrowse/?data=data_bonobo1_1&tracks=ARGD_curated_genes";
                        break;
                    case "6":
                        jbrowseUrl = "/jbrowse/?data=data_dog3_1&tracks=ARGD_curated_genes";
                        break;
                    case "9":
                        jbrowseUrl = "/jbrowse/?data=data_pig11_1&tracks=ARGD_curated_genes";
                        break;
                    default:
                        jbrowseUrl = "/jbrowse/?data=data_rn7_2&tracks=ARGD_curated_genes";
                }

                gviewer = new Gviewer("gviewer", 250, 800);

                    gviewer.imagePath = "/rgdweb/gviewer/images";
                    gviewer.exportURL = "/rgdweb/report/format.html";
                    gviewer.annotationTypes = new Array("gene","qtl","strain");
                    gviewer.genomeBrowserURL = jbrowseUrl;
                    gviewer.genomeBrowserName = "JBrowse";
                    gviewer.regionPadding=2;
                    gviewer.annotationPadding = 1;


                    gviewer.loadBands("/rgdweb/gviewer/data/portal_" + $scope.speciesTypeKey + "_ideo.xml");
                    gviewer.addZoomPane("zoomWrapper", 250, 800);


                var ids="";

                var cnt = 0;
                //alert("portal genes len = " + JSON.stringify($scope.portalGenes));
                for(var key in $scope.portalGenes) {

                    if (cnt==0) {
                        ids += $scope.portalGenes[key].rgdId;
                    }else {
                        ids += "," + $scope.portalGenes[key].rgdId;

                    }
                    cnt++;

                }

                if (ids != "") {
                    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?ids=" + ids);
                }
                ids="";
                var first = 1;
                for(var key in $scope.portalQTLs) {

                    if (first) {
                        ids += $scope.portalQTLs[key].rgdId;
                        first=0;
                    }else {
                        ids += "," + $scope.portalQTLs[key].rgdId;

                    }

                }

                if (ids != "") {
                    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?ids=" + ids);
                }

                ids="";
                var first = 1;
                for(var key in $scope.portalStrains) {

                    if (first) {
                        ids += $scope.portalStrains[key].rgdId;
                        first=0;
                    }else {
                        ids += "," + $scope.portalStrains[key].rgdId;

                    }
                }

                if (ids != "") {
                    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?ids=" + ids); // "/rgdweb/gviewer/getAnnotationXmlByID.html?ids=" + ids);
                }

            }


            ctrl.enrich = function(ont) {

                if (Object.keys($scope.portalGenes).length == 0) {
                    alert("Zero genes in gene set above.  Enrichment available when gene set is populated.");
                    return;
                }else if ( $scope.portalGenes && $scope.portalGenes["loading"]) {
                    alert("Gene set still is loading.  Please try again when gene set is loaded above.");
                    return;
                }


                enrichment.init(ont,$scope.speciesTypeKey,true,true,Object.keys($scope.portalGenes),false,100,475,200,100,1100,900);
            }


            ctrl.update = function (objectKey, termAcc, term) {

                if ($scope.currentTerm) {
                    $scope.subTitle = $scope.title + " AND " + $scope.currentTerm;
                }else {
                    $scope.subTitle = $scope.title;
                }

                if (objectKey == 1) {
                    $scope.portalGenesLen = "Calculating";
                }

                if (objectKey == 6) {
                    $scope.portalQTLsLen="Calculating"
                }

                if (objectKey == 5) {
                    $scope.portalStrainsLen = "Calculating"
                }

                $scope.currentTermAcc=termAcc;

                if (objectKey ==1) {
                    $scope.portalGenes = {"loading": {"symbol": "Searching Genes..."}};
                    //$scope.portalGenes = [];
                }else if (objectKey==6) {
                    $scope.portalQTLs = {"loading": {"symbol": "Searching QTL..."}};

                }else if (objectKey==5) {
                    $scope.portalStrains = {"loading": {"symbol": "Searching Strains..."}};

                }

                var cmd = "~" + $scope.rootTermAcc + "|!" + termAcc;

                $scope.urlString = $scope.olgaHost + "/rgdweb/generator/list.html?a=" + encodeURI(cmd) + "&mapKey=" + $scope.mapKey + "&oKey=" + objectKey + "&vv=&ga=&act=json";

                var timeout = "";
                if (objectKey==1) {
                    if ($scope.geneCanceler) {
                        $scope.geneCanceler.resolve("canceled");
                    }
                    $scope.geneCanceler = $q.defer();
                    timeout=$scope.geneCanceler.promise;

                    //document.getElementById("gviewer").innerHTML="";


                }else if (objectKey==5) {
                    if ($scope.qtlCanceler) {
                        $scope.qtlCanceler.resolve("canceled");
                    }
                    $scope.qtlCanceler = $q.defer();
                    timeout=$scope.qtlCanceler.promise;
                    //document.getElementById("gviewer").innerHTML="";

                }else if (objectKey==6) {
                    if ($scope.strainCanceler) {
                        $scope.strainCanceler.resolve("canceled");
                    }
                    $scope.strainCanceler = $q.defer();
                    timeout=$scope.strainCanceler.promise;
                    //document.getElementById("gviewer").innerHTML="";

                }

                $http({
                    method: 'GET',
                    url: $scope.olgaHost + "/rgdweb/generator/list.html?a=" + encodeURI(cmd) + "&mapKey=" + $scope.mapKey + "&oKey=" + objectKey + "&vv=&ga=&act=json",
                    timeout: timeout,
                }).then(function successCallback(response) {
                    if (objectKey ==1) {
                        $scope.portalGenes = response.data;
                        $scope.portalGenesLen = Object.keys($scope.portalGenes).length;


                        var geneStr = "";

                        for(var key in response.data) {
                            geneStr += "<span class='geneList'>" + key + "</span>";
                        }
                        //alert(geneStr);
                        document.getElementById("toolGenes").innerHTML = geneStr;

                        if ($scope.speciesTypeKey==4 || $scope.speciesTypeKey==7 || $scope.speciesTypeKey==8 || $scope.speciesTypeKey==13 || $scope.speciesTypeKey==14) {
                            document.getElementById('gviewer').innerText = 'GViewer not supported for the selected species.';
                        }
                        else { ctrl.buildGViewer(); }
                    }else if (objectKey==6) {
                        $scope.portalQTLs=response.data;
                        $scope.portalQTLsLen=Object.keys($scope.portalQTLs).length;

                    }else if (objectKey==5) {
                        $scope.portalStrains=response.data;
                        $scope.portalStrainsLen=Object.keys($scope.portalStrains).length;
                    }


                    $("#loadingModal").modal("hide");


                }, function errorCallback(response) {
                    //alert("response = " + response.data);
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });
            }

        }

    ]);
</script>


<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">

<div id="portalController" ng-controller="portalController as portal">

    <div class="rgd-panel rgd-panel-default">

        <div class="rgd-panel-heading">
        <table width="100%" align="center" >
        <tr>
            <td width="75"><img src="/rgdweb/common/images/portals/<%=request.getParameter("p")%>-65.png" border="0" style="padding-bottom:10px;"/></td>
            <td><div style='font-size:32px; clear:left; color:#24609C;"'>{{title}}&nbsp;Portal</div></td>
            <td align="right"><div style="font-size:26px; clear:left; ">{{speciesCommonName}}</div></td>
        </tr>
        </table>
            </div>
    </div>


    <table width="100%" align="center" style="background-color:#D6E5FF; margin:10px;">
        <tr>
            <td><div style='font-size:14px; clear:left; padding:5px; color:#24609C;"'>Select a category</div></td>
        </tr>
    </table>

    <table align="center">
        <tr>

        <td>

        <table border="0" align="center">
            <tr>
                <td align="center">
                    <div id="d" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.browse(rootTermAcc,'d')">Diseases<br><span style="font-size:11px;">{{title}}</span></div>
                    <div id="ph" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.browse('MP:0000001','ph')">Mammalian Phenotype<br><span style="font-size:11px;">{{title}}</span></div>
                    <div id="hp" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.browse('HP:0000001','hp')">Human Phenotype<br><span style="font-size:11px;">{{title}}</span></div>
                </td>
            </tr>
            <tr>
                <td align="center">
                    <div id="bp" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.browse('GO:0008150','bp')">Biological Processes<br><span style="font-size:11px;">{{title}}</span></div>
                    <div id="pw" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.browse('PW:0000001','pw')">Pathways<br><span style="font-size:11px;">{{title}}</span></div>
                    <div id="c" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.browse('CHEBI:59999','c')">Chemicals and Drugs<br><span style="font-size:11px;">{{title}}</span></div>
                </td>
            </tr>
            <tr>
                <td align="center">
                    <div id="vt" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('VT:0000001','vt')">Vertebrate Traits<br><span style="font-size:11px;">{{title}}</span></div>
                    <div id="cm" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('CMO:0000000','cm')">Clinical Measurements<br><span style="font-size:11px;">{{title}}</span></div>
                    <div id="ec" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('XCO:0000000','ec')">Experimental Conditions<br><span style="font-size:11px;">{{title}}</span></div>
                </td>
            </tr>
        </table>

        </td>
    </tr></table>

    <table width="100%" align="center" style="background-color:#D6E5FF; margin:10px;">
        <tr>
            <td><div style='font-size:14px; clear:left; padding:5px; color:#24609C;"'>Select a species</div></td>
        </tr>
    </table>


<table align="center" border="0" cellpadding="2" cellspacing="0">
    <tr>
        <td>
            <div border="0" id="speciesButton3" class="speciesButton" ng-click="portal.updateSpecies(3,'<%=MapManager.getInstance().getReferenceAssembly(3).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(3)%> (<%=SpeciesType.getCommonName(3)%>)')">
            <table>
                <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/ratS.png"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(3)%></td>
                </tr>
                <tr>
                    <td align="center">
                    <table class="countTable" border="0">
                        <tr>
                            <td class="countTitle">Genes:</td>
                            <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|3|1|1"] }}</td>
                        </tr>
                        <tr>
                            <td class="countTitle">QTL:</td>
                            <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|3|6|1"] }}</td>
                        </tr>
                        <tr>
                            <td class="countTitle">Strains:</td>
                            <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|3|5|1"] }}</td>
                        </tr>
                    </table>
                    </td>
                </tr>
            </table>
            </div>
        </td>

        <td >
            <div border="0"  id="speciesButton2" class="speciesButton" ng-click="portal.updateSpecies(2,'<%=MapManager.getInstance().getReferenceAssembly(2).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(2)%> (<%=SpeciesType.getCommonName(2)%>)')" >
            <table>
                <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/mouseS.jpg"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(2)%></td>
                </tr>
                <tr>
                    <td align="center">
                        <table  class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|2|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|2|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
            </div>
        </td>
        <td>
            <div border="0" id="speciesButton1" class="speciesButton" ng-click="portal.updateSpecies(1,'<%=MapManager.getInstance().getReferenceAssembly(1).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(1)%> (<%=SpeciesType.getCommonName(1)%>)')">
              <table>
                <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/humanS.jpg"></td>
                    <!--<td height="150" valign="bottom"><img src="/rgdweb/common/images/species/baby.jpg"></td>-->
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(1)%></td>
                </tr>
                <tr>
                    <td align="center" >
                        <table  class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|1|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|1|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
                  </table>
            </div>
        </td>
        <td>
            <div border="0" id="speciesButton4" class="speciesButton" ng-click="portal.updateSpecies(4,'<%=MapManager.getInstance().getReferenceAssembly(4).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(4)%> (<%=SpeciesType.getCommonName(4)%>)')">
             <table>
                 <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/chinchillaS.jpg"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(4)%></td>
                </tr>
                <tr>
                    <td align="center">
                        <table class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|4|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|4|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
                 </table>
            </div>
        </td>
        <td>
            <div border="0" id="speciesButton5" class="speciesButton"  ng-click="portal.updateSpecies(5,'<%=MapManager.getInstance().getReferenceAssembly(5).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(5)%> (<%=SpeciesType.getCommonName(5)%>)')">
               <table>
                <tr>
                    <td  height="150" valign="bottom"><img src="/rgdweb/common/images/species/bonoboS.jpg?"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(5)%></td>
                </tr>
                <tr>
                    <td align="center">
                        <table class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|5|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|5|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
                   </table>
            </div>
        </td>
    </tr><tr>
        <td>

            <div border="0" id="speciesButton6" class="speciesButton" ng-click="portal.updateSpecies(6,'<%=MapManager.getInstance().getReferenceAssembly(6).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(6)%> (<%=SpeciesType.getCommonName(6)%>)')">
            <table>
            <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/dogS.jpg"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(6)%></td>
                </tr>
                <tr>
                    <td align="center">
                        <table class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|6|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|6|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
                </table>
            </div>
        </td>
        <td>

            <div border="0" id="speciesButton7" class="speciesButton" ng-click="portal.updateSpecies(7,'<%=MapManager.getInstance().getReferenceAssembly(7).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(7)%> (<%=SpeciesType.getCommonName(7)%>)')">
            <table>
            <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/squirrelS.jpg?3"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(7)%></td>
                </tr>
                <tr>
                    <td align="center">
                        <table class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|7|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|7|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
                </table>
            </div>

        </td>
        <td>

            <div border="0" id="speciesButton9" class="speciesButton" ng-click="portal.updateSpecies(9,'<%=MapManager.getInstance().getReferenceAssembly(9).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(9)%> (<%=SpeciesType.getCommonName(9)%>)')">
                <table>
                    <tr>
                        <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/pig.png"></td>
                    </tr>
                    <tr>
                        <td align="center"><%=SpeciesType.getCommonName(9)%></td>
                    </tr>
                    <tr>
                        <td align="center">
                            <table class="countTable" >
                                <tr>
                                    <td class="countTitle">Genes:</td>
                                    <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|9|1|1"] }}</td>
                                </tr>
                                <tr>
                                    <td class="countTitle">QTL:</td>
                                    <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|9|6|1"] }}</td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                            </table>
                        <td></td>
                    </tr>
                </table>
            </div>

        </td>
        <td>

            <div border="0" id="speciesButton13" class="speciesButton" ng-click="portal.updateSpecies(13,'<%=MapManager.getInstance().getReferenceAssembly(13).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(13)%> (<%=SpeciesType.getCommonName(13)%>)')">
                <table>
                    <tr>
                        <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/green-monkeyS.png"></td>
                    </tr>
                    <tr>
                        <td align="center"><%=SpeciesType.getCommonName(13)%></td>
                    </tr>
                    <tr>
                        <td align="center">
                            <table class="countTable" >
                                <tr>
                                    <td class="countTitle">Genes:</td>
                                    <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|13|1|1"] }}</td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr><td>&nbsp;</td></tr>
                            </table>
                        <td></td>
                    </tr>
                </table>
            </div>

        </td>
        <td>

            <div border="0" id="speciesButton14" class="speciesButton" ng-click="portal.updateSpecies(14,'<%=MapManager.getInstance().getReferenceAssembly(14).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(14)%> (<%=SpeciesType.getCommonName(14)%>)')">
                <table>
                    <tr>
                        <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/mole-ratS.png"></td>
                    </tr>
                    <tr>
                        <td align="center"><%=SpeciesType.getCommonName(14)%></td>
                    </tr>
                    <tr>
                        <td align="center">
                            <table class="countTable" >
                                <tr>
                                    <td class="countTitle">Genes:</td>
                                    <td align="right" class="dnavCount">{{ objectCounts["annotated_object_count|14|1|1"] }}</td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr><td>&nbsp;</td></tr>
                            </table>
                        <td></td>
                    </tr>
                </table>
            </div>

        </td>

    </tr>
</table>



<script>

    function browse(id, term) {

        angular.element(document.getElementById('portalController')).scope().thisCtrl.browse(id,null,term);
    }

    function browserBack() {
        angular.element(document.getElementById('portalController')).scope().thisCtrl.browserBack();
    }


</script>

    <table width="100%" align="center" style="background-color:#D6E5FF; margin:10px;">
        <tr>
            <td><div style='font-size:14px; clear:left; padding:5px; color:#24609C;"'>Select a term</div></td>
        </tr>
    </table>

    <div id="browser" ng-init="portal.browse('<%=filter%>','d')">

</div>

    <br>

<table width="100%" cellpadding="4" style="padding:5px; font-size:18px;background-color:#f6f6f6; border:1px solid black; color:#2865A3;">
    <tr>
        <td style="font-size:20px;">{{ subTitle }}</td>
        <td style="font-size:16px;" align="right">{{speciesCommonName}}</td>
    </tr>
</table>

<table align="center" border="0">
    <tr>
        <td>
            <div class="diseasePortalListBoxTitle"><table border="0" width="100%"><tr><td valign="bottom"><b>Genes:</b><span  class="dnavCount">{{ portalGenesLen }}</span></td><td align="right"><img  style="cursor:pointer;" height=33 width=35 ng-click="portal.downloadGenes()" src="https://rgd.mcw.edu/rgdweb/common/images/excel.png"/>
                <!--<img ng-click="rgd.showTools('geneList',3,360,1,'')" src="/rgdweb/common/images/tools-white-40.png"/>--></td></tr></table></div>
            <div class="diseasePortalListBox">
                <div ng-repeat="portalGene in portalGenes" style="padding:3px;" ng-class-even="'even'" ng-class-odd="'odd'">

                    <a target="_blank" href="/rgdweb/report/gene/main.html?id={{ portalGene.rgdId }}">
                        <span ng-bind-html="portalGene.symbol"></span>
                    </a>
                    <br />
                </div>
            </div>
        </td>
        <td>
            <div class="diseasePortalListBoxTitle"><table border="0" width="100%"><tr><td valign="bottom"><b>QTL:</b><span  class="dnavCount">{{ portalQTLsLen }}</span></td><td align="right"><img style="cursor:pointer;" height=33 width=35 ng-click="portal.downloadQTL()" src="https://rgd.mcw.edu/rgdweb/common/images/excel.png"/></td></tr></table></div>
            <div class="diseasePortalListBox">
                <div ng-repeat="portalQTL in portalQTLs" style="padding:3px;" ng-class-even="'even'" ng-class-odd="'odd'">
                    <a class="qtlList"  target="_blank" href="/rgdweb/report/qtl/main.html?id={{portalQTL.rgdId}}"><span ng-bind-html="portalQTL.symbol"></span></a><br />
                </div>

            </div>
        </td>
        <td>
            <div class="diseasePortalListBoxTitle"><table border="0" width="100%"><tr><td valign="bottom"><b>Strains:</b><span  class="dnavCount">{{ portalStrainsLen }}</span></td><td align="right"><img  style="cursor:pointer;" height=33 width=35 ng-click="portal.downloadStrains()" src="https://rgd.mcw.edu/rgdweb/common/images/excel.png"/></td></tr></table></div>
            <div class="diseasePortalListBox" style="width:500px;">
                <div ng-repeat="portalStrain in portalStrains" style="margin-top:3px; padding:3px;" ng-class-even="'even'" ng-class-odd="'odd'">
                    <a class="strainList"  target="_blank" href="/rgdweb/report/strain/main.html?id={{portalStrain.rgdId}}"><span ng-bind-html="portalStrain.symbol"></span></a><br />
                </div>

            </div>
        </td>

    </tr>
</table>
<br>

    <table width="100%"  style="background-color:#D6E5FF; margin:10px;">
        <tr>
            <td><div style='font-size:20px; clear:left; padding:10px; color:#24609C;"'>Genome View</div> </td>
        </tr>
    </table>

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


    <table align="center">
        <tr>
            <td>
                <div id="gviewer" class="gviewer" style="text-align: center"></div>
                <div id="zoomWrapper" class="zoom-pane"></div>
            </td>
        </tr>
    </table>



    <table width="100%" align="center" style="background-color:#D6E5FF; margin:10px;">
        <tr>
            <td><div style='font-size:20px; clear:left; padding:10px; color:#24609C;"'>Gene Set Enrichment</div></td>
        </tr>
    </table>

    <table border="0" align="center">
        <tr>
            <td align="center">
                <div id="d" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.enrich('RDO')">DO: Diseases Ontology<br><span style="font-size:11px;">Enrichment</span></div>
                <div id="ph" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.enrich('PW')">PW: Pathway Ontology<br><span style="font-size:11px;">Enrichment</span></div>
                <div id="bp" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.enrich('MP')">MP: Phenotype Ontology<br><span style="font-size:11px;">Enrichment</span></div>
                <div id="pw" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.enrich('BP')">GO: Biological Process<br><span style="font-size:11px;">Enrichment</span></div>
            </td>
        </tr>
        <tr>
            <td align="center">
                <div id="vt" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.enrich('CC')">GO: Cellular Component<br><span style="font-size:11px;">Enrichment</span></div>
                <div id="cm" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.enrich('MF')">GO: Molecular Function<br><span style="font-size:11px;">Enrichment</span></div>
                <div id="c" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.enrich('CHEBI')">CHEBI: Chemical/Drug<br><span style="font-size:11px;">Enrichment</span></div>
                <!--<div id="ec" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('XCO:0000000','ec')">Chemical Interactions<br><span style="font-size:11px;">{{title}}</span></div>-->
            </td>
        </tr>
    </table>

    <!--script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script-->
    <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

    <link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">

    <table align="center" >
        <tr>
            <td>
                <div id="enrichment" style="padding-top:20px;">
                    <%@ include file="../../WEB-INF/jsp/enrichment/annotatedGenes.jsp" %>
                    <%@ include file="../../WEB-INF/jsp/enrichment/terms.jsp" %>
                </div>
                <script src="/rgdweb/js/enrichment/analysis.js?fff"></script>


            </td>
        </tr>
    </table>

    <script>
        //var enrichment = EnrichmentVue("enrichment","http://localhost:8080");
        var enrichment = EnrichmentVue();
    </script>

    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

    <br>
    <table width="100%"  style="background-color:#D6E5FF; margin:10px;">
        <tr>
            <td><div style='font-size:20px; clear:left; padding:10px; color:#24609C;"'>Additional Resources</div></td>
        </tr>
    </table>
    <br>
    <table  align="center">
        <tr>
            <!--<td align="center"><a href="http://navigator.rgd.mcw.edu/navigator/ui/home.jsp?accId={{ontologyId}}" target="_blank">
                <img height=150 width=200 src="/rgdweb/common/images/dnavExample.png" style="margin:10px;" /><div style="font-size:16px;">Disease Navigator</div>
            </a>
            </td>
            -->
            <td  align="center"><a href="{{portalLinks[rootTermAcc].tools}}" target="_blank">
                <img  src="https://rgd.mcw.edu/rgdweb/common/images/phenotypes.png"  style="margin:10px;"/><div style="font-size:16px;">Analysis Tools</div>
            </a>
            </td>
            <td  align="center"><a href="{{portalLinks[rootTermAcc].models}}" target="_blank">
                <img  src="https://rgd.mcw.edu/rgdweb/common/images/geneticModels.png"  style="margin:10px;"/><div style="font-size:16px;">Rat Strain Models</div>
            </a>
            </td>
            <td  align="center"><a href="{{portalLinks[rootTermAcc].links}}" target="_blank">
                <img  src="https://rgd.mcw.edu/rgdweb/common/images/strainMedicalRecords.png"  style="margin:10px;"/><div style="font-size:16px;">Related Links</div>
            </a>
            </td>
        </tr>
    </table>

<div style="width:1px; height:1px; overflow:hidden;visibility:hidden;">
<form id="download" name="download" >
    <input name="species" value=""/>
    <input name="ids" value=""/>
</form>


<div id="toolGenes" >

</div>
</div>


<% } catch (Exception e) {
    e.printStackTrace();
%>

<% } %>

<%@ include file="/common/footerarea.jsp"%>
