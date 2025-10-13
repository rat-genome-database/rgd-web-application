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
    #exprData td{
        border: 1px solid #dddddd;
        text-align: center;
        padding: 4px;
        /*display: block;*/
        /*height: 40px;*/
        z-index: 29;
        position: relative;
    }

    .outerDiv {
        /*background: grey;*/
        height: 180px;
        width: 55px;
        border: 1px solid black;
        border-bottom: 0;
        border-left: 0;
        transform: skew(-22deg) translateX(68%);
    }

    th:first-child .outerDiv {
        border-left: 1px solid black;
        position: relative;
    }

    .innerDiv {
        position: absolute;
        width: 225px;
        height: 80px;
        bottom: -34%;
        left: 10px;
        transform: skew(30deg) rotate(-60deg);
        transform-origin: 0 0;
        text-align: left;
        z-index: 1;
    }
</style>
<%@ include file="../sectionHeader.jsp"%>
<%
    RGDManagementDAO managementDAO = new RGDManagementDAO();
    Gene obj = (Gene) request.getAttribute("reportObject");
    RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    GeneExpressionDAO gedao = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    List<String> terms = xdao.getAllSlimTermsOrdered("UBERON","AGR");
    List<String> include = new ArrayList<>();
    HashMap<String,String> termCnt = new HashMap<>();
    for (String term : terms){
        String sampleCnt = gedao.getGeneExprReValCountForGeneBySlim(obj.getRgdId(), "TPM", "all", term);
//        System.out.println(sampleCnt);
        if (sampleCnt!=null){
            include.add(term);
            termCnt.put(term,sampleCnt);
        }
    }
%>

<div class="light-table-border">
    <div class="sectionHeading" id="rnaSeqExpression" style="padding-bottom: 5px">RNA-SEQ Expression</div>
    <input type="hidden" id="geneRgdId" value="<%=obj.getRgdId()%>">
    <label style="font-size: 16px">
        <b>Click on a value in the shaded box below the category label to view a detailed expression data table for that system.</b>
    </label>
    <br>
    <img id="spinner" style="display: none;" src="/rgdweb/images/spinner.gif">
    <form id="downloadExpressionData" style="z-index: 30; position: relative;">
        <input type="hidden" id="geneId" value="<%=obj.getRgdId()%>">
        <label id="downloadBtn" style="cursor: pointer; width: fit-content;" v-on:click="downloadExpression('<%=obj.getRgdId()%>')"><u>Download All Expressed Objects for this Gene</u></label>
        <%for (String t : include){%>
        <label id="downloadTerm<%=t%>" style="cursor: pointer; display: none; width: fit-content;" v-on:click="downloadExpressionByTerm('<%=obj.getRgdId()%>','<%=t%>')">
            <u>Download Selected Expressed Objects</u>
        </label>
        <% } %>
    </form>
    <div id="expresTable" style="padding-top: 5px;">
        <table id="exprData" name="exprData" >
            <tr>
                <%  int col = 0;
                    for(String t:include) {
                    Term term = xdao.getTermByAccId(t);
                    if( term != null) {
                %>
                <th>
                    <div class="outerDiv">
                        <div class="innerDiv">
                        <%=xdao.getTerm(t).getTerm()%>
                        </div>
                    </div>
                </th>
                <% } else{  %>
                <th>
                    <div class="outerDiv">
                        <div class="innerDiv">
                            <%=t%>
                        </div>
                    </div>
                </th>
                <% } } %>
            </tr>
            <tr>
                <% for (String t : include){%>
                <td v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>')" style="cursor: pointer; background: lightcyan;" onclick="highlightCurrent('<%=col%>','<%=t%>')" title="">
                    <%=termCnt.get(t)%>
                </td>
                <% col++;} %>
            </tr>
        </table>
        <input type="button" id="hideBtn1" onclick="hideTable()" style="display: none;top: 5px;position: relative;" value="Hide Table">
        <div id="tooManyMsg" style="display: none;">
            <label style="color: red; padding-top: 10px;">Too many to show, limit is 500. Download them if you would like to view them all.</label>
        </div>
        <div id="coolTable" style="display: none; overflow-y: auto; padding-top: 10px;">
            <div style="margin-bottom: 10px; padding: 5px; background: #f5f5f5; border: 1px solid #ddd; border-radius: 4px;">
                <label style="font-weight: bold; margin-right: 10px;">Filter by Expression Level:</label>
                <label style="margin-right: 5px;">
                    <input type="checkbox" v-model="selectedLevels" value="High" style="margin-right: 5px;">
                    <b><span style="color: DarkBlue;">High:</span> TPM > 1000</b>
                </label>
                <label style="margin-right: 5px;">
                    <input type="checkbox" v-model="selectedLevels" value="Medium" style="margin-right: 5px;">
                    <b><span style="color: DarkBlue;">Medium:</span> 10 < TPM &le; 1000 TPM</b>
                </label>
                <label style="margin-right: 5px;">
                    <input type="checkbox" v-model="selectedLevels" value="Low" style="margin-right: 5px;">
                    <b><span style="color: Red;">Low:</span> 0.5 &le; TPM &le; 10</b>
                </label>
                <label style="margin-right: 5px;">
                    <input type="checkbox" v-model="selectedLevels" value="Below Cutoff" style="margin-right: 5px;">
                    <b><span style="color: Red;">Below Cutoff:</span> TPM < 0.5</b>
                </label>
                <button @click="clearFilters" style="margin-left: 10px; padding: 2px 10px;">Clear Filters</button>
                <span style="margin-left: 15px; color: #666;">Showing {{ filteredExpItems.length }} of {{ expItems.length }} records</span>
            </div>
            <template>
                <b-table :items="filteredExpItems" :fields="fields" :busy.sync="isBusy" responsive="sm" sticky-header="475px">
                    <template v-slot:table-busy>
                        <div class="text-center text-primary my-2">
                            <b-spinner class="align-middle"></b-spinner>
                            <strong>Loading...</strong>
                        </div>
                    </template>
                    <template #cell(strain)="data">
                        <span v-html="data.value"></span>
                    </template>
                    <tempplate #cell(tissue)="data">
                        {{data.value}}
                    </tempplate>
                    <template #cell(refRgd)="data">
