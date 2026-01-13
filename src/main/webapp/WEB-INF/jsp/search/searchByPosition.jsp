<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery.jcarousel.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/rgdweb/common/angular/1.8.3/angular.js"></script>
<script type="text/javascript" src="https://code.jquery.com/jquery-3.5.1.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>

<link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" type="text/css" rel="stylesheet" >
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" type="text/css">
<link href="/rgdweb/css/report.css?" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="/rgdweb/js/report.js?v=6"></script>
<script type="text/javascript" src="/rgdweb/my/my.js"></script>

<style>
    .t {
        border: 1px solid #ddd;
        border-radius: 2px;
        width: 100%;
        text-align: center;
        font-size: 12px;

    }

    .t th {
        background: rgb(246, 248, 249); /* Old browsers */
        background: -moz-linear-gradient(top, rgba(246, 248, 249, 1) 0%, rgba(229, 235, 238, 1) 50%, rgba(215, 222, 227, 1) 51%, rgba(245, 247, 249, 1) 100%); /* FF3.6-15 */
        background: -webkit-linear-gradient(top, rgba(246, 248, 249, 1) 0%, rgba(229, 235, 238, 1) 50%, rgba(215, 222, 227, 1) 51%, rgba(245, 247, 249, 1) 100%); /* Chrome10-25,Safari5.1-6 */
        background: linear-gradient(to bottom, rgba(246, 248, 249, 1) 0%, rgba(229, 235, 238, 1) 50%, rgba(215, 222, 227, 1) 51%, rgba(245, 247, 249, 1) 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#f6f8f9', endColorstr='#f5f7f9', GradientType=0);
        cursor: pointer;
        padding: 5px;
    }

    .t td {
        padding: 5px;
        border-left: 1px solid #c3c3c3;
        border-right: 1px solid #c3c3c3;
    }

    .t tr:nth-child(odd) {
        background-color: #f2f2f2
    }

    .t tr:hover {
        background-color: #daeffc;
    }

    .t tbody th{
        background:#99BFE6;
        border-left: 1px solid #c3c3c3;
        border-right: 1px solid #c3c3c3;
    }

    .t thead td {
        border-left: 1px solid #c3c3c3;
        border-right: 1px solid #c3c3c3;
    }

    .bordereddiv {
        padding: 20px;
        border: 3px solid #f1f1f1;
        margin: 10px;
        display: flex;
        overflow-x: auto;
        flex-flow: column wrap;
        max-width: 80vw;
        overflow-x: auto;
    }

    .searchBox {
        border: 3px solid #f1f1f1;
        margin: 10px;
        border-color: cornflowerblue;
        border-width: thin;
        min-width: 40vw;
        max-width: 50vw;
    }

    .downloadbtn {
        background-color: DodgerBlue;
        border: none;
        color: white;
        cursor: pointer;
        font-size: 15px;
    }

    /* Darker background on mouse-over */
    .downloadbtn:hover {
        background-color: RoyalBlue;
    }

    label {
        font-size: 1.6em;
        align-self: center;
        align-items: center;
    }

    /* Chrome, Safari, Edge, Opera */
    input::-webkit-outer-spin-button,
    input::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Firefox */
    input[type=number] {
        -moz-appearance: textfield;
        height:20px;
        font-size:11pt;
    }
</style>

<%
    String pageHeader = "Search for genes, SSLPs, QTLs, and Strains by position";
    String pageTitle = "Search By Position";
    String headContent = "";
    String pageDescription = "Search all objects using Position";
%>

<script>
    var selectedSpecies = 0;
    var selectedMapKey = 0;

    function checkActiveStatus(type){
        if(type == "result"){
            document.getElementById("resultDataLink").className = "active";
        }
        else{
            document.getElementById("resultDataLink").className = "";
        }
    }

    //on press of enter ket getdata()
    var input = document.getElementById("searchByPosSubmit");
    if(input) {
        input.addEventListener("keyup", function (event) {
            if (event.keyCode === 13) {
                event.preventDefault();
                document.getElementById("searchByPosSubmit").click();
            }
        });
    }

    function setVariables() {
        var showToolsImgId = document.getElementById("showToolsImgId");
        if (showToolsImgId) {
            selectedSpecies = document.getElementById("species").selectedOptions[0].value;
            selectedMapKey = document.getElementById("mapKey").selectedOptions[0].value;
        }
    }

    function isNumber(evt)
    {
        var regex = new RegExp("^[0-9-!@#$%*?,]");
        var key = String.fromCharCode(event.charCode ? event.which : event.charCode);
        if (!regex.test(key)) {
            event.preventDefault();
            return false;
        }
    }
</script>

<%@ include file="/common/headerarea.jsp" %>

<!--Tablesorter
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>
<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"></script>

<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<link href="/rgdweb/css/report.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>-->

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%>
    </div>
</div>

<script>
    window.addEventListener("scroll", (event) => {
        let domRect = document.getElementById("reportMainSidebar").getBoundingClientRect();
        let top = domRect.top + document.body.scrollTop;
    });
</script>
<style>
    input[type=text] {
        height:20px;
        font-size:11pt;
    }

    select{
        height:20px;
        font-size:11pt;
    }

    option{
        font-size:11pt;
    }

    .searchBox td{
        padding: 25px;
    }
</style>
<div id="search">
    <div align="left">
        <form>
            <p v-if="errors.length">
                <b style="color: red">Please correct the following error(s):</b>
            <ul>
                <li v-for="error in errors">{{ error }}</li>
            </ul>
            </p>
        <table class="searchBox">
            <tr>
                <td>
                    <label for="species" style="color: #24609c;">Species: </label>
                    <select id="species" name="species" v-model="species" onchange="v.setMaps(species)" required style="width: 70px;font-size:11pt">
                        <option value="3" selected="true">Rat</option>
                        <option value="2">Mouse</option>
                        <option value="1">Human</option>
                        <option value="4">Chinchilla</option>
                        <option value="5">Bonobo</option>
                        <option value="6">Dog</option>
                        <option value="7">Squirrel</option>
                        <option value="9">Pig</option>
                        <option value="14">Naked Mole-Rat</option>
                        <option value="13">Green Monkey</option>
                    </select>
                </td>
                <td>
                    <label for="mapKey" style="color: #24609c;">Assembly: </label>
                    <select id="mapKey" name="mapKey" v-model="mapKey" required onchange="v.setKeyMap(mapKey)" style="width: 110px;font-size:11pt">
                        <option v-for="value in maps" :value="value.key" :selected="mapKey == value.key">{{value.name}}</option>
                    </select>
                </td>
                <td>
                    <label for="chr" style="color: #24609c;">Chromosome: </label>
                    <select id="chr" name="chr" v-model="chr" required style="width: 50px;font-size:11pt">
                        <option v-for="value in chromosomes" :value="value">{{value}}</option>
                    </select>
                </td>
                <td>
                    <label for="start"
                           style="color: #24609c;">Start(bp): </label>
                    <input id="start" type="text" name="start" required style="width: 160px" onkeypress="return isNumber(event)"/>
                </td>
                <td>
                    <label for="stop"
                           style="color: #24609c;">Stop(bp): </label>
                    <input id="stop" type="text" name="stop" required style="width: 160px" onkeypress="return isNumber(event)"/>
                </td>
                <td>
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="submit" name="submit" id="searchByPosSubmit" style="font-size: 20px" @click="getData($event)">
                            <i class="fa fa-search"></i>
                        </button>&nbsp;&nbsp;
                    </div>
                </td>
                <!--<td>
                    <button type="submit" @click="" class="btn btn-primary reset"> Reset </button>
                </td>-->
            </tr>
        </table>
        </form>
    </div>

    <br><br><br>
    <div id="page-container" style="display: none">
        <div id="left-side-wrap" style="margin: 10px">
            <nav id="reportMainSidebar" class="navbar report-page-grey"
                 style="position: fixed;padding: 10px;height:30vh;overflow-y: hidden;">
                <ul class="navbar-nav" id="navbarUlId">
                    <li class="nav-item" id="summary"><a class="nav-link active" href="#top" id="resultDataLink" onclick=checkActiveStatus('result')
                                            style="font-size: large">Results</a></li>
                    <br>
                    <li class="nav-item sub-nav-item" v-if="genes"><a class="nav-link" href="#searchGeneResultId"
                                                         style="font-size: medium;" onclick=checkActiveStatus('gene')>Genes</a>
                    </li>
                    <br>
                    <li class="nav-item sub-nav-item" v-if="qtls"><a class="nav-link" href="#searchQTLsResultId" onclick=checkActiveStatus('qtl')
                                                        style="font-size: medium;">QTLs</a></li>
                    <br>
                    <li class="nav-item sub-nav-item" v-if="sslps"><a class="nav-link" href="#searchSSLPsResultId" onclick=checkActiveStatus('sslp')
                                                         style="font-size: medium;">SSLPs</a></li>
                    <br>
                    <li class="nav-item sub-nav-item" v-if="strains"><a class="nav-link" href="#searchStrainsResultId" onclick=checkActiveStatus('strain')
                                                                      style="font-size: medium;">Strains</a></li>
                </ul>
            </nav>
        </div>
        <div id="content-wrap">
            <table width="100%" border="0">
                <tr><!--Results summary section-->
                    <td>
                        <div class="bordereddiv" id="searchByPositionResultsId">
                            <div style="display: flex; flex-flow: row; padding: 10px">
                                <div style="padding: 5px;width: 100%"><h2>Total Objects in the selected region: </h2>
                                    <label for="downloadAllBtnId" style="font-size:small">Download All Objects Here: </label>
                                    <button id="downloadAllBtnId" class="downloadbtn" @click="download('all')"><i class="fa fa-download"
                                                                                            title="Download All"></i>
                                    </button>
                                </div>
                                <div style="padding: 10px; width:100%">
                                    <table style="border-style: dotted" class="t">
                                        <tr>
                                            <td style="font-size: large">Genes -
                                                {{geneCount}}
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('gene')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download Genes"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="font-size: large">QTLs -
                                                {{qtlCount}}
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('qtl')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download QTLs"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="font-size: large">SSLPs -
                                                {{sslpCount}}
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('sslp')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download SSLPs"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="font-size: large">Strains -
                                                {{strainCount}}
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('strain')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download Strains"></i></button>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr><!--Genes section-->
                    <td>
                        <div class="bordereddiv" id="searchGeneResultId">
                            <div style="display: flex;flex-direction: row;padding: 10px;width:100%">
                                <div style="padding: 10px">
                                    <h2>Genes</h2>
                                </div>
                                <div style="padding: 10px;width:90%">
                                    <button class="downloadbtn" @click="download('gene')"><i class="fa fa-download"
                                                                                             style="align-self: auto"
                                                                                             title="Download Genes"></i>
                                    </button>
                                </div>
                                <div style="padding: 10px;width: 10%" >
                                    <img src="/rgdweb/common/images/tools-white-50.png" id="showToolsImgId"
                                         style="cursor:hand; border: 2px solid black;" border="0" onclick="setVariables()"
                                             ng-click="rgd.showTools('geneList',selectedSpecies,selectedMapKey,1,'')"/>
                                </div>
                            </div>
                            <table id="geneResultsTable" class="t" role="grid">
                                <tr role="row">
                                    <th>RGD ID</th>
                                    <th>Type</th>
                                    <th>Symbol</th>
                                    <th>Name</th>
                                    <th>Chr</th>
                                    <th>Start</th>
                                    <th>Stop</th>
                                </tr>
                                <tr v-for="record in geneData">
                                    <td>{{record.gene.rgdId}}</td>
                                    <td>{{record.gene.type}}</td>
                                    <td><a :href="geneUrl+record.gene.rgdId" class="geneList"> {{record.gene.symbol}}</a></td>
                                    <td>{{record.gene.name}}</td>
                                    <td>{{record.chromosome}}</td>
                                    <td>{{record.start}}</td>
                                    <td>{{record.stop}}</td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr><!--QTLs Section-->
                    <td>
                        <div class="bordereddiv" id="searchQTLsResultId" style="display: none">
                            <div style="display: flex;flex-direction: row;padding: 10px;width:100%">
                                <div style="padding: 10px">
                                    <h2>QTLs</h2>
                                </div>
                                <div style="padding: 10px;width:90%">
                                    <button class="downloadbtn" @click="download('qtl')"><i class="fa fa-download"
                                                                                            style="align-self: auto"
                                                                                            title="Download QTLs"></i>
                                    </button>
                                </div>
                                <div style="padding: 10px;width: 10%" >
                                    <img src="/rgdweb/common/images/tools-white-50.png"
                                         style="cursor:hand; border: 2px solid black;" border="0"
                                         ng-click="rgd.showTools('geneList',3,60,6,'')"/>
                                </div>
                            </div>

                            <table class="t" role="grid">
                                <tr role="row">
                                    <th>RGD ID</th>
                                    <th>Symbol</th>
                                    <th>Name</th>
                                    <th>Chr</th>
                                    <th>Start</th>
                                    <th>Stop</th>
                                </tr>
                                <tr v-for="record in qtlData"
                                    class="record">
                                    <td>{{record.qtl.rgdId}}</td>
                                    <td><a :href="qtlUrl+record.qtl.rgdId" class="geneList">{{record.qtl.symbol}}</a></td>
                                    <td>{{record.qtl.name}}</td>
                                    <td>{{record.chromosome}}</td>
                                    <td>{{record.start}}</td>
                                    <td>{{record.stop}}</td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr><!--SSLPs Section-->
                    <td>
                        <div class="bordereddiv" id="searchSSLPsResultId" style="display: none">
                            <div style="display: flex;flex-direction: row;padding: 10px">
                                <div style="padding: 10px">
                                    <h2>SSLPs</h2>
                                </div>
                                <div style="padding: 10px">
                                    <button class="downloadbtn" @click="download('sslp')"><i class="fa fa-download"
                                                                                             style="align-self: auto"
                                                                                             title="Download SSLPs"></i>
                                    </button>
                                </div>
                            </div>
                            <table class="t" role="grid">
                                <tr role="row">
                                    <th>RGD ID</th>
                                    <th>Symbol</th>
                                    <th>Name</th>
                                    <th>Chr</th>
                                    <th>Start</th>
                                    <th>Stop</th>
                                </tr>
                                <tr v-for="record in sslpData"
                                    class="record">
                                    <td>{{record.sslp.rgdId}}</td>
                                    <td><a :href="sslpUrl+record.sslp.rgdId" class="geneList">{{record.sslp.name}}</a></td>
                                    <td>{{record.sslp.name}}</td>
                                    <td>{{record.chromosome}}</td>
                                    <td>{{record.start}}</td>
                                    <td>{{record.stop}}</td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr> <!-- Strain section -->
                    <td>
                        <div class="bordereddiv" id="searchStrainsResultId" style="display: none">
                            <div style="display: flex;flex-direction: row;padding: 10px">
                                <div style="padding: 10px">
                                    <h2>Strains</h2>
                                </div>
                                <div style="padding: 10px">
                                    <button class="downloadbtn" @click="download('strain')"><i class="fa fa-download"
                                                                                             style="align-self: auto"
                                                                                             title="Download Strains"></i>
                                    </button>
                                </div>
                            </div>
                            <table class="t" role="grid">
                                <tr role="row">
                                    <th>RGD ID</th>
                                    <th>Symbol</th>
                                    <th>Name</th>
                                    <th>Chr</th>
                                    <th>Start</th>
                                    <th>Stop</th>
                                </tr>
                                <tr v-for="record in strainData"
                                    class="record">
                                    <td>{{record.strain.rgdId}}</td>
                                    <td><a :href="strainUrl+record.strain.rgdId" class="geneList" v-html="record.strain.symbol"></a></td>
                                    <td  v-html="record.strain.symbol"></td>
                                    <td>{{record.chromosome}}</td>
                                    <td>{{record.start}}</td>
                                    <td>{{record.stop}}</td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>


<script>
    var div = '#search';
    var host = window.location.protocol + window.location.host;
    if (window.location.host.indexOf('localhost') > -1) {
        host = 'https://dev.rgd.mcw.edu';
    } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host = window.location.protocol + '//dev.rgd.mcw.edu';
    } else if (window.location.host.indexOf('test.rgd') > -1) {
        host = window.location.protocol + '//test.rgd.mcw.edu';
    } else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host = window.location.protocol + '//pipelines.rgd.mcw.edu';
    } else {
        host = window.location.protocol + '//rest.rgd.mcw.edu';
    }
    // host = 'https://dev.rgd.mcw.edu';
    var v = new Vue({
        el: div,
        data: {
            hostName: host,
            maps: [],
            chromosomes: [],
            species: 3,
            chr: 1,
            mapKey: "Rnor_6.0",
            geneData: {},
            qtlData: {},
            sslpData: {},
            strainData: {},
            geneCount: 0,
            qtlCount: 0,
            sslpCount: 0,
            strainCount: 0,
            strains: false,
            qtls: false,
            sslps: false,
            genes: false,
            loading: false,
            errors : [],
            geneUrl : "/rgdweb/report/gene/main.html?id=",
            qtlUrl : "/rgdweb/report/qtl/main.html?id=",
            sslpUrl : "/rgdweb/report/marker/main.html?id=",
            strainUrl: "/rgdweb/report/strain/main.html?id="
        },
        methods: {
            getData: function (e) {
                var chr = document.getElementById('chr').value;
                var txt = document.getElementById('start').value;
                var start = txt.replace(/,/g, "");
                start = Number(start);
                txt = document.getElementById('stop').value;
                var stop = txt.replace(/,/g, "");
                stop = Number(stop);
                var mapKey = document.getElementById('mapKey').value;

                v.qtls = false;
                v.geneCount = 0;
                v.qtlCount = 0;
                v.sslpCount = 0;
                v.strainCount = 0;
                v.sslps = false;
                v.genes = false;
                v.strains = false;

                this.errors = [];
                //var start = document.getElementById('start').value;
                //var stop = document.getElementById('stop').value;
                if(Number(start) > Number(stop)) {
                    this.errors.push('Start number is greater than Stop number.');
                }
                if (this.errors.length>0) {
                    e.preventDefault();
                    document.getElementById('page-container').style.display = 'none';
                }else {
                    axios
                        .get(this.hostName + '/rgdws/genes/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.geneData = response.data;
                            if (v.geneData.length != 0) {
                                v.geneCount = v.geneData.length;
                                v.genes = true;

                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "30vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchGeneResultId').style.display = 'block';
                                /*var geneResultsTable = document.getElementById("geneResultsTable");
                                if (geneResultsTable) {
                                    $('#geneResultsTable').tablesorter({
                                        theme: 'blue'
                                    });
                                }*/
                            }else{
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "20vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchGeneResultId').style.display = 'none';
                            }
                        }).catch(function (error) {
                        console.log(error)
                    });
                    axios
                        .get(this.hostName + '/rgdws/qtls/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.qtlData = response.data;
                            if (v.qtlData.length != 0) {
                                v.qtlCount = v.qtlData.length;
                                v.qtls = true;
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "30vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchQTLsResultId').style.display = 'block';
                            }else{
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "20vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchQTLsResultId').style.display = 'none';
                            }
                        }).catch(function (error) {
                        console.log(error)
                    });
                    axios
                        .get(this.hostName + '/rgdws/sslps/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.sslpData = response.data;
                            if (v.sslpData.length != 0) {
                                v.sslpCount = v.sslpData.length;
                                v.sslps = true;
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "30vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchSSLPsResultId').style.display = 'block';
                            }else{
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "20vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchSSLPsResultId').style.display = 'none';
                            }
                        }).catch(function (error) {
                        console.log(error)
                    });
                    axios
                        .get(this.hostName + '/rgdws/strains/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.strainData = response.data;
                            if (v.strainData.length != 0) {
                                v.strainCount = v.strainData.length;
                                v.strains = true;
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "30vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchStrainsResultId').style.display = 'block';
                            }else{
                                document.getElementById('resultDataLink').className = 'active';
                                document.getElementById('reportMainSidebar').style.height = "20vh";
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchStrainsResultId').style.display = 'none';
                            }
                        }).catch(function (error) {
                        console.log(error)
                    });
                }
            },
            setMaps: function (species) {
                var mapKey = 0;
                v.maps = [];
                if (species !== this.species) {
                    species = species.options[species.selectedIndex].value;
                    this.species = species;
                }
                axios
                    .get(this.hostName + '/rgdws/maps/' + species)
                    .then(function (response) {
                        v.maps = (response.data);
                        mapKey = v.maps[0].key;
                        v.mapKey = v.maps[0].key;
                        v.setChromosomes(mapKey);
                        document.getElementById('start').value = '';
                        document.getElementById('stop').value = '';
                    }).catch(function (error) {
                    console.log(error)
                });
            },
            setKeyMap:function (mapKey){

            },
            setChromosomes: function (mapKey) {
                if (v.mapKey == 'Rnor_6.0')
                    mapKey = 360;
                axios
                    .get(this.hostName + '/rgdws/maps/chr/' + mapKey)
                    .then(function (response) {
                        v.chromosomes = response.data;
                    }).catch(function (error) {
                    console.log(error)
                });
            },
            setSource: function (mapKey) {
                if (mapKey != this.mapKey)
                    mapKey = mapKey.options[mapKey.selectedIndex].value;
            },
            download: function (objType) {

                params = new Object();
                var form = document.createElement("form");
                var method = "POST";
                form.setAttribute("method", method);
                form.setAttribute("action", "/rgdweb/search/searchByPosition.html?fmt=csv");

                var txt = document.getElementById('start').value;
                var start = txt.replace(/,/g, "");
                txt = document.getElementById('stop').value;
                var stop = txt.replace(/,/g, "");


                params.chr = document.getElementById('chr').value;
                params.start = Number(start);
                params.stop = Number(stop);
                params.mapKey = document.getElementById('mapKey').value;
                params.objType = objType;
                for (var key in params) {
                    var hiddenField = document.createElement("input");
                    hiddenField.setAttribute("type", "hidden");
                    hiddenField.setAttribute("name", key);
                    hiddenField.setAttribute("value", params[key]);
                    form.appendChild(hiddenField);
                }
                document.body.appendChild(form);
                form.submit();
            }
        }
    });
    v.species = 3;
    v.setMaps(3);
</script>

<%@ include file="/common/footerarea.jsp" %>

