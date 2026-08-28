<%@ page import="edu.mcw.rgd.dao.impl.GeneExpressionDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDManagementDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.GeneExpressionValueCount" %>
<%@ page import="static edu.mcw.rgd.web.RgdContext.getAPIHostname" %>

<script src="https://unpkg.com/bootstrap-vue@2.5.0/dist/bootstrap-vue.min.js"></script>

<link href="https://unpkg.com/bootstrap-vue@2.5.0/dist/bootstrap-vue.css" rel="stylesheet" />
<%--<link href="https://unpkg.com/bootstrap@4.3.1/dist/css/bootstrap.min.css" rel="stylesheet" />--%>
<style>
    /* RNA-Seq expression ribbon
       ------------------------------------------------------------------------
       Modelled on the Alliance / Gene Ontology ribbon widget
       (geneontology/wc-ribbon, wc-ribbon-strips/.../ribbon-strips.scss): an 18px
       square per system in one row, shaded white -> blue by sample count, with
       the system names as -45 degree labels above and the count in the tooltip.

       The whole strip is ~500px wide instead of the 1300px the old table needed,
       and the rotated labels sit inside the 12.4rem top margin the ribbon
       reserves for them, so nothing escapes the card. */

    #expresTable {
        max-width: 100%;
        overflow-x: auto;
        padding-top: 5px;
    }

    .ribbon { display: table; width: 100%; }
    .ribbon, .ribbon * { box-sizing: border-box; }

    /* the row of angled system names; the top margin is the room they rotate into */
    .ribbonCategory {
        display: block;
        margin-top: 12.4rem;
        margin-bottom: .5rem;
    }
    .ribbonCategoryLabel {
        display: inline-block;
        width: 18px;
        margin-right: 4px;
        font-size: 12px;
        line-height: 1;
        color: #1f2933;
        white-space: nowrap;
        text-align: left;
        vertical-align: bottom;
        transform: translateY(-2px) rotate(-45deg);
    }
    .ribbonCategoryLabel:hover { cursor: help; font-weight: bold; }
    .ribbonCategoryLabel.is-selected { font-weight: bold; }

    .ribbonRow {
        display: block;
        padding-bottom: 3px;
        white-space: nowrap;
    }
    .ribbonRowLabel {
        display: inline-block;
        width: 108px;
        font-size: 12.5px;
        font-weight: 700;
        color: #1f2933;
        vertical-align: bottom;
    }
    .ribbonCell {
        display: inline-block;
        width: 18px;
        height: 18px;
        margin-right: 4px;
        box-shadow: 0 1px 4px rgba(0, 0, 0, .26);
        outline: 2px solid transparent;
        outline-offset: 1px;
        vertical-align: bottom;
        cursor: pointer;
    }
    /* a system with no samples at this level - present, but not a target */
    .ribbonCell--empty {
        background: repeating-linear-gradient(45deg,
                    #ffffff, rgba(0, 0, 0, .1) 1px, #ffffff 2px, #ffffff 12px);
        cursor: not-allowed;
    }
    .ribbonCell:not(.ribbonCell--empty):hover { outline-color: rgba(31, 41, 51, .55); }
    .ribbonCell:focus-visible,
    .ribbonCell.is-selected  { outline-color: #1f2933; }

    /* colour is the only magnitude channel, and the ramp is logarithmic, so the
       key carries real tick values rather than just "low ... high" */
    #exprLegend {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 6px 14px;
        margin: 16px 0 4px;
        font-size: 11.5px;
        color: #5b6672;
    }
    #exprLegend b { color: #1f2933; }
    .exprLegendScale {
        display: block;
        position: relative;
        width: 260px;
        height: 12px;
        border-radius: 2px;
        background: linear-gradient(to right, rgb(255,255,255), rgb(24,73,180));
        box-shadow: 0 1px 4px rgba(0, 0, 0, .26);
    }
    .exprLegendTicks {
        display: block;
        position: relative;
        width: 260px;
        height: 14px;
        margin-top: 2px;
    }
    .exprLegendTicks span {
        position: absolute;
        transform: translateX(-50%);
        font-variant-numeric: tabular-nums;
    }
    #exprTableToggle { margin-left: auto; cursor: pointer; }

    /* the table view - the same numbers, for reading and for screen readers */
    #exprTableView { padding-top: 10px; }
    #exprData {
        border-collapse: collapse;
        width: 100%;
        max-width: 780px;
    }
    #exprData th,
    #exprData td {
        padding: 5px 10px;
        font-size: 12.5px;
        text-align: left;
        border-bottom: 1px solid #edf0f4;
    }
    #exprData th { font-weight: 700; }
    #exprData td.exprNum {
        text-align: right;
        font-variant-numeric: tabular-nums;
    }
    #exprData tr[data-col] { cursor: pointer; }
    #exprData tr[data-col]:hover { background: #f8fafc; }
    #exprData tr.is-selected { background: #eaf2fb; }