<%--                        <div id="expressionReferences"></div>--%>
                        <!-- `data.value` is the value after formatted by the Formatter -->
<%--                        <li id="refList" v-for="item in data">--%>
<%--                            <b-link :href="'/rgdweb/report/reference/main.html?id='+item">RGD:{{ item }}</b-link>--%>
                            <span v-html="data.value"></span>
<%--&lt;%&ndash;                            {{item}}&ndash;%&gt;--%>
<%--                        </li>--%>
<%--                        <b-link :href="'/rgdweb/report/reference/main.html?id='+data.value">RGD:{{ data.value }}</b-link>--%>
<%--                        {{ data.value }}--%>
                    </template>
                    <template #cell(geoStudyAcc)="data">
                        <span v-html="data.value"></span>
                    </template>
                </b-table>
            </template>
        </div>
    </div>
<%--    <input type="button" id="hideBtn2" onclick="hideTable()" style="display: none;" value="Hide Table">--%>
</div>

<%@ include file="../sectionFooter.jsp"%>

<script>
        var tableVue = new Vue({
        el: '#expresTable',
        data() {
            return {
                isBusy: false,
                selectedLevels: [],
                fields: [
                    {
                        key: 'strain',
                        label: 'Strain/CellLine',
                        formatter: value =>{
                          return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'sex',
                        sortable: true
                    },
                    {
                      key: 'computedSex',
                        label: 'Computed Sex',
                        formatter: value => {
                            if (value == null || value === "")
                                return "N/A"
                            return value;
                        },
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
                                return "N/A"
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
                        key: 'level',
                        label: "Level",
                        formatter: value => {
                            return value;
                        },
                        sortable: true,
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
                        formatter: 'createLinks',
                        // formatter: value => {
                        //     return value;
                        // }
                        sortable: true
                    },
                    {
                        key: 'geoStudyAcc',
                        label: 'GEO Study',
                        formatter: 'createGEOLinks',
                        sortable: true
                    }
                ],
                expItems: []
            }
        },
        computed: {
            filteredExpItems() {
                if (this.selectedLevels.length === 0) {
                    return this.expItems;
                }
                return this.expItems.filter(item => {
                    // Normalize both values for comparison
                    var normalizedItemLevel = (item.level || '').toLowerCase().trim();
                    return this.selectedLevels.some(selectedLevel => {
                        var normalizedSelected = selectedLevel.toLowerCase().trim();
                        return normalizedItemLevel === normalizedSelected ||
                               normalizedItemLevel === normalizedSelected.replace(' ', '_') ||
                               normalizedItemLevel === normalizedSelected.replace(' ', '');
                    });
                });
            }
        },
        methods: {
            clearFilters() {
                this.selectedLevels = [];
            },
            // need to do 3 api calls to get proper record, and study
            // proceed like in expression controller
            createTable(termAcc,rgdId){
                // clear table if full
                // termAcc = termAcc.replace(':','%3A')
                // Reset filters when loading new data
                this.selectedLevels = [];
                tableVue.isBusy = true;
                var download = document.getElementById("downloadTerm"+termAcc);
                download.style.display = 'block';
                var someItems = [];
                $.ajax({
                    type: "GET",
                    url: "https://rest.rgd.mcw.edu/rgdws/expression/"+termAcc+"/"+rgdId+"/TPM",
                    dataType: "json",
                    success: function (result, status, xhr){
                            result.forEach((recVal) => {
                                var tpmVal = recVal["geneExpressionRecordValue"]["tpmValue"];
                                var mapKey = recVal["geneExpressionRecordValue"]["mapKey"];
                                var expLevel = recVal["geneExpressionRecordValue"]["expressionLevel"];
                                // var experimentId = recVal["geneExpressionRecord"]["experimentId"];
                                var strainTerm = recVal["sample"]["strainAccId"];
                                var sex = recVal["sample"]["sex"];
                                if (sex == null)
                                    sex = '';
                                var ageHigh = recVal["sample"]["ageDaysFromHighBound"];
                                var ageLow = recVal["sample"]["ageDaysFromLowBound"];
                                var displayAge = '';
                                if (ageHigh == 0 && ageLow == 0){
                                    displayAge = 'not available';
                                }else if (ageLow < 0 || ageHigh < 0) {
                                    if (mapKey === 37 || mapKey === 38) {
                                        ageLow = ageLow + 280;
                                        ageHigh = ageHigh + 280;
                                        if (ageHigh === ageLow)
                                            displayAge = ageLow + ' days post conception';
                                        else
                                            displayAge = ageLow + ' - ' + ageHigh + ' days post conception';
                                    } else {
                                        ageLow = ageLow + 22;
                                        ageHigh = ageHigh + 22;
                                        if (ageLow === ageHigh) {
                                            displayAge = ageLow + ' embryonic days';
                                        } else {
                                            displayAge = ageLow + ' - ' + ageHigh + ' embryonic days';
                                        }

                                    }
                                } else if (ageHigh === ageLow)
                                    displayAge = ageHigh + ' days';
                                else
                                    displayAge = ageLow + ' - ' + ageHigh + ' days';
                                var tissue = recVal["sample"]["tissueAccId"];
                                var geoSample = recVal["sample"]["geoSampleAcc"];
                                var compSex = recVal['sample']['computedSex'];
                                var reference = []; //recVal["refRgdId"];
                                var studyId = recVal["studyId"];
                                var geoStudyAcc = recVal["geoSeriesAcc"];
                                $.ajax({
                                    type: "GET",
                                    url: "https://rest.rgd.mcw.edu/rgdws/expression/study/references/" + studyId,
                                    dataType: "json",
                                    success: function (refRes, status, xhr) {
                                        refRes.forEach((ref) => {
                                            reference.push(ref);
                                        })
                                        $.ajax({
                                            type: "GET",
                                            url: "https://rest.rgd.mcw.edu/rgdws/maps/assembly/" + mapKey,
                                            dataType: "json",
                                            success: function (resMap) {
                                                // var json = $.parseJSON(resMap);
                                                // var speciesName = json.name;
                                                var speciesName = resMap["name"];
                                                // console.log("in mapkey");
                                                // busyState = false;
                                                if (strainTerm != null && strainTerm !== '') {
                                                    $.ajax({
                                                        type: "GET",
                                                        context: this,
                                                        url: "https://rest.rgd.mcw.edu/rgdws/ontology/term/" + strainTerm,
                                                        dataType: "json",
                                                        success: function (r, s, x) {
                                                            var link = '';
                                                            if (strainTerm.startsWith('RS:'))
                                                                link = '/rgdweb/report/strainOnt/main.html?acc='+strainTerm;
                                                            else
                                                                link = '/rgdweb/ontology/view.html?acc_id=' + strainTerm;
                                                            // var link = "/rgdweb/report/expressionStudy/main.html?geoAcc=" + data;
                                                            var a = '<a href="' + link + '">' + r["term"] + '</a>';
                                                            // console.log(a);
                                                            // console.log("strain: "+r)
                                                            // console.log('tissue');
                                                            if (tissue == null || tissue == '') {
                                                                tissue = '';
                                                                someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                        strain: a,
                                                                        sex: sex,
                                                                        computedSex: compSex,
                                                                        age: displayAge,
                                                                        tissue: tissue,
                                                                        GeoSampleId: geoSample,
                                                                        tpmValue: tpmVal,
                                                                        unit: 'TPM',
                                                                        assembly: speciesName,
                                                                        refRgd: reference,//{myId: reference, mrLink: link}
                                                                        level: expLevel,
                                                                        geoStudyAcc: geoStudyAcc
                                                                    }
                                                                )
                                                            } else {
                                                                // console.log("here2")
                                                                $.ajax({
                                                                    type: "GET",
                                                                    context: this,
                                                                    url: "https://rest.rgd.mcw.edu/rgdws/ontology/term/" + tissue,
                                                                    dataType: "json",
                                                                    success: function (r2, s, x) {
                                                                        // console.log('tissue');
                                                                        // console.log("tissue: "+r)
                                                                        someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                                strain: a,
                                                                                sex: sex,
                                                                                computedSex: compSex,
                                                                                age: displayAge,
                                                                                tissue: r2["term"],
                                                                                GeoSampleId: geoSample,
                                                                                tpmValue: tpmVal,
                                                                                unit: 'TPM',
                                                                                assembly: speciesName,
                                                                                refRgd: reference,//{myId: reference, mrLink: link}
                                                                                level: expLevel,
                                                                                geoStudyAcc: geoStudyAcc
                                                                            }
                                                                        )

                                                                    },
                                                                    error: function (x, s, err) {
                                                                        console.log("Result: " + s + " " + err + " " + x.status + " " + x.statusText);
                                                                    }
                                                                })
                                                            }
                                                        },
                                                        complete: function (){
                                                            tableVue.isBusy = false;
                                                        }
                                                    })
                                                } else {
                                                    if (tissue == null) {
                                                        // console.log("here3")
                                                        tissue = '';
                                                        // console.log('tissue');
                                                        // console.log(tpmVal);
                                                        someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                strain: 'None Available',
                                                                sex: sex,
                                                                computedSex: compSex,
                                                                age: displayAge,
                                                                tissue: tissue,
                                                                GeoSampleId: geoSample,
                                                                tpmValue: tpmVal,
                                                                unit: 'TPM',
                                                                assembly: speciesName,
                                                                refRgd: reference,//{myId: reference, mrLink: link}
                                                                level: expLevel,
                                                                geoStudyAcc: geoStudyAcc
                                                            }
                                                        )
                                                        tableVue.isBusy = false;
                                                    } else {
                                                        // console.log("here4")
                                                        $.ajax({
                                                            type: "GET",
                                                            context: this,
                                                            url: "https://rest.rgd.mcw.edu/rgdws/ontology/term/" + tissue,
                                                            dataType: "json",
                                                            success: function (r, s, x) {
                                                                // console.log("tissue: "+r)
                                                                // console.log('tissue');
                                                                someItems.push({ // strain, sex, age, tissue, value, unit, assembly, reference
                                                                        strain: 'None Available',
                                                                        sex: sex,
                                                                        computedSex: compSex,
                                                                        age: displayAge,
                                                                        tissue: r["term"],
                                                                        GeoSampleId: geoSample,
                                                                        tpmValue: tpmVal,
                                                                        unit: 'TPM',
                                                                        assembly: speciesName,
                                                                        refRgd: reference,//{myId: reference, mrLink: link}
                                                                        level: expLevel,
                                                                        geoStudyAcc: geoStudyAcc
                                                                    }
                                                                )

                                                            },
                                                            complete: function (){
                                                                tableVue.isBusy = false;
                                                            },
                                                            error: function (x, s, err) {
                                                                console.log("Result: " + s + " " + err + " " + x.status + " " + x.statusText);
                                                            }
                                                        });

                                                    }
                                                }

                                            },
                                            error: function (x, s, err) {
                                                console.log("Result: " + s + " " + err + " " + x.status + " " + x.statusText);
                                            }
                                        }); // end mapKey AJAX call
                                    }
                                })

                            });
                        // }
                    },
                    error: function (xhr, status, error) {
                        console.log("Result: " + status + " " + error + " " + xhr.status + " " + xhr.statusText);
                    }
                }); // end ajax getting all expression records
                // console.log("the end");
                this.expItems = someItems;
                // this.isBusy = busyState;
                // Debug: Log unique level values to console
                var uniqueLevels = [...new Set(someItems.map(item => item.level))];
                // console.log("Unique expression levels in data:", uniqueLevels);
                // console.log("Sample items:", someItems.slice(0, 3));
                showTable(termAcc);
                // return someItems;
            },
            createLinks(data){
                // console.log(data);
                var valLen = data.length;
                var valCopy = data;
                // var i = 0;
                // var list = document.getElementById("refList");
                var value2 = '';
                // console.log(data);
                for (var i = 0; i < valLen; i++){
                    // console.log(data[i]);
                    var link = "/rgdweb/report/reference/main.html?id="+data[i];
                    var d2 = '<a href="'+link+'">RGD:'+data[i]+'</a>';
                    value2 += d2 + " ";
                }
                // console.log(value2);
                if (value2 == null || value2 === '')
                    return "N/A";
                return value2;
            },
            createGEOLinks(data){
                // var valLen = data.length;
                // var valCopy = data;
                // var i = 0;
                // var list = document.getElementById("refList");
                if (data == null || data ===''){
                    return 'N/A';
                }
                var value2 = '';
                // console.log(data);
                var link = "/rgdweb/report/expressionStudy/main.html?geoAcc=" + data;
                var a = '<a href="' + link + '">' + data + '</a>';
                value2 += a;
                // console.log(value2);
                return value2;
            }
        }
    });

    var downloadExpressionVue = new Vue ({
        el: '#downloadExpressionData',
        data: {
            geneId: ''
        },
        methods: {
            downloadExpression: function (geneId) {
                // alert("Start vue");
                var btn = document.getElementById('downloadExpressionData');
                var spin = document.getElementById('spinner');
                btn.style.display = 'none';
                spin.style.display = 'block';
                axios
                    .post('/rgdweb/report/gene/downloadExpression.html',
                        {
                            rgdId: geneId,
                            term: "UBERON:9999999"
                        },
                        {responseType: 'blob'})
                    .then(function (response) {
                        // alert("done");
                        // console.log(response);
                        var a = document.createElement("a");
                        document.body.appendChild(a);
                        a.style = "display: none";
                        let blob = new Blob([response.data], { type: 'text/csv' }),
                            url = window.URL.createObjectURL(blob);
                        a.href = url;
                        // Extract filename from Content-Disposition header
                        var filename = "gene_expression_data.csv"; // default
                        var disposition = response.headers['content-disposition'];
                        if (disposition && disposition.indexOf('filename=') !== -1) {
                            var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
                            var matches = filenameRegex.exec(disposition);
                            if (matches != null && matches[1]) {
                                filename = matches[1].replace(/['"]/g, '');
                            }
                        }
                        a.download = filename;
                        a.click();
                        window.URL.revokeObjectURL(url);
                        // window.open(url)
                        btn.style.display = 'block';
                        spin.style.display = 'none';
                    })
                    .catch(function (error) {
                        console.log(error);
                        // console.log(error.response.data);
                    })
            },
            downloadExpressionByTerm: function (geneId,termAcc) {
                // alert("Start vue");
                var btn = document.getElementById('downloadBtn');
                var spin = document.getElementById('spinner');
                btn.style.display = 'none';
                var elms = document.querySelectorAll("[id^='downloadTerm']");

                for (var i = 0; i < elms.length; i++) {
                    elms[i].style.display = 'none';
                }
                spin.style.display = 'block';
                axios
                    .post('/rgdweb/report/gene/downloadExpression.html',
                        {
                            rgdId: geneId,
                            term: termAcc
                        },
                        {responseType: 'blob'})
                    .then(function (response) {
                        // alert("done");
                        // console.log(response);
                        var a = document.createElement("a");
                        document.body.appendChild(a);
                        a.style = "display: none";
                        let blob = new Blob([response.data], { type: 'text/csv' }),
                            url = window.URL.createObjectURL(blob);
                        a.href = url;
                        // Extract filename from Content-Disposition header
                        var filename = "gene_expression_data.csv"; // default
                        var disposition = response.headers['content-disposition'];
                        if (disposition && disposition.indexOf('filename=') !== -1) {
                            var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
                            var matches = filenameRegex.exec(disposition);
                            if (matches != null && matches[1]) {
                                filename = matches[1].replace(/['"]/g, '');
                            }
                        }
                        a.download = filename;
                        a.click();
                        window.URL.revokeObjectURL(url);
                        // window.open(url)
                        btn.style.display = 'block';
                        spin.style.display = 'none';
                        for (var i = 0; i < elms.length; i++) {
                            if (elms[i].id === 'downloadTerm' + termAcc) {
                                elms[i].style.display = 'block';
                            }
                            else
                                elms[i].style.display = 'none';
                        }
                    })
                    .catch(function (error) {
                        console.log(error);
                        // console.log(error.response.data);
                    })
            }
        }
    });

    function hideTable(){
        // hideErrorMessage();
        var div = document.getElementById("coolTable");
        var button1 = document.getElementById("hideBtn1");
        // var button2 = document.getElementById("hideBtn2");
        div.style.display = 'none';
        button1.style.display = 'none';
        // button2.style.display = 'none'
        highlightCurrent(-1);
        var elms = document.querySelectorAll("[id^='downloadTerm']");

        for(var i = 0; i < elms.length; i++)
            elms[i].style.display='none';

        var e = document.getElementById('rnaSeqExpression');
        e.scrollIntoView();
    }

    function showTable(termAcc) {
        hideErrorMessage();
        var div = document.getElementById("coolTable");
        var button1 = document.getElementById("hideBtn1");
        // var button2 = document.getElementById("hideBtn2");
        div.style.display = 'block';
        button1.style.display = 'block'
        // button2.style.display = 'block'
        var elms = document.querySelectorAll("[id^='downloadTerm']");

        for (var i = 0; i < elms.length; i++) {
            if (elms[i].id === 'downloadTerm' + termAcc) {
                elms[i].style.display = 'block';
            }
            else
                elms[i].style.display = 'none';
        }
    }

    function showErrorMessage(){
        var div = document.getElementById("tooManyMsg");
        div.style.display = 'block';
    }

    function hideErrorMessage(){
        var div = document.getElementById("tooManyMsg");
        div.style.display = 'none';
    }

    function highlightCurrent(colNum,termAcc) {
        var table = document.getElementById("exprData");
        var ths = table.getElementsByClassName("outerDiv");
        var cols = table.getElementsByTagName("td");
        for (var i = 0; i < cols.length; i++) {
            if (i == colNum) {
                // highlight column
                ths[i].style.background = 'yellow'
                cols[i].style.background = 'yellow';
            } else {
                // clear style
                ths[i].style.background = 'white';
                cols[i].removeAttribute("style");
                cols[i].style.background = 'lightcyan';
            }
            cols[i].style.cursor = 'pointer';

        }
    }
    tableVue;
</script>