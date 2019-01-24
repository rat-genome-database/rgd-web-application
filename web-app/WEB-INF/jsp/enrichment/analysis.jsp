<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>


<html>
<body>
<%@ include file="/common/compactHeaderArea.jsp" %>


<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
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
</style>
<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
%>
    <div id="new-nav" style="padding: 5px; border: 1px solid black; background-color:#F0F6F9">Cross Analysis: Select terms below from <span style="color:steelblue" >Disease, Pathway, Mammalian Phenotype, Biological Process, Cellular Component, Molecular Function, ChEBI</span> </div>
    <div style="font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>
    <% if (om.getMapped().size() == 0) {
        return;

    }%>
    <%
        String firstId = null;
        String species = req.getParameter("species");
        List symbols = (List) request.getAttribute("symbols");
        Iterator symbolIt = om.getMapped().iterator();
        String geneSymbols = "";
        while (symbolIt.hasNext()) {
            Object obj = symbolIt.next();

            String symbol = "";
            int rgdId = -1;
            String type = "";

            if (obj instanceof Gene) {
                Gene g = (Gene) obj;
                symbol = g.getSymbol();
                if(geneSymbols.equals(""))
                    geneSymbols = symbol;
                else
                    geneSymbols+= ","+symbol;
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
    <h1>Gene Enrichment</h1>
    <section v-if="errored">
        <p>We're sorry, we're not able to retrieve this information at the moment, please try back later</p>
    </section>

    <section v-else>


    <div style="background-color:#F8F8F8; width:1600px; border: 1px solid #346F97;" v-for="pair in pairs">
        <div v-if="loading">Loading...</div>
    <span style="font-size:22px;font-weight:700;">{{getOntologyTitle(pair.ont)}}</span>

        <table>
            <tr><td>
        <div style="overflow-x:auto; height:500px; width:700px; background-color:#F8F8F8; border: 1px solid #346F97;">


        <table id="t" >
            <tr>
                <th></th>
                <th> Term </th>
                <th>Matches</th>
                <th>pvalue</th>
                <th>correctedPvalue</th>
            </tr>
            <tr
                    v-for="record in pair.info"
                    class="record"
            >
<td><img v-bind:id=record.acc src="/rgdweb/common/images/add.png"  /></td>
                <td>{{record.term}} </td>
                <td>{{record.count}}</td>
                <td> {{record.pvalue}}</td>
                <td>{{record.correctedpvalue}}</td>
            </tr>
        </table>

        </div></td><td>
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
                errored: false
            }
        },
        methods: {
            dataLoad: function(aspect,index) {

                axios
                        .post('https://dev.rgd.mcw.edu/rgdws/enrichment/data',
                                {speciesTypeKey: <%=species%>,
                                genes: <%=geneSymbols%>, 
                                aspect: aspect})
                        .then(response => {
                    this.info.push({name: aspect,
                    value: response.data}),
                        v.loadChart(response.data,aspect)


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
            loadChart: function (info,name) {
                var arr = info;
                var xarray = [];
                var yarray = [];
                var y1array = [];
                for (i in arr) {
                    if (arr[i].pvalue < 0.05) {
                        xarray.push(arr[i].term);
                        yarray.push(arr[i].count);
                        y1array.push(arr[i].pvalue);
                    }
                }

                var trace1 = {
                    x: xarray,
                    y: yarray,
                    name: 'match data',
                    type: 'bar'

                };

                var trace2 = {
                    x: xarray,
                    y: y1array,
                    name: 'pvalue data',
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
                    }
                };

                Plotly.newPlot(name, data, layout);
            },
            loadPairs: function(ont) {
                for(i=0;i<this.info.length;i++){
                    if(this.info[i].name == ont)
                        return this.info[i].value;
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
                        })
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