</style>
<%@ include file="../sectionHeader.jsp"%>
<%
    RGDManagementDAO managementDAO = new RGDManagementDAO();
    Gene obj = (Gene) request.getAttribute("reportObject");
    RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    GeneExpressionDAO gedao = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    List<String> terms = xdao.getAllSlimTermsOrdered("UBERON","AGR");

    // The ribbon carries one row per expression level. getValueCountsByGeneRgdIdTermAndUnit
    // hands back every level for a system in a single query, so the four extra rows
    // cost no more round trips than the single "all" row used to.
    //
    // Level keys are folded to lowercase with spaces and underscores stripped, because
    // GENE_EXPRESSION_VALUE_COUNTS is not consistent about "below cutoff" vs
    // "below_cutoff" - the Vue filter below hedges the same three ways.
    final String[] RIBBON_LEVELS  = {"all", "high", "medium", "low", "belowcutoff"};
    final String[] RIBBON_LABELS  = {"All", "High", "Medium", "Low", "Below cutoff"};
    final String[] RIBBON_FILTERS = {"", "High", "Medium", "Low", "Below Cutoff"};
    final String[] RIBBON_TITLES  = {"All samples",
                                     "High: TPM > 1000",
                                     "Medium: 10 < TPM <= 1000",
                                     "Low: 0.5 <= TPM <= 10",
                                     "Below cutoff: TPM < 0.5"};

    List<String> include = new ArrayList<>();
    HashMap<String,String> termCnt = new HashMap<>();                       // term -> "all" count, as before
    HashMap<String,HashMap<String,Integer>> termLevelCnt = new HashMap<>(); // term -> level -> count

    for (String term : terms){
        List<GeneExpressionValueCount> counts =
                gedao.getValueCountsByGeneRgdIdTermAndUnit(obj.getRgdId(), term, "TPM");
        if( counts==null || counts.isEmpty() ) {
            continue;
        }

        HashMap<String,Integer> byLevel = new HashMap<>();
        for( GeneExpressionValueCount c: counts ) {
            String lvl = c.getLevel()==null ? "" : c.getLevel().trim().toLowerCase().replaceAll("[ _]", "");
            Integer running = byLevel.get(lvl);
            byLevel.put(lvl, (running==null ? 0 : running) + c.getValueCnt());
        }

        // same admission test as before: a system is shown when it has an "all" count
        if( !byLevel.containsKey("all") ) {
            continue;
        }
        include.add(term);
        termCnt.put(term, String.valueOf(byLevel.get("all")));
        termLevelCnt.put(term, byLevel);
    }
%>

