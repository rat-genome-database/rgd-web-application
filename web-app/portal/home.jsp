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
            filter = "RDO:9000433";
            break;
        case 2:
            title = "Cancer";
            filter = "RDO:0005309";
            break;
        case 3:
            title = "Cardiovascular Disease";
            filter = "RDO:0005134";
            break;
        case 4:
            title = "Diabetes Disease";
            filter = "RDO:0000249";
            break;
        case 5:
            title = "Hematologic Disease";
            filter = "RDO:0003591";
            break;
        case 6:
            title = "Immune & Inflammatory Disease";
            filter = "RDO:9001566";
            break;
        case 7:
            title = "Neurological Disease";
            filter = "RDO:0001228";
            break;
        case 8:
            title = "Obesity/Metabolic Syndrome";
            filter = "RDO:0006123";
            break;
        case 9:
            title = "Renal Disease";
            filter = "RDO:0000692";
            break;
        case 10:
            title = "Respiratory Disease";
            filter = "RDO:0003158";
            break;
        case 11:
            title = "Sensory Organ Disease";
            filter = "RDO:9001567";
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
        border:1px solid white;
    }

    .speciesButton:hover {
        border:1px solid #8E0026;
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
        width:130px;
        text-align:center;
        padding-top: 8px;
        padding-bottom: 8px;
        font-size:18px;
        border-radius:8px;
        float:left;
        margin-left:5px;
        margin-bottom:5px;
        margin-top:20px;
        height:65px;
        cursor: pointer;
        font-family:Helvetica;
        border: 0px solid white;

    }
    .diseasePortalButton:hover {
        idth:180px;
        eight:100px;
        ont-size:24px;
        border: 0px solid #8E0026;
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


</style>

<script>
    rgdModule.controller('portalController', [
        '$scope','$http',


        function ($scope, $http) {

            var ctrl = this;

            $scope.title = "<%=title%>";
            $scope.subTitle = "";

            $scope.thisCtrl = ctrl;
            $scope.currentTermAcc='<%=filter%>'
            $scope.currentTerm="";
            $scope.rootTermAcc='<%=filter%>';
            $scope.rootTerm='';
            $scope.urlString="";

            $scope.portalGenes=[{"name":"a2m", "symbol":"A2m"}];
            $scope.portalGenesLen="";
            $scope.portalQTLs=[{"name":"a2m", "symbol":"BP100"}];
            $scope.portalQTLsLen="";
            $scope.portalStrains=[{"name":"a2m", "symbol":"SS/JR"}];
            $scope.portalStrainsLen="";
            $scope.portalVariants=[{"name":"a2m", "symbol":"331223"}];
            $scope.portalVariantsLen="";

            $scope.speciesTypeKey = "<%=speciesTypeKey%>";
            $scope.mapKey = "<%=MapManager.getInstance().getReferenceAssembly(Integer.parseInt(species)).getKey()%>";
            $scope.speciesCommonName = "<%=SpeciesType.getTaxonomicName(speciesTypeKey)%> (<%=SpeciesType.getCommonName(speciesTypeKey)%>)";
            $scope.ontology ="";
            $scope.ontologyId="";
            $scope.objectCounts={};


            ctrl.updateCounts = function (ontId, filter) {
                $http({
                    method: 'GET',
                    url: "http://dev.rgd.mcw.edu:8080/rgdws/stats/term/" + ontId + "/" + filter,
                }).then(function successCallback(response) {
                    $scope.objectCounts = response.data;

                }, function errorCallback(response) {
                    alert("response = " + response.data);
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });


            }

            ctrl.updateAll = function (ont, ontId) {
                ctrl.updateCounts(ontId,$scope.rootTermAcc);
                ctrl.update(1,ontId);
                ctrl.update(6,ontId);
                ctrl.update(5,ontId);
            }

            ctrl.browse = function (ontId, ont, term) {

                document.getElementById("speciesButton" + $scope.speciesTypeKey).style.borderColor = "#8E0026";

                var ontologyCodes = ["d","ph","bp","pw","c","vt","cm","ec"];

                for (var i=0; i< ontologyCodes.length; i++) {
                    document.getElementById(ontologyCodes[i]).style.height = "65px";
                    document.getElementById(ontologyCodes[i]).style.borderBottomLeftRadius = "8px";
                    document.getElementById(ontologyCodes[i]).style.borderBottomRightRadius = "8px";
                }


                if (ont != null) {
                    $scope.ontology = ont;
                }
                $scope.onttologyId = ontId;


                document.getElementById($scope.ontology).style.height = "80px";
                document.getElementById($scope.ontology).style.borderBottomLeftRadius = "100px";
                document.getElementById($scope.ontology).style.borderBottomRightRadius = "100px";


                if (ont=='d') {
                    $scope.title="<%=title%>";
                }else if (ont=='ph') {
                    $scope.title="<%=title%>: Phenotypes";
                }else if (ont=='bp') {
                    $scope.title="<%=title%>: Biological Processes";
                }else if (ont=='pw') {
                    $scope.title="<%=title%>: Pathways";
                }else if (ont=='c') {
                    $scope.title="<%=title%>: Chemicals and Drugs";
                }else if (ont=='vt') {
                    $scope.title="<%=title%>: Vertibrate Traits";
                }else if (ont=='cm') {
                    $scope.title="<%=title%>: Clinical Measurements";
                }else if (ont=='ec') {
                    $scope.title="<%=title%>: Experimental Conditions";
                }

                $.ajax({url: "/rgdweb/ontology/view.html?pv=1&mode=popup&filter=<%=filter%>&acc_id=" + ontId, success: function(result){
                    $("#browser").html(result);
                    //alert(result);
                }});

                $scope.currentTerm=term;
                $scope.currentTermAcc=ontId;

                ctrl.updateAll(ont, ontId)

                //ctrl.update(1,ontId);
                //ctrl.update(6,ontId);
                //ctrl.update(5,ontId);

            }


            ctrl.updateSpecies = function (speciesType, map, commonName) {

                for (var i=1; i< 8; i++) {
                    document.getElementById("speciesButton" + i).style.borderColor = "white";
                }

                document.getElementById("speciesButton" + speciesType).style.borderColor = "#8E0026";

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


            }

            ctrl.clear = function (objectKey) {

                if (objectKey ==1) {
                    $scope.portalGenes = {};
                    $scope.portalGenesLen = 0;
                }else if (objectKey==6) {
                    $scope.portalQTLs={};
                    $scope.portalQTLsLen=0;
                }else if (objectKey==5) {
                    $scope.portalStrains={};
                    $scope.portalStrainsLen=0;
                }

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
                    $scope.portalGenes = [{"name": "a2m", "symbol": "Searching Genes"}];
                }else if (objectKey==6) {
                    $scope.portalQTLs = [{"name": "a2m", "symbol": "Searching QTL"}];

                }else if (objectKey==5) {
                    $scope.portalStrains = [{"name": "a2m", "symbol": "Searching Strains"}];

                }

                var host = window.location.host;

                $scope.urlString = "http://" + host + "/rgdweb/generator/list.html?a=~" + $scope.rootTermAcc + "|!" + termAcc + "&mapKey=" + $scope.mapKey + "&oKey=" + objectKey + "&vv=&ga=&act=json";

                $http({
                    method: 'GET',
                    url: "http://" + host + "/rgdweb/generator/list.html?a=~" + $scope.rootTermAcc + "|!" + termAcc + "&mapKey=" + $scope.mapKey + "&oKey=" + objectKey + "&vv=&ga=&act=json",
                }).then(function successCallback(response) {
                    //alert(response.data);
                    if (objectKey ==1) {
                        $scope.portalGenes = response.data;
                        $scope.portalGenesLen = Object.keys($scope.portalGenes).length;

                    }else if (objectKey==6) {
                        $scope.portalQTLs=response.data;
                        $scope.portalQTLsLen=Object.keys($scope.portalQTLs).length;

                    }else if (objectKey==5) {
                        $scope.portalStrains=response.data;
                        $scope.portalStrainsLen=Object.keys($scope.portalStrains).length;
                    }

                }, function errorCallback(response) {
                    //alert("response = " + response.data);
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });
            }

        }

    ]);
