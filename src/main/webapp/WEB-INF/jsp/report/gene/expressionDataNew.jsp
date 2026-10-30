<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDManagementDAO" %>
<%@ page import="edu.mcw.rgd.expression.ExpressionIndexCounts" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="static edu.mcw.rgd.web.RgdContext.getAPIHostname" %>
<%!
    /* Reading one cell out of the per-assembly counts. byTissuePerMapKey omits a system an
       assembly has no records for, and omits a level that system has none at, so every lookup is
       two levels of "might not be there" - which inline in the markup below would bury the
       ribbon in null checks. Declarations rather than scriptlet locals because a scriptlet
       cannot hold a method, and this page is <jsp:include>d, so it compiles as its own servlet. */
    private static java.util.Map<String,Integer> exprLevels(
            java.util.Map<Integer, java.util.LinkedHashMap<String, java.util.Map<String,Integer>>> all,
            Integer mapKey, String term) {

        java.util.LinkedHashMap<String, java.util.Map<String,Integer>> perTerm = all.get(mapKey);
        return perTerm==null ? null : perTerm.get(term);
    }

    /** records this assembly has for this system at this level; 0 when it has none */
    private static int exprCount(
            java.util.Map<Integer, java.util.LinkedHashMap<String, java.util.Map<String,Integer>>> all,
            Integer mapKey, String term, String level) {

        java.util.Map<String,Integer> perLevel = exprLevels(all, mapKey, term);
        if( perLevel==null ) {
            return 0;
        }
        Integer n = perLevel.get(level);
        return n==null ? 0 : n;
    }
