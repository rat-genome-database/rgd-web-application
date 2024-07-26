<%@ page import="edu.mcw.rgd.dao.impl.GeneExpressionDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDManagementDAO" %>

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
    RGDManagementDAO managementDAO = new RGDManagementDAO();
    Gene obj = (Gene) request.getAttribute("reportObject");
    RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    GeneExpressionDAO gedao = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    List<String> terms = xdao.getAllSlimTerms("UBERON","AGR");
    List<String> include = new ArrayList<>();
    int total = 0;
    HashMap<String,Integer> termCnt = new HashMap<>();
    for (String term : terms){
        int sampleCnt = gedao.getGeneExpressionCountByTermRgdIdUnit(term,obj.getRgdId(),"TPM");
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
                <td v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>')" style="cursor: pointer; background: lightcyan;" onclick="highlightCurrent('<%=col%>')"><%=termCnt.get(t)%></td>
                <% col++;} %>
            </tr>
        </table>
        <input type="button" id="hideBtn1" onclick="hideTable()" style="display: none;top: 5px;position: relative;" value="Hide Table">
        <div id="coolTable" style="display: none; overflow-y: auto; padding-top: 10px;">
            <template>
                <b-table :items="expItems" :fields="fields" responsive="sm" sticky-header="475px">
                    <tempplate #cell(tissue)="data">
                        {{data.value}}
                    </tempplate>
                    <template #cell(refRgd)="data">
                        <!-- `data.value` is the value after formatted by the Formatter -->
                        <b-link :href="'/rgdweb/report/reference/main.html?id='+data.value">RGD:{{ data.value }}</b-link>
                    </template>
                </b-table>
            </template>
        </div>
    </div>
<%--    <input type="button" id="hideBtn2" onclick="hideTable()" style="display: none;" value="Hide Table">--%>
</div>

<%@ include file="../sectionFooter.jsp"%>

