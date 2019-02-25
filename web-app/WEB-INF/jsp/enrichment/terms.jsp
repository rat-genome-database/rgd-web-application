<div style="background-color: white; width:1700px; " v-for="pair in pairs">

    <div v-if="loading">Loading...</div>
    <section v-if="pair.info != 0">
    <span style="font-size:22px;font-weight:700;">{{getOntologyTitle(pair.ont)}}</span><br>

    <table>
        <tr><td>
            <div style="overflow-x:auto; height:600px; width:800px; background-color:white; ">


                <table id="t">
                    <tr>

                        <th @click="sort('term',pair.ont)"> Term <i class="fa fa-fw fa-sort"></i></th>
                        <th @click="sort('count',pair.ont)">Annotated Genes <i class="fa fa-fw fa-sort"></i></th>
                        <th @click="sort('pvalue',pair.ont)">p value <i class="fa fa-fw fa-sort"></i></th>
                        <th @click="sort('correctedpvalue',pair.ont)">Bonferroni Correction <i class="fa fa-fw fa-sort"></i></th>
                    </tr>
                    <tr
                            v-for="record in pair.info"
                            class="record"
                    >

                        <td><b>{{record.term}} ({{record.acc}})</b> </td>
                        <td  @click="getGenes(record.acc,0)"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
                            {{record.count}}
                        </button></td>
                        <td> {{record.pvalue}}</td>
                        <td>{{record.correctedpvalue}}</td>
                    </tr>
                </table>

            </div></td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td>
                <label>&nbsp;&nbsp;<b>Pvalue Limit</b></label>
                <select v-on:change="loadChart(pair.info,pair.ont,pvalueLimit)" v-model="pvalueLimit">
                    <option v-for="value in pvalues">{{value}}</option>
                </select>
                <div v-bind:id=pair.ont style="font-weight:700; width:800px;"></div>
            </td>   </tr>

    </table>
    </section>

</div>