<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%
    Map map = mapDAO.getMap(mapKey);
//    int objRgdId = (int) request.getAttribute("rgdId");
    String start =  request.getAttribute("start").toString();
    String stop = request.getAttribute("stop").toString();
    String chr = request.getAttribute("chr").toString();
%>
<script>
    rgdModule.controller('rsIdController', [
        '$scope','$http','$q',

        function ($scope, $http, $q) {

            var ctrl = this;

            $scope.wsHost = window.location.protocol + window.location.host;
            if (window.location.host.indexOf('localhost') > -1) {
                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';
                $scope.olgaHost = $scope.wsHost;
//                $scope.wsHost= window.location.protocol + '//localhost:8080';
//                $scope.olgaHost = $scope.wsHost;
            } else if (window.location.host.indexOf('dev.rgd') > -1) {
                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';
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
            } $scope.wsHost = window.location.protocol + window.location.host;
            if (window.location.host.indexOf('localhost') > -1) {
                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';
                $scope.olgaHost = $scope.wsHost;
//                $scope.wsHost= window.location.protocol + '//localhost:8080';
//                $scope.olgaHost = $scope.wsHost;
            } else if (window.location.host.indexOf('dev.rgd') > -1) {
                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';
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

            ctrl.downloadVariants = function() {

                var form = document.getElementById("download");
                form.action="downloadVariants.jsp";
                form.method="POST";
                form.start.value = "<%=start%>";
                form.stopPos.value = "<%=stop%>";
                form.chr.value = "<%=chr%>";
                form.mapKey.value = "<%=mapKey%>";
                form.symbol.value = "<%=symbol%>";
                form.submit();
            }

        }

    ]);

</script>
<div id="rsIdController" ng-controller="rsIdController as variant">

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
    <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<table>
    <tr>
        <td colspan="2" style="font-size:20px; color:#2865A3; font-weight:700;">
            Your selection has multiple variants. Select which variant for <%=symbol%>&nbsp;you would like to view -&nbsp;<a style="font-size:20px; color:#2865A3; font-weight:700;" href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=SpeciesType.getTaxonomicName(speciesType)%></a>
        </td>
        <td width="10%"></td>
        <td align="right"><img  style="cursor:pointer;" height=33 width=35 ng-click="variant.downloadVariants()" src="/rgdweb/common/images/excel.png"/></td>
    </tr>
    <tr>
        <td><b>
            <a style="font-size: 14px;" href="/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=<%=symbol%>&mapKey=<%=map.getKey()%>&con=&depthLowBound=1&depthHighBound=&sample1=3000&sample2=3016&sample3=3031&sample4=3001&sample5=3017&sample6=3032&sample7=3002&sample8=3018&sample9=3033&sample10=3004&sample11=3020&sample12=3036&sample13=3003&sample14=3019&sample15=3035&sample16=3005&sample17=3021&sample18=3037&sample19=3006&sample20=3022&sample21=3038&sample22=3007&sample23=3030&sample24=3039&sample25=3008&sample26=3023&sample27=3041&sample28=3009&sample29=3034&sample30=3040&sample31=3010&sample32=3024&sample33=3042&sample34=3012&sample35=3025&sample36=3043&sample37=3011&sample38=3026&sample39=3044&sample40=3013&sample41=3027&sample42=3046&sample43=3014&sample44=3028&sample45=3045&sample46=3015&sample47=3029&sample48=3047">View in Variant Visualizer</a>
        </b></td>
    </tr>
</table>
<br>

<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div id="mapDataTableDiv" class="annotation-detail" >
    <table border="0" id="mapDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' aria-describedby="mapDataTable_pager_info">
        <tr>
            <th align="left"></th>
            <% if (isGene) { %>
            <th align="left">rs ID</th> <% } %>
            <th align="left">Chr</th>
            <th align="left">Position</th>
            <th align="left">Type</th>
            <th align="left">Reference Nucleotide</th>
            <th align="left">Variant Nucleotide</th>
            <th align="left">Assembly</th>
            <th align="left">VV</th>
        </tr>
        <% for (VariantMapData v : vars) { %>
        <tr>
            <td><a style='color:blue;font-weight:700;font-size:11px;' href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>" title="see more information in the variant page">View more Information</a></td>
            <% if (isGene) {
                String rsId = "<a href=\"https://www.ebi.ac.uk/eva/?variant&accessionID="+v.getRsId()+"\">"+v.getRsId()+"</a>";%>
            <td align="left"><%=(v.getRsId()!=null && !v.getRsId().equals("."))?rsId:"-"%></td> <% } %>
            <td><%=v.getChromosome()%></td>
            <td><%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%></td>
            <td><%=v.getVariantType()%></td>
            <td><%=Utils.NVL(v.getReferenceNucleotide(), "-")%></td>
            <td><%=Utils.NVL(v.getVariantNucleotide(),"-")%></td>
            <td><%=map.getName()%></td>
            <td><a title="View in Variant Visualizer" href="/rgdweb/front/variants.html?start=<%=v.getStartPos()%>&stop=<%=v.getEndPos()%>&chr=<%=v.getChromosome()%>&geneStart=&geneStop=&geneList=&mapKey=<%=map.getKey()%>&con=&depthLowBound=1&depthHighBound=&sample1=3000&sample2=3016&sample3=3031&sample4=3001&sample5=3017&sample6=3032&sample7=3002&sample8=3018&sample9=3033&sample10=3004&sample11=3020&sample12=3036&sample13=3003&sample14=3019&sample15=3035&sample16=3005&sample17=3021&sample18=3037&sample19=3006&sample20=3022&sample21=3038&sample22=3007&sample23=3030&sample24=3039&sample25=3008&sample26=3023&sample27=3041&sample28=3009&sample29=3034&sample30=3040&sample31=3010&sample32=3024&sample33=3042&sample34=3012&sample35=3025&sample36=3043&sample37=3011&sample38=3026&sample39=3044&sample40=3013&sample41=3027&sample42=3046&sample43=3014&sample44=3028&sample45=3045&sample46=3015&sample47=3029&sample48=3047">VV</a></td>
        </tr>
        <% } %>
    </table>
</div>
<div style="width:1px; height:1px; overflow:hidden;visibility:hidden;">
    <form id="download" name="download" >
        <input name="start" value=""/>
        <input name="stopPos" value=""/>
        <input name="chr" value=""/>
        <input name="mapKey" value=""/>
        <input name="symbol" value=""/>
    </form>
</div>

</div>
