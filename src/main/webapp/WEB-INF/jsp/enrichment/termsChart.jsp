<div>

    <table v-if="!loading>
        <tr>
            <td>
    <label v-if="!loading">&nbsp;&nbsp;<b>Pvalue Limit </b></label>
    <select v-if="!loading" v-on:change="loadChart(pair.info,pair.ont,pvalueLimit)" v-model.lazy="pvalueLimit">
        <option v-for="value in pvalues">{{value}}</option>
    </select>
            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td>
                <input style="margin-bottom:5px;background-color:#14A2B8; color:white;" type="button" onclick="fullScreen()" value="Expand/Colapse Chart"/>
            </td>
        </tr>
    </table>
    <div v-bind:id=pair.ont style=" font-weight:700;width:700px;"></div>
</div>