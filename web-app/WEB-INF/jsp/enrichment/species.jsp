<div style="background-color: white; width:1024px; " v-for="pair in speciesPairs">

    <div v-if="loading"><span style="font-size:20px;">Loading...</span>
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
        <span style="font-size:22px;font-weight:700;">{{pair.spec}}</span> &nbsp;&nbsp;<button v-if="!loading" type="button" class="btn btn-info" @click="download(pair.info)" >Download Result Set</button>
        <div style="color:#2865a3; font-size:14px; font-weight:500; height:55px; overflow-y: scroll;padding:10px;width: 1300px; "> Orthologs:
            <span v-for="gene in pair.genes" class="gene">
              {{gene.symbol}},&nbsp;</span>
        </div>
        <table>
            <tr><td v-if ="table">
                <div style="overflow:auto; height:600px; width:600px; background-color:white; ">


                    <table id="t">

                        <tr>

                            <th v-on:click="sort('term',pair.spec)"> Term <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('count',pair.spec)">Annotated Genes <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('refCount',pair.spec)">Ref Genes <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('pvalue',pair.spec)">P-Value <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('correctedpvalue',pair.spec)">Bonferroni Correction <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('oddsratio',pair.spec)">Odds Ratio<i class="fa fa-fw fa-sort"></i></th>
                        </tr>


                        <tr
                                v-for="record in pair.info"
                                class="record"
                        >

                            <td>{{record.term}} ({{record.acc}}) </td>
                            <td  @click="getGenes(record.acc,pair.spec)"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
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
                <td v-if="graph">&nbsp;&nbsp;
                    <%@ include file="speciesChart.jsp" %>
                </td>   </tr>

        </table>
    </section>

</div>