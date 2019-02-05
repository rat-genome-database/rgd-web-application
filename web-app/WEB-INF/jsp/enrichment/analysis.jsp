<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<html>
<body>
<%@ include file="/common/compactHeaderArea.jsp" %>



<style>
    #t{
        border:1px solid #ddd;
        margin-top:5px;
        padding:15px;
        margin-left:1%;
        margin-right:1%;
        border-radius:4px;

    }
    #t th{
        background-color:#cce6ff;
    }
    #t tr{
        text-align:center;
    }
    #t  tr:nth-child(even) {background-color:#e6e6e6}

    .modal-body{
        width: 800px;
    }
</style>
<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
%>
<h1>Gene Enrichment</h1>
<div style="font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>
    <% if (om.getMapped().size() == 0) {
        return;

    }%>
    <%
        String firstId = null;
        String species = req.getParameter("species");
        List symbols = (List) request.getAttribute("symbols");
        Iterator symbolIt = om.getMapped().iterator();
        List<String> geneSymbols = new ArrayList<>();
        while (symbolIt.hasNext()) {
            Object obj = symbolIt.next();

            String symbol = "";
            int rgdId = -1;
            String type = "";

            if (obj instanceof Gene) {
                Gene g = (Gene) obj;
                symbol = g.getSymbol();
                if(geneSymbols.size() == 0)
                    geneSymbols.add("\""+symbol+"\"");
                else
                    geneSymbols.add("\""+symbol+"\"");
            }
        }



    %>
    <% List<String> ontologies = req.getParameterValues("o");

        for(int i=0;i< ontologies.size();i++) {
            String ont = ontologies.get(i) ;
            ontologies.remove(i);
            ontologies.add(i,"'"+ont+"'");
        }

       %>

    <br>

<div id="app">
    <div class="modal fade" id="myModal">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">

                <div class="modal-header">
                    <a @click="explore();" href="javascript:void(0);">Explore this Gene Set</a>
                </div>
                <!-- Modal body -->
                <div class="modal-body">
                    <div v-if="geneLoading">Loading...</div>
                 <table class="table table-striped">
                     <tr
                             v-for="data in geneData.geneData"
                             class="data"
                     >
                  <td>{{data.gene}}</td>
                  <td>{{data.terms}}</td>
                  </tr>
                 </table>
                </div>

                <!-- Modal footer -->
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
                </div>

            </div>
        </div>
    </div>

    <section v-if="errored">
        <p>We're sorry, we're not able to retrieve this information at the moment, please try back later</p>
    </section>

    <section v-else>


    <div style="background-color:#F8F8F8; width:1700px; border: 1px solid #346F97;" v-for="pair in pairs">

        <div v-if="loading">Loading...</div>
    <span style="font-size:22px;font-weight:700;">{{getOntologyTitle(pair.ont)}}</span><br>

        <table>
            <tr><td>
        <div style="overflow-x:auto; height:500px; width:750px; background-color:#F8F8F8; border: 1px solid #346F97;">


        <table id="t">
            <thead>
            <tr>

                <th @click="sort('term',pair.ont)"> Term <i class="fa fa-fw fa-sort"></i></th>
                <th @click="sort('count',pair.ont)">Annotated Genes <i class="fa fa-fw fa-sort"></i></th>
                <th @click="sort('pvalue',pair.ont)">p value <i class="fa fa-fw fa-sort"></i></th>
                <th @click="sort('correctedpvalue',pair.ont)">Bonferroni Correction <i class="fa fa-fw fa-sort"></i></th>
            </tr>
            </thead>
            <tbody>
            <tr
                    v-for="record in pair.info"
                    class="record"
            >

                <td>{{record.term}}({{record.acc}}) </td>
                <td  @click="getGenes(record.acc)"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
                    {{record.count}}
                </button></td>
                <td> {{record.pvalue}}</td>
                <td>{{record.correctedpvalue}}</td>
            </tr>
            </tbody>
        </table>

        </div></td>

                <td>
                    <label>Pvalue Limit</label>
                    <select v-on:change="loadChart(pair.info,pair.ont,pvalueLimit)" v-model="pvalueLimit">
                        <option v-for="value in pvalues">{{value}}</option>
                    </select>
                <div v-bind:id=pair.ont style="font-weight:700; width:800px;"></div>
            </td>   </tr>

        </table>

</div>
    </section>
