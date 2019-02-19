<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<html>
<body style="background-color: white">
<%@ include file="/common/compactHeaderArea.jsp" %>

<style>
    #t{
        border:1px solid #ddd;
        margin-top:2px;
        border-radius:2px;
        width: 100%;
        text-align: center;
    }
    #t th{
        max-width: 40px;
        background-color:#2865a3;
        color: white;
        padding: 5px;
    }
    #t td{
        max-width: 40px;
        padding: 5px;
    }
    #t  tr:nth-child(even) {background-color:#E6E6FA}
    .modal-body{
        width: 800px;
    }
    .heading
    {
        margin-top: 2px;
        text-align: center;
        height: 80px;
        background: linear-gradient(135deg,#2655c1,#372f7f,#2655c1,#372f7f);
        color: #fff;
        font-weight: bold;
        line-height: 80px;
    }
    .btnSubmit
    {
        border:none;
        border-radius:1.5rem;
        padding: 3%;
        width: 25%;
        cursor: pointer;
        background: #2655c1;
        color: #fff;
    }

    .btn-primary:active {
       background-color: green;
        }
</style>
<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
%>
<h1 class="heading">Gene Enrichment</h1>
<div style="color:#2865a3; font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>
<% if (om.getMapped().size() == 0) {
    return;
}%>
<%
    String firstId = null;
    String species = req.getParameter("species");
    List symbols = (List) request.getAttribute("genes");
    String ontology = "";
    ontology = "\""+req.getParameter("o")+"\"";
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



<br>

<div id="app" >
    <div class="modal fade" id="myModal">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">

                <div class="modal-header">
                    <a @click="explore(geneData.genes);" href="javascript:void(0);">Explore this Gene Set</a>
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

    <table>
        <tr>
        <td><button type="button" v-bind:class="{'btn':true, 'btn-sm':true, 'btn-primary': selectedOne, 'btn-success': selectedAll}" @click="loadView('All')">All</button>&nbsp;&nbsp;</td>
            <td v-for="s in allSpecies"><button type="button" v-bind:class="{'btn':true, 'btn-sm':true, 'btn-primary': true, 'btn-success': getSpeciesKey(s)== species}" @click="loadOntView(s)">{{s}}</button>&nbsp;&nbsp;</td>
        </tr>
  </table>

    <table><tr>
        <td v-if="selectedAll" v-for="o in allOntologies"><button type="button" v-bind:class="{'btn':true, 'btn-primary':true, 'btn-sm':true, 'btn-success': o==ontology}" @click="loadSpeciesView(o)">{{getOntologyTitle(o)}}</button>&nbsp;&nbsp;</td>
    </tr></table>
    <section v-if="errored">
        <p>We're sorry, we're not able to retrieve this information at the moment, please try back later</p>
    </section>

    <section v-else>
        <section v-if="selectedAll" >
             <%@ include file="species.jsp" %>
        </section>
        <section v-else>
            <%@ include file="terms.jsp" %>
        </section>
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
                ontology: <%=ontology%>,
                allSpecies:["Rat","Human","Mouse","Dog","Squirrel","Bonobo","Chinchilla"],
                allOntologies:["D","W","P","C","F","N","E"],
                loading: true,
                geneLoading: true,
                errored: false,
                pvalues: [0.01,0.05,0.1,0.5,1],
                pvalueLimit: 0.05,
                geneData: {},
                genes: <%=geneSymbols%>,
                currentSort:'pvalue',
                currentSortDir:'asc',
                selectedAll: false,
                selectedOne: false,
            }
        },
        methods: {
            getGenes: function (accId,species) {
                var s = this.species;
                if(species != 0)
                      s = v.getSpeciesKey(species);
                var modal = document.getElementById('myModal');
                var span = document.getElementsByClassName("close")[0];
                axios
                        .post('https://dev.rgd.mcw.edu/rgdws/enrichment/annotatedGenes',
                                { accId: accId,
                                    speciesTypeKey: s,
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

            loadView: function(s) {
                this.species = v.getSpeciesKey(s);
                if(this.species == 0) {
                    this.selectedAll = true;
                    this.selectedOne = false;
                } else {
                    this.selectedAll = false;
                    this.selectedOne = true;
                }


            },
            loadOntView: function(s) {
                v.loadView(s);
                v.explore(this.genes);
            },
            loadSpeciesView: function(o){
                this.ontology = o;
                v.explore(this.genes);
            },
            getSpeciesKey: function(s){

                if(s == "Rat")
                    return <%=SpeciesType.RAT%> ;
                else if(s == "Human")
                    return <%=SpeciesType.HUMAN%> ;
                else if(s == "Mouse")
                    return <%=SpeciesType.MOUSE%>;
                else if(s == "Chinchilla")
                    return <%=SpeciesType.CHINCHILLA%>;
                else if(s == "Bonobo")
                    return <%=SpeciesType.BONOBO%>;
                else if(s == "Dog")
                    return <%=SpeciesType.DOG%>;
                else if(s == "Squirrel")
                    return <%=SpeciesType.SQUIRREL%>;
                else
                    return <%=SpeciesType.ALL%>;
            },
            explore: function (genes) {


                params= new Object();
                var form = document.createElement("form");
                var method = "POST";
                form.setAttribute("method", method);
                form.setAttribute("action", "/rgdweb/enrichment/analysis.html");
                params.species=this.species;
                params.genes=genes;
                params.mapKey="<%=req.getParameter("mapKey")%>";
                params.o= this.ontology;
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
            dataLoad: function(aspect,s) {

                axios
                        .post('https://dev.rgd.mcw.edu/rgdws/enrichment/data',
                                {speciesTypeKey: s,
                                    genes: this.genes,
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
            dataLoadSpecies: function(aspect,s,key) {

                axios
                        .post('https://dev.rgd.mcw.edu/rgdws/enrichment/data',
                                {speciesTypeKey: key,
                                    genes: this.genes,
                                    aspect: aspect})
                        .then(response => {
                    this.info.push({name: s,
                    value: response.data}),
                        v.loadChart(response.data,s,0.05)
            })
                .catch(error => {
                    console.log(error)
                this.errored = true
            })
                .finally(() => this.loading = false)
            },
            getOntologyTitle: function(aspect) {
                if(aspect == "D")
                    return "Disease Ontology";
                else if(aspect == "W")
                    return "Pathway Ontology";
                else if(aspect == "P")
                    return "GO: Biological Process Ontology";
                else if(aspect == "N")
                    return "Phenotype Ontology";
                else if(aspect == "C")
                    return "GO: Cellular Component Ontology";
                else if(aspect == "F")
                    return "GO: Molecular Function Ontology";
                else if(aspect == "E")
                    return "Chemical Interactions Ontology"
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
                    autosize: false,
                    width: 800,
                    height: 600,
                    margin: {
                        l: 100,
                        r: 100,
                        b: 175,
                        t: 25,
                        pad: 1
                    },
                    title: 'Gene Enrichment',
                    titlefont:{
                      size: 18
                    },
                    legend: {
                        x: 0,
                        y: 1.15,
                        bgcolor: 'rgba(255, 255, 255, 0)',
                        bordercolor: 'rgba(255, 255, 255, 0)'
                    },
                    yaxis: {
                        zeroline: true,
                        zerolinecolor: '#969696',
                        zerolinewidth: 4,
                        title: 'Gene Count'
                    },
                    yaxis2: {
                        zeroline: true,
                        zerolinecolor: '#969696',
                        zerolinewidth: 4,
                        title: 'pvalue',
                        titlefont: {color: 'rgb(148, 103, 189)'},
                        tickfont: {color: 'rgb(148, 103, 189)'},
                        overlaying: 'y',
                        side: 'right',
                        automargin: true,
                    },
                    xaxis: {
                        tickfont: {
                            size: 10,
                            color: 'rgb(107, 107, 107)'
                        },
                        tickangle: -45
                    }
                };
                Plotly.newPlot(name, data, layout);
            },
            loadPairs: function(view) {

                for(i=0;i<this.info.length;i++){
                    if(this.info[i].name == view) {
                        if(this.info[i].value.length != 0) {
                            if (this.selected == view) {
                                return this.info[i].value.sort((a, b) => {
                                            let modifier = 1;
                                if (this.currentSortDir === 'desc') modifier = -1;
                                if (a[this.currentSort] < b[this.currentSort]) return -1 * modifier;
                                if (a[this.currentSort] > b[this.currentSort]) return 1 * modifier;
                                return 0;
                            });
                            }
                            else return this.info[i].value;
                        }else return 0;
                    }
                }

            }

        },
        computed: {
            pairs () {
                return this.allOntologies.map((ont, i) => {
                            return {
                                ont: ont,
                                info: this.loadPairs(ont)
                            }
                        });
            },
            speciesPairs() {
                return this.allSpecies.map((spec, i) => {
                            return {
                                spec: spec,
                                info: this.loadPairs(spec)
                            }
                        });
            }


        },
        mounted() {
            this.info = [];

            if(this.species != 0) {
                this.selectedAll = false;
                this.selectedOne = true;
                for (i = 0; i < this.allOntologies.length; i++) {
                    console.log(this.allOntologies[i]);
                    this.dataLoad(this.allOntologies[i],this.species);
                }
            } else {
                this.selectedAll = true;
                this.selectedOne = false;

                for (i = 0; i < this.allSpecies.length; i++) {
                    var key = this.getSpeciesKey(this.allSpecies[i]);
                    this.dataLoadSpecies(this.ontology, this.allSpecies[i], key);
                }
            }

        },
    })
</script>

</body>
</html>