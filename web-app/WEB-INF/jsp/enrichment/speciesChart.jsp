<div> <label><b>Pvalue Limit</b></label>
    <select v-on:change="loadChart(pair.info,pair.spec,pvalueLimit)" v-model.lazy="pvalueLimit">
        <option v-for="value in pvalues">{{value}}</option>
    </select>
    <div v-bind:id="pair.spec" style="font-weight:700; width:700px;"></div>
</div>