</script>

<div id="portalController" ng-controller="portalController as portal">

    <table align="center">
        <tr>
        <td>


<div id="d" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.browse('RDO:0005134','d')">Disease</div>
<div id="ph" class="diseasePortalButton" style="background-color:#885D74;" ng-click="portal.browse('MP:0000001','ph')">Phenotype</div>
<div id="bp" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.browse('GO:0008150','bp')">Biological Process</div>
<div id="pw" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.browse('PW:0000001','pw')">Pathway</div>
<div id="c" class="diseasePortalButton" style="background-color:#548235;" ng-click="portal.browse('CHEBI:59999','c')">Chemical/Drug</div>
<div id="vt" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('VT:0000001','vt')">Vertebrate Trait</div>
<div id="cm" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('CMO:0000000','cm')">Clinical Measurement</div>
<div id="ec" class="diseasePortalButton" style="background-color:#002060;" ng-click="portal.browse('XCO:0000000','ec')">Experimental Condition</div>

        </td>
    </tr></table>

<table width="95%" align="center">
    <tr>
        <td><div style='font-size:30px; clear:left; color:#24609C; font-family:"Old Sans Black;"'>{{title}}&nbsp;Portal</div></td>
        <td align="right"><div style="font-size:26px; clear:left; ">{{speciesCommonName}}</div></td>
    </tr>
