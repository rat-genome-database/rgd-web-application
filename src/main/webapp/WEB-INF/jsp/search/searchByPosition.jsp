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
        background: linear-gradient(to bottom, rgba(246, 248, 249, 1) 0%, rgba(229, 235, 238, 1) 50%, rgba(215, 222, 227, 1) 51%, rgba(245, 247, 249, 1) 100%);
        cursor: pointer;
        padding: 5px;
        user-select: none;
        white-space: nowrap;
    }

    .t th .sort-indicator {
        font-size: 10px;
        margin-left: 3px;
        color: #24609c;
    }

    .t td {
        padding: 5px;
        border-left: 1px solid #c3c3c3;
        border-right: 1px solid #c3c3c3;
    }

    .t tr:nth-child(odd) {
        background-color: #f2f2f2;
    }

    .t tr:hover {
        background-color: #daeffc;
    }

    .t tbody th {
        background: #99BFE6;
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
    }

    .downloadbtn {
        background-color: DodgerBlue;
        border: none;
        color: white;
        cursor: pointer;
        font-size: 15px;
    }

    .downloadbtn:hover {
        background-color: RoyalBlue;
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
    }

    /* Search card styles */
    .search-hero {
        background: #f8f9fa;
        padding: 40px 20px 50px;
        text-align: center;
    }

    .search-hero-title {
        font-size: 28px;
        font-weight: 700;
        color: #24609c;
        margin: 0 0 8px 0;
    }

    .search-hero-subtitle {
        font-size: 15px;
        color: #666;
        margin: 0 0 30px 0;
    }

    .search-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
        max-width: 700px;
        margin: 0 auto;
        padding: 32px 36px 28px;
    }

    .search-form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px 24px;
    }

    .search-form-grid .field-group {
        display: flex;
        flex-direction: column;
    }

    .search-form-grid .field-group.full-width {
        grid-column: 1 / -1;
    }

    .search-form-grid .field-group label {
        font-size: 13px;
        font-weight: 600;
        color: #24609c;
        margin-bottom: 6px;
    }

    .search-form-grid .field-group select,
    .search-form-grid .field-group input[type="text"] {
        width: 100%;
        padding: 10px 12px;
        font-size: 14px;
        border: 1px solid #ccc;
        border-radius: 6px;
        background: #fff;
        color: #333;
        box-sizing: border-box;
        transition: border-color 0.2s;
    }

    .search-form-grid .field-group select:focus,
    .search-form-grid .field-group input[type="text"]:focus {
        outline: none;
        border-color: #24609c;
        box-shadow: 0 0 0 3px rgba(36, 96, 156, 0.12);
    }

    .search-form-grid .field-group select {
        appearance: auto;
    }

    .search-btn-wrap {
        text-align: center;
        margin-top: 28px;
    }

    .search-btn-primary {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: #24609c;
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: 12px 36px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s, box-shadow 0.2s;
    }

    .search-btn-primary:hover {
        background: #1b4d7e;
        box-shadow: 0 4px 12px rgba(36, 96, 156, 0.3);
    }

    .search-btn-primary:active {
        background: #163f68;
    }

    .search-errors {
        background: #fff0f0;
        border: 1px solid #e0b4b4;
        border-radius: 8px;
        padding: 14px 18px;
        margin-bottom: 20px;
    }

    .search-errors b {
        color: #c33;
        font-size: 14px;
    }

    .search-errors ul {
        margin: 6px 0 0 18px;
        padding: 0;
    }

    .search-errors li {
        color: #c33;
        font-size: 13px;
    }

    .t td a:hover {
        text-decoration: underline !important;
        color: #24609c !important;
    }

    @media (max-width: 600px) {
        .search-form-grid {
            grid-template-columns: 1fr;
        }
        .search-card {
            padding: 24px 20px 20px;
        }
        .search-hero-title {
            font-size: 22px;
        }
    }
</style>

<%
    String pageHeader = "Search by Genomic Position";
    String pageTitle = "Search by Genomic Position";
    String headContent = "";
    String pageDescription = "Search for genes, QTLs, SSLPs, and strains at a specific genomic location";
%>

<script>
    var selectedSpecies = 0;
    var selectedMapKey = 0;

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