%>

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
    /* Wide enough for the longest level plus its TPM range on one line - "Medium
       (10 < TPM <= 1000)". The angled system names above are spaced off a .ribbonRowLabel used
       as a spacer, so widening this keeps the header and the rows in step by itself. */
    .ribbonRowLabel {
        display: inline-block;
        width: 162px;
        font-size: 12.5px;
        font-weight: 700;
        color: #1f2933;
        vertical-align: bottom;
    }
    /* the band is what the level means, not a second label - it sits back from the name */
    .ribbonRowRange {
        font-size: 11px;
        font-weight: 400;
        color: #5b6672;
        white-space: nowrap;
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
    /* a system with no records at this level - present, but not a target */
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

    /* caption over the detail table: says which square is open, since the square is the
       filter now and there are no controls here to read the state off */
    #exprTableCaption {
        display: flex;
        align-items: baseline;
        flex-wrap: wrap;
        gap: 4px 10px;
        margin-bottom: 10px;
        padding: 7px 10px;
        font-size: 13px;
        color: #1f2933;
        background: #f8fafc;
        border: 1px solid #edf0f4;
        border-radius: 4px;
    }
    #exprTableCaption .exprCaptionCount {
        font-variant-numeric: tabular-nums;
        font-weight: 700;
    }
    #exprTableCaption .exprCaptionHint {
        margin-left: auto;
        font-size: 11.5px;
        color: #5b6672;
    }

    /* a note under the caption when the result runs past the index's reachable window,
       or when the page could not be loaded at all */
    .exprTableNote {
        margin-bottom: 10px;
        padding: 7px 10px;
        font-size: 12px;
        border-radius: 4px;
    }
    .exprTableNote--info {
        color: #5b4708;
        background: #fdf6e3;
        border: 1px solid #f2e2b4;
    }
    .exprTableNote--error {
        color: #8a1c1c;
        background: #fdf0f0;
        border: 1px solid #f2c9c9;
    }

    /* Condition cell: one line per ordinality step, the step number hanging to the left so the
       condition names stay aligned with each other and wrap under themselves. Only rendered for
       records with more than one step. */
    #exprRecords td .exprCondStep {
        padding-left: 1.35em;
        text-indent: -1.35em;
    }
    #exprRecords td .exprCondStep + .exprCondStep {
        margin-top: 2px;
    }
    #exprRecords td .exprCondStepNum {
        display: inline-block;
        /* min-width, not width: curated ordinalities run 1-6 today, so a two-digit step would
           just shift its own line rather than overrun the number into the condition name */
        min-width: 1.35em;
        text-indent: 0;
        font-variant-numeric: tabular-nums;
        color: #5b6672;
    }

    /* pager under the detail table: rows-per-page on the left, the page buttons in the
       middle, the range being shown on the right */
    #exprPager {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 6px 16px;
        padding-top: 10px;
        font-size: 12.5px;
        color: #1f2933;
    }
    #exprPager .exprPageSize select {
        margin-left: 4px;
        padding: 1px 4px;
        font-size: 12.5px;
    }
    #exprPager .pagination { margin-bottom: 0; }
    #exprPager .exprPageInfo {
        margin-left: auto;
        font-variant-numeric: tabular-nums;
        color: #5b6672;
    }


    /* Assembly picker. A sample aligned to several assemblies is a separate record per assembly,
       so the ribbon can only report one assembly at a time; this is what says which. Drawn only
       when the gene has records on more than one. */
    #exprAssemblyChoice {
        display: flex;
        align-items: baseline;
        flex-wrap: wrap;
        gap: 4px 18px;
        margin: 14px 0 4px;
        padding: 7px 12px 9px;
        border: 1px solid #edf0f4;
        border-radius: 4px;
        background: #f8fafc;
    }
    #exprAssemblyChoice legend {
        float: none;              /* the report pages' base css floats a legend */
        width: auto;
        margin: 0 4px 0 0;
        padding: 0;
        font-size: 12px;
        font-weight: 700;
        line-height: inherit;
        color: #5b6672;
        border: 0;
        text-transform: uppercase;
        letter-spacing: .04em;
    }
    .exprAssemblyOption {
        display: inline-flex;
        align-items: baseline;
        gap: 5px;
        margin: 0;
        font-size: 13px;
        font-weight: 400;
        color: #1f2933;
        cursor: pointer;
    }
    .exprAssemblyOption input { margin: 0; cursor: pointer; }
    /* how many records the assembly carries - the ribbon's own total, so the choice can be made
       without opening each one in turn */
    .exprAssemblyCount {
        font-size: 11.5px;
        color: #5b6672;
        font-variant-numeric: tabular-nums;
    }
    /* the table view - the same numbers, for reading and for screen readers */
    #exprTableView { padding-top: 10px; }
    .exprData {
        border-collapse: collapse;
        width: 100%;
        max-width: 780px;
    }
    .exprData th,
    .exprData td {
        padding: 5px 10px;
        font-size: 12.5px;
        text-align: left;
        border-bottom: 1px solid #edf0f4;
    }
    .exprData th { font-weight: 700; }
    .exprData td.exprNum {
        text-align: right;
        font-variant-numeric: tabular-nums;
    }
    .exprData tr[data-col][onclick] { cursor: pointer; }
    .exprData tr[data-col][onclick]:hover { background: #f8fafc; }
    .exprData tr.is-selected { background: #eaf2fb; }
</style>
<%@ include file="../sectionHeader.jsp"%>
<%
    RGDManagementDAO managementDAO = new RGDManagementDAO();
    Gene obj = (Gene) request.getAttribute("reportObject");
    RgdId rgdId = managementDAO.getRgdId(obj.getRgdId());
    OntologyXDAO xdao = new OntologyXDAO();
    List<String> terms = xdao.getAllSlimTermsOrdered("UBERON","AGR");

    // The ribbon carries one row per expression level. The counts come from the rgdws
    // expression index (/rgdws/expression/index/facets?rgdIds=..&tissueIds=..&mapKey=..), which
    // is the same index and the same filter as
    // /rgdws/expression/index/records/search?tissueIds=UBERON:0002107 - so a square on the
    // ribbon and a search on that system report the same number. ExpressionIndexCounts
    // fans the ~22 systems out per assembly, in parallel, and caches per gene.
    //
    // Counts are TPM only, through the endpoint's units filter, so they line up with the TPM
    // detail table a square opens. Descendant systems are rolled up by the index itself,
    // from the ancestors it stores on each record, so the AGR slim term is passed as-is.
    //
    // The level rows are driven by what actually came back: RIBBON_LEVELS lists the rows
    // in display order, but a row with no counts anywhere is dropped below, so the ribbon
    // never shows a band of empty squares for a level the index does not carry.
    final String[] RIBBON_LEVELS  = {"all", "high", "medium", "low", "belowcutoff"};
    final String[] RIBBON_LABELS  = {"All", "High", "Medium", "Low", "Below cutoff"};
    final String[] RIBBON_FILTERS = {"", "High", "Medium", "Low", "Below Cutoff"};

    // The TPM band each level stands for, shown next to the row label so the thresholds are on
    // the plot rather than only in a tooltip. "All" spans every level, so it has no range.
    // Written as entities, not as literal > and <= - this page carries no pageEncoding (see the
    // note on activeLevelDescription() below), and entities also decode inside a title attribute,
    // which lets the tooltips be built from these and the thresholds be written once.
    final String[] RIBBON_RANGES  = {"",
                                     "TPM &gt; 1000",
                                     "10 &lt; TPM &le; 1000",
                                     "0.5 &le; TPM &le; 10",
                                     "TPM &lt; 0.5"};

    // the same thing in prose, for the counts table's numeric column headers, which have no room
    // for the range and still carry it as a tooltip
    final String[] RIBBON_TITLES  = new String[RIBBON_RANGES.length];
    RIBBON_TITLES[0] = "All expression records";
    for( int r = 1; r < RIBBON_RANGES.length; r++ ) {
        RIBBON_TITLES[r] = RIBBON_LABELS[r] + ": " + RIBBON_RANGES[r];
    }

    // Counts are per assembly. A sample aligned to several assemblies is one record per assembly
    // in the index, so a gene with three loaded assemblies reported roughly three times its
    // samples when the ribbon summed over all of them - the liver square counted the same liver
    // sample once for GRCr8, once for mRatBN7.2 and once for Rnor_6.0. The radio buttons pick one
    // assembly and the ribbon, the counts table and the detail table all answer for that one.
    //
    // Which assemblies to offer comes from the index rather than from MapManager: only the
    // assemblies the expression load actually covered have records, and that is a subset of the
    // species' assemblies.
    java.util.LinkedHashMap<Integer,Integer> asmRecordCnt =
            ExpressionIndexCounts.mapKeyCounts(obj.getRgdId(), ExpressionIndexCounts.UNIT_TPM);

    final MapManager mapManager = MapManager.getInstance();
    final HashMap<Integer, edu.mcw.rgd.datamodel.Map> asmMaps = new HashMap<>();
    for( Integer mk: asmRecordCnt.keySet() ) {
        asmMaps.put(mk, mapManager.getMap(mk));
    }

    // Listed in the database's own assembly order (MapData rows are sorted by rank the same way
    // on the position section), not by how many records each carries - so the list reads the same
    // on every gene. An assembly MapManager does not know lands last under its bare map key.
    List<Integer> asmKeys = new ArrayList<>(asmRecordCnt.keySet());
    java.util.Collections.sort(asmKeys, new java.util.Comparator<Integer>() {
        public int compare(Integer k1, Integer k2) {
            edu.mcw.rgd.datamodel.Map m1 = asmMaps.get(k1), m2 = asmMaps.get(k2);
            int r1 = m1==null ? Integer.MAX_VALUE : m1.getRank();
            int r2 = m2==null ? Integer.MAX_VALUE : m2.getRank();
            return r1!=r2 ? r1-r2 : k2-k1;   // same rank: newer map key first
        }
    });

    // Opens on the primary reference assembly, which is what the rest of the report page shows
    // positions on, so the two sections agree on what "this gene" means. A gene whose expression
    // was never loaded against the reference assembly opens on the first one it does have.
    int selectedMapKey = asmKeys.isEmpty() ? 0 : asmKeys.get(0);
    for( Integer mk: asmKeys ) {
        edu.mcw.rgd.datamodel.Map m = asmMaps.get(mk);
        if( m!=null && m.isPrimaryRefAssembly() ) {
            selectedMapKey = mk;
            break;
        }
    }

    // One fan-out for every assembly at once, so switching assemblies is a show/hide rather than
    // a round trip - each assembly's ribbon is rendered here and only one is displayed.
    java.util.LinkedHashMap<Integer, java.util.LinkedHashMap<String, java.util.Map<String,Integer>>> asmTermLevelCnt =
            ExpressionIndexCounts.byTissuePerMapKey(obj.getRgdId(), terms,
                    ExpressionIndexCounts.UNIT_TPM, asmKeys);

    // The columns are shared across assemblies: a system is a column if ANY assembly has records
    // for it, hatched empty on the assemblies that do not. Per-assembly column sets would renumber
    // the columns - Rnor_6.0 carries a fraction of the systems GRCr8 does - so the ribbon would
    // reshuffle under the cursor on every switch, and data-col would stop meaning one system.
    List<String> include = new ArrayList<>();
    for( String term: terms ) {
        for( Integer mk: asmKeys ) {
            if( exprLevels(asmTermLevelCnt, mk, term)!=null ) {
                include.add(term);
                break;
            }
        }
    }

    // mapKey -> assembly name. The index carries the numeric mapKey and nothing else, so the
    // names are emitted once here rather than looked up per row when the detail table loads.
    StringBuilder assemblyJs = new StringBuilder();
    for( edu.mcw.rgd.datamodel.Map aMap: mapManager.getAllMaps(obj.getSpeciesTypeKey()) ) {
        if( assemblyJs.length()>0 ) {
            assemblyJs.append(",");
        }
        assemblyJs.append(aMap.getKey()).append(":\"")
                .append(org.apache.commons.text.StringEscapeUtils.escapeEcmaScript(
                        aMap.getName()==null ? String.valueOf(aMap.getKey()) : aMap.getName()))
                .append("\"");
    }

    // rows to draw: keep a level only if some system on some assembly has records at it. Shared
    // across assemblies for the same reason the columns are - the ribbon keeps its height, so
    // switching assemblies does not move the rows the cursor is over.
    List<Integer> rows = new ArrayList<>();
    for( int r = 0; r < RIBBON_LEVELS.length; r++ ) {
        boolean any = false;
        for( Integer mk: asmKeys ) {
            for( String term: include ) {
                if( exprCount(asmTermLevelCnt, mk, term, RIBBON_LEVELS[r])>0 ) {
                    any = true;
                    break;
                }
            }
            if( any ) {
                break;
            }
        }
        if( any ) {
            rows.add(r);
        }
    }

    // Nothing to draw at all. byTissuePerMapKey returns only the systems that actually have
    // records, so no column on any assembly means this gene has no RNA-SEQ expression - every
    // gene of a species the expression index does not carry lands here, which is why a naked
    // mole rat or bonobo report used to show the heading, the instructions and a blank ribbon.
    // asmKeys being empty lands here too, by the same route: no assemblies, no counts, no columns.
    //
    // Returning rather than wrapping the rest in a conditional: the ribbon, the Vue detail table
    // and the script that feeds them run past the try block sectionFooter.jsp closes, where the
    // scriptlet variables are already out of scope, so one guard here is the only place that can
    // take down all three. The outer "Expression" heading in main.jsp goes with it - geneReport.js
    // hideEmptySections() drops a .subTitle whose siblings hold no table or card.
    //
    // Note this cannot tell "no data" from "the index did not answer": the counts log and omit a
    // system whose fetch fails, so an index outage reads as an empty gene and hides the section
    // rather than showing an empty ribbon.
    if( include.isEmpty() ) {
        return;
    }
%>

<div class="light-table-border">
    <div class="sectionHeading" id="rnaSeqExpression" style="padding-bottom: 5px">RNA-SEQ Expression</div>
    <input type="hidden" id="geneRgdId" value="<%=obj.getRgdId()%>">
    <label style="font-size: 16px">
        <b>Rows are expression levels, columns are anatomical systems.<%
            if( asmKeys.size()>1 ) {
        %> Counts are for the selected assembly.<%
            }
        %> Click a square for the detailed data table, filtered to that level. Darker means more expression records; hover for the exact count.</b>
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

    <%-- The assembly every panel below is showing, and what the download and the detail table
         filter on. Always present, even for a gene loaded against one assembly only, so the
         script has one place to read the selection from whether or not the radios are drawn. --%>
    <input type="hidden" id="exprMapKey" value="<%=selectedMapKey%>">
    <%
        if( asmKeys.size()>1 ) {
    %>
    <fieldset id="exprAssemblyChoice">
        <legend>Assembly</legend>
        <%
            for( Integer mk: asmKeys ) {
                edu.mcw.rgd.datamodel.Map aMap = asmMaps.get(mk);
                String asmName = org.apache.commons.text.StringEscapeUtils.escapeHtml4(
                        (aMap!=null && aMap.getName()!=null) ? aMap.getName() : String.valueOf(mk));
                int asmCnt = asmRecordCnt.get(mk)==null ? 0 : asmRecordCnt.get(mk);
        %>
        <label class="exprAssemblyOption">
            <input type="radio" name="exprAssembly" value="<%=mk%>"
                   <%=mk==selectedMapKey ? "checked" : ""%>
                   onchange="selectExprAssembly(this.value)">
            <%=asmName%>
            <span class="exprAssemblyCount" title="expression records for this gene on <%=asmName%>"><%=String.format("%,d", asmCnt)%></span>
        </label>
        <% } %>
    </fieldset>
    <% } %>

    <div id="expresTable">

        <%
            // Alliance / GO ribbon heat scale, verbatim from wc-ribbon's heatColor():
            //     fraction = min(10 * ln(level + 1), maxHeatLevel) / maxHeatLevel
            //     colour   = minColour + fraction * (maxColour - minColour)
            // The log step is what stops the largest systems from flattening the rest.
            // wc-ribbon defaults maxHeatLevel to 48 because it counts GO annotations
            // (tens); these are sample counts (thousands), so the ceiling is raised to
            // saturate near 8,000 instead of near 120. It stays a fixed ceiling, so a
            // shade means the same count in every row, on every assembly and on every
            // gene report - which is also what lets two assemblies be compared by eye
            // rather than each being normalised to its own largest system.
            final double MAX_HEAT = 90.0;
            final int[] MIN_COLOR = {255, 255, 255};
            final int[] MAX_COLOR = {24, 73, 180};

            java.util.List<String> ribbonLabel = new ArrayList<>();
            // ... and the same names as a JS lookup, so the caption over the detail table can
            // name the system it was opened from without passing a label through an attribute
            // (labels like "Peyer's patch" carry an apostrophe that would end the JS string)
            StringBuilder systemLabelJs = new StringBuilder();
            for( String t: include ) {
                Term aTerm = xdao.getTermByAccId(t);
                String label = (aTerm!=null && aTerm.getTerm()!=null) ? aTerm.getTerm() : t;
                ribbonLabel.add(org.apache.commons.text.StringEscapeUtils.escapeHtml4(label));
                if( systemLabelJs.length()>0 ) {
                    systemLabelJs.append(",");
                }
                systemLabelJs.append("\"").append(org.apache.commons.text.StringEscapeUtils.escapeEcmaScript(t))
                        .append("\":\"").append(org.apache.commons.text.StringEscapeUtils.escapeEcmaScript(label))
                        .append("\"");
            }
        %>

        <%-- One ribbon per assembly, all rendered, one shown. The counts behind them were all
             fetched in the one fan-out above, so switching is a show/hide with no round trip;
             and because the columns and rows are shared, the two ribbons are directly comparable
             square for square. --%>
        <% for( Integer mk: asmKeys ) { %>
        <div class="exprAssemblyPanel" data-mapkey="<%=mk%>"<%=mk==selectedMapKey ? "" : " style=\"display: none;\""%>>
            <div class="ribbon">

                <div class="ribbonCategory">
                    <span class="ribbonRowLabel">&nbsp;</span>
                    <% for( int i = 0; i < include.size(); i++ ) { %>
                    <span class="ribbonCategoryLabel" data-col="<%=i%>"
                          title="<%=ribbonLabel.get(i)%>"><%=ribbonLabel.get(i)%></span>
                    <% } %>
                </div>

                <% for( int r: rows ) { %>
                <div class="ribbonRow">
                    <%-- no title here: the range used to live in a tooltip and now sits on the row,
                         so repeating it would only be read out twice --%>
                    <span class="ribbonRowLabel"><%=RIBBON_LABELS[r]%><%
                        if( !RIBBON_RANGES[r].isEmpty() ) {
                    %> <span class="ribbonRowRange">(<%=RIBBON_RANGES[r]%>)</span><%
                        }
                    %></span>
                    <%
                        for( int i = 0; i < include.size(); i++ ) {
                            String t = include.get(i);
                            int cnt = exprCount(asmTermLevelCnt, mk, t, RIBBON_LEVELS[r]);
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
                          title="<%=ribbonLabel.get(i)%> - no <%=RIBBON_LABELS[r].toLowerCase()%> records"></span>
                    <%      } else { %>
                    <span class="ribbonCell"
                          data-col="<%=i%>"
                          tabindex="0"
                          role="button"
                          aria-label="<%=ribbonLabel.get(i)%>, <%=RIBBON_LABELS[r]%>, <%=cntShown%> records"
                          title="<%=ribbonLabel.get(i)%> - <%=cntShown%> <%=RIBBON_LABELS[r].toLowerCase()%> records"
                          style="background-color: <%=rgb%>;"
                          v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>','<%=cnt%>','<%=RIBBON_FILTERS[r]%>','<%=mk%>')"
                          onclick="highlightCurrent('<%=i%>','<%=t%>');"
                          onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();this.click();}"></span>
                    <%      }
                        } %>
                </div>
                <% } %>
            </div>
        </div>
        <% } %>

        <div id="exprLegend">
            <b>Expression records</b>
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

        <%-- The counts behind the ribbon as numbers, also one table per assembly. The wrapper
             carries the show/hide the toggle link drives; the panels inside it follow the
             assembly, so the two are independent - picking another assembly does not collapse
             a table the user opened. --%>
        <div id="exprTableView" style="display: none;">
            <% for( Integer mk: asmKeys ) { %>
            <div class="exprAssemblyPanel" data-mapkey="<%=mk%>"<%=mk==selectedMapKey ? "" : " style=\"display: none;\""%>>
                <table class="exprData" name="exprData">
                    <tr>
                        <th scope="col">System</th>
                        <% for( int r: rows ) { %>
                        <th scope="col" class="exprNum" title="<%=RIBBON_TITLES[r]%>"><%=RIBBON_LABELS[r]%></th>
                        <% } %>
                    </tr>
                    <% for( int i = 0; i < include.size(); i++ ) {
                           String t = include.get(i);
                           int allCnt = exprCount(asmTermLevelCnt, mk, t, ExpressionIndexCounts.LEVEL_ALL);
                           java.util.Map<String,Integer> levelCnt = exprLevels(asmTermLevelCnt, mk, t); %>
                    <tr data-col="<%=i%>"
                        <%-- a system this assembly has nothing for opens nothing: the whole row is
                             dashes, and the detail table would come back empty --%>
                        <% if( allCnt>0 ) { %>
                        v-on:click="createTable('<%=t%>','<%=rgdId.getRgdId()%>','<%=allCnt%>','','<%=mk%>')"
                        onclick="highlightCurrent('<%=i%>','<%=t%>');"
                        <% } %>>
                        <td><%=ribbonLabel.get(i)%></td>
                        <% for( int r: rows ) {
                               Integer boxed = levelCnt==null ? null : levelCnt.get(RIBBON_LEVELS[r]); %>
                        <td class="exprNum"><%=boxed==null ? "&ndash;" : String.format("%,d", boxed)%></td>
                        <% } %>
                    </tr>
                    <% } %>
                </table>
            </div>
            <% } %>
        </div>

        <input type="button" id="hideBtn1" onclick="hideTable()" style="display: none;top: 5px;position: relative;" value="Hide Table">
        <div id="coolTable" style="display: none; overflow-y: auto; padding-top: 10px;">
            <%-- The ribbon square is the filter: its system, its level and the assembly it was
                 drawn for all go into the request, so the table holds exactly what the square's
                 tooltip counted. This used to be a row of level checkboxes filtering the loaded
                 rows client side, which could disagree with the tooltip; it is a caption now,
                 not a control. --%>
            <div id="exprTableCaption">
                <b>{{ activeSystem }}</b>
                <span>&mdash; {{ activeLevel ? activeLevelDescription : 'all expression levels' }}</span>
                <span v-if="activeAssembly">&mdash; {{ activeAssembly }}</span>
                <span class="exprCaptionCount">{{ rangeLabel }}</span>
                <span class="exprCaptionHint">Click another square in the ribbon to change the system or the level. Sorting a column orders every matching record, not just the page shown.</span>
            </div>
            <%-- A system can hold more records than the index will page into; say so rather than
                 refusing to show anything, and point at the download that has no such limit. --%>
            <div class="exprTableNote exprTableNote--info" v-if="beyondWindow">
                Showing the first <b>{{ pagedRows.toLocaleString() }}</b> of
                <b>{{ totalRows.toLocaleString() }}</b> records &mdash; the search index pages no
                deeper than that. Use <b>Download Selected Expressed Objects</b> above to get them all.
            </div>
            <div class="exprTableNote exprTableNote--error" v-if="loadError">{{ loadError }}</div>
            <template>
                <%-- no-local-sorting is what makes a sorted column mean the whole result: the table
                     holds one page, so sorting it itself could only reorder those rows. The header
                     click goes to onSortChanged instead, which asks the index to order every
                     matching record and opens the first page of that ordering. --%>
                <b-table id="exprRecords" :items="expItems" :fields="fields" :busy.sync="isBusy"
                         no-local-sorting
                         :sort-by="sortBy" :sort-desc="sortDesc" v-on:sort-changed="onSortChanged"
                         responsive="sm" sticky-header="475px">
                    <template v-slot:table-busy>
                        <div class="text-center text-primary my-2">
                            <b-spinner class="align-middle"></b-spinner>
                            <strong>Loading...</strong>
                        </div>
                    </template>
                    <template #cell(strain)="data">
                        <span v-html="data.value"></span>
                    </template>
                    <%-- tissue and condition are ontology links now, so they need the same
                         v-html slot strain has (this was a <tempplate> typo before, which meant
                         the slot never registered) --%>
                    <template #cell(tissue)="data">
                        <span v-html="data.value"></span>
                    </template>
                    <template #cell(condition)="data">
                        <span v-html="data.value"></span>
                    </template>
                    <template #cell(geoStudyAcc)="data">
                        <span v-html="data.value" title="Click to see more information about the study"></span>
                    </template>
                    <template #cell(referenceRgdId)="data">
                        <span v-html="data.value"></span>
                    </template>
                </b-table>
            </template>
            <%-- Paging is server side: each page is its own /index/records/search call with page
                 and size, so a system with tens of thousands of records costs the same one page
                 of rows as a small one. --%>
            <div id="exprPager" v-if="pageCount > 1">
                <label class="exprPageSize">Rows per page
                    <select v-model.number="perPage" v-on:change="changePerPage" :disabled="isBusy">
                        <option v-for="n in pageSizes" :key="n" :value="n">{{ n }}</option>
                    </select>
                </label>
                <b-pagination
                        v-model="currentPage"
                        :total-rows="pagedRows"
                        :per-page="perPage"
                        :disabled="isBusy"
                        :limit="7"
                        v-on:change="onPageChange"
                        size="sm"
                        aria-controls="exprRecords"></b-pagination>
                <span class="exprPageInfo">Page {{ currentPage.toLocaleString() }} of {{ pageCount.toLocaleString() }}</span>
            </div>
        </div>
    </div>
