<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%
    Map map = mapDAO.getMap(mapKey);
//    int objRgdId = (int) request.getAttribute("rgdId");
    String start =  request.getAttribute("start").toString();
    String stop = request.getAttribute("stop").toString();
    String chr = request.getAttribute("chr").toString();
    String vvSamples = "";
    if (speciesType==1)
        vvSamples="&strain%5B%5D=2&sample1=2";
    else if (speciesType==3)
        vvSamples = "&sample1=3000&sample2=3016&sample3=3031&sample4=3001&sample5=3017&sample6=3032&sample7=3002&sample8=3018" +
                "&sample9=3033&sample10=3004&sample11=3020&sample12=3036&sample13=3003&sample14=3019&sample15=3035&sample16=3005" +
                "&sample17=3021&sample18=3037&sample19=3006&sample20=3022&sample21=3038&sample22=3007&sample23=3030&sample24=3039" +
                "&sample25=3008&sample26=3023&sample27=3041&sample28=3009&sample29=3034&sample30=3040&sample31=3010&sample32=3024" +
                "&sample33=3042&sample34=3012&sample35=3025&sample36=3043&sample37=3011&sample38=3026&sample39=3044&sample40=3013" +
                "&sample41=3027&sample42=3046&sample43=3014&sample44=3028&sample45=3045&sample46=3015&sample47=3029&sample48=3047";
    else
        vvSamples = "&sample1=3000&sample2=3016&sample3=3031&sample4=3001&sample5=3017&sample6=3032&sample7=3002&sample8=3018" +
                "&sample9=3033&sample10=3004&sample11=3020&sample12=3036&sample13=3003&sample14=3019&sample15=3035&sample16=3005" +
                "&sample17=3021&sample18=3037&sample19=3006&sample20=3022&sample21=3038&sample22=3007&sample23=3030&sample24=3039" +
                "&sample25=3008&sample26=3023&sample27=3041&sample28=3009&sample29=3034&sample30=3040&sample31=3010&sample32=3024" +
                "&sample33=3042&sample34=3012&sample35=3025&sample36=3043&sample37=3011&sample38=3026&sample39=3044&sample40=3013" +
                "&sample41=3027&sample42=3046&sample43=3014&sample44=3028&sample45=3045&sample46=3015&sample47=3029&sample48=3047";
%>

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
            Your selection has multiple variants. Select which variant for <%=symbol%>&nbsp;you would like to view -&nbsp;<%=SpeciesType.getTaxonomicName(speciesType)%></td>
        <td width="10%"></td>
        <td align="right">
            <form id="downloadVue">
                <input type="hidden" id="start" value=""/>
                <input type="hidden" id="stopPos" value=""/>
                <input type="hidden" id="chr" value=""/>
                <input type="hidden" id="mapKey" value=""/>
                <input type="hidden" id="symbol" value=""/>
                <input type="image" style="cursor:pointer;" height=33 width=35 v-on:click="downloadVars" src="/rgdweb/common/images/excel.png"></input> <!--  onclick="downloadVariants()" -->
            </form>
        </td>
    </tr>
    <tr>
        <td>Assembly:&nbsp;<a href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=map.getName()%></a></td>
    </tr>
    <% if (speciesType == 1 || speciesType == 3 ){ %>
    <tr>
        <td><b>
            <a style="font-size: 14px;" href="/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=<%=symbol%>&mapKey=<%=map.getKey()%>&con=&depthLowBound=1&depthHighBound=<%=vvSamples%>">View in Variant Visualizer</a>
        </b></td>
    </tr>
    <% } %>
</table>
<br>

<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div id="mapDataTableDiv" class="annotation-detail" >
    <div class="search-and-pager">
        <div class="modelsViewContent" >
            <div class="pager mapDataPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option selected="selected" value="10">10</option>
                        <option value="20">20</option>
                        <option value="30">30</option>
                        <option  value="40">40</option>
                        <option   value="100">100</option>
                        <option value="1000">1000</option>
                    </select>
                </form>
            </div>
        </div>
    </div>

    <table border="0" id="mapDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' aria-describedby="mapDataTable_pager_info">
        <tr>
            <th align="left">Variant Page</th>
            <% if (isGene) { %>
            <th align="left">rs ID</th> <% } %>
            <th align="left">Chr</th>
            <th align="left">Position</th>
            <th align="left">Type</th>
            <th align="left">Reference Nucleotide</th>
            <th align="left">Variant Nucleotide</th>
            <% if (speciesType == 1 || speciesType == 3 ){ %>
            <th align="left">VV</th>
            <%}%>
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
            <% if (speciesType == 1 || speciesType == 3 ){ %>
            <td><a title="View in Variant Visualizer" href="/rgdweb/front/variants.html?start=<%=v.getStartPos()%>&stop=<%=v.getEndPos()%>&chr=<%=v.getChromosome()%>&geneStart=&geneStop=&geneList=&mapKey=<%=map.getKey()%>&con=&depthLowBound=1&depthHighBound=<%=vvSamples%>">
                <img src="/rgdweb/common/images/variantVisualizer-abr.png" width="30" height="15">
            </a></td>
            <% } %>
        </tr>
        <% } %>
    </table>
    <div class="modelsViewContent" >
        <div class="pager mapDataPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="1000">1000</option>
                </select>
            </form>
        </div>
    </div>