<div id="search">
    <div class="search-hero" v-show="!showResults">
        <h1 class="search-hero-title">Search by Genomic Position</h1>
        <p class="search-hero-subtitle">Find genes, QTLs, SSLPs, and strains at a specific genomic location</p>

        <div class="search-card">
            <form>
                <div v-if="errors.length" class="search-errors">
                    <b>Please correct the following error(s):</b>
                    <ul>
                        <li v-for="error in errors">{{ error }}</li>
                    </ul>
                </div>

                <div class="search-form-grid">
                    <div class="field-group">
                        <label for="species">Species</label>
                        <select id="species" name="species" v-model="species" onchange="v.setMaps(species)" required>
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
                            <option value="17">Black Rat</option>
                        </select>
                    </div>

                    <div class="field-group">
                        <label for="mapKey">Assembly</label>
                        <select id="mapKey" name="mapKey" v-model="mapKey" required onchange="v.setKeyMap(mapKey)">
                            <option v-for="value in maps" :value="value.key" :selected="mapKey == value.key">{{value.name}}</option>
                        </select>
                    </div>

                    <div class="field-group">
                        <label for="chr">Chromosome</label>
                        <select id="chr" name="chr" v-model="chr" required>
                            <option v-for="value in chromosomes" :value="value">{{value}}</option>
                        </select>
                    </div>

                    <div class="field-group">
                        <!-- empty cell for grid alignment -->
                    </div>

                    <div class="field-group">
                        <label for="start">Start (bp)</label>
                        <input id="start" type="text" name="start" required placeholder="e.g. 1000000" onkeypress="return isNumber(event)"/>
                    </div>

                    <div class="field-group">
                        <label for="stop">Stop (bp)</label>
                        <input id="stop" type="text" name="stop" required placeholder="e.g. 5000000" onkeypress="return isNumber(event)"/>
                    </div>
                </div>

                <div class="search-btn-wrap">
                    <button class="search-btn-primary" type="button" id="searchByPosSubmit" @click="getData($event)">
                        <i class="fa fa-search"></i> Search
                    </button>
                </div>
            </form>
        </div>
    </div>

    <br><br><br>
    <div id="page-container" style="display: none">
        <div id="content-wrap">
            <table width="100%" border="0">
                <tr><!--Results summary section-->
                    <td>
                        <div class="bordereddiv" id="searchByPositionResultsId">
                            <div style="display: flex; align-items: center; padding: 10px 10px 0 10px;">
                                <button class="search-btn-primary" type="button" @click="showResults=false" style="padding: 8px 20px; font-size: 14px; margin-right: 15px;">
                                    <i class="fa fa-arrow-left"></i> New Search
                                </button>
                                <span style="color: #666; font-size: 14px;">{{searchLabel}}</span>
                            </div>
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
                                            <td><a href="#searchGeneResultId" style="text-decoration:none;color:inherit;font-size:18px;">Genes -
                                                {{geneCount}}</a>
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('gene')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download Genes"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><a href="#searchQTLsResultId" style="text-decoration:none;color:inherit;font-size:18px;">QTLs -
                                                {{qtlCount}}</a>
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('qtl')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download QTLs"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><a href="#searchSSLPsResultId" style="text-decoration:none;color:inherit;font-size:18px;">SSLPs -
                                                {{sslpCount}}</a>
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('sslp')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download SSLPs"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><a href="#searchStrainsResultId" style="text-decoration:none;color:inherit;font-size:18px;">Strains -
                                                {{strainCount}}</a>
                                            </td>
                                            <td>
                                                <button class="downloadbtn" @click="download('strain')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download Strains"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><a href="#top" style="text-decoration:none;color:inherit;font-size:18px;">Variants -
                                                <span v-if="variantCount >= 0">{{variantCount.toLocaleString()}}</span>
                                                <span v-else><i class="fa fa-spinner fa-spin"></i></span></a>
                                            </td>
                                            <td>
                                                <button v-if="variantCount >= 0 && variantCount <= 500000" class="downloadbtn" @click="download('variant')"><i
                                                        class="fa fa-download" style="align-self: auto"
                                                        title="Download Variants"></i></button>
                                                <span v-if="variantCount > 500000" style="font-size:11px; color:#999;" title="Narrow your region to enable download">too large</span>
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
                                         style="cursor:pointer; border: 2px solid black;" border="0"
                                             onclick="setVariables(); var el=document.getElementById('RGDPageController'); var s=angular.element(el).scope(); s.$apply(function(){ s.rgd.showTools('geneList',selectedSpecies,selectedMapKey,1,''); })"/>
                                </div>
                            </div>
                            <table id="geneResultsTable" class="t" role="grid">
                                <tr role="row">
                                    <th @click="sortBy('gene','rgdId','gene')">RGD ID <span class="sort-indicator" v-text="sortIndicator('gene','rgdId','gene')"></span></th>
                                    <th @click="sortBy('gene','type','gene')">Type <span class="sort-indicator" v-text="sortIndicator('gene','type','gene')"></span></th>
                                    <th @click="sortBy('gene','symbol','gene')">Symbol <span class="sort-indicator" v-text="sortIndicator('gene','symbol','gene')"></span></th>
                                    <th @click="sortBy('gene','name','gene')">Name <span class="sort-indicator" v-text="sortIndicator('gene','name','gene')"></span></th>
                                    <th @click="sortBy('gene','chromosome')">Chr <span class="sort-indicator" v-text="sortIndicator('gene','chromosome')"></span></th>
                                    <th @click="sortBy('gene','start')">Start <span class="sort-indicator" v-text="sortIndicator('gene','start')"></span></th>
                                    <th @click="sortBy('gene','stop')">Stop <span class="sort-indicator" v-text="sortIndicator('gene','stop')"></span></th>
                                </tr>
                                <tr v-for="record in geneData">
                                    <td>{{record.gene.rgdId}}</td>
                                    <td>{{record.gene.type}}</td>
                                    <td><a :href="geneUrl+record.gene.rgdId" class="geneList" target="_blank"> {{record.gene.symbol}}</a></td>
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
                                         style="cursor:pointer; border: 2px solid black;" border="0"
                                         onclick="setVariables(); var el=document.getElementById('RGDPageController'); var s=angular.element(el).scope(); s.$apply(function(){ s.rgd.showTools('geneList',selectedSpecies,selectedMapKey,6,''); })"/>
                                </div>
                            </div>

                            <table class="t" role="grid">
                                <tr role="row">
                                    <th @click="sortBy('qtl','rgdId','qtl')">RGD ID <span class="sort-indicator" v-text="sortIndicator('qtl','rgdId','qtl')"></span></th>
                                    <th @click="sortBy('qtl','symbol','qtl')">Symbol <span class="sort-indicator" v-text="sortIndicator('qtl','symbol','qtl')"></span></th>
                                    <th @click="sortBy('qtl','name','qtl')">Name <span class="sort-indicator" v-text="sortIndicator('qtl','name','qtl')"></span></th>
                                    <th @click="sortBy('qtl','chromosome')">Chr <span class="sort-indicator" v-text="sortIndicator('qtl','chromosome')"></span></th>
                                    <th @click="sortBy('qtl','start')">Start <span class="sort-indicator" v-text="sortIndicator('qtl','start')"></span></th>
                                    <th @click="sortBy('qtl','stop')">Stop <span class="sort-indicator" v-text="sortIndicator('qtl','stop')"></span></th>
                                </tr>
                                <tr v-for="record in qtlData"
                                    class="record">
                                    <td>{{record.qtl.rgdId}}</td>
                                    <td><a :href="qtlUrl+record.qtl.rgdId" class="geneList" target="_blank">{{record.qtl.symbol}}</a></td>
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
                                    <th @click="sortBy('sslp','rgdId','sslp')">RGD ID <span class="sort-indicator" v-text="sortIndicator('sslp','rgdId','sslp')"></span></th>
                                    <th @click="sortBy('sslp','name','sslp')">Symbol <span class="sort-indicator" v-text="sortIndicator('sslp','name','sslp')"></span></th>
                                    <th @click="sortBy('sslp','name','sslp')">Name <span class="sort-indicator" v-text="sortIndicator('sslp','name','sslp')"></span></th>
                                    <th @click="sortBy('sslp','chromosome')">Chr <span class="sort-indicator" v-text="sortIndicator('sslp','chromosome')"></span></th>
                                    <th @click="sortBy('sslp','start')">Start <span class="sort-indicator" v-text="sortIndicator('sslp','start')"></span></th>
                                    <th @click="sortBy('sslp','stop')">Stop <span class="sort-indicator" v-text="sortIndicator('sslp','stop')"></span></th>
                                </tr>
                                <tr v-for="record in sslpData"
                                    class="record">
                                    <td>{{record.sslp.rgdId}}</td>
                                    <td><a :href="sslpUrl+record.sslp.rgdId" class="geneList" target="_blank">{{record.sslp.name}}</a></td>
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
                                    <th @click="sortBy('strain','rgdId','strain')">RGD ID <span class="sort-indicator" v-text="sortIndicator('strain','rgdId','strain')"></span></th>
                                    <th @click="sortBy('strain','symbol','strain')">Symbol <span class="sort-indicator" v-text="sortIndicator('strain','symbol','strain')"></span></th>
                                    <th @click="sortBy('strain','symbol','strain')">Name <span class="sort-indicator" v-text="sortIndicator('strain','symbol','strain')"></span></th>
                                    <th @click="sortBy('strain','chromosome')">Chr <span class="sort-indicator" v-text="sortIndicator('strain','chromosome')"></span></th>
                                    <th @click="sortBy('strain','start')">Start <span class="sort-indicator" v-text="sortIndicator('strain','start')"></span></th>
                                    <th @click="sortBy('strain','stop')">Stop <span class="sort-indicator" v-text="sortIndicator('strain','stop')"></span></th>
                                </tr>
                                <tr v-for="record in strainData"
                                    class="record">
                                    <td>{{record.strain.rgdId}}</td>
                                    <td><a :href="strainUrl+record.strain.rgdId" class="geneList" target="_blank" v-html="record.strain.symbol"></a></td>
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
            geneData: [],
            qtlData: [],
            sslpData: [],
            strainData: [],
            geneCount: 0,
            qtlCount: 0,
            sslpCount: 0,
            strainCount: 0,
            variantCount: -1,
            showResults: false,
            searchLabel: '',
            strains: false,
            qtls: false,
            sslps: false,
            genes: false,
            loading: false,
            errors : [],
            geneUrl : "/rgdweb/report/gene/main.html?id=",
            qtlUrl : "/rgdweb/report/qtl/main.html?id=",
            sslpUrl : "/rgdweb/report/marker/main.html?id=",
            strainUrl: "/rgdweb/report/strain/main.html?id=",
            geneSortKey: '',
            geneSortAsc: true,
            qtlSortKey: '',
            qtlSortAsc: true,
            sslpSortKey: '',
            sslpSortAsc: true,
            strainSortKey: '',
            strainSortAsc: true
        },
        methods: {
            sortBy: function (type, key, nestedProp) {
                var sortKeyProp = type + 'SortKey';
                var sortAscProp = type + 'SortAsc';
                var fullKey = nestedProp ? nestedProp + '.' + key : key;
                if (this[sortKeyProp] === fullKey) {
                    this[sortAscProp] = !this[sortAscProp];
                } else {
                    this[sortKeyProp] = fullKey;
                    this[sortAscProp] = true;
                }
                var asc = this[sortAscProp];
                var numericKeys = ['rgdId', 'start', 'stop'];
                var isNumeric = numericKeys.indexOf(key) !== -1;
                var dataProp = type + 'Data';
                var sorted = this[dataProp].slice().sort(function (a, b) {
                    var valA = nestedProp ? a[nestedProp][key] : a[key];
                    var valB = nestedProp ? b[nestedProp][key] : b[key];
                    if (valA == null) valA = '';
                    if (valB == null) valB = '';
                    if (isNumeric) {
                        valA = Number(valA) || 0;
                        valB = Number(valB) || 0;
                        return asc ? valA - valB : valB - valA;
                    } else {
                        valA = String(valA).toLowerCase();
                        valB = String(valB).toLowerCase();
                        if (valA < valB) return asc ? -1 : 1;
                        if (valA > valB) return asc ? 1 : -1;
                        return 0;
                    }
                });
                this[dataProp] = sorted;
            },
            sortIndicator: function (type, key, nestedProp) {
                var fullKey = nestedProp ? nestedProp + '.' + key : key;
                if (this[type + 'SortKey'] !== fullKey) return '';
                return this[type + 'SortAsc'] ? '\u25B2' : '\u25BC';
            },
            getData: function (e) {
                e.preventDefault();
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
                v.variantCount = -1;
                v.sslps = false;
                v.genes = false;
                v.strains = false;

                this.errors = [];
                if(Number(start) > Number(stop)) {
                    this.errors.push('Start number is greater than Stop number.');
                }
                if (this.errors.length>0) {
                    v.showResults = false;
                    document.getElementById('page-container').style.display = 'none';
                }else {
                    v.searchLabel = 'Chr' + chr + ':' + Number(start).toLocaleString() + '..' + Number(stop).toLocaleString();
                    v.showResults = true;
                    axios
                        .get(this.hostName + '/rgdws/genes/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.geneData = response.data;
                            if (v.geneData.length != 0) {
                                v.geneCount = v.geneData.length;
                                v.genes = true;

                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchGeneResultId').style.display = 'block';
                                /*var geneResultsTable = document.getElementById("geneResultsTable");
                                if (geneResultsTable) {
                                    $('#geneResultsTable').tablesorter({
                                        theme: 'blue'
                                    });
                                }*/
                            }else{
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
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchQTLsResultId').style.display = 'block';
                            }else{
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
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchSSLPsResultId').style.display = 'block';
                            }else{
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
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchStrainsResultId').style.display = 'block';
                            }else{
                                document.getElementById('page-container').style.display = 'block';
                                document.getElementById('searchStrainsResultId').style.display = 'none';
                            }
                        }).catch(function (error) {
                        console.log(error)
                    });
                    // Variant count from elasticsearch
                    axios
                        .get('/rgdweb/search/variantCount.html?chr=' + chr + '&start=' + start + '&stop=' + stop + '&mapKey=' + mapKey)
                        .then(function (response) {
                            v.variantCount = response.data.count >= 0 ? response.data.count : 0;
                        }).catch(function (error) {
                            v.variantCount = 0;
                            console.log(error);
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

