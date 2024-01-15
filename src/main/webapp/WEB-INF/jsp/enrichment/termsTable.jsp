<div style="overflow:auto; height:600px; width:800px; background-color:white; ">

    <table id="t" border="1">
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
            <td  @click="getGenes(record.acc,species[0])"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
                {{record.count}}
            </button></td>
            <td> {{record.pvalue}}</td>
            <td>{{record.correctedpvalue}}</td>
        </tr>
    </table>

</div>