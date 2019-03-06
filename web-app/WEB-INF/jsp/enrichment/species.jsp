<div style="background-color: white; width:1024px; " v-for="pair in speciesPairs">

    <div v-if="loading">Loading...</div>
    <section v-if="pair.info != 0">
        <span style="font-size:22px;font-weight:700;">{{pair.spec}}</span>
        <div style="color:#2865a3; font-size:14px; font-weight:500; height:55px; overflow-y: scroll;padding:10px;width: 1200px; "> Orthologs:
            <span v-for="gene in pair.genes" class="gene">
              {{gene.symbol}},&nbsp;</span>
        </div>
        <table>
            <tr><td v-if ="table">
                <div style="overflow:auto; height:600px; width:500px; background-color:white; ">


                    <table id="t">

                        <tr>

                            <th v-on:click="sort('term',pair.spec)"> Term <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('count',pair.spec)">Annotated Genes <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('pvalue',pair.spec)">P-Value <i class="fa fa-fw fa-sort"></i></th>
                            <th v-on:click="sort('correctedpvalue',pair.spec)">Bonferroni Correction <i class="fa fa-fw fa-sort"></i></th>
                        </tr>


                        <tr
                                v-for="record in pair.info"
                                class="record"
                        >

                            <td><b>{{record.term}} ({{record.acc}})</b> </td>
                            <td  @click="getGenes(record.acc,pair.spec)"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
                                {{record.count}}
                            </button></td>
                            <td> {{record.pvalue}}</td>
                            <td>{{record.correctedpvalue}}</td>
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