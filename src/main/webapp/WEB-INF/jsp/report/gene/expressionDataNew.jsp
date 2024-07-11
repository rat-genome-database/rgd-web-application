<%@ page import="edu.mcw.rgd.dao.impl.GeneExpressionDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>

<script src="https://unpkg.com/bootstrap-vue@2.5.0/dist/bootstrap-vue.min.js"></script>

<link href="https://unpkg.com/bootstrap-vue@2.5.0/dist/bootstrap-vue.css" rel="stylesheet" />
<%--<link href="https://unpkg.com/bootstrap@4.3.1/dist/css/bootstrap.min.css" rel="stylesheet" />--%>
<style>
    #exprData {
        border-radius:2px;
        border-spacing: 5px;
        /*overflow-y: auto;*/
    }
    #exprData td, #exprData th{
        border: 1px solid #dddddd;
        text-align: center;
        padding: 4px;
        /*display: block;*/
        /*height: 40px;*/

    }
</style>
<%@ include file="../sectionHeader.jsp"%>
<%
    GeneExpressionDAO gedao = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    List<String> terms = xdao.getAllSlimTerms("UBERON","AGR");
    List<String> include = new ArrayList<>();
    int total = 0;
    HashMap<String,Integer> termCnt = new HashMap<>();
    for (String term : terms){
        int sampleCnt = gedao.getGeneExpressionSamplesCountByTermRgdIdUnit(term,obj.getRgdId(),"TPM");
//        System.out.println(sampleCnt);
        if (sampleCnt!=0){
            include.add(term);
            termCnt.put(term,sampleCnt);
            total += sampleCnt;
        }
    }
%>

<div class="light-table-border">
    <div class="sectionHeading" id="rnaSeqExpression">RNA-SEQ Expression</div>
    <input type="hidden" id="geneRgdId" value="<%=obj.getRgdId()%>">
    <input type="button" onclick="hideTable()" value="Hide Table">
    <div id="expresTable">
        <table id="exprData" name="exprData">
            <tr>
                <%  int col = 0;
                    for(String t:include) {
                    Term term = xdao.getTermByAccId(t);
                    if( term != null) {
                %>
                <th><%=xdao.getTerm(t).getTerm()%></th>
                <% } else{  %>
                <th><%=t%></th>
                <% } } %>
            </tr>
            <tr>
                <% for (String t : include){%>
                <td v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>')" style="cursor: pointer;" onclick="highlightCurrent('<%=col%>')"><%=termCnt.get(t)%></td>
                <% col++;} %>
            </tr>
        </table>

        <template>
            <div id="coolTable" style="display: none;">
                <b-table  :items="expItems" :fields="fields" responsive="sm">
                    <template #cell(refRgd)="data">
                        <!-- `data.value` is the value after formatted by the Formatter -->
                        <b-link :href="'/rgdweb/report/reference/main.html?id='+data.value">RGD:{{ data.value }}</b-link>
                    </template>
                </b-table>
            </div>
        </template>
    </div>
</div>

<%@ include file="../sectionFooter.jsp"%>

