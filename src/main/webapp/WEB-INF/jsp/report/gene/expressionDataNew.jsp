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
    <div id="expresTable">
        <table id="exprData" name="exprData">
            <tr>
                <% for(String t:include) {
                    Term term = xdao.getTermByAccId(t);
                    if( term != null) {
                %>
                <td><%=xdao.getTerm(t).getTerm()%></td>
                <% } else{  %>
                <td><%=t%></td>
                <% } } %>
            </tr>
            <tr>
                <% for (String t : include){%>
                <td v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>')"><%=termCnt.get(t)%></td>
                <% } %>
            </tr>
        </table>

        <template>
            <b-table :items="expItems" :fields="fields" responsive="sm">

            </b-table>
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
                        sortable: true
                    }
                ],
                expItems: [
                    {
                        strain:'RS:00000004',
                        sex:'male',
                        age:'2-10 days',
                        tissue: 'liver',
                        tpmValue: '6',
                        unit: 'TPM',
                        assembly: "rnor 6.0",
                        refRgd: 'rgd'
                    },
                    {
                        strain:'RS:00000006',
                        sex:'female',
                        age:'2-15 days',
                        tissue: 'heart',
                        tpmValue: '50',
                        unit: 'TPM',
                        assembly: "rnor 6.0",
                        refRgd: 'rgd'
                    }
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
                                                    var refRgd = record["refRgdId"];
                                                    var reference = '<a href="/rgdweb/report/reference/main.html?id='+refRgd+'">'+ refRgd +'</a>';
                                                    someItems.push( {
                                                            strain: record["sample"]["strainAccId"],
                                                            sex: sex,
                                                            age: displayAge,
                                                            tissue: tissue,
                                                            tpmValue: tpmVal,
                                                            unit: 'TPM',
                                                            assembly: 'rat',
                                                            refRgd: reference})

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
                console.log(this.expItems);
                console.log(someItems);
                this.expItems = someItems;
                console.log(this.expItems);
            }
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
</script>