<div class="light-table-border">
    <div class="sectionHeading" id="rnaSeqExpression" style="padding-bottom: 5px">RNA-SEQ Expression</div>
    <input type="hidden" id="geneRgdId" value="<%=obj.getRgdId()%>">
    <label style="font-size: 16px">
        <b>Rows are expression levels, columns are anatomical systems. Click a square for the detailed data table, filtered to that level. Darker means more samples; hover for the exact count.</b>
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
    <div id="expresTable">

        <%
            // Alliance / GO ribbon heat scale, verbatim from wc-ribbon's heatColor():
            //     fraction = min(10 * ln(level + 1), maxHeatLevel) / maxHeatLevel
            //     colour   = minColour + fraction * (maxColour - minColour)
            // The log step is what stops the largest systems from flattening the rest.
            // wc-ribbon defaults maxHeatLevel to 48 because it counts GO annotations
            // (tens); these are sample counts (thousands), so the ceiling is raised to
            // saturate near 8,000 instead of near 120. It stays a fixed ceiling, so a
            // shade means the same count in every row and on every gene report.
            final double MAX_HEAT = 90.0;
            final int[] MIN_COLOR = {255, 255, 255};
            final int[] MAX_COLOR = {24, 73, 180};

            java.util.List<String> ribbonLabel = new ArrayList<>();
            for( String t: include ) {
                Term aTerm = xdao.getTermByAccId(t);
                String label = (aTerm!=null && aTerm.getTerm()!=null) ? aTerm.getTerm() : t;
                ribbonLabel.add(org.apache.commons.text.StringEscapeUtils.escapeHtml4(label));
            }
        %>

        <div class="ribbon" id="exprRibbon">

            <div class="ribbonCategory">
                <span class="ribbonRowLabel">&nbsp;</span>
                <% for( int i = 0; i < include.size(); i++ ) { %>
                <span class="ribbonCategoryLabel" data-col="<%=i%>"
                      title="<%=ribbonLabel.get(i)%>"><%=ribbonLabel.get(i)%></span>
                <% } %>
            </div>

            <% for( int r = 0; r < RIBBON_LEVELS.length; r++ ) { %>
            <div class="ribbonRow">
                <span class="ribbonRowLabel" title="<%=RIBBON_TITLES[r]%>"><%=RIBBON_LABELS[r]%></span>
                <%
                    for( int i = 0; i < include.size(); i++ ) {
                        String t = include.get(i);
                        Integer boxed = termLevelCnt.get(t).get(RIBBON_LEVELS[r]);
                        int cnt = boxed==null ? 0 : boxed;
                        String cntShown = String.format("%,d", cnt);

                        double fraction = Math.min(10.0 * Math.log(cnt + 1.0), MAX_HEAT) / MAX_HEAT;
                        StringBuilder rgb = new StringBuilder("rgb(");
                        for( int c = 0; c < 3; c++ ) {
                            rgb.append(Math.round(MIN_COLOR[c] + fraction * (MAX_COLOR[c] - MIN_COLOR[c])));
                            rgb.append(c < 2 ? "," : ")");
                        }

                        if( cnt == 0 ) {
                %>
                <span class="ribbonCell ribbonCell--empty"
                      title="<%=ribbonLabel.get(i)%> - no <%=RIBBON_LABELS[r].toLowerCase()%> samples"></span>
                <%      } else { %>
                <span class="ribbonCell"
                      data-col="<%=i%>"
                      tabindex="0"
                      role="button"
                      aria-label="<%=ribbonLabel.get(i)%>, <%=RIBBON_LABELS[r]%>, <%=cntShown%> samples"
                      title="<%=ribbonLabel.get(i)%> - <%=cntShown%> <%=RIBBON_LABELS[r].toLowerCase()%> samples"
                      style="background-color: <%=rgb%>;"
                      v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>','<%=termCnt.get(t)%>')"
                      onclick="highlightCurrent('<%=i%>','<%=t%>'); selectExprLevel('<%=RIBBON_FILTERS[r]%>');"
                      onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();this.click();}"></span>
                <%      }
                    } %>
            </div>
            <% } %>
        </div>

        <div id="exprLegend">
            <b>Samples</b>
            <span style="display: inline-block;">
                <span class="exprLegendScale"></span>
                <span class="exprLegendTicks">
                    <%
                        int[] ticks = {1, 10, 100, 1000, 8000};
                        for( int tick: ticks ) {
                            double pct = 100.0 * Math.min(10.0 * Math.log(tick + 1.0), MAX_HEAT) / MAX_HEAT;
                    %>
                    <span style="left: <%=String.format("%.1f", pct)%>%;"><%=String.format("%,d", tick)%><%=tick==8000?"+":""%></span>
                    <% } %>
                </span>
            </span>
            <a href="javascript:void(0)" id="exprTableToggle" onclick="toggleExprTableView()">Show data table</a>
        </div>

        <div id="exprTableView" style="display: none;">
            <table id="exprData" name="exprData">
                <tr>
                    <th scope="col">System</th>
                    <% for( int r = 0; r < RIBBON_LABELS.length; r++ ) { %>
                    <th scope="col" class="exprNum" title="<%=RIBBON_TITLES[r]%>"><%=RIBBON_LABELS[r]%></th>
                    <% } %>
                </tr>
                <% for( int i = 0; i < include.size(); i++ ) {
                       String t = include.get(i); %>
                <tr data-col="<%=i%>"
                    v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>','<%=termCnt.get(t)%>')"
                    onclick="highlightCurrent('<%=i%>','<%=t%>'); selectExprLevel('');">
                    <td><%=ribbonLabel.get(i)%></td>
                    <% for( String lvl: RIBBON_LEVELS ) {
                           Integer boxed = termLevelCnt.get(t).get(lvl); %>
                    <td class="exprNum"><%=boxed==null ? "&ndash;" : String.format("%,d", boxed)%></td>
                    <% } %>
                </tr>
                <% } %>
            </table>
        </div>

        <input type="button" id="hideBtn1" onclick="hideTable()" style="display: none;top: 5px;position: relative;" value="Hide Table">
        <div id="tooManyMsg" style="display: none;">
            <label style="color: red; padding-top: 10px;">Too many to show, limit is 6000. Download them if you would like to view them all.</label>
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
                        <span v-html="data.value" title="Click to see more information about the study"></span>
                    </template>
                </b-table>
            </template>
        </div>
    </div>