<script>
    // vue for getting expression record value list?
    // then make a table for each gerv

    new Vue({
        el: '#expresTable',
        data() {
            return {
                fields: [
                    {
                        key: 'strain',
                        sortable: true
                    },
                    {
                        key: 'sex',
                        sortable: true
                    },
                    {
                        key: 'age',
                        sortable: true
                    },
                    {
                        key: 'tissue',
                        sortable: true
                    },
                    {
                        key: 'tpmValue',
                        label: 'Value',
                        sortable: true
                    },
                    {
                        key: 'unit',
                        sortable: true
                    },
                    {
                        key: 'assembly',
                        sortable: true
                    },
                    {
                        key: 'refRgd',
                        label: 'Reference',
                        formatter: value => {
                            return value;
                        },//'LinkFormatter',
                        sortable: true
                    }
                ],
                expItems: [

                ]
            }
        },
        methods: {
            // need to do 3 api calls to get proper record, and study
            // proceed like in expression controller
            createTable(termAcc,rgdId){
                // clear table if full
                termAcc = termAcc.replace(':','%3A')
                var studyMap = {};
                var expIdList = [];
                var someItems = [];
                $.ajax({
                    type: "GET",
                    url: "https://dev.rgd.mcw.edu/rgdws/expression/"+termAcc+"/"+rgdId+"/TPM",
                    dataType: "json",
                    success: function (result, status, xhr){
                        result.forEach((recVal) =>{
                            // console.log(recVal);
                            // console.log('here now');
                            var geneExpRecId = recVal["geneExpressionRecordId"];
                            var tpmVal = recVal["tpmValue"];
                            var mapKey = '';
                            // console.log(geneExpRecId);
                            // var geneExpRecord = getJSON('https://dev.rgd.mcw.edu/rgdws/expression/expressionRecord/'+geneExpRecId);
                            $.ajax({
                                type: "GET",
                                url: "https://dev.rgd.mcw.edu/rgdws/expression/expressionRecord/"+geneExpRecId,
                                dataType: "json",
                                success: function (result2, status2, xhr2){
                                    // console.log(result2);
                                    var experimentId = result2["experimentId"];
                                    if (!expIdList.includes(experimentId)){
                                        expIdList.push(experimentId);
                                        mapKey = result2['mapKey'];
                                        $.ajax({
                                            type: "GET",
                                            url: "https://dev.rgd.mcw.edu/rgdws/expression/record/"+experimentId,
                                            dataType: "json",
                                            success: function (res, stat, x){
                                                // loop through results
                                                // console.log(res);
                                                res.forEach((record) =>{
                                                    var sex = record["sample"]["sex"];
                                                    if (sex == null)
                                                        sex = '';
                                                    var ageHigh = record["sample"]["ageDaysFromHighBound"];
                                                    var ageLow = record["sample"]["ageDaysFromLowBound"];
                                                    var displayAge;
                                                    if ( ageHigh==ageLow)
                                                        displayAge = ageHigh + ' days';
                                                    else
                                                        displayAge = ageLow + ' - ' + ageHigh + ' days';
                                                    var tissue = record["sample"]["tissueAccId"];
                                                    if (tissue == null)
                                                        tissue = '';
                                                    // var refRgd = record["refRgdId"];
                                                    var reference = record["refRgdId"];//'<b-link :href="/rgdweb/report/reference/main.html?id='+refRgd+'">'+ refRgd +'</b-link>';
                                                    var link = '/rgdweb/report/reference/main.html?id='+reference;
                                                    someItems.push({
                                                            strain: record["sample"]["strainAccId"],
                                                            sex: sex,
                                                            age: displayAge,
                                                            tissue: tissue,
                                                            tpmValue: tpmVal,
                                                            unit: 'TPM',
                                                            assembly: 'rat',
                                                            refRgd: reference//{myId: reference, mrLink: link}
                                                        }
                                                    )

                                                })
                                                // strain, sex, age, tissue, value, unit, assembly, reference
                                                // this.data.push({strain: })
                                            },
                                            error: function (x, stat, err) {
                                                console.log("Result: " + stat + " " + err + " " + x.status + " " + x.statusText);
                                            }
                                        })
                                    }
                                },
                                error: function(xhr2, status2, error){
                                    console.log("Result: " + status2 + " " + error + " " + xhr2.status + " " + xhr2.statusText);
                                }
                            });
                        });
                    },
                    error: function (xhr, status, error) {
                        console.log("Result: " + status + " " + error + " " + xhr.status + " " + xhr.statusText);
                    }
                });
                // console.log();
                // console.log(this.expItems);
                // console.log(someItems);
                this.expItems = someItems;
                // console.log(this.expItems);
                showTable();
            }
            // getRef(value){
            //     return value;
            // },
            // LinkFormatter(value, row, index) {
            //     return "<a href='"+value.mrLink+"'>"+value.myId+"</a>";
            // }
        }
    })

    function getJSON(url = ""){
        $.ajax({
            type: "GET",
            url: url,
            dataType: "json",
            success: function (result){
                return result;
            }
        })
    }
    function hideTable(){
        var div = document.getElementById("coolTable");
            div.style.display = 'none';
            highlightCurrent(-1);
    }
    function showTable(){
        var div = document.getElementById("coolTable");
        div.style.display = 'block';
    }
    function highlightCurrent(colNum){
        var table = document.getElementById("exprData");
        var ths = table.getElementsByTagName("th");
        var cols = table.getElementsByTagName("td");
        for (var i = 0; i < cols.length; i++){
            if (i==colNum){
                // highlight column
                ths[i].style.background = 'yellow'
                cols[i].style.background = 'yellow';
            }
            else{
                // clear style
                ths[i].removeAttribute("style");
                cols[i].removeAttribute("style");
            }
            cols[i].style.cursor = 'pointer';
        }
    }
</script>