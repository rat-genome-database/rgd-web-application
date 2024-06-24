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

        <b-container>
            <b-table :items="items" :fields="fields">

            </b-table>
        </b-container>
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
                items: [],
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
                        key: 'value',
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
                        key: 'reference',
                        sortable: true
                    }
                ]
            }
        },
        methods: {
            // need to do 3 api calls to get proper record, and study
            // proceed like in expression controller
            createTable(termAcc,rgdId){
                termAcc = termAcc.replace(':','%3A')
                // console.log('here1')
                var values = getJSON('https://dev.rgd.mcw.edu/rgdws/expression/'+termAcc+'/'+rgdId+'/TPM');
                // console.log(values);

                // for (var i = 0; i < jsonArr.length; i++){
                //     console.log(i);
                // }
                values.forEach((recVal) =>{
                    // console.log(recVal);
                    // console.log('here now');
                    var geneExpRecId = recVal.geneExpressionRecordId;
                    var tpmVal = recVal.tpmValue;
                    var geneExpRecord = getJSON('https://dev.rgd.mcw.edu/rgdws/expression/expressionRecord/'+geneExpRecId);
                    // var expRecJson = JSON.parse(geneExpRecord);
                    console.log(geneExpRecord);
                    geneExpRecord.forEach((experiment) => {
                        var experimentId = experiment.experimentId;
                        var record = getJSON('https://dev.rgd.mcw.edu/rgdws/expression/record/'+experimentId);
                        console.log(record);
                    })
                });

            }
        }
    })

    async function getJSON(url = ""){
        try {
            const response = await fetch(url);
            let result = await response.json();
            // console.log("Success:", result);
            return result;
        } catch (error) {
            console.error("Error:", error);
        }
    }
</script>