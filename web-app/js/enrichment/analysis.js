function EnrichmentVue(divId,speciesKey,ont,geneSymbols,graph,host) {

    var div = '#'+divId;

    var v = new Vue({
        el: div,
        data: {
            graph: (graph == 3 || graph == 1)? true: false,
            table: (graph == 3 || graph == 2)? true: false,
            info: [],
            hostName: host,
            species: [speciesKey],
            ontology: [ont],
            allSpecies: ["Rat", "Human", "Mouse", "Dog", "Squirrel", "Bonobo", "Chinchilla"],
            allOntologies: ["RDO", "PW", "BP", "CC", "MF", "MP", "CHEBI"],
            loading: true,
            geneLoading: true,
            errored: false,
            pvalues: [0.01, 0.05, 0.1, 0.5, 1],
            pvalueLimit: 0.05,
            geneData: {},
            genes: geneSymbols,
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


            loadView: function (s) {
                this.species[0] = v.getSpeciesKey(s);
                v.selectView();


            },
            loadOntView: function (s) {
                v.loadView(s);
                v.selectView();
            },
            loadSpeciesView: function (o) {
                this.ontology[0] = o;
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
                            value: response.data
                        });
                        if (response.data.length != 0 && graph)
                            v.loadChart(response.data, aspect, 0.05);

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
                            value: response.data
                        });
                        if (response.data.length != 0 && graph)
                            v.loadChart(response.data, s, 0.05);
                        v.loading = false;
                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })

            },
            getOntologyTitle: function (aspect) {
                if (aspect == "RDO")
                    return "Disease Ontology";
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
                                return this.info[i].value.sort(function (a, b) {
                                    let modifier = 1;
                                    if (v.currentSortDir === 'desc') modifier = -1;
                                    if (a[v.currentSort] < b[v.currentSort]) return -1 * modifier;
                                    if (a[v.currentSort] > b[v.currentSort]) return 1 * modifier;
                                    return 0;
                                });
                            }
                            else return this.info[i].value;
                        } else return 0;
                    }
                }

            },
            selectView: function () {
                this.info = [];
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
                        info: v.loadPairs(ont)
                    }
                });
            },
            speciesPairs: function () {
                var v = this;
                return this.allSpecies.map(function (spec) {
                    return {
                        spec: spec,
                        info: v.loadPairs(spec)
                    }
                });
            }
        },
        mounted: function () {
            this.selectView();
        },
    })

    return v;
}