</div>
<%--<div style="width:1px; height:1px; overflow:hidden;visibility:hidden;">--%>
<%--    <form id="download" name="download" >--%>
<%--        <input name="start" value=""/>--%>
<%--        <input name="stopPos" value=""/>--%>
<%--        <input name="chr" value=""/>--%>
<%--        <input name="mapKey" value=""/>--%>
<%--        <input name="symbol" value=""/>--%>
<%--    </form>--%>
<%--</div>--%>

<script>
    var downloadVue = new Vue ({
        el: '#downloadVue',
        data: {
            start: '<%=start%>',
            stopPos: '<%=stop%>',
            chr: '<%=chr%>',
            mapKey: '<%=mapKey%>',
            symbol: '<%=symbol%>'
        },
        methods: {
            downloadVars: function () {
                // alert("Start vue");
                axios
                    .post('/rgdweb/report/rsIds/download.html',
                        {
                            start: downloadVue.start,
                            stopPos: downloadVue.stopPos,
                            chr: downloadVue.chr,
                            mapKey: downloadVue.mapKey,
                            symbol: downloadVue.symbol
                        },
                    {responseType: 'blob'})
                    .then(function (response) {
                        // alert("done");
                        // console.log(response);
                        var a = document.createElement("a");
                        document.body.appendChild(a);
                        a.style = "display: none";
                        let blob = new Blob([response.data], { type: 'text/csv' }),
                            url = window.URL.createObjectURL(blob);
                        a.href = url;
                        a.download = "variants.csv";
                        a.click();
                        window.URL.revokeObjectURL(url);
                        // window.open(url)
                    })
                    .catch(function (error) {
                    console.log(error.response.data)
                })
            }
        }
    });

    <%--function downloadVariants() {--%>

    <%--    var form = document.getElementById("downloadVue");--%>
    <%--    form.action="/rgdweb/report/rsIds/download.html";--%>
    <%--    form.method="POST";--%>
    <%--    form.start.value = '<%=start%>';--%>
    <%--    form.stopPos.value = '<%=stop%>';--%>
    <%--    form.chr.value = '<%=chr%>';--%>
    <%--    form.mapKey.value = '<%=mapKey%>';--%>
    <%--    form.symbol.value = '<%=symbol%>';--%>
    <%--    form.submit();--%>
    <%--}--%>
    <%--    rgdModule.controller('rsIdController', [--%>
    <%--        '$scope','$http','$q',--%>

    <%--        function ($scope, $http, $q) {--%>

    <%--            var ctrl = this;--%>

    <%--            $scope.wsHost = window.location.protocol + window.location.host;--%>
    <%--            if (window.location.host.indexOf('localhost') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--//                $scope.wsHost= window.location.protocol + '//localhost:8080';--%>
    <%--//                $scope.olgaHost = $scope.wsHost;--%>
    <%--            } else if (window.location.host.indexOf('dev.rgd') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--            }else if (window.location.host.indexOf('test.rgd') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//test.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--            }else if (window.location.host.indexOf('pipelines.rgd') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//pipelines.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--            }else {--%>
    <%--                $scope.wsHost=window.location.protocol + '//rest.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = "https://rgd.mcw.edu";--%>
    <%--            } $scope.wsHost = window.location.protocol + window.location.host;--%>
    <%--            if (window.location.host.indexOf('localhost') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--//                $scope.wsHost= window.location.protocol + '//localhost:8080';--%>
    <%--//                $scope.olgaHost = $scope.wsHost;--%>
    <%--            } else if (window.location.host.indexOf('dev.rgd') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//dev.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--            }else if (window.location.host.indexOf('test.rgd') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//test.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--            }else if (window.location.host.indexOf('pipelines.rgd') > -1) {--%>
    <%--                $scope.wsHost= window.location.protocol + '//pipelines.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = $scope.wsHost;--%>
    <%--            }else {--%>
    <%--                $scope.wsHost=window.location.protocol + '//rest.rgd.mcw.edu';--%>
    <%--                $scope.olgaHost = "https://rgd.mcw.edu";--%>
    <%--            }--%>

    <%--            $scope.title = "<%=title%>";--%>
    <%--            $scope.subTitle = "";--%>
    <%--            $scope.thisCtrl = ctrl;--%>

    <%--            ctrl.downloadVariants = function() {--%>

    <%--                var form = document.getElementById("download");--%>
    <%--                form.action="downloadVariants.jsp";--%>
    <%--                form.method="POST";--%>
    <%--                form.start.value = "<%=start%>";--%>
    <%--                form.stopPos.value = "<%=stop%>";--%>
    <%--                form.chr.value = "<%=chr%>";--%>
    <%--                form.mapKey.value = "<%=mapKey%>";--%>
    <%--                form.symbol.value = "<%=symbol%>";--%>
    <%--                form.submit();--%>
    <%--            }--%>

    <%--        }--%>

    <%--    ]);--%>
</script>