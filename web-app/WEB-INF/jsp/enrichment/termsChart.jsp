<div>
    <label v-if="!loading">&nbsp;&nbsp;<b>Pvalue Limit </b></label>
    <select v-if="!loading" v-on:change="loadChart(pair.info,pair.ont,pvalueLimit)" v-model.lazy="pvalueLimit">
        <option v-for="value in pvalues">{{value}}</option>
    </select>
    <div v-bind:id=pair.ont style=" font-weight:700;width:700px;"></div>
</div>