<script>
    <%--var speciesMap = {--%>
    <%--    <%for (Map m : mapDAO.getMaps(obj.getSpeciesTypeKey())){--%>
    <%--        out.print(m.getKey()+": "+ m.getName());--%>
    <%--            out.print(",");--%>
    <%--    }%>--%>
    <%--};--%>
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
                        formatter: value => {
                            if (value == null || value === "")
                                return "No Tissue Available"
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'GeoSampleId',
                        formatter: value => {
                            if (value == null || value === "")
                                return "No Geo Sample"
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'tpmValue',
                        label: 'Value',
                        formatter:value => {
                            return parseFloat(value.toFixed(3));
                        },
                        sortable: true
                    },
                    {
                        key: 'unit',
                        sortable: true
                    },
                    {
                        key: 'assembly',
                        formatter: value => {
                            return value;
                        },
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
                // termAcc = termAcc.replace(':','%3A')
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
                            var tpmVal = recVal["geneExpressionRecordValue"]["tpmValue"];
                            var mapKey = recVal["geneExpressionRecordValue"]["mapKey"];
                            var experimentId = recVal["geneExpressionRecord"]["experimentId"];
                            var strainTerm = recVal["sample"]["strainAccId"];
                            var sex = recVal["sample"]["sex"];
                            if (sex == null)
                                sex = '';
                            var ageHigh = recVal["sample"]["ageDaysFromHighBound"];
                            var ageLow = recVal["sample"]["ageDaysFromLowBound"];
                            var displayAge = '';
                            if (ageLow < 0 || ageHigh < 0){
                                if (mapKey === 37 || mapKey === 38){
                                    ageLow = ageLow + 280;
                                    ageHigh = ageHigh + 280;
                                    if (ageHigh === ageLow)
                                        displayAge = ageLow + ' days post conception';
                                    else
                                        displayAge = ageLow + ' - ' + ageHigh + ' days post conception';
                                }
                                else {
                                    ageLow = ageLow + 21;
                                    ageHigh = ageHigh + 23;
                                    displayAge = ageLow + ' - ' + ageHigh + ' embryonic days';
                                }
                            }else if (ageHigh === ageLow)
                                displayAge = ageHigh + ' days';
                            else
                                displayAge = ageLow + ' - ' + ageHigh + ' days';
                            var tissue = recVal["sample"]["tissueAccId"];
                            var geoSample = recVal["sample"]["geoSampleAcc"];
                            //var speciesName = mapKey;//speciesName.get(mapKey);
                            console.log(geoSample);
                            $.ajax({
                                type: "GET",
                                url: "https://dev.rgd.mcw.edu/rgdws/maps/assembly/"+mapKey,
                                dataType: "json",
                                success: function (resMap, statMap, xhrMap){
                                    var speciesName = resMap["name"];
                                    // console.log(resMap);

                                        $.ajax({
                                            type: "GET",
                                            url: "https://dev.rgd.mcw.edu/rgdws/expression/experiment/"+experimentId,
                                            dataType: "json",
                                            success: function (res, stat, x){

                                                // loop through results
                                                // console.log("experiment: "+res);
                                                var studyId = res["studyId"];
                                                $.ajax({
                                                    type: "GET",
                                                    url: "https://dev.rgd.mcw.edu/rgdws/expression/study/"+studyId,
                                                    dataType: "json",
                                                    success: function (res1,stat1,x1){
                                                        // console.log("study: "+res1)
                                                        var reference = res1["refRgdId"];
                                                        if (strainTerm != null || strainTerm !== ''){
                                                            $.ajax({
                                                                type: "GET",
                                                                context: this,
                                                                url: "https://dev.rgd.mcw.edu/rgdws/ontology/term/"+strainTerm,
                                                                dataType: "json",
                                                                success: function (r, s, x){
                                                                    // console.log("strain: "+r)
                                                                    // console.log('tissue');
                                                                    if (tissue == null || tissue=='') {
                                                                        tissue = '';
                                                                        someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                                strain: r["term"],
                                                                                sex: sex,
                                                                                age: displayAge,
                                                                                tissue: tissue,
                                                                                GeoSampleId: geoSample,
                                                                                tpmValue: tpmVal,
                                                                                unit: 'TPM',
                                                                                assembly: speciesName,
                                                                                refRgd: reference//{myId: reference, mrLink: link}
                                                                            }
                                                                        )
                                                                    }
                                                                    else{
                                                                        $.ajax({
                                                                            type: "GET",
                                                                            context: this,
                                                                            url: "https://dev.rgd.mcw.edu/rgdws/ontology/term/" + tissue,
                                                                            dataType: "json",
                                                                            success: function (r2, s, x) {
                                                                                // console.log('tissue');
                                                                                // console.log("tissue: "+r)
                                                                                someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                                        strain: r["term"],
                                                                                        sex: sex,
                                                                                        age: displayAge,
                                                                                        tissue: r2["term"],
                                                                                        GeoSampleId: geoSample,
                                                                                        tpmValue: tpmVal,
                                                                                        unit: 'TPM',
                                                                                        assembly: speciesName,
                                                                                        refRgd: reference//{myId: reference, mrLink: link}
                                                                                    }
                                                                                )

                                                                            },
                                                                            error: function(x, s, err){
                                                                                console.log("Result: " + s + " " + err + " " + x.status + " " + x.statusText);
                                                                            }
                                                                        })
                                                                    }
                                                                }
                                                            })
                                                        }
                                                        else {
                                                            if (tissue == null) {
                                                                tissue = '';
                                                                // console.log('tissue');
                                                                // console.log(tpmVal);
                                                                someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                        strain: strainTerm,
                                                                        sex: sex,
                                                                        age: displayAge,
                                                                        tissue: tissue,
                                                                        GeoSampleId: geoSample,
                                                                        tpmValue: tpmVal,
                                                                        unit: 'TPM',
                                                                        assembly: speciesName,
                                                                        refRgd: reference//{myId: reference, mrLink: link}
                                                                    }
                                                                )
                                                            }
                                                            else{
                                                                $.ajax({
                                                                    type: "GET",
                                                                    context: this,
                                                                    url: "https://dev.rgd.mcw.edu/rgdws/ontology/term/" + tissue,
                                                                    dataType: "json",
                                                                    success: function (r, s, x) {
                                                                        // console.log("tissue: "+r)
                                                                        // console.log('tissue');
                                                                        someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                                strain: strainTerm,
                                                                                sex: sex,
                                                                                age: displayAge,
                                                                                tissue: r["term"],
                                                                                GeoSampleId: geoSample,
                                                                                tpmValue: tpmVal,
                                                                                unit: 'TPM',
                                                                                assembly: speciesName,
                                                                                refRgd: reference//{myId: reference, mrLink: link}
                                                                            }
                                                                        )

                                                                    },
                                                                    error: function(x, s, err){
                                                                        console.log("Result: " + s + " " + err + " " + x.status + " " + x.statusText);
                                                                    }
                                                                })

                                                            }
                                                        }
                                                    }
                                                })
                                            },
                                            error: function (x, stat, err) {
                                                console.log("Result: " + stat + " " + err + " " + x.status + " " + x.statusText);
                                            }
                                        }); // end ajax for experiment

                                },
                                error: function(x, s, err){
                                    console.log("Result: " + s + " " + err + " " + x.status + " " + x.statusText);
                                }
                            })
                            // console.log(geneExpRecId);
                            // var geneExpRecord = getJSON('https://dev.rgd.mcw.edu/rgdws/expression/expressionRecord/'+geneExpRecId);

                        });
                    },
                    error: function (xhr, status, error) {
                        console.log("Result: " + status + " " + error + " " + xhr.status + " " + xhr.statusText);
                    }
                }); // end ajax getting all expression records
                this.expItems = someItems;
                // console.log(this.expItems);
                showTable();
            },
            downloadExpression(termAcc, rgdId){

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
    function hideTable(){
        var div = document.getElementById("coolTable");
        var button1 = document.getElementById("hideBtn1");
        // var button2 = document.getElementById("hideBtn2");
        div.style.display = 'none';
        button1.style.display = 'none'
        // button2.style.display = 'none'
        highlightCurrent(-1);
        var e = document.getElementById('rnaSeqExpression');
        e.scrollIntoView();
    }
    function showTable(){
        var div = document.getElementById("coolTable");
        var button1 = document.getElementById("hideBtn1");
        // var button2 = document.getElementById("hideBtn2");
        div.style.display = 'block';
        button1.style.display = 'block'
        // button2.style.display = 'block'
    }

    function highlightCurrent(colNum) {
        var table = document.getElementById("exprData");
        var ths = table.getElementsByTagName("th");
        var cols = table.getElementsByTagName("td");
        for (var i = 0; i < cols.length; i++) {
            if (i == colNum) {
                // highlight column
                ths[i].style.background = 'yellow'
                cols[i].style.background = 'yellow';
            } else {
                // clear style
                ths[i].removeAttribute("style");
                cols[i].removeAttribute("style");
                cols[i].style.background = 'lightcyan';
            }
            cols[i].style.cursor = 'pointer';

        }
    }

</script>