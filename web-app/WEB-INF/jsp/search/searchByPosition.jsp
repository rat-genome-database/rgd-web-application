<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery.jcarousel.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<style>
.t{
border:1px solid #ddd;
border-radius:2px;
width: 100%;
text-align: center;
font-size: 12px;

}
.t th{
background: rgb(246,248,249); /* Old browsers */
background: -moz-linear-gradient(top, rgba(246,248,249,1) 0%, rgba(229,235,238,1) 50%, rgba(215,222,227,1) 51%, rgba(245,247,249,1) 100%); /* FF3.6-15 */
background: -webkit-linear-gradient(top, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* Chrome10-25,Safari5.1-6 */
background: linear-gradient(to bottom, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=0 );
}
.t td{
max-width: 15px;
min-width: 5px;
padding: 2px;

}
.t  tr:nth-child(odd) {background-color: #f2f2f2}
.t tr:hover {
background-color: #daeffc;
}

</style>
<%
    String pageHeader="Search for genes, SSLPs and QTLs by position";
    String pageTitle="Search By Position";
    String headContent="";
    String pageDescription = "Search all objects using Position";
%>
<%@ include file="/common/headerarea.jsp"%>
<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>




<div id="search">
<div class="container">


        <table>
            <tr><td>
            <label for="species" style="color: #24609c; font-weight: bold;">Select a species:</label>
            <select id="species" name="species" v-model="species" onchange="v.setMaps(species,source)">
                <option value="3" selected="true">Rat</option>
                <option  value="2">Mouse</option>
                <option  value="1">Human</option>
                <option  value="4">Chinchilla</option>
                <option  value="5">Bonobo</option>
                <option  value="6">Dog</option>
                <option  value="7">Squirrel</option>
                <option value="9">Pig</option>
            </select>
            </td>
                <td>
                    <label for="source" style="color: #24609c; font-weight: bold;">Source:</label>
                    <select id="source" name="source" v-model="source" onchange="v.setMaps(species,source)">
                        <option>NCBI</option>
                        <option>Ensembl</option>
                    </select>
                </td>
                <td>
                    <label for="mapKey" style="color: #24609c; font-weight: bold;">Assembly:</label>
                    <select id="mapKey" name="mapKey" v-model="mapKey">
                        <option v-for="value in maps" :value="value.key">{{value.name}}</option>
                    </select>
                </td>

    <td>

        <label for="chr" style="color: #24609c; font-weight: bold;">Chromosome:</label>
        <select id="chr" name="chr" v-model="chr">
            <option v-for="value in chromosomes" :value="value">{{value}}</option>
        </select>
        </td><td>
            <label for="start" style="color: #24609c; font-weight: bold;">Start:</label>
            <input id="start" type="text" name="start" />

        </td><td>
            <label for="stop" style="color: #24609c; font-weight: bold;">Stop:</label>
            <input id="stop" type="text" name="stop"/>
        </td>
        <td>
            <input type="submit" name="submit" class="btn btn-info btn-md" value="Search" @click="getData()">
        </td>
        </tr>

    </table>

</div>
<div v-if="genes">
    <h3>Total Objects in the selected region: </h3>
    <table  class="t">
        <tr>
    <th @click="download('gene')">Genes - {{geneCount}}</th></tr>
   <tr> <th @click="download('qtl')">QTLs - {{qtlCount}}</th></tr>
   <tr> <th @click="download('sslp')">SSLPs - {{sslpCount}}</th></tr>
    <button @click="download('all')">Download All Objects</button>

        </table>
</div>
    <div v-if="genes">

<h3>Genes</h3>
        <button @click="download('gene')">Download Genes</button>
                <table  class="t">
                    <tr>
                        <th>RGD ID</th>
                        <th>Type</th>
                        <th>Symbol</th>
                        <th>Name</th>
                        <th>Chr</th>
                        <th>Start</th>
                        <th>Stop</th>
                    </tr>
                    <tr
                            v-for="record in geneData"
                            class="record"
                    >

                        <td>{{record.gene.rgdId}} </td>
                        <td>{{record.gene.type}}</td>
                        <td> {{record.gene.symbol}}</td>
                        <td>{{record.gene.name}}</td>
                        <td>{{record.chromosome}}</td>
                        <td>{{record.start}}</td>
                        <td>{{record.stop}}</td>
                    </tr>
                </table>
    </div>
    <div v-if="qtls">

    <h3>QTLs</h3>
        <button @click="download('qtl')">Download QTLs</button>
    <table  class="t">
        <tr>
            <th>RGD ID</th>
            <th>Symbol</th>
            <th>Name</th>
            <th>Chr</th>
            <th>Start</th>
            <th>Stop</th>
        </tr>
        <tr
                v-for="record in qtlData"
                class="record"
        >

            <td>{{record.qtl.rgdId}} </td>
            <td> {{record.qtl.symbol}}</td>
            <td>{{record.qtl.name}}</td>
            <td>{{record.chromosome}}</td>
            <td>{{record.start}}</td>
            <td>{{record.stop}}</td>
        </tr>
    </table>
    </div>
    <div v-if="sslps">

    <h3>SSLPs</h3>
        <button @click="download('sslp')">Download SSLPs</button>
    <table class="t">
        <tr>
        <th>RGD ID</th>
        <th>Symbol</th>
        <th>Name</th>
            <th>Chr</th>
            <th>Start</th>
            <th>Stop</th>
        </tr>
        <tr
                v-for="record in sslpData"
                class="record"
        >

            <td>{{record.sslp.rgdId}} </td>
            <td> {{record.sslp.name}}</td>
            <td>{{record.sslp.name}}</td>
            <td>{{record.chromosome}}</td>
            <td>{{record.start}}</td>
            <td>{{record.stop}}</td>
        </tr>
    </table>
    </div>
</div>
<script>
    var div = '#search';
    var host = window.location.protocol + window.location.host;
    if (window.location.host.indexOf('localhost') > -1) {
        host= window.location.protocol + '//localhost';
    } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host= window.location.protocol + '//dev.rgd.mcw.edu';
    }else if (window.location.host.indexOf('test.rgd') > -1) {
        host= window.location.protocol + '//test.rgd.mcw.edu';
    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host= window.location.protocol + '//pipelines.rgd.mcw.edu';
    }else {
        host=window.location.protocol + '//rest.rgd.mcw.edu';
    }
host = 'https://dev.rgd.mcw.edu';
    var v = new Vue({
        el: div,
        data: {
            hostName: host,
            maps: [],
            chromosomes: [],
            species: 3,
            source: "NCBI",
            chr: 1,
            mapKey: "Rnor_6.0",
            geneData: {},
            qtlData: {},
            sslpData: {},
            geneCount: 0,
            qtlCount: 0,
            sslpCount: 0,
            qtls: false,
            sslps: false,
            genes: false,
            loading: false
        },
        methods: {
            getData: function () {
                var chr = document.getElementById('chr').value;
                var txt = document.getElementById('start').value;
                var start = txt.replace(/,/g,"");
                start = Number(start);
                txt =document.getElementById('stop').value;
                var stop = txt.replace(/,/g,"");
                stop = Number(stop);
                var mapKey = document.getElementById('mapKey').value;

                v.qtls = false;
                v.geneCount = 0;
                v.qtlCount = 0;
                v.sslpCount = 0;
                v.sslps = false;
                v.genes= false;
                axios
                        .get(this.hostName + '/rgdws/genes/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.geneData = response.data;
                            if(v.geneData.length != 0) {
                                v.geneCount = v.geneData.length;
                                v.genes = true;
                            }
                        }).catch(function (error) {
                    console.log(error)
                });
                axios
                        .get(this.hostName + '/rgdws/qtls/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.qtlData = response.data;
                            if(v.qtlData.length != 0) {
                                v.qtlCount = v.qtlData.length;
                                v.qtls = true;
                            }
                        }).catch(function (error) {
                    console.log(error)
                });
                axios
                        .get(this.hostName + '/rgdws/sslps/mapped/' + chr + '/' + start + '/' + stop + '/' + mapKey)
                        .then(function (response) {
                            v.sslpData = response.data;
                            if(v.sslpData.length != 0) {
                                v.sslpCount = v.sslpData.length;
                                v.sslps = true;
                            }
                        }).catch(function (error) {
                    console.log(error)
                });
            },
            setMaps: function(species,source) {
                var mapKey = 0;
                v.maps = [];
                if(species != this.species )
                    species = species.options[species.selectedIndex].value;
                if(source != this.source )
                    source = source.options[source.selectedIndex].value;
                axios
                        .get(this.hostName + '/rgdws/maps/'+species+'/'+source)
                        .then(function (response) {
                            v.maps = (response.data);
                            mapKey = v.maps[0].key;
                            v.setChromosomes(mapKey);
                        }).catch(function (error) {
                    console.log(error)
                });


            },
            setChromosomes: function(mapKey) {
                if(v.mapKey == 'Rnor_6.0')
                    mapKey = 360;
                axios
                        .get(this.hostName + '/rgdws/maps/chr/' + mapKey)
                        .then(function (response) {
                            v.chromosomes = response.data;
                        }).catch(function (error) {
                    console.log(error)
                });
            },
            setSource: function(mapKey) {
                if(mapKey != this.mapKey )
                    mapKey = mapKey.options[mapKey.selectedIndex].value;
            },
            download: function(objType) {
              
                params = new Object();
                var form = document.createElement("form");
                var method = "POST";
                form.setAttribute("method", method);
                form.setAttribute("action", "/rgdweb/search/searchByPosition.html?fmt=csv");

                var txt = document.getElementById('start').value;
                var start = txt.replace(/,/g,"");
                txt =document.getElementById('stop').value;
                var stop = txt.replace(/,/g,"");


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
            },
        }
    });
    v.species = 3;
    v.source='NCBI';
    v.setMaps(3,"NCBI");
</script>
<%@ include file="/common/footerarea.jsp"%>