</div>
<script>
    var values = {};

    var v = new Vue({
        el: '#app',
        data () {
            return {
                info:[],
                species: <%=req.getParameter("species")%>,
                ontologies: <%=ontologies%>,
                loading: true,
                geneLoading: true,
                errored: false,
                pvalues: [0.01,0.05,0.1,0.5,1],
                pvalueLimit: 0.05,
                geneData: {},
                genes: <%=geneSymbols%>,
                currentSort:'pvalue',
                currentSortDir:'asc',
                selected: 'D'
            }
        },
        methods: {
            getGenes: function (accId) {
                var modal = document.getElementById('myModal');
                var span = document.getElementsByClassName("close")[0];

                axios
                        .post('https://dev.rgd.mcw.edu/rgdws/enrichment/annotatedGenes',
                                { accId: accId,
                                  speciesTypeKey: this.species,
                                  geneSymbols:  <%=geneSymbols%>})
                        .then(response => {

                    this.geneData = response.data;

            }) .catch(error => {
                    console.log(error)

            }) .finally(() => this.geneLoading = false)
            },
            sort:function(s,ont) {
                //if s == current sort, reverse
                if(s === this.currentSort) {
                    this.currentSortDir = this.currentSortDir==='asc'?'desc':'asc';
                }
                this.currentSort = s;
                this.selected = ont;
            },

            explore: function () {
                params= new Object();

                var form = document.createElement("form");

                var method = "POST";

                form.setAttribute("method", method);
                form.setAttribute("action", "/rgdweb/enrichment/analysis.html");

                params.species="<%=req.getParameter("species")%>";
                params.genes=this.geneData.genes;
                params.mapKey="<%=req.getParameter("mapKey")%>";

                for(i=0;i<this.ontologies.length;i++) {
                    hiddenField = document.createElement("input");
                    hiddenField.setAttribute("type", "hidden");
                    hiddenField.setAttribute("name", "o");
                    hiddenField.setAttribute("value", this.ontologies[i]);
                    form.appendChild(hiddenField);
                }

                for(var key in params) {
                    var hiddenField = document.createElement("input");
                    hiddenField.setAttribute("type", "hidden");
                    hiddenField.setAttribute("name", key);
                    hiddenField.setAttribute("value", params[key]);

                    form.appendChild(hiddenField);
                }

                document.body.appendChild(form);
                form.submit();
    },
            dataLoad: function(aspect,index) {

                axios
                        .post('https://dev.rgd.mcw.edu/rgdws/enrichment/data',
                                {speciesTypeKey: <%=species%>,
                                genes: <%=geneSymbols%>,
                                aspect: aspect})
                        .then(response => {
                    this.info.push({name: aspect,
                    value: response.data}),
                        v.loadChart(response.data,aspect,0.05)


            })
                .catch(error => {
                    console.log(error)
                this.errored = true
            })
                .finally(() => this.loading = false)
            },
            getOntologyTitle: function(aspect) {
                if(aspect == "D")
                        return "Disease";
                else if(aspect == "W")
                        return "Pathway";
                else if(aspect == "P")
                        return "GO: Biological Process";
                else if(aspect == "N")
                        return "Mammalian Phenotype";
                else if(aspect == "C")
                        return "GO: Cellular Component";
                else if(aspect == "F")
                        return "GO: Molecular Function";
                else if(aspect == "E")
                        return "Chemical Interactions"
            },
            loadChart: function (info,name,value) {
                var arr = info;
                var xarray = [];
                var yarray = [];
                var y1array = [];
                for (i in arr) {
                    if (arr[i].pvalue < value) {
                        xarray.push(arr[i].term);
                        yarray.push(arr[i].count);
                        y1array.push((arr[i].pvalue));
                    }
                }

                var trace1 = {
                    x: xarray,
                    y: yarray,
                    name: 'No of genes',
                    type: 'bar'

                };

                var trace2 = {
                    x: xarray,
                    y: y1array,
                    name: 'p value',
                    yaxis: 'y2',
                    type: 'bar'
                };

                var data = [trace1, trace2];
                var layout = {
                    title: 'Gene Enrichment',
                    yaxis: {title: 'count'},
                    yaxis2: {
                        title: 'pvalue',
                        titlefont: {color: 'rgb(148, 103, 189)'},
                        tickfont: {color: 'rgb(148, 103, 189)'},
                        overlaying: 'y',
                        side: 'right'
                    },
                    xaxis: {
                        tickangle: -45
                    }
                };

                Plotly.newPlot(name, data, layout);
            },
            loadPairs: function(ont) {
                for(i=0;i<this.info.length;i++){
                    if(this.info[i].name == ont)
                    if(this.selected == ont) {
                    return this.info[i].value.sort((a,b) => {
                                let modifier = 1;
                    if(this.currentSortDir === 'desc') modifier = -1;
                    if(a[this.currentSort] < b[this.currentSort]) return -1 * modifier;
                    if(a[this.currentSort] > b[this.currentSort]) return 1 * modifier;
                    return 0;
                });}
                    else return this.info[i].value;
                }
            }
            },
        computed: {
            pairs () {

                return this.ontologies.map((ont, i) => {
                            return {
                                ont: ont,
                                info: this.loadPairs(ont)
                            }
                        });
            }

        },
        mounted() {
            for (i=0;i< this.ontologies.length; i++) {
                this.dataLoad(this.ontologies[i],i);

            }
        },


    })


</script>

</body>
</html>