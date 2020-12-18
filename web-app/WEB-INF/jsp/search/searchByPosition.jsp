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
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular.js"></script>
<script type="text/javascript" src="/rgdweb/my/my.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" type="text/css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" type="text/css">

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
    cursor:pointer;
    padding: 5px;
}
.t td{
max-width: 30px;
min-width: 20px;
padding: 5px;

}
.t  tr:nth-child(odd) {background-color: #f2f2f2}
.t tr:hover {
background-color: #daeffc;
}

.bordereddiv{
    border-style: ridge;
    padding: 20px;
    border-color: cornflowerblue;
    border-width: thin ;
    margin: 10px;
}

.downloadbtn {
    background-color: DodgerBlue;
    border: none;
    color: white;
    padding: 12px 30px;
    cursor: pointer;
    font-size: 20px;
}

/* Darker background on mouse-over */
.downloadbtn:hover {
    background-color: RoyalBlue;
}

label{
    font-size: large;
}

.arrow_down {
    background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB8AAAAaCAYAAABPY4eKAAAAAXNSR0IArs4c6QAAAvlJREFUSA29Vk1PGlEUHQaiiewslpUJiyYs2yb9AyRuJGm7c0VJoFXSX9A0sSZN04ULF12YEBQDhMCuSZOm1FhTiLY2Rky0QPlQBLRUsICoIN/0PCsGyox26NC3eTNn3r3n3TvnvvsE1PkwGo3yUqkkEQqFgw2Mz7lWqwng7ztN06mxsTEv8U0Aam5u7r5EInkplUol/f391wAJCc7nEAgE9Uwmkzo4OPiJMa1Wq6cFs7Ozt0H6RqlUDmJXfPIx+qrX69Ti4mIyHA5r6Wq1egND+j+IyW6QAUoul18XiUTDNHaSyGazKcZtdgk8wqhUKh9o/OMvsVgsfHJy0iWqVrcQNRUMBnd6enqc9MjISAmRP3e73T9al3XnbWNjIw2+KY1Gc3imsNHR0YV4PP5+d3e32h3K316TySQFoX2WyWR2glzIO5fLTSD6IElLNwbqnFpbWyO/96lCoai0cZjN5kfYQAYi5H34fL6cxWIZbya9iJyAhULBHAqFVlMpfsV/fHxMeb3er+Vy+VUzeduzwWC45XA4dlD/vEXvdDrj8DvURsYEWK3WF4FA4JQP9mg0WrHZbEYmnpa0NxYgPVObm5teiLABdTQT8a6vrwdRWhOcHMzMzCiXlpb2/yV6qDttMpkeshEzRk4Wo/bfoe4X9vb2amzGl+HoXNT29vZqsVi0sK1jJScG+Xx+HGkL4Tew2TPi5zUdQQt9otPpuBk3e0TaHmMDh1zS7/f780S0zX6Yni+NnBj09fUZUfvudDrNZN+GkQbl8Xi8RLRtHzsB9Hr9nfn5+SjSeWUCXC7XPq5kw53wsNogjZNohYXL2EljstvtrAL70/mVaW8Y4OidRO1/gwgbUMvcqGmcDc9aPvD1gnTeQ+0nmaInokRj0nHh+uvIiVOtVvt2a2vLv7Ky0tL3cRTXIcpPAwMDpq6R4/JXE4vFQ5FI5CN+QTaRSFCYc8vLy1l0rge4ARe5kJ/d27kYkLXoy2Jo4C7K8CZOsEBvb+9rlUp1xNXPL7v3IDwxvPD6AAAAAElFTkSuQmCC')
}
.arrow_up {
    background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAaCAYAAACgoey0AAAAAXNSR0IArs4c6QAAAwpJREFUSA21Vt1PUmEYP4dvkQ8JFMwtBRocWAkDbiqXrUWXzU1rrTt0bdVqXbb1tbW16C9IBUSmm27cODdneoXjputa6069qwuW6IIBIdLvdaF4OAcOiGeDc87zPs/vd57P96WpFq7p6enbGo1mjKZpeTabjU1MTCRagGnOZHFxcXxtbe1XKpUq7+zslJeXl//Mz8+Hy+Uy3RxSE9qTk5M3otFooVQqgef4Wl9f343FYoEmoISrxuNxFX5f9vb2jhn/PxUKhfLS0tIPfFifUESRUMV8Pv/M6XReRm5rTGQyGeXxeGxYe1ezeBpBOBx2rKysbO7v79d4Wy3Y2Nj4GQqFbgnhaugxwiuGJx99Pp9FLBbXxYTXvTqd7v3MzIy6riIWGxJnMpl7AwMD14xGYyMsSq1WUyQdUqn0eSPlusQIsbGrq+vl4OCgvhFQZd1utyv1en0gEolcqsi47nWJlUrlG5fLZVcoFFy2nDKSDpIWlUoVTCQSEk4lCHmJMZ2GTCbTiMVikfIZ88l7enoos9l8dXt7+z6fDicxSJUokqDX6xXcl2wCROoc0vQCWL3sNfLOSdzR0fHY4XC4tVotl40gmVwup9xuN4OQv+UyqCFGH9rg7SOGYVRcBs3IEG4J0nVnamrqOtvuBDGGgQg9+wHFcVEi4a0LNkbdd6TrPKo8ODc311mteIIYjT/a398/jK+s1jnVM0kXoufCFvq0GuiIGEVgQIhfoygM1QrteEa9dAL7ITiYCt4RMabOK5AyKKzKWtvupLcRciu8D5J0EuDDPyT/Snd39yh6VtY2NhYQSR9G79Ds7OxdskRjEyAufvb7/cPoO5Z6e1+xtVKrq6vfcFzyi/A3ZrPZ3GdNSlwgo5ekE4X2RIQGf2C1WlufFE0GBeGWYQ8YERWLxQtnUVB830MKLZfL9RHir8lkssCn2G751tZWEWe03zTKm15YWPiEiXXTYDB0Ig/t7yd8PRws4EicwWHxO4jHD8/C5HiTTqd1BwcHFozKU89origB+y/kmzgYpgOBQP4fGmUiZmJ+WNgAAAAASUVORK5CYII=')
}
.arrow {
    float: right;
    width: 12px;
    height: 15px;
    background-repeat: no-repeat;
    background-size: contain;
    background-position-y: bottom;
}
</style>

<script>

    function toggleResults (type) {
        if(type == 'result')
            document.getElementById("searchByPositionResultsId").style.display="block";
        if(type == 'gene')
            document.getElementById("searchGeneResultId").style.display="block";
        if(type == 'qtls')
            document.getElementById("searchQTLsResultId").style.display="block";
        if(type == 'sslps')
            document.getElementById("searchSSLPsResultId").style.display="block";
    }


</script>
<%
    String pageHeader="Search for genes, SSLPs and QTLs by position";
    String pageTitle="Search By Position";    String headContent="";
    String pageDescription = "Search all objects using Position";
%>
<%@ include file="/common/headerarea.jsp"%>

<!--Tablesorter-->
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css?v=1'>
<link href="/rgdweb/css/report.css?v=2" rel="stylesheet" type="text/css" />
<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>

<div id="search">
    <div align="left" class="bordereddiv" style="display: inline-block;overflow: auto;" >
        <table>
            <tr>
                <td>
                <label for="species" style="color: #24609c; font-weight: bold;">Species: </label>
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
                    <label for="mapKey" style="color: #24609c; font-weight: bold;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Assembly: </label>
                    <select id="mapKey" name="mapKey" v-model="mapKey">
                        <option v-for="value in maps" :value="value.key">{{value.name}}</option>
                    </select>
                </td>
                <td>
                    <label for="chr" style="color: #24609c; font-weight: bold;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Chromosome: </label>
                    <select id="chr" name="chr" v-model="chr">
                        <option v-for="value in chromosomes" :value="value">{{value}}</option>
                    </select>
                </td>
                <td>
                    <label for="start" style="color: #24609c; font-weight: bold;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Start: </label>
                    <input id="start" type="text" name="start" />
                </td>
                <td>
                    <label for="stop" style="color: #24609c; font-weight: bold;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stop: </label>
                    <input id="stop" type="text" name="stop"/>
                </td>
                <td>
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="submit" name="submit" @click="getData()" >
                            <i class="fa fa-search" ></i>
                        </button>&nbsp;&nbsp;
                    </div>
                </td>
                <!--<td>
                    <button type="submit" @click="" class="btn btn-primary reset"> Reset </button>
                </td>-->
            </tr>
        </table>
    </div>

    <br><br><br>
    <div id="page-container" v-if="genes">
        <div id="left-side-wrap" style="margin: 10px" >
            <nav id="searchByPositionNavSideBarId" class="navbar report-page-grey bordereddiv" style="overflow-y: hidden; position: fixed;width:10%; padding: 10px">
                <ul class="navbar-nav">
                    <li class="nav-item"><a class="nav-link active" href="#" style="font-size: x-large;color: dodgerblue">Results</a></li>
                    <br>
                    <li class="nav-item" v-if="genes"><a href="#searchGeneResultId" class="associationsToggle" style="font-size: large;" onclick="toggleResults('gene');">Genes</a></li>
                    <br>
                    <li class="nav-item" v-if="qtls"><a href="#searchQTLsResultId" class="associationsToggle" style="font-size: large;">QLTs</a></li>
                    <br>
                    <li class="nav-item" v-if="sslps"><a href="#searchSSLPsResultId" class="associationsToggle" style="font-size: large;">SSLPs</a></li>
                </ul>
            </nav>
        </div>
        <div id="content-wrap">
            <table width="100%" border="0">
                <tr><!--Results summary section-->
                    <td>
                    <div v-if="genes" class="bordereddiv" id= "searchByPositionResultsId" style="width: 50%;padding: 10px" >
                        <div style="display: flex; flex-flow: row; padding: 10px">
                            <div style="padding: 5px;width: 70%"><h2>Total Objects in the selected region: </h2></div>
                            <div style="padding: 5px;width: 50%">
                                <button class="downloadbtn" @click="download('all')"><i class="fa fa-download" style="align-self: auto" title="Download All" ></i></button>
                            </div>
                            <div style="padding: 10px; width:70%">
                                <table style="border-style: dotted" class="t">
                                    <tr>
                                        <td style="background-color: powderblue;font-size: large">Genes - {{geneCount}}</td>
                                        <td><button class="downloadbtn" @click="download('gene')" ><i class="fa fa-download" style="align-self: auto" title="Download Genes"></i></button>
                                        </td>
                                    </tr>
                                    <tr><td style="background-color: whitesmoke;font-size: large">QTLs - {{qtlCount}}</td>
                                        <td><button class="downloadbtn" @click="download('qtl')"><i class="fa fa-download" style="align-self: auto" title="Download QTLs"></i></button>
                                        </td>
                                    </tr>
                                    <tr><td style="background-color: powderblue;font-size: large">SSLPs - {{sslpCount}}</td>
                                        <td><button class="downloadbtn" @click="download('sslp')"><i class="fa fa-download" style="align-self: auto" title="Download SSLPs"></i></button>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div></td>
                </tr>
                <tr><!--Genes section-->
                    <td>
                    <div v-if="genes" class="bordereddiv" id="searchGeneResultId">
                        <div style="display: flex;flex-flow: row;padding: 10px">
                            <div style="padding: 10px">
                                <h2>Genes</h2>
                            </div>.
                            <div style="padding: 10px">
                                <button class="downloadbtn" @click="download('gene')" ><i class="fa fa-download" style="align-self: auto" title="Download Genes"></i></button>
                            </div>
                            <div style="padding: 10px" align="right">
                                <img src="/rgdweb/common/images/tools-white-50.png" style="cursor:hand; border: 2px solid black;" border="0" ng-click="rgd.showTools('geneList',3,360,1,'')" />
                            </div>
                        </div>
                        <table id="geneResultsTable" class="tablesorter tablesorter-blue">
                            <tr class="headerRow tablesorter-headerRow" >
                                <th>RGD ID</th>
                                <th>Type</th>
                                <th>Symbol</th>
                                <th>Name</th>
                                <th>Chr</th>
                                <th>Start</th>
                                <th>Stop</th>
                            </tr>
                            <tr v-for="record in geneData">
                                <td>{{record.gene.rgdId}} </td>
                                <td>{{record.gene.type}}</td>
                                <td class="geneList"> {{record.gene.symbol}}</td>
                                <td>{{record.gene.name}}</td>
                                <td>{{record.chromosome}}</td>
                                <td>{{record.start}}</td>
                                <td>{{record.stop}}</td>
                            </tr>
                        </table>
                    </div></td>
                </tr>
                <tr><!--QTLs Section-->
                    <td>
                    <div v-if="qtls" class="bordereddiv" id="searchQTLsResultId">
                        <div style="display: flex;flex-flow: row;padding: 10px">
                            <div style="padding: 10px">
                                <h2>QTLs</h2>
                            </div>
                            <div style="padding: 10px">
                                <button class="downloadbtn" @click="download('qtl')"><i class="fa fa-download" style="align-self: auto" title="Download QTLs"></i></button>
                            </div>
                        </div>

                        <table  class="tablesorter tablesorter-blue hasFilters" role="grid">
                            <tr class="headerRow tablesorter-headerRow" role="row">
                                <th>RGD ID</th>
                                <th>Symbol</th>
                                <th>Name</th>
                                <th>Chr</th>
                                <th>Start</th>
                                <th>Stop</th>
                            </tr>
                            <tr v-for="record in qtlData"
                                class="record">
                                <td>{{record.qtl.rgdId}} </td>
                                <td> {{record.qtl.symbol}}</td>
                                <td>{{record.qtl.name}}</td>
                                <td>{{record.chromosome}}</td>
                                <td>{{record.start}}</td>
                                <td>{{record.stop}}</td>
                            </tr>
                        </table>
                    </div></td>
                </tr>
                <tr><!--SSLPs Section-->
                    <td>
                    <div v-if="sslps" class="bordereddiv" id="searchSSLPsResultId">
                            <div style="display: flex;flex-flow: row;padding: 10px">
                                <div style="padding: 10px">
                                    <h2>SSLPs</h2>
                                </div>
                                <div style="padding: 10px">
                                    <button class="downloadbtn" @click="download('sslp')"><i class="fa fa-download" style="align-self: auto" title="Download SSLPs"></i></button>
                                </div>
                            </div>

                            <table class="tablesorter tablesorter-blue hasFilters" role="grid">
                                <tr class="headerRow tablesorter-headerRow" role="row">
                                    <th>RGD ID</th>
                                    <th>Symbol</th>
                                    <th>Name</th>
                                    <th>Chr</th>
                                    <th>Start</th>
                                    <th>Stop</th>
                                </tr>
                                <tr v-for="record in sslpData"
                                    class="record">
                                    <td>{{record.sslp.rgdId}} </td>
                                    <td> {{record.sslp.name}}</td>
                                    <td>{{record.sslp.name}}</td>
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
                $('#geneResultsTable').addClass('tablesorter');
                $('#geneResultsTable')
                    .tablesorter({
                        theme: 'blue',
                        widgets: ['zebra']
                    })
            },
            setMaps: function(species) {
                var mapKey = 0;
                v.maps = [];
                if(species != this.species )
                    species = species.options[species.selectedIndex].value;
                axios
                        .get(this.hostName + '/rgdws/maps/'+species)
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
            }
        }
    });
    v.species = 3;
    v.setMaps(3);
</script>

<%@ include file="/common/footerarea.jsp"%>

