function EnrichmentVue(divId, hostname) {

    var div = '#enrichment';
    if (divId) {
        div='#' + divId;
    }

    var host = window.location.protocol + window.location.host;
    if (window.location.host.indexOf('localhost') > -1) {
        host= window.location.protocol + '//localhost:8080';
    } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host= window.location.protocol + '//dev.rgd.mcw.edu';
    }else if (window.location.host.indexOf('test.rgd') > -1) {
        host= window.location.protocol + '//test.rgd.mcw.edu';
    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host= window.location.protocol + '//pipelines.rgd.mcw.edu';
    }else {
        host=window.location.protocol + '//rest.rgd.mcw.edu';
    }

    if (hostname) {
        host=hostname;
    }

    var v = new Vue({
        el: div,
        data: {
            graph: true,
            table: true,
            info: [],
            hostName: host,
            species: [],
            ontology: [],
            allSpecies: ["Rat", "Human", "Mouse", "Dog", "Squirrel", "Bonobo", "Chinchilla","Pig"],
            allOntologies: ["RDO", "PW", "BP", "CC", "MF", "MP", "CHEBI"],
            loading: true,
            geneLoading: true,
            orthologs: false,
            errored: false,
            pvalues: [0.01, 0.05, 0.1, 0.5, 1],
            pvalueLimit: 0.05,
            geneData: {},
            genes: [],
            currentSort: 'pvalue',
            currentSortDir: 'asc',
            selectedAll: false,
            selectedOne: false,

        },
        methods: {
            getGenes: function (accId, species) {
                var modal = document.getElementById('myModal');
                var span = document.getElementsByClassName("close")[0];
                axios
                    .post(this.hostName + '/rgdws/enrichment/annotatedGenes',
                        {
                            accId: accId,
                            species: species,
                            geneSymbols: this.genes
                        })
                    .then(function (response) {
                        v.geneData = response.data;
                        v.geneLoading = false;
                    }).catch(function (error) {
                    console.log(error)
                })
            },
            sort:function(s,ont) {
                //if s == current sort, reverse
                if(s === this.currentSort) {
                    this.currentSortDir = this.currentSortDir==='asc'?'desc':'asc';
                }
                this.currentSort = s;
                this.selected = ont;
                v.loadPairs(ont);
            },
            loadView: function (s) {
                this.species = [v.getSpeciesKey(s)];
                v.selectView();


            },
            loadOntView: function (s) {
                document.getElementById(this.ontology[0]).innerHTML = "";
                v.loadView(s);
                v.selectView();
            },
            loadSpeciesView: function (o) {
                document.getElementById(this.ontology[0]).innerHTML = "";
                this.ontology = [o];
                v.selectView();
            },
            init: function (ont,species,graph,table,genes,orthologs) {
              if(document.getElementById(v.ontology) != null)
                document.getElementById(v.ontology[0]).innerHTML = "";
              v.ontology = [ont];
              v.species = [species];
              v.genes = genes;
              v.graph = graph;
              v.table = table;
              v.orthologs=orthologs;
              v.selectView();
            },
            getSpeciesKey: function (s) {
                if (s == "Rat")
                    return 3;
                else if (s == "Human")
                    return 1;
                else if (s == "Mouse")
                    return 2;
                else if (s == "Chinchilla")
                    return 4;
                else if (s == "Bonobo")
                    return 5;
                else if (s == "Dog")
                    return 6;
                else if (s == "Squirrel")
                    return 7;
                else if (s == "Pig")
                    return 9;
                else
                    return 0;
            },
            explore: function (genes) {
                params = new Object();
                var form = document.createElement("form");
                var method = "POST";
                form.setAttribute("method", method);
                form.setAttribute("action", "/rgdweb/enrichment/analysis.html");
                params.species = this.species;
                params.genes = genes;
                params.o = this.ontology;
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
            dataLoad: function (aspect, s) {
                axios
                    .post(this.hostName + '/rgdws/enrichment/data',
                        {
                            species: s,
                            genes: this.genes,
                            aspect: aspect
                        })
                    .then(function (response) {

                        v.info.push({
                            name: aspect,
                            value: response.data.enrichment,
                            genes: response.data.geneSymbols
                        });

                        if (response.data.length != 0 && (v.graph))
                        {
                            v.loadChart(response.data.enrichment, aspect, 0.05);}
                        v.loading = false;
                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })

            },
            dataLoadSpecies: function (aspect, s) {
                axios
                    .post(this.hostName + '/rgdws/enrichment/data',
                        {
                            species: s,
                            genes: this.genes,
                            aspect: aspect
                        })
                    .then(function (response) {

                        v.info.push({
                            name: s,
                            value: response.data.enrichment,
                            genes: response.data.geneSymbols
                        });
                        if (response.data.length != 0 && v.graph)
                        {
                            v.loadChart(response.data.enrichment, s, 0.05);}
                        v.loading = false;
                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })

            },
            getOntologyTitle: function (aspect) {

                if (aspect == "RDO"){
                    return "Disease Ontology"; }
                else if (aspect == "PW")
                    return "Pathway Ontology";
                else if (aspect == "BP")
                    return "GO: Biological Process Ontology";
                else if (aspect == "MP")
                    return "Phenotype Ontology";
                else if (aspect == "CC")
                    return "GO: Cellular Component Ontology";
                else if (aspect == "MF")
                    return "GO: Molecular Function Ontology";
                else if (aspect == "CHEBI")
                    return "Chemical Interactions Ontology"
            },

            loadChart: function (info, name, value) {

                var arr = info;
                var xarray = [];
                var yarray = [];
                var y1array = [];
                for (i in arr) {
                    var v = arr[i].pvalue;
                    if (value > Number(v)) {
                        xarray.push(arr[i].term);
                        yarray.push(arr[i].count);
                        y1array.push(arr[i].pvalue);
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
                    width: 700,
                    height: 600,
                    margin: {
                        l: 100,
                        r: 100,
                        b: 175,
                        t: 25,
                        pad: 1
                    },
                    title: 'Gene Enrichment',
                    titlefont: {
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
            loadPairs: function (view) {
                for (i = 0; i < this.info.length; i++) {
                    if (this.info[i].name == view) {
                        if (this.info[i].value.length != 0) {
                            if (this.selected == view) {
                                if(v.currentSort == 'count' || v.currentSort == 'term') {
                                    return this.info[i].value.sort(function (a, b) {
                                        let modifier = 1;
                                        if (v.currentSortDir === 'desc') modifier = -1;
                                        if (a[v.currentSort] < b[v.currentSort]) return -1 * modifier;
                                        if (a[v.currentSort] > b[v.currentSort]) return 1 * modifier;
                                        return 0;
                                    });
                                }
                                else
                                    return this.info[i].value.sort(function (a, b) {
                                    let modifier = 1;
                                    if (v.currentSortDir === 'desc') modifier = -1;
                                    if (Number(a[v.currentSort]) < Number(b[v.currentSort])) return -1 * modifier;
                                    if (Number(a[v.currentSort]) > Number(b[v.currentSort])) return 1 * modifier;
                                    return 0;
                                });
                            }
                            else return this.info[i].value;
                        } else return 0;
                    }
                }

            },
            loadGenes: function(view){

                for (i = 0; i < this.info.length; i++) {
                    if (this.info[i].name == view) {
                        return this.info[i].genes;
                    }
                }
            },
            selectView: function () {
                this.info = [];
                this.loading=true;
                this.errored = false;

                if (this.species[0] != 0) {
                    this.selectedAll = false;
                    this.selectedOne = true;

                    this.dataLoad(this.ontology[0], this.species[0]);

                } else {
                    this.selectedAll = true;
                    this.selectedOne = false;

                    for (i = 0; i < this.allSpecies.length; i++) {
                        this.dataLoadSpecies(this.ontology[0], this.allSpecies[i]);
                    }
                }
            }

        },
        computed: {
            pairs: function () {
                var v = this;
                return this.ontology.map(function (ont) {

                    return {
                        ont: ont,
                        info: v.loadPairs(ont),
                        genes: v.loadGenes(ont)
                    }
                });
            },
            speciesPairs: function () {
                var v = this;
                return this.allSpecies.map(function (spec) {
                    return {
                        spec: spec,
                        info: v.loadPairs(spec),
                        genes: v.loadGenes(spec)
                    }
                });
            }
        },
    })

    return v;
}