<%--    <input type="button" id="hideBtn2" onclick="hideTable()" style="display: none;" value="Hide Table">--%>
</div>

<%@ include file="../sectionFooter.jsp"%>

<script>
    var apiUrl = "<%=getAPIHostname()%>";
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
                        label: 'Source Sample ID',
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
                        label: 'RGD Study Report',
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
            createTable(termAcc,rgdId,count){
                // clear table if full
                // termAcc = termAcc.replace(':','%3A')
                // Reset filters when loading new data
                this.selectedLevels = [];
                var download = document.getElementById("downloadTerm"+termAcc);
                download.style.display = 'block';
                // Limit display to 6000 records; if the count for this system exceeds 6000,
                // show the "too many" message and skip loading the table (user can still download)
                var recordCount = parseInt(String(count).replace(/[^0-9]/g, ''), 10);
                if (!isNaN(recordCount) && recordCount > 6000) {
                    this.expItems = [];
                    tableVue.isBusy = false;
                    var coolTableDiv = document.getElementById("coolTable");
                    if (coolTableDiv)
                        coolTableDiv.style.display = 'none';
                    var hideBtn = document.getElementById("hideBtn1");
                    if (hideBtn)
                        hideBtn.style.display = 'block';
                    showErrorMessage();
                    return;
                }
                // Show the table container up front with an empty dataset so the
                // b-table's busy spinner is visible while the fetch is in flight
                // (previously the spinner never appeared because showTable was
                // only called after the AJAX success, by which point isBusy was
                // already false and there was nothing to show a spinner in).
                tableVue.expItems = [];
                tableVue.isBusy = true;
                showTable(termAcc);

                // RGDD followup: call the server's enriched /rows endpoint that
                // pre-joins strain/tissue names, assembly name, and study refs.
                // Replaces the previous four-nested-AJAX explosion (~4 requests
                // per record) that made large categories unusable.
                var _rgdwsHost = "https://rest.rgd.mcw.edu";
                if (window.location.host.indexOf('localhost') > -1) {
                    // Local dev: hit the dev REST server (running rgd-web-services
                    // standalone locally is a separate setup).
                    _rgdwsHost = "https://dev.rgd.mcw.edu";
                }
                $.ajax({
                    type: "GET",
                    url: _rgdwsHost + "/rgdws/expression/" + termAcc + "/" + rgdId + "/TPM/rows",
                    dataType: "json",
                    success: function (rows, status, xhr) {
                        tableVue.expItems = rows || [];
                        tableVue.isBusy = false;
                    },
                    error: function (xhr, status, error) {
                        console.log("Result: " + status + " " + error + " " + xhr.status + " " + xhr.statusText);
                        tableVue.isBusy = false;
                    }
                });
                return;

                // Legacy path preserved below in case someone needs to revert.
                var someItems = [];
                $.ajax({
                    type: "GET",
                    url: apiUrl+"/rgdws/expression/"+termAcc+"/"+rgdId+"/TPM",
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
                                    url: apiUrl+"/rgdws/expression/study/references/" + studyId,
                                    dataType: "json",
                                    success: function (refRes, status, xhr) {
                                        refRes.forEach((ref) => {
                                            reference.push(ref);
                                        })
                                        $.ajax({
                                            type: "GET",
                                            url: apiUrl+"/rgdws/maps/assembly/" + mapKey,
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
                                                        url: apiUrl+"/rgdws/ontology/term/" + strainTerm,
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
                                                                    url: apiUrl+"/rgdws/ontology/term/" + tissue,
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
                                                            url: apiUrl+"/rgdws/ontology/term/" + tissue,
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

    // marks the system whose detail table is open, in the heatmap and in the table
    // view at once. hideTable() calls this with -1 to clear the selection.
    function highlightCurrent(colNum, termAcc) {
        var marks = document.querySelectorAll("#exprRibbon [data-col], #exprTableView tr[data-col]");
        for (var i = 0; i < marks.length; i++) {
            var selected = String(marks[i].getAttribute("data-col")) === String(colNum);
            marks[i].classList.toggle("is-selected", selected);
        }
    }

    // clicking a level row also narrows the detail table to that level, so the
    // High row and the Low row do not open the same thing. "" clears the filter.
    function selectExprLevel(level) {
        if (typeof tableVue === "undefined" || !tableVue) {
            return;
        }
        tableVue.selectedLevels = level ? [level] : [];
    }

    function toggleExprTableView() {
        var view = document.getElementById("exprTableView");
        var toggle = document.getElementById("exprTableToggle");
        var show = view.style.display === "none";
        view.style.display = show ? "block" : "none";
        toggle.textContent = show ? "Hide data table" : "Show data table";
    }
    tableVue;
</script>