</table>


<table align="center" border="0">
    <tr>
        <td >
            <table border="0" id="speciesButton3" class="speciesButton" ng-click="portal.updateSpecies(3,'<%=MapManager.getInstance().getReferenceAssembly(3).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(3)%> (<%=SpeciesType.getCommonName(3)%>)')">
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
                            <td align="right">{{ objectCounts["annotated_object_count|3|1|1"] }}</td>
                        </tr>
                        <tr>
                            <td class="countTitle">QTL:</td>
                            <td align="right">{{ objectCounts["annotated_object_count|3|6|1"] }}</td>
                        </tr>
                        <tr>
                            <td class="countTitle">Strains:</td>
                            <td align="right">{{ objectCounts["annotated_object_count|3|5|1"] }}</td>
                        </tr>
                    </table>
                    </td>
                </tr>
            </table>
        </td>

        <td >
            <table border="0"  id="speciesButton2" class="speciesButton" ng-click="portal.updateSpecies(2,'<%=MapManager.getInstance().getReferenceAssembly(2).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(2)%> (<%=SpeciesType.getCommonName(2)%>)')" >
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
                                <td align="right">{{ objectCounts["annotated_object_count|2|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|2|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
        </td>
        <td>
            <table border="0" id="speciesButton1"  class="speciesButton" ng-click="portal.updateSpecies(1,'<%=MapManager.getInstance().getReferenceAssembly(1).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(1)%> (<%=SpeciesType.getCommonName(1)%>)')">
                <tr>
                    <td height="150" valign="bottom"><img src="/rgdweb/common/images/species/humanS.jpg"></td>
                </tr>
                <tr>
                    <td align="center"><%=SpeciesType.getCommonName(1)%></td>
                </tr>
                <tr>
                    <td align="center" >
                        <table  class="countTable" >
                            <tr>
                                <td class="countTitle">Genes:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|1|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|1|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
        </td>
        <td>
            <table border="0" id="speciesButton4"  class="speciesButton" ng-click="portal.updateSpecies(4,'<%=MapManager.getInstance().getReferenceAssembly(4).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(4)%> (<%=SpeciesType.getCommonName(4)%>)')">
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
                                <td align="right">{{ objectCounts["annotated_object_count|4|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|4|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
        </td>
        <td>
            <table border="0" id="speciesButton5"  class="speciesButton" ng-click="portal.updateSpecies(5,'<%=MapManager.getInstance().getReferenceAssembly(5).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(5)%> (<%=SpeciesType.getCommonName(5)%>)')">
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
                                <td align="right">{{ objectCounts["annotated_object_count|5|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|5|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
        </td>
        <td>
            <table border="0" id="speciesButton6"  class="speciesButton" ng-click="portal.updateSpecies(6,'<%=MapManager.getInstance().getReferenceAssembly(6).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(6)%> (<%=SpeciesType.getCommonName(6)%>)')">
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
                                <td align="right">{{ objectCounts["annotated_object_count|6|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|6|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
        </td>
        <td>
            <table border="0" id="speciesButton7"  class="speciesButton" ng-click="portal.updateSpecies(7,'<%=MapManager.getInstance().getReferenceAssembly(7).getKey()%>' ,'<%=SpeciesType.getTaxonomicName(7)%> (<%=SpeciesType.getCommonName(7)%>)')">
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
                                <td align="right">{{ objectCounts["annotated_object_count|7|1|1"] }}</td>
                            </tr>
                            <tr>
                                <td class="countTitle">QTL:</td>
                                <td align="right">{{ objectCounts["annotated_object_count|7|6|1"] }}</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    <td></td>
                </tr>
            </table>
        </td>


    </tr>
</table>



<script>

    function browse(id, term) {

        angular.element(document.getElementById('portalController')).scope().thisCtrl.browse(id,null,term);
    }
</script>


<div id="browser" ng-init="portal.browse('<%=filter%>','d')">

</div>

    <br>
    <!--<div>{{ urlString }}</div>-->

<table width="100%"  style="padding:5px; font-size:18px;background-color:#f6f6f6; border:1px solid black; color:#2865A3;">
    <tr>
        <td>{{ subTitle }}</td>
        <td align="right">{{speciesCommonName}}</td>
    </tr>
</table>

<table align="center" border="0">
    <tr>
        <td>
            <div class="diseasePortalListBoxTitle"><table border="0" width="100%"><tr><td valign="bottom"><b>Genes:</b> {{ portalGenesLen }}</td><td align="right"><img height=33 width=35 ng-click="portal.download('geneList',1)" src="http://rgd.mcw.edu/rgdweb/common/images/excel.png"/><img ng-click="rgd.showTools('geneList',3,360,1,0)" src="/rgdweb/common/images/tools-white-40.png"/></td></tr></table></div>
            <div class="diseasePortalListBox">
                <div ng-repeat="portalGene in portalGenes" style="padding:3px;" ng-class-even="'even'" ng-class-odd="'odd'">

                    <a class="geneList" href="/rgdweb/report/gene/main.html?id={{ portalGene.rgdId }}">{{portalGene.symbol}}</a><br />
                </div>
            </div>
        </td>
        <td>
            <div class="diseasePortalListBoxTitle"><table border="0" width="100%"><tr><td valign="bottom"><b>QTL:</b> {{ portalQTLsLen }}</td><td align="right"><img height=33 width=35 ng-click="rgd.showTools('qtlList',portal.speciesTypeKey,portal.mapKey,6,0,'excel')" src="http://rgd.mcw.edu/rgdweb/common/images/excel.png"/></td></tr></table></div>
            <div class="diseasePortalListBox">
                <div ng-repeat="portalQTL in portalQTLs" style="padding:3px;" ng-class-even="'even'" ng-class-odd="'odd'">
                    <a class="qtlList" href="/rgdweb/report/qtl/main.html?id={{portalQTL.rgdId}}">{{portalQTL.symbol}}</a><br />
                </div>

            </div>
        </td>
        <td>
            <div class="diseasePortalListBoxTitle"><table border="0" width="100%"><tr><td valign="bottom"><b>Strains:</b> {{ portalStrainsLen }}</td><td align="right"><img height=33 width=35 ng-click="rgd.showTools('strainList',rgd.speciesTypeKey,rgd.mapKey,5,0,'excel')" src="http://rgd.mcw.edu/rgdweb/common/images/excel.png"/></td></tr></table></div>
            <div class="diseasePortalListBox" style="width:500px;">
                <div ng-repeat="portalStrain in portalStrains" style="margin-top:3px; padding:3px;" ng-class-even="'even'" ng-class-odd="'odd'">
                    <a class="strainList" href="/rgdweb/report/strain/main.html?id={{portalStrain.rgdId}}">{{portalStrain.symbol}}</a><br />
                </div>

            </div>
        </td>
       <!--
        <td>
            <div class="diseasePortalListBoxTitle">Variants</div>
            <div class="diseasePortalListBox">
                <div ng-repeat="portalVariant in portalVariants">
                    {{portalVariant.symbol}}<br />
                </div>

            </div>
        </td>
        -->
    </tr>
</table>
</div>



<!--
<iframe style="border:0px solid black;" id="gviewerWindow" align="center" src="gviewer.jsp" height="400" width="100%">

</iframe>
-->

<% } catch (Exception e) {
    e.printStackTrace();
%>


<% } %>
<%@ include file="/common/footerarea.jsp"%>