<%--    <input type="button" id="hideBtn2" onclick="hideTable()" style="display: none;" value="Hide Table">--%>
</div>

<script>
    // mapKey -> assembly name for this species; the expression index returns the numeric mapKey
    // only. Emitted here because it has to be outside #expresTable, which Vue compiles as a
    // template and would warn about a <script> in, but still inside the section, because
    // scriptlet variables go out of scope with the try block sectionFooter.jsp closes.
    var ASSEMBLY_NAMES = {<%=assemblyJs%>};

    // system accession -> display name, for the caption over the detail table
    var SYSTEM_LABELS = {<%=systemLabelJs%>};
</script>

<%@ include file="../sectionFooter.jsp"%>

<script>
    const apiUrl = "<%=getAPIHostname()%>";

    // The gene report reports TPM.
    const EXPR_UNIT = "TPM";

    // The detail table is paged by the search endpoint rather than pulled in one request: a
    // square covering tens of thousands of records used to ask for all of them at once (and,
    // past 6,000, refused to show anything), which is one huge response the browser then has
    // to render. Now each page is its own request for EXPR_PAGE_SIZE rows.
    const EXPR_PAGE_SIZES = [25, 50, 100, 250];
    const EXPR_PAGE_SIZE = 100;

    // The endpoint pages by offset, capped by Elasticsearch's result window: from + size cannot
    // exceed this, so only the first EXPR_MAX_RESULT_WINDOW records of a result are reachable
    // however many match (page 100 of size 100 is a 500 from the server). Every value in
    // EXPR_PAGE_SIZES divides it evenly, so the last page is always a full one.
    // Must mirror ExpressionWebService.MAX_RESULT_WINDOW.
    const EXPR_MAX_RESULT_WINDOW = 10000;

    // An ontology field that carries one value comes back as an accession and a label in their own
    // fields (strainAcc / strainTerm). Normalize either to an array of non-empty trimmed strings so
    // a caller never builds one link out of a whole array.
    // (Same helper, same reason, as expressMiner/result.jsp.)
    function asList(v) {
        if (v == null) {
            return [];
        }
        var arr = Array.isArray(v) ? v : [v];
        var out = [];
        for (var i = 0; i < arr.length; i++) {
            var s = (arr[i] == null ? '' : String(arr[i])).trim();
            if (s) {
                out.push(s);
            }
        }
        return out;
    }

    // An ontology accession as a link. Strain accessions get the strain report, everything
    // else the ontology browser - the same split the web service uses for its own rows.
    function ontTermLink(acc, label) {
        let text = label || acc;
        if (!acc) {
            return text || "";
        }
        var href = String(acc).indexOf("RS:") === 0
            ? "/rgdweb/report/strainOnt/main.html?acc=" + encodeURIComponent(acc)
            : "/rgdweb/ontology/view.html?acc_id=" + encodeURIComponent(acc);
        return '<a href="' + href + '">' + text + '</a>';
    }

    // One ontology field as links: each accession linked under its own label, paired by position
    // and separated by commas. A single-valued field goes down the same path as a list of one, so
    // the caller does not have to know which fields the index can return several values for.
    function ontTermLinks(accs, labels) {
        var accList = asList(accs);
        var labelList = asList(labels);
        if (accList.length === 0) {
            return labelList.join(", ");   // labelled but not accessioned: plain text
        }
        var out = [];
        for (var i = 0; i < accList.length; i++) {
            out.push(ontTermLink(accList[i], labelList[i] || accList[i]));
        }
        return out.join(", ");
    }

    // A field that can carry several ontology terms is indexed as a list of objects, each holding
    // its own accession and label: conditions is [{accId, term, obsolete, ordinality}, ...]. This
    // replaced the parallel condition / conditionTerm arrays, which only lined up by position - a
    // record with two conditions had to have its two labels matched to its two accessions by
    // index, and anything that treated the field as a scalar built one link out of the whole array.
    // An entry with neither accession nor label is dropped: the index does emit bare {obsolete:0}.
    //
    // Conditions are a protocol rather than a set: `ordinality` is the step a condition belongs
    // to, and several conditions can share one step because they were applied together. The same
    // condition can also come back at a later step - RGD:2004 carries ovalbumin at both step 1 and
    // step 4 - which a flat comma list showed as an apparent duplicate. So the conditions are
    // grouped by ordinality and the steps are numbered with the curated value, not a renumbered
    // 1..n, so a gap in the ordinalities stays visible.
    //
    // A record whose conditions are all one step is left as a plain comma list: there is no
    // sequence to report, and that is the great majority of records.
    function conditionStepLinks(objs) {
        if (objs == null) {
            return "";
        }
        var arr = Array.isArray(objs) ? objs : [objs];
        var groups = [];     // [{ord, links[]}] - one entry per distinct ordinality
        var byOrd = {};
        for (var i = 0; i < arr.length; i++) {
            var o = arr[i];
            if (o == null) {
                continue;
            }
            var acc = o.accId == null ? "" : String(o.accId).trim();
            var label = o.term == null ? "" : String(o.term).trim();
            if (!acc && !label) {
                continue;
            }
            // ordinality is curated as a positive integer. Anything else - absent, 0, junk - has
            // no step to report, so those conditions group together and trail the numbered ones.
            var n = Number(o.ordinality);
            var ord = (isFinite(n) && n > 0) ? n : null;
            var key = (ord === null) ? "none" : "o" + ord;
            if (!byOrd[key]) {
                byOrd[key] = { ord: ord, links: [] };
                groups.push(byOrd[key]);
            }
            byOrd[key].links.push(ontTermLink(acc, label || acc));
        }
        if (groups.length === 0) {
            return "";
        }
        groups.sort(function (a, b) {
            if (a.ord === null) { return b.ord === null ? 0 : 1; }
            if (b.ord === null) { return -1; }
            return a.ord - b.ord;
        });
        if (groups.length === 1) {
            return groups[0].links.join(", ");
        }
        var out = [];
        for (var g = 0; g < groups.length; g++) {
            var num = (groups[g].ord === null)
                ? ''
                : '<span class="exprCondStepNum">' + groups[g].ord + '.</span> ';
            out.push('<div class="exprCondStep">' + num + groups[g].links.join(", ") + '</div>');
        }
        return out.join("");
    }

    // One record from /expression/index/records/search as a row of the detail table. A record
    // made under several experimental conditions carries them all, so its Condition cell lists
    // every one of them rather than the record appearing once per condition.
    function expressionIndexRow(rec) {
        return {
            strain: ontTermLinks(rec.strainAcc, rec.strainTerm),
            sex: rec.sex,
            computedSex: rec.computedSex,
            // The age bounds are "days from date of birth", so the cell value is the low bound -
            // a number, so the column sorts by age instead of by its own formatted text ("7 days"
            // ahead of "63 days"). formatAgeDays reads the high bound and the species off the row
            // to build the label; neither is a column of its own, and a key no field names is
            // carried by the row without being rendered.
            ageDays: rec.ageDaysFromDobLowBound,
            ageDaysHigh: rec.ageDaysFromDobHighBound,
            species: rec.species,
            tissue: ontTermLinks(rec.tissueAcc, rec.tissueTerm),
            condition: conditionStepLinks(rec.conditions),
            GeoSampleId: rec.geoSampleAcc,
            tpmValue: rec.expressionValue,
            unit: rec.expressionUnit,
            level: rec.expressionLevel,
            assembly: ASSEMBLY_NAMES[rec.mapKey] || rec.mapKey,
            geoStudyAcc: rec.geoSeriesAcc,
            // The study's reference, carried on the record by the index itself - the old /rows
            // path had to fetch it per record from /expression/study/references/{studyId}, which
            // is why this column went away with that endpoint. 0 is how the index spells "no
            // reference curated for this study", not an RGD id.
            referenceRgdId: rec.referenceRgdId
        };
    }
        var tableVue = new Vue({
        el: '#expresTable',
        data() {
            return {
                isBusy: false,
                // what the open detail table is showing, for the caption; "" level = every level
                activeSystem: '',
                activeLevel: '',
                activeAssembly: '',
                // the query the open table stands for, kept so a page change can re-issue it
                activeTerm: '',
                activeRgdId: '',
                // the assembly the open query is filtered to - always set, since every square is
                // drawn for one assembly and the counts only agree with the index if it is sent
                activeMapKey: '',
                // server side paging state. currentPage is 1-based, b-pagination's convention;
                // the request wants a 0-based page, so loadPage subtracts.
                currentPage: 1,
                perPage: EXPR_PAGE_SIZE,
                pageSizes: EXPR_PAGE_SIZES,
                // The column the index is ordering by, as its field key; '' is no sort, which is the
                // index's own order. Sent with every page request, so paging stays inside the one
                // ordering rather than each page arriving in an order of its own.
                sortBy: '',
                sortDesc: false,
                totalRows: 0,     // matching records the index reports for the whole query
                loadError: '',
                // increments per load; a response whose stamp is stale (an older page, or the
                // system the user just clicked away from) is dropped instead of drawn
                loadSeq: 0,
                fields: [
                    // One column per field the expression index actually returns, so the table is
                    // just the search response rendered. Computed sex, age and the reference were
                    // dropped when the old /rows endpoint went, because the index did not carry
                    // them; it does now, so they are columns again with no per-record fetch
                    // behind them. The experimental condition is index-only. Life stage is not a
                    // column: the age bounds next to it say the same thing in curated days.
                    //
                    // The order follows the section's own download (Strain, Sex, Computed Sex,
                    // Age, ...) so the table and the file read the same way.
                    {
                        key: 'strain',
                        label: 'Strain/Cell Line',
                        formatter: value => {
                            if (value == null || value === "")
                                return "N/A";
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'sex',
                        formatter: value => {
                            if (value == null || value === "")
                                return "N/A";
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'computedSex',
                        label: 'Computed Sex',
                        formatter: value => {
                            if (value == null || value === "")
                                return "N/A";
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'ageDays',
                        label: 'Age',
                        formatter: 'formatAgeDays',
                        sortable: true
                    },
                    {
                        key: 'tissue',
                        formatter: value => {
                            if (value == null || value === "")
                                return "No Tissue Available";
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'condition',
                        label: 'Condition',
                        formatter: value => {
                            if (value == null || value === "")
                                return "N/A";
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'GeoSampleId',
                        label: 'Source Sample ID',
                        formatter: value => {
                            if (value == null || value === "")
                                return "N/A";
                            return value;
                        },
                        sortable: true
                    },
                    {
                        key: 'tpmValue',
                        label: 'Value',
                        formatter: value => {
                            if (value == null || isNaN(value))
                                return "N/A";
                            return parseFloat(Number(value).toFixed(3));
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
                        sortable: true
                    },
                    {
                        key: 'assembly',
                        sortable: true
                    },
                    {
                        key: 'referenceRgdId',
                        label: 'Reference',
                        formatter: 'createReferenceLink',
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
            // The level in the caption, with the cutoff it stands for. The cutoff symbols are
            // written as JS escapes: this page carries no pageEncoding, so a raw multi-byte
            // character in the source comes out mojibake.
            activeLevelDescription() {
                return {
                    'High':         'High expression (TPM > 1000)',
                    'Medium':       'Medium expression (10 < TPM \u2264 1000)',
                    'Low':          'Low expression (0.5 \u2264 TPM \u2264 10)',
                    'Below Cutoff': 'Below cutoff (TPM < 0.5)'
                }[this.activeLevel] || this.activeLevel;
            },
            // How many of the matching records the pager can actually walk to: everything the
            // result window reaches, rounded down to a whole page so the last page is full and
            // no page asks the endpoint for an offset it answers with a 500.
            pagedRows() {
                var reachable = Math.floor(EXPR_MAX_RESULT_WINDOW / this.perPage) * this.perPage;
                return Math.min(this.totalRows, reachable);
            },
            pageCount() {
                return Math.max(1, Math.ceil(this.pagedRows / this.perPage));
            },
            // true when the query matched more than the pager can reach - the download is then
            // the only way to see the rest, and the note over the table says so
            beyondWindow() {
                return this.totalRows > this.pagedRows;
            },
            // "1-100 of 11,927 records", the range this page covers within the whole result
            rangeLabel() {
                if (this.totalRows === 0) {
                    return this.isBusy ? '' : '0 records';
                }
                var first = (this.currentPage - 1) * this.perPage + 1;
                var last = Math.min(first + this.expItems.length - 1, this.totalRows);
                if (this.totalRows <= this.perPage) {
                    return this.totalRows.toLocaleString() + ' records';
                }
                return first.toLocaleString() + '-' + last.toLocaleString()
                    + ' of ' + this.totalRows.toLocaleString() + ' records';
            }
        },
        methods: {
            // The square that was clicked is the filter: its system and its level are both sent
            // to the index, so the table is the answer to the query the square stands for. Level
            // is a parameter of this one handler rather than something a second click handler
            // sets - an element's inline onclick attribute is registered before Vue attaches its
            // v-on listener (Vue's attrs module runs before its events module), so an onclick
            // that set the filter ran first and was wiped by this method's own reset, and every
            // level square opened the whole system.
            //
            // mapKey is a parameter for the same reason: a square belongs to one assembly, and
            // sending it is what keeps the table the answer to the square that was clicked rather
            // than to every assembly summed together.
            createTable(termAcc,rgdId,count,level,mapKey){
                // clear table if full
                // termAcc = termAcc.replace(':','%3A')
                this.activeSystem = SYSTEM_LABELS[termAcc] || termAcc;
                this.activeLevel = level || '';
                this.activeTerm = termAcc;
                this.activeRgdId = rgdId;
                this.activeMapKey = (mapKey == null) ? '' : String(mapKey);
                this.activeAssembly = ASSEMBLY_NAMES[this.activeMapKey] || this.activeMapKey;
                var download = document.getElementById("downloadTerm"+termAcc);
                download.style.display = 'block';

                // A new square is a new query: back to the first page. The ribbon already knows
                // how many records the square stands for, so seed the total from it and the pager
                // is drawn right away rather than after the first response; the response's own
                // total then replaces it (they agree - both are this index, this filter).
                var recordCount = parseInt(String(count).replace(/[^0-9]/g, ''), 10);
                this.totalRows = isNaN(recordCount) ? 0 : recordCount;
                this.currentPage = 1;
                showTable(termAcc);
                this.loadPage();
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
            // One page of the open query, from the expression index: the same index, gene, system,
            // unit, level and assembly the ribbon square was drawn from, so the totals agree with
            // the square's tooltip. Descendant systems are rolled up by the index. Levels are
            // indexed lower case, and expressionLevel is an exact match.
            //
            // Only the page being looked at is fetched. The whole result used to come down in one
            // request - which meant a system with more than 6,000 records was refused outright
            // rather than shown - so the cost of opening a square no longer grows with how much
            // the gene is expressed.
            loadPage(){
                var vm = this;
                if (!this.activeTerm) {
                    return;
                }
                // clamp to what the pager can serve, so a stale currentPage can never ask the
                // endpoint for an offset past the result window (it answers those with a 500)
                var page = Math.min(Math.max(1, this.currentPage), this.pageCount);
                if (page !== this.currentPage) {
                    this.currentPage = page;
                }

                // Rapid clicks (another square, another page) overlap; stamp each request and
                // draw only the newest response, so a slow early one cannot land on top of it.
                var seq = ++this.loadSeq;
                this.loadError = '';
                // Empty the rows up front so the b-table's busy spinner has something to show
                // while the fetch is in flight, instead of the previous page sitting there.
                this.expItems = [];
                this.isBusy = true;

                $.ajax({
                    type: "GET",
                    url: apiUrl + "/rgdws/expression/index/records/search"
                        + "?rgdIds=" + encodeURIComponent(this.activeRgdId)
                        + "&tissueIds=" + encodeURIComponent(this.activeTerm)
                        + "&units=" + encodeURIComponent(EXPR_UNIT)
                        + (this.activeLevel ? "&expressionLevel=" + encodeURIComponent(this.activeLevel.toLowerCase()) : "")
                        + (this.activeMapKey ? "&mapKey=" + encodeURIComponent(this.activeMapKey) : "")
                        + "&page=" + (page - 1)   // the endpoint pages from 0, the pager from 1
                        + "&size=" + this.perPage
                        // Sorting is the endpoint's job: it orders all the matching records and
                        // returns the requested page of that order. Omitted when no column is
                        // sorted, so the index's own order is what comes back.
                        + (this.sortBy ? "&sortBy=" + encodeURIComponent(this.sortBy)
                                       + "&sortOrder=" + (this.sortDesc ? "desc" : "asc") : ""),
                    dataType: "json",
                    success: function (resp, status, xhr) {
                        if (seq !== vm.loadSeq) return;  // superseded by a newer square or page
                        var records = (resp && resp.records) ? resp.records : [];
                        if (resp && resp.total != null) {
                            vm.totalRows = resp.total;
                        }
                        vm.expItems = records.map(expressionIndexRow);
                        vm.isBusy = false;
                    },
                    error: function (xhr, status, error) {
                        if (seq !== vm.loadSeq) return;
                        console.log("Result: " + status + " " + error + " " + xhr.status + " " + xhr.statusText);
                        vm.loadError = "Could not load these expression records. Please try again, "
                            + "or use the download link above to get the data.";
                        vm.isBusy = false;
                    }
                });
            },
            // b-pagination has already moved its own model by the time change fires; take the page
            // it hands over so the fetch cannot read a half-updated currentPage.
            onPageChange(page){
                this.currentPage = page;
                this.loadPage();
                this.scrollTableTop();
            },
            // A column header was clicked. The rows on screen are one page of the result, so the
            // new order has to come from the index: re-issue the open query with the column and
            // direction the header asked for.
            //
            // The values are read off the event's context rather than from sortBy/sortDesc, which
            // are bound one way and so still hold the previous sort at this point.
            onSortChanged(ctx){
                this.sortBy = ctx.sortBy || '';
                this.sortDesc = !!ctx.sortDesc;
                // A different order is a different page 1: the record that was at the top of page 4
                // is now wherever the whole result puts it, so staying on page 4 would open the
                // table at an arbitrary place in the new ordering.
                this.currentPage = 1;
                this.loadPage();
                this.scrollTableTop();
            },
            // The table body is its own 475px scroller; without this a new page or a new sort opens
            // wherever the last one was left scrolled to, which reads as a missing first row.
            scrollTableTop(){
                this.$nextTick(function () {
                    var body = document.querySelector("#coolTable .b-table-sticky-header, #coolTable .table-responsive");
                    if (body) body.scrollTop = 0;
                });
            },
            // A different page size renumbers the pages, so go back to the first one rather than
            // landing on whatever row the old page number now points at.
            changePerPage(){
                this.currentPage = 1;
                this.loadPage();
            },
            // The assembly radio moved. The ribbons are already drawn for every assembly, so this
            // only has to re-aim the open detail table; selectExprAssembly() does the show/hide.
            //
            // The square stays selected rather than the table closing: the columns and rows are
            // the same on every assembly, so "liver, medium" means the same thing on the new one
            // and showing it there is the comparison the radio was clicked for. The seeded total
            // is dropped because it came from the old assembly's square - the response carries
            // the new one, and a system this assembly has no records for honestly reads as 0.
            switchAssembly(mapKey){
                this.activeMapKey = (mapKey == null) ? '' : String(mapKey);
                this.activeAssembly = ASSEMBLY_NAMES[this.activeMapKey] || this.activeMapKey;
                if (!this.activeTerm) {
                    return;              // no table open, nothing to reload
                }
                this.totalRows = 0;
                this.currentPage = 1;
                this.loadPage();
            },
            // Back to no open query, for when the table is hidden.
            resetTable(){
                this.loadSeq++;          // drop any response still in flight
                this.activeTerm = '';
                this.activeRgdId = '';
                this.activeMapKey = '';
                this.activeSystem = '';
                this.activeLevel = '';
                this.activeAssembly = '';
                this.expItems = [];
                this.totalRows = 0;
                this.currentPage = 1;
                // The sort is dropped with the query here, so the next square opens in the index's
                // own order. It is deliberately kept across createTable and switchAssembly: those
                // re-aim the same table at a different filter, where the column the user chose to
                // order by still means the same thing.
                this.sortBy = '';
                this.sortDesc = false;
                this.loadError = '';
                this.isBusy = false;
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
            // The sample's age. The index carries it as two bounds in days from date of birth,
            // so a range is printed as a range and a single day as one number.
            //
            // Both bounds 0 is how an uncurated age is stored, not "born today" - every other
            // place this is rendered (the section's download, ExpressionDataController) reads it
            // that way too, so it is N/A here rather than "0 days".
            //
            // A negative bound is a sample taken before birth, which as "-2 days" means nothing
            // to a reader: it is shifted onto the scale the curators use, days post conception
            // for human and embryonic days otherwise, gestation being ~22 days in rat. That is
            // the same conversion, and the same 22, as expressionDownload.jsp. Non-human means
            // rat in practice - the only pre-birth records in the index are on rat assemblies -
            // so no other species' gestation is being approximated by it today.
            formatAgeDays(value, key, item){
                var lo = Number(value);
                if (!isFinite(lo)) {
                    lo = 0;
                }
                var hi = Number(item == null ? lo : item.ageDaysHigh);
                if (!isFinite(hi)) {
                    hi = lo;
                }
                if (lo === 0 && hi === 0) {
                    return "N/A";
                }
                var unit = " days";
                if (lo < 0 || hi < 0) {
                    var human = item != null && String(item.species).toLowerCase() === "human";
                    var gestation = human ? 280 : 22;
                    unit = human ? " days post conception" : " embryonic days";
                    lo += gestation;
                    hi += gestation;
                }
                return (lo === hi ? String(lo) : lo + " - " + hi) + unit;
            },
            // The record's reference as a link to its reference report. One scalar RGD id per
            // record, so unlike createLinks - which took the array the old per-study fetch built -
            // there is nothing to join. 0 is the index's "no reference curated", so it reads N/A
            // the same as an absent field rather than linking RGD:0.
            createReferenceLink(data){
                var id = parseInt(data, 10);
                if (!id) {
                    return "N/A";
                }
                return '<a href="/rgdweb/report/reference/main.html?id=' + id + '">RGD:' + id + '</a>';
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
                            term: "UBERON:9999999",
                            // the assembly on screen, so the csv holds the records the ribbon
                            // just counted rather than the same sample once per assembly
                            mapKey: selectedExprMapKey()
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
                            term: termAcc,
                            mapKey: selectedExprMapKey()
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
        tableVue.resetTable();
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

    // marks the system whose detail table is open, in the heatmap and in the table
    // view at once. hideTable() calls this with -1 to clear the selection.
    //
    // Every assembly's panel is marked, not only the visible one: the columns mean the same
    // system on all of them, so the selection is still on the right column after a switch.
    function highlightCurrent(colNum, termAcc) {
        var marks = document.querySelectorAll(".exprAssemblyPanel [data-col], #exprTableView tr[data-col]");
        for (var i = 0; i < marks.length; i++) {
            var selected = String(marks[i].getAttribute("data-col")) === String(colNum);
            marks[i].classList.toggle("is-selected", selected);
        }
    }

    // Shows the picked assembly's ribbon and counts table and hides the others, then points the
    // open detail table at it. Every panel is already in the page, so there is nothing to fetch
    // for the plot; only the detail table, which is paged server side, reloads.
    function selectExprAssembly(mapKey) {
        document.getElementById("exprMapKey").value = mapKey;
        var panels = document.querySelectorAll(".exprAssemblyPanel");
        for (var i = 0; i < panels.length; i++) {
            var mine = String(panels[i].getAttribute("data-mapkey")) === String(mapKey);
            panels[i].style.display = mine ? "block" : "none";
        }
        tableVue.switchAssembly(mapKey);
    }

    // the assembly every part of this section is currently showing
    function selectedExprMapKey() {
        var input = document.getElementById("exprMapKey");
        return input ? input.value : "";
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