<div style="background-color: white;width:1024px;  " v-for="pair in pairs">
    <div v-if="loading"><span style="font-size:20px;">Building Gene Set Enrichment...</span>
        <div class="spinner-border text-primary" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <div class="spinner-border text-secondary" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <div class="spinner-border text-success" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <div class="spinner-border text-danger" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <div class="spinner-border text-warning" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <br>
        <br>
    </div>
    <section v-if="pair.info != 0">
        <span style="font-size:22px;font-weight:700;">{{getOntologyTitle(pair.ont)}}</span> &nbsp;&nbsp;<button v-if="!loading" type="button" class="btn btn-info" @click="download(pair.info)" >Download Result Set</button>

        <div v-if="orthologs" style="color:#2865a3; font-size:14px; font-weight:500; height:55px; overflow-y: scroll;padding:10px; width: 1300px; ">  Orthologs:
            <span v-for="gene in pair.genes" class="gene">
              {{gene.symbol}},&nbsp;</span>
        </div>

        <table>
            <tr><td v-if ="table">

                <% if (request.getParameter("full") !=null && request.getParameter("full").equals("1")) {%>

                <div style="display:none;overflow:auto; height:600px; width:600px; margin-left:10px; background-color:white; ">
                <% } else { %>
                    <div style="overflow:auto; height:800px; width:600px; margin-left:10px; background-color:white; ">
                        <% } %>

                    <table id="t">
                        <tr v-if="!loading">

                            <th v-on:click="sort('term',pair.ont)"> Term <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('count',pair.ont)">Annotated Genes <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('refCount',pair.ont)">Ref Genes <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('pvalue',pair.ont)">p value <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('correctedpvalue',pair.ont)">Bonferroni Correction <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('oddsratio',pair.ont)">Odds Ratio <i class="fa fa-fw fa-sort"></i></th>
                        </tr>
                        <tr
                                v-for="record in pair.info"
                                class="record"
                        >

                            <td>{{record.term}} ({{record.acc}}) </td>
                            <td  @click="getGenes(record.acc,species[0])"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
                                {{record.count}}
                            </button></td>
                            <td> {{record.refCount}}</td>
                            <td> {{record.pvalue}}</td>
                            <td>{{record.correctedpvalue}}</td>
                            <td>{{record.oddsratio}}</td>
                        </tr>
                    </table>

                </div>
            </td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td v-if="graph">
                    <%@ include file="termsChart.jsp" %>
                </td>   </tr>

        </table>
    </section>
    <section v-else>
        <br>
        <p style="font-size: large;font-weight: bold"> There are no annotations currently available for this combination</p>
    </section>

</div>


