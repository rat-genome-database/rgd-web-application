<%@ page import="static edu.mcw.rgd.web.RgdContext.getAPIHostname" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
  String pageTitle = "Expression Miner (Results)";
  String headContent = "";
  String pageDescription = "Expression Miner results table";
%>
<%@ include file="/common/headerarea.jsp" %>

<style>
  /* Two-column layout: collapsible facet panel + results */
  .em-layout {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    max-width: 1400px;
    margin: 20px auto;
    padding: 0 20px 20px 20px;
  }

  .em-result-main {
    flex: 1 1 auto;
    min-width: 0; /* allow the table to shrink/scroll inside flex */
  }

  /* Facet panel */
  .em-facet-panel {
    flex: 0 0 270px;
    width: 270px;
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
    /* Stay pinned beside the results while the page scrolls, and cap to the viewport so the panel
       scrolls internally instead of running off the bottom of the page. */
    position: sticky;
    top: 12px;
    align-self: flex-start;
    max-height: calc(100vh - 35px);
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .em-facet-panel.collapsed { display: none; }

  /* Header and clear stay put; only the groups scroll. */
  .em-facet-panel .em-facet-header,
  .em-facet-panel .em-facet-clear { flex: 0 0 auto; }

  .em-facet-scroll {
    flex: 1 1 auto;
    overflow-y: auto;
    overflow-x: hidden;
  }

  .em-facet-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #dce8f4;
    padding: 10px 14px;
    font-size: 14px;
    font-weight: bold;
    color: #1a3a5a;
    border-bottom: 1px solid #c0d0e0;
  }

  .em-facet-close {
    background: none;
    border: none;
    color: #3a7aba;
    font-size: 18px;
    line-height: 1;
    cursor: pointer;
    padding: 0 2px;
  }
  .em-facet-close:hover { color: #1a3a5a; }

  .em-facet-clear {
    padding: 8px 14px;
    border-bottom: 1px solid #dde5ef;
  }
  .em-facet-clear a {
    display: inline-block;
    padding: 6px 12px;
    background: #eef4fb;
    border: 1px solid #cddcec;
    border-radius: 4px;
    color: #3a7aba;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
  }
  .em-facet-clear a:hover { background: #dce8f4; border-color: #3a7aba; }

  .em-facet-group { border-bottom: 1px solid #dde5ef; }

  .em-facet-group-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 9px 14px;
    font-size: 13px;
    font-weight: 600;
    color: #1a3a5a;
    cursor: pointer;
    user-select: none;
  }
  .em-facet-group-title:hover { background: #eef4fb; }

  .em-facet-caret { color: #7a8a9a; font-size: 11px; transition: transform 0.15s ease; }
  .em-facet-group.collapsed .em-facet-caret { transform: rotate(-90deg); }
  .em-facet-group.collapsed .em-facet-group-body { display: none; }

  .em-facet-group-body {
    max-height: 220px;
    overflow-y: auto;
    padding: 4px 8px 10px 14px;
  }

  .em-facet-item {
    display: flex;
    align-items: flex-start;
    gap: 7px;
    padding: 3px 0;
    font-size: 12px;
    color: #33475b;
    cursor: pointer;
    line-height: 1.35;
  }
  .em-facet-item:hover { color: #1a3a5a; }
  .em-facet-item input { margin-top: 2px; }

  .em-facet-search {
    position: sticky;
    top: 0;
    width: 100%;
    box-sizing: border-box;
    padding: 5px 8px;
    margin-bottom: 6px;
    border: 1px solid #bccada;
    border-radius: 4px;
    background: #f8fafc;
    font-size: 12px;
  }
  .em-facet-search:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 2px rgba(58, 122, 186, 0.15);
    background: #fff;
  }

  .em-facet-label { flex: 1; }
  .em-facet-count { color: #7a8a9a; white-space: nowrap; }
  .em-level-range { color: #7a8a9a; font-size: 11px; white-space: nowrap; }

  /* Heatmap toggle: stays at the top of the page (scrolls away normally). */
  .em-heatmap-bar {
    margin-bottom: 12px;
  }

  /* Filters toggle -- a compact pill that stays pinned while the results scroll, so the panel can be
     shown/hidden anywhere on the page (mirroring the sticky filter panel). It shrink-wraps the button
     and carries its own opaque background so scrolling content doesn't bleed through. */
  .em-toolbar {
    display: flex;
    width: fit-content;
    align-items: center;
    gap: 10px;
    margin-bottom: 12px;
    position: sticky;
    top: 12px;
    z-index: 30;
    padding: 6px 8px;
    border-radius: 8px;
    background: #dce8f4;
    box-shadow: 0 2px 6px rgba(0,0,0,0.18);
  }

  .em-facet-toggle {
    font-size: 13px;
    font-weight: bold;
    background: #eef4fb;
    color: #2f6699;
    border: 1px solid #bccada;
    border-radius: 4px;
    padding: 7px 14px;
    cursor: pointer;
    white-space: nowrap;
  }
  .em-facet-toggle:hover { background: #dce8f4; border-color: #3a7aba; }

  /* ---- Edit / Add-to-selection modal --------------------------------------------------------- */
  .em-edit-overlay {
    position: fixed; inset: 0; z-index: 100;
    background: rgba(20,40,60,0.45);
    display: flex; align-items: flex-start; justify-content: center;
    padding: 40px 16px; overflow-y: auto;
  }
  .em-edit-overlay.collapsed { display: none; }
  .em-edit-modal {
    background: #f4f8fc; border-radius: 8px; width: 100%; max-width: 720px;
    box-shadow: 0 8px 30px rgba(0,0,0,0.35);
  }
  .em-edit-header {
    display: flex; justify-content: space-between; align-items: center;
    padding: 14px 18px; background: #1a3a5a; color: #fff; border-radius: 8px 8px 0 0;
  }
  .em-edit-title { font-size: 16px; font-weight: bold; }
  .em-edit-close { background: none; border: none; color: #cfe0f0; font-size: 22px; cursor: pointer; line-height: 1; }
  .em-edit-close:hover { color: #fff; }
  .em-edit-body { padding: 18px; max-height: 65vh; overflow-y: auto; }
  .em-edit-footer {
    display: flex; justify-content: flex-end; gap: 10px;
    padding: 14px 18px; border-top: 1px solid #cddcec;
  }
  .em-edit-textarea {
    width: 100%; box-sizing: border-box; min-height: 64px; resize: vertical;
    padding: 8px 12px; border: 1px solid #bccada; border-radius: 4px;
    background: #fff; color: #333; font-size: 13px; font-family: inherit;
  }
  .em-edit-textarea:focus { outline: none; border-color: #3a7aba; box-shadow: 0 0 0 3px rgba(58,122,186,0.15); }
  .em-update-btn {
    font-size: 14px; font-weight: bold;
    background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
    color: #fff; border: 1px solid #1e7e34; border-radius: 4px; padding: 9px 20px; cursor: pointer;
  }
  .em-update-btn:hover { background: linear-gradient(to bottom, #34ce57 0%, #28a745 100%); }
  .em-cancel-btn {
    font-size: 14px; font-weight: bold; background: #eef4fb; color: #2f6699;
    border: 1px solid #bccada; border-radius: 4px; padding: 9px 18px; cursor: pointer;
  }
  .em-cancel-btn:hover { background: #dce8f4; border-color: #3a7aba; }

  /* Ontology picker cards (shared look with strainTissue.jsp) */
  .st-card { background: #e8f0f8; border: 1px solid #c0d0e0; border-radius: 6px; padding: 16px; margin-bottom: 16px; }
  .st-card-title {
    font-size: 15px; font-weight: bold; color: #1a3a5a; margin-bottom: 12px;
    padding-bottom: 8px; border-bottom: 1px solid #dde5ef;
    display: flex; justify-content: space-between; align-items: center;
  }
  .st-count { font-size: 12px; color: white; background: #3a7aba; padding: 2px 9px; border-radius: 10px; }
  .st-browse-btn {
    font-size: 13px; font-weight: bold;
    background: linear-gradient(to bottom, #4a8ac9 0%, #3a7aba 100%);
    color: white; border: 1px solid #2f6699; border-radius: 4px; padding: 8px 18px; cursor: pointer;
  }
  .st-browse-btn:hover { background: linear-gradient(to bottom, #5a9ada 0%, #4a8ac9 100%); }
  .st-add { display: flex; gap: 8px; align-items: center; margin-top: 12px; }
  .st-add-input {
    flex: 1; padding: 8px 12px; border: 1px solid #bccada; border-radius: 4px;
    background: #f8fafc; color: #333; font-size: 13px;
  }
  .st-add-input:focus { outline: none; border-color: #3a7aba; box-shadow: 0 0 0 3px rgba(58,122,186,0.15); background: #fff; }
  .st-add-btn {
    font-size: 13px; font-weight: bold; background: #eef4fb; color: #2f6699;
    border: 1px solid #bccada; border-radius: 4px; padding: 8px 16px; cursor: pointer; white-space: nowrap;
  }
  .st-add-btn:hover { background: #dce8f4; border-color: #3a7aba; }
  .st-add-error { color: #b34747; font-size: 12px; margin-top: 6px; min-height: 14px; }
  .st-list { list-style: none; margin: 14px 0 0 0; padding: 0; }
  .st-list-empty { color: #6a7a8a; font-size: 13px; font-style: italic; margin-top: 12px; }
  .st-row {
    display: flex; align-items: center; justify-content: space-between;
    padding: 8px 12px; background: #f8fafc; border: 1px solid #dde5ef; border-radius: 4px; margin-bottom: 6px;
  }
  .st-row-label { font-size: 13px; color: #1a3a5a; }
  .st-row-acc { font-size: 12px; color: #5a7a9a; margin-left: 6px; }
  .st-remove { background: none; border: none; color: #b34747; font-size: 16px; font-weight: bold; cursor: pointer; line-height: 1; padding: 0 4px; }
  .st-remove:hover { color: #e05050; }

  .em-result-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid rgba(255,255,255,0.3);
  }

  .em-result-title { font-size: 18px; font-weight: bold; color: #ffffff; }
  .em-result-assembly { font-size: 14px; color: #b8d4f0; }

  .em-filters {
    background: #e8f4fc;
    border-left: 4px solid #3a7aba;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #2a4a6a;
    font-size: 13px;
    line-height: 1.6;
  }

  .em-filters .chip {
    display: inline-block;
    background: #3a7aba;
    color: #fff;
    border-radius: 10px;
    padding: 1px 9px;
    font-size: 12px;
    margin: 2px 3px;
  }

  .em-status {
    padding: 14px 15px;
    margin-bottom: 20px;
    border-radius: 4px;
    font-size: 13px;
    line-height: 1.5;
  }

  .em-status.loading { background: #eef4fb; border-left: 4px solid #3a7aba; color: #2a4a6a; }
  .em-status.empty   { background: #f5e9e9; border-left: 4px solid #b34747; color: #6b1a1a; }
  .em-status.error   { background: #fdecea; border-left: 4px solid #c0392b; color: #922b21; font-weight: bold; }
  .em-status.warn    { background: #fdf3e7; border-left: 4px solid #d98c2b; color: #6b4a1a; }

  .em-table-card {
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
    overflow: hidden;
  }

  .em-table-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 18px;
    font-size: 13px;
    color: #1a3a5a;
    border-bottom: 1px solid #dde5ef;
  }

  /* Own bounded scroll region so the header can stick to the top of the table (top:0 below) instead of
     to a full-table-height box. Vertical scroll happens here; horizontal scroll is preserved. */
  .em-table-scroll { overflow: auto; max-height: calc(100vh - 90px); }

  table.em-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }

  table.em-table thead th {
    background: #dce8f4;
    color: #1a3a5a;
    text-align: left;
    padding: 10px 12px;
    font-weight: 600;
    white-space: nowrap;
    border-bottom: 1px solid #c0d0e0;
    /* Freeze the header at the top of the table's own scroll region (.em-table-scroll). */
    position: sticky;
    top: 0;
    z-index: 1;
  }

  table.em-table tbody td {
    padding: 8px 12px;
    border-bottom: 1px solid #e3ebf3;
    color: #33475b;
    vertical-align: top;
  }

  table.em-table tbody tr:nth-child(even) { background: #f3f7fb; }
  table.em-table tbody tr:hover { background: #eaf2fb; }

  table.em-table td.num { text-align: right; font-variant-numeric: tabular-nums; }

  .em-cond-list { margin: 0; padding-left: 16px; }
  .em-cond-list li { margin: 0; }

  .em-link { color: #3a7aba; text-decoration: none; }
  .em-link:hover { text-decoration: underline; }

  .em-acc { color: #7a8a9a; font-size: 11px; }
  .em-lifestage { border-bottom: 1px dotted #888; cursor: help; }

  .level-badge {
    display: inline-block;
    padding: 1px 8px;
    border-radius: 10px;
    font-size: 11px;
    font-weight: 600;
    text-transform: capitalize;
  }
  .level-high   { background: #d4edda; color: #1e6b2e; }
  .level-medium { background: #fff3cd; color: #7a5a10; }
  .level-low    { background: #f8d7da; color: #8a2a30; }
  .level-none   { background: #e2e8ee; color: #566575; }

  .form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 15px;
  }

  .backLink { color: #0052a1; text-decoration: none; font-size: 13px; }
  .backLink:hover { color: #bd80ff; text-decoration: underline; }

  /* Table pager */
  .em-pager {
    display: none;
    align-items: center;
    justify-content: center;
    gap: 12px;
    padding: 12px;
    border-top: 1px solid #dde5ef;
    font-size: 13px;
    color: #1a3a5a;
  }
  .em-pager button {
    font-size: 13px;
    font-weight: bold;
    background: #eef4fb;
    color: #2f6699;
    border: 1px solid #bccada;
    border-radius: 4px;
    padding: 6px 14px;
    cursor: pointer;
  }
  .em-pager button:hover:not([disabled]) { background: #dce8f4; border-color: #3a7aba; }
  .em-pager button[disabled] { opacity: 0.5; cursor: not-allowed; }
  .em-pager-jump {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-weight: 600;
  }
  .em-pager-jump select {
    font-size: 13px;
    padding: 5px 8px;
    border: 1px solid #bccada;
    border-radius: 4px;
    background: #f8fafc;
    color: #1a3a5a;
    cursor: pointer;
  }
  .em-pager-jump select:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 2px rgba(58, 122, 186, 0.15);
    background: #fff;
  }
</style>

<%
  int mapKey = 380;
  try { mapKey = (Integer) request.getAttribute("mapKey"); } catch (Exception ignore) {}

  String assemblyName = null;
  try { assemblyName = MapManager.getInstance().getMap(mapKey).getName(); } catch (Exception ignore) {}

  List<String> tissueIds = (List<String>) request.getAttribute("tissueIds");
  if (tissueIds == null) tissueIds = new ArrayList<String>();
  List<String> strainAccIds = (List<String>) request.getAttribute("strainAccIds");
  if (strainAccIds == null) strainAccIds = new ArrayList<String>();
  List<String> conditionIds = (List<String>) request.getAttribute("conditionIds");
  if (conditionIds == null) conditionIds = new ArrayList<String>();
  String expressionLevel = (String) request.getAttribute("expressionLevel");

  List<Integer> rgdIds = (List<Integer>) request.getAttribute("rgdIds");
  if (rgdIds == null) rgdIds = new ArrayList<Integer>();
  List<String> unresolvedSymbols = (List<String>) request.getAttribute("unresolvedSymbols");
  if (unresolvedSymbols == null) unresolvedSymbols = new ArrayList<String>();

  // Gene symbols the user originally typed (resolved server-side to rgdIds). Preserved so the
  // "Add genes" control on this page can re-submit them alongside any newly typed symbols.
  String geneListParam = (String) request.getAttribute("geneList");
  if (geneListParam == null) geneListParam = "";
%>

<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>
<script type="text/javascript" src="/rgdweb/common/ontologyAutocomplete.js"></script>

<div class="typerMat">
  <div class="em-layout">

    <!-- Collapsible facet panel (populated from /index/facets) -->
    <aside id="emFacetPanel" class="em-facet-panel">
      <div class="em-facet-header">
        <span>Filter Results</span>
        <button type="button" class="em-facet-close" title="Hide filters" onclick="toggleFacets()">&times;</button>
      </div>
      <div class="em-facet-clear"><a onclick="clearFacets()">Clear all filters</a></div>
      <div class="em-facet-scroll">
        <div id="emFacetGroups"></div>
        <!-- Sex / Life Stage facets are computed on the client from the loaded records (the server
             /facets endpoint does not provide them). -->
        <div id="emClientFacetGroups"></div>
      </div>
    </aside>

    <div class="em-result-main">
      <div class="em-result-header">
        <div class="em-result-title">Expression Results</div>
        <% if (assemblyName != null) { %>
        <div class="em-result-assembly"><%=assemblyName%> assembly</div>
        <% } %>
      </div>

      <!-- Heatmap toggle stays at the top of the page and scrolls away with the content. -->
      <div class="em-heatmap-bar">
        <button type="button" id="emHeatmapToggle" class="em-facet-toggle" onclick="toggleHeatmap()">&#128202; Heatmap</button>
      </div>

      <!-- Filters toggle stays pinned so the panel can be shown/hidden anywhere on the page. -->
      <div class="em-toolbar">
        <button type="button" id="emFacetToggle" class="em-facet-toggle" onclick="toggleFacets()">&#9776; Filters</button>
        <button type="button" id="emEditToggle" class="em-facet-toggle" onclick="toggleEditPanel()">&#9998; Edit selection</button>
      </div>

      <div class="em-filters">
        <strong>Query:</strong>
        <span>Tissues:</span>
        <% if (tissueIds.isEmpty()) { out.print("<em>none</em>"); }
           for (String t : tissueIds) { %><span class="chip"><%=t%></span><% } %>
        &nbsp;&nbsp;<span>Strains:</span>
        <% if (strainAccIds.isEmpty()) { out.print("<em>none</em>"); }
           for (String s : strainAccIds) { %><span class="chip"><%=s%></span><% } %>
        <% if (!conditionIds.isEmpty()) { %>
        &nbsp;&nbsp;<span>Conditions:</span>
        <% for (String c : conditionIds) { %><span class="chip"><%=c%></span><% } %>
        <% } %>
        <% if (!rgdIds.isEmpty()) { %>
        &nbsp;&nbsp;<span>Genes:</span> <span class="chip"><%=rgdIds.size()%> gene<%=rgdIds.size()==1?"":"s"%></span>
        <% } %>
        <% if (expressionLevel != null && !expressionLevel.isBlank()) { %>
        &nbsp;&nbsp;<span>Level:</span> <span class="chip"><%=expressionLevel%></span>
        <% } %>
      </div>

      <!-- Edit / Add-to-selection modal (opened from the toolbar). Re-posts to this same result page
           with the revised gene list and strain/tissue/condition selection; the controller resolves
           the symbols to RGD ids server-side and re-renders, so the user never leaves this page. -->
      <div id="emEditOverlay" class="em-edit-overlay collapsed">
        <div class="em-edit-modal" role="dialog" aria-modal="true" aria-label="Edit selection">
          <div class="em-edit-header">
            <span class="em-edit-title">Edit / Add to Selection</span>
            <button type="button" class="em-edit-close" title="Close" onclick="toggleEditPanel()">&times;</button>
          </div>
          <form id="emEditForm" method="post" action="/rgdweb/expressMiner/result.html">
            <div class="em-edit-body">
              <input type="hidden" name="mapKey" value="<%=mapKey%>"/>
              <% if (expressionLevel != null && !expressionLevel.isBlank()) { %>
              <input type="hidden" name="expressionLevel" value="<%=expressionLevel%>"/>
              <% } %>

              <!-- Staging inputs the ontology popup writes to before our hook fires -->
              <input type="hidden" id="strainStaging"/>
              <input type="hidden" id="strainStaging_term"/>
              <input type="hidden" id="tissueStaging"/>
              <input type="hidden" id="tissueStaging_term"/>
              <input type="hidden" id="conditionStaging"/>
              <input type="hidden" id="conditionStaging_term"/>

              <!-- Genes -->
              <div class="st-card">
                <div class="st-card-title"><span>Genes</span></div>
                <textarea id="emEditGeneList" name="geneList" class="em-edit-textarea" autocomplete="off"
                          placeholder="Enter gene symbols, e.g. Tp53, Brca1 Lepr"><%= geneListParam.replace("&","&amp;").replace("<","&lt;") %></textarea>
              </div>

              <!-- Strains (RS) -->
              <div class="st-card">
                <div class="st-card-title">
                  <span>Strains (RS) <span id="strainCount" class="st-count">0</span></span>
                  <button type="button" class="st-browse-btn"
                          onclick="ontPopup('strainStaging','rs','strainStaging_term'); return false;">Browse Ontology Tree</button>
                </div>
                <div class="st-add">
                  <input type="text" id="strainInput" class="st-add-input" autocomplete="off"
                         placeholder="Search by name (e.g. SS/JrHsd) or enter an accession (e.g. RS:0000681)"
                         onkeydown="onPickerKey(event, 'strainStaging')"/>
                  <button type="button" class="st-add-btn" onclick="addManual('strainStaging')">Add</button>
                </div>
                <div id="strainAddError" class="st-add-error"></div>
                <ul id="strainList" class="st-list"></ul>
                <div id="strainEmpty" class="st-list-empty">No strains selected yet.</div>
              </div>

              <!-- Tissues (UBERON) -->
              <div class="st-card">
                <div class="st-card-title">
                  <span>Tissues (UBERON) <span id="tissueCount" class="st-count">0</span></span>
                  <button type="button" class="st-browse-btn"
                          onclick="ontPopup('tissueStaging','uberon','tissueStaging_term'); return false;">Browse Ontology Tree</button>
                </div>
                <div class="st-add">
                  <input type="text" id="tissueInput" class="st-add-input" autocomplete="off"
                         placeholder="Search by name (e.g. liver) or enter an accession (e.g. UBERON:0002107)"
                         onkeydown="onPickerKey(event, 'tissueStaging')"/>
                  <button type="button" class="st-add-btn" onclick="addManual('tissueStaging')">Add</button>
                </div>
                <div id="tissueAddError" class="st-add-error"></div>
                <ul id="tissueList" class="st-list"></ul>
                <div id="tissueEmpty" class="st-list-empty">No tissues selected yet.</div>
              </div>

              <!-- Conditions (XCO), optional -->
              <div class="st-card">
                <div class="st-card-title">
                  <span>Conditions (XCO) <span id="conditionCount" class="st-count">0</span>
                    <span style="font-weight:normal;font-size:12px;color:#6a7a8a;">&mdash; optional</span></span>
                  <button type="button" class="st-browse-btn"
                          onclick="ontPopup('conditionStaging','xco','conditionStaging_term'); return false;">Browse Ontology Tree</button>
                </div>
                <div class="st-add">
                  <input type="text" id="conditionInput" class="st-add-input" autocomplete="off"
                         placeholder="Search by name (e.g. controlled exercise) or enter an accession (e.g. XCO:0000105)"
                         onkeydown="onPickerKey(event, 'conditionStaging')"/>
                  <button type="button" class="st-add-btn" onclick="addManual('conditionStaging')">Add</button>
                </div>
                <div id="conditionAddError" class="st-add-error"></div>
                <ul id="conditionList" class="st-list"></ul>
                <div id="conditionEmpty" class="st-list-empty">No conditions selected yet.</div>
              </div>
            </div>
            <div class="em-edit-footer">
              <button type="button" class="em-cancel-btn" onclick="toggleEditPanel()">Cancel</button>
              <button type="button" class="em-update-btn" onclick="submitEditForm()">Update Results</button>
            </div>
          </form>
        </div>
      </div>

      <% if (!unresolvedSymbols.isEmpty()) { %>
      <div class="em-status warn">
        Could not resolve <%=unresolvedSymbols.size()%> gene symbol<%=unresolvedSymbols.size()==1?"":"s"%>
        on this assembly:
        <strong><% for (int i = 0; i < unresolvedSymbols.size(); i++) { if (i > 0) out.print(", "); out.print(unresolvedSymbols.get(i)); } %></strong>
      </div>
      <% } %>

      <!-- Status region: loading / warning / empty / error -->
      <div id="emStatus" class="em-status loading">Loading expression records&hellip;</div>

      <%-- Heatmap panel (markup + styles + JS). Toggled by the #emHeatmapToggle button above. --%>
      <%@ include file="heatmap.jsp" %>

      <!-- Table (hidden until we have rows) -->
      <div id="emTableCard" class="em-table-card" style="display:none;">
        <div class="em-table-meta">
          <span id="emCount"></span>
          <span id="emTruncated" style="color:#8a6d1a;"></span>
        </div>
        <div class="em-table-scroll">
          <table class="em-table">
            <thead>
              <tr>
                <th>Gene</th>
                <th>Vertebrate Trait</th>
                <th>Tissue</th>
                <th>Strain</th>
                <th>Value</th>
                <th>Unit</th>
                <th>Level</th>
                <th>Sex</th>
                <th>Life Stage</th>
                <th>Condition</th>
                <th>Species</th>
                <th>Study</th>
                <th>GEO Series</th>
                <th>GEO Sample</th>
              </tr>
            </thead>
            <tbody id="emTableBody"></tbody>
          </table>
        </div>
        <div id="emPager" class="em-pager">
          <button type="button" id="emPagerPrev" onclick="prevPage()">&#8592; Prev</button>
          <label class="em-pager-jump">Page
            <select id="emPageSelect" onchange="goToPage(parseInt(this.value, 10))" title="Jump to page"></select>
          </label>
          <span id="emPageInfo"></span>
          <button type="button" id="emPagerNext" onclick="nextPage()">Next &#8594;</button>
        </div>
      </div>

      <div class="form-actions">
        <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
      </div>
    </div>
  </div>
</div>

<script>
  var apiUrl = "<%=getAPIHostname()%>";

  // Selections handed in from the wizard steps.
  var TISSUE_IDS = [<% for (int i = 0; i < tissueIds.size(); i++) { if (i>0) out.print(","); out.print("'" + tissueIds.get(i).replace("'", "\\'") + "'"); } %>];
  var STRAIN_IDS = [<% for (int i = 0; i < strainAccIds.size(); i++) { if (i>0) out.print(","); out.print("'" + strainAccIds.get(i).replace("'", "\\'") + "'"); } %>];
  // Optional condition (XCO) filter carried in from the wizard. Acts as the base value for the Condition
  // server facet: sent to /index/records/search and /index/facets when no condition box is checked.
  var CONDITION_IDS = [<% for (int i = 0; i < conditionIds.size(); i++) { if (i>0) out.print(","); out.print("'" + conditionIds.get(i).replace("'", "\\'") + "'"); } %>];
  var MAP_KEY = <%=mapKey%>;
  var EXPRESSION_LEVEL = <%= (expressionLevel == null || expressionLevel.isBlank()) ? "null" : ("'" + expressionLevel.replace("'", "\\'") + "'") %>;
  var RGD_IDS = [<% for (int i = 0; i < rgdIds.size(); i++) { if (i>0) out.print(","); out.print(rgdIds.get(i)); } %>];

  var PAGE_SIZE = 2000;  // records fetched per page from the search endpoint (server-side paging)
  var RENDER_CAP = 5000; // safety cap on rows drawn at once (a single page is normally well under this)
  var currentPage = 0;   // 0-based page index into the server result set (see serverRecordsUrl / renderPager)
  var FACET_SEARCH_THRESHOLD = 8; // groups longer than this get a search box

  var HAS_GENES = RGD_IDS.length > 0;

  var allRecords = [];      // the loaded records; all facet filtering runs against these
  var serverTotal = 0;      // total matching records reported by the server
  var filteredRecords = []; // records surviving the current facet selection (feeds table + heatmap)
  var reloadSeq = 0;        // increments per reloadRecords() call; guards against out-of-order responses

  function capitalize(v) { return v ? String(v).charAt(0).toUpperCase() + String(v).slice(1) : ''; }

  // A record's condition (accession and term) can come back from the index as a single value or an
  // array, since a record may carry several conditions. Normalize to an array of non-empty trimmed
  // strings so callers never assume a scalar (and never call .trim() on an array).
  function asList(v) {
    if (v == null) return [];
    var arr = Array.isArray(v) ? v : [v];
    var out = [];
    for (var i = 0; i < arr.length; i++) {
      var s = (arr[i] == null ? '' : String(arr[i])).trim();
      if (s) out.push(s);
    }
    return out;
  }

  // A record's conditions come back from the expression index as an array of ontology objects:
  // [{ accId, term, obsolete }]. Older index builds exposed flat `condition` / `conditionTerm` strings
  // (sometimes arrays), so accept either shape and normalize to [{ acc, term }].
  function condList(r) {
    var out = [];
    if (r.conditions != null) {
      var arr = Array.isArray(r.conditions) ? r.conditions : [r.conditions];
      for (var i = 0; i < arr.length; i++) {
        var c = arr[i];
        if (c == null) continue;
        if (typeof c !== 'object') {                       // plain accession string
          var s = String(c).trim();
          if (s) out.push({ acc: s, term: '' });
          continue;
        }
        var acc = String(c.accId || c.acc || '').trim();
        var term = String(c.term || '').trim();
        if (acc || term) out.push({ acc: acc, term: term });
      }
      return out;
    }
    // Legacy flat fields, paired by position.
    var accs = asList(r.condition), terms = asList(r.conditionTerm);
    for (var j = 0; j < accs.length; j++) out.push({ acc: accs[j], term: terms[j] || '' });
    return out;
  }

  // Facet groups shown in the panel. `accOf` maps a record to the value the facet keys on, used to
  // filter the table client-side. Server groups (Level, Unit, Gene, Tissue, Strain, Condition) get their
  // options/counts from the /index/facets call and, when checked, narrow the /index/records/search query
  // server-side. `client: true` groups (Sex, Life Stage) are not provided by that endpoint, so their
  // options and counts are computed from the loaded records instead (see renderClientFacets). `labelOf`
  // formats a value for display; `recLabelOf` pulls a display label straight off a record (used when
  // the facet keys on an id/accession but should show a friendlier name).
  var FACET_GROUPS = [
    { key: 'levels',  title: 'Expression Level', accOf: function (r) { return r.expressionLevel; } },
    { key: 'units',   title: 'Unit',             accOf: function (r) { return r.expressionUnit; } },
    { key: 'genes',   title: 'Gene',             accOf: function (r) { return String(r.geneRgdId); } },
    { key: 'tissues', title: 'Tissue',           accOf: function (r) { return r.tissueAcc; } },
    { key: 'strains', title: 'Strain',           accOf: function (r) { return r.strainAcc; } },
    // Condition (XCO ontology): a server-backed facet like Tissue/Strain. Options, resolved term names
    // and counts come from /index/facets; checked accessions are sent to /index/records/search.
    { key: 'conditions', title: 'Condition',     accOf: function (r) { return condList(r).map(function (c) { return c.acc; }); } },
    { key: 'sex',        title: 'Sex',        client: true, labelOf: capitalize,
      accOf: function (r) { return (r.sex || r.computedSex || '').trim().toLowerCase(); } },
    { key: 'lifeStages', title: 'Life Stage', client: true, labelOf: capitalize,
      accOf: function (r) { return (r.lifeStage || '').trim().toLowerCase(); } }
  ];
  var selectedFacets = {}; // key -> { accValue: true }

  function setStatus(cls, html) {
    var el = document.getElementById('emStatus');
    el.className = 'em-status ' + cls;
    el.innerHTML = html;
    el.style.display = 'block';
  }
  function hideStatus() { document.getElementById('emStatus').style.display = 'none'; }

  function esc(s) {
    if (s === null || s === undefined) return '';
    return String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function num(v, digits) {
    if (v === null || v === undefined || v === '' || isNaN(v)) return '';
    return Number(v).toFixed(digits === undefined ? 2 : digits);
  }

  function levelBadge(level) {
    if (!level) return '<span class="level-badge level-none">n/a</span>';
    var cls = 'level-none';
    var l = String(level).toLowerCase();
    if (l.indexOf('high') === 0) cls = 'level-high';
    else if (l.indexOf('med') === 0) cls = 'level-medium';
    else if (l.indexOf('low') === 0) cls = 'level-low';
    return '<span class="level-badge ' + cls + '">' + esc(level) + '</span>';
  }

  // Rat life-stage -> age range (in days), shown as a hover tooltip on Life Stage values.
  var LIFE_STAGE_AGES = {
    'embryonic': '< 0',
    'neonatal': '0 - 20',
    'weanling': '21 - 34',
    'juvenile': '35 - 55',
    'adult': '56 - 719',
    'aged': '> 719'
  };
  function lifeStageAge(stage) {
    return LIFE_STAGE_AGES[String(stage || '').trim().toLowerCase()] || '';
  }
  function lifeStageCell(stage) {
    if (!stage) return '';
    var age = lifeStageAge(stage);
    if (!age) return esc(stage);
    return '<span class="em-lifestage" title="Age: ' + esc(age) + ' days">' + esc(stage) + '</span>';
  }

  function geneCell(rec) {
    var sym = rec.geneSymbol || rec.geneSymbolWithRgdId || '';
    if (rec.geneRgdId) {
      return '<a class="em-link" target="_blank" href="/rgdweb/report/gene/main.html?id=' + rec.geneRgdId + '">' + esc(sym) + '</a>';
    }
    return esc(sym);
  }

  function ontCell(term, acc) {
    if (!acc) return term ? esc(term) : '';
    // Link the accession id to its ontology term report page.
    var accLink = '<a class="em-link" target="_blank" title="View ontology term report" ' +
                  'href="/rgdweb/ontology/view.html?acc_id=' + encodeURIComponent(acc) + '">' + esc(acc) + '</a>';
    var name = term && term !== acc ? term : '';
    if (name) return esc(name) + ' <span class="em-acc">(' + accLink + ')</span>';
    return '<span class="em-acc">' + accLink + '</span>';
  }

  function studyCell(rec) {
    if (!rec.studyId) return '';
    return '<a class="em-link" target="_blank" href="/rgdweb/report/expressionStudy/main.html?id=' + esc(rec.studyId) + '">' + esc(rec.studyId) + '</a>';
  }

  function geoCell(rec) {
    var geo = rec.geoSeriesAcc;
    if (!geo) return '';
    return '<a class="em-link" target="_blank" href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=' + esc(geo) + '">' + esc(geo) + '</a>';
  }

  function geoSampleCell(rec) {
    var gsm = rec.geoSampleAcc;
    if (!gsm) return '';
    return '<a class="em-link" target="_blank" href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=' + esc(gsm) + '">' + esc(gsm) + '</a>';
  }

  // Records that are identical on every displayed field except condition are the "duplicate"
  // rows -- collapse them into one group whose conditions are collected into a list.
  function groupRecords(records) {
    var byKey = {};
    var order = [];
    for (var i = 0; i < records.length; i++) {
      var r = records[i];
      var key = [
        r.geneRgdId, r.geneSymbol, r.traitOntId, r.tissueAcc, r.tissueTerm, r.strainAcc, r.strainTerm,
        r.expressionValue, r.expressionUnit, r.expressionLevel,
        (r.sex || r.computedSex || ''), r.lifeStage, r.species, r.studyId, r.geoSeriesAcc, r.geoSampleAcc
      ].join('');
      var g = byKey[key];
      if (!g) { g = { rec: r, conditions: [], condSeen: {} }; byKey[key] = g; order.push(key); }
      // A record can carry several conditions (ontology objects from the index). Collect the distinct
      // terms across the merged rows, keyed by accession (label as fallback).
      var conds = condList(r);
      for (var ci = 0; ci < conds.length; ci++) {
        var cAcc = conds[ci].acc, cTerm = conds[ci].term;
        var cKey = cAcc || cTerm;
        if (cKey && !g.condSeen[cKey]) { g.condSeen[cKey] = 1; g.conditions.push({ acc: cAcc, term: cTerm }); }
      }
    }
    return order.map(function (k) { return byKey[k]; });
  }

  // Render conditions like the other ontology columns: term name with its accession linked to the
  // ontology term report. Merged rows may carry several distinct conditions, shown as a list.
  function conditionCell(conditions) {
    if (!conditions || conditions.length === 0) return '';
    if (conditions.length === 1) return ontCell(conditions[0].term, conditions[0].acc);
    var items = conditions.slice().sort(function (a, b) {
      return (a.term || a.acc).localeCompare(b.term || b.acc);
    }).map(function (c) { return '<li>' + ontCell(c.term, c.acc) + '</li>'; });
    return '<ul class="em-cond-list">' + items.join('') + '</ul>';
  }

  // Returns the number of rows rendered (groups), which differs from the record count when
  // rows were merged.
  function renderRows(records) {
    var groups = groupRecords(records);
    var rows = [];
    var limit = Math.min(groups.length, RENDER_CAP); // cap drawn rows; count still reflects all
    for (var i = 0; i < limit; i++) {
      var r = groups[i].rec;
      rows.push(
        '<tr>' +
          '<td>' + geneCell(r) + '</td>' +
          '<td>' + ontCell(r.traitTerm, r.traitOntId) + '</td>' +
          '<td>' + ontCell(r.tissueTerm, r.tissueAcc) + '</td>' +
          '<td>' + ontCell(r.strainTerm, r.strainAcc) + '</td>' +
          '<td class="num">' + num(r.expressionValue) + '</td>' +
          '<td>' + esc(r.expressionUnit) + '</td>' +
          '<td>' + levelBadge(r.expressionLevel) + '</td>' +
          '<td>' + esc(r.sex || r.computedSex || '') + '</td>' +
          '<td>' + lifeStageCell(r.lifeStage) + '</td>' +
          '<td>' + conditionCell(groups[i].conditions) + '</td>' +
          '<td>' + esc(r.species) + '</td>' +
          '<td>' + studyCell(r) + '</td>' +
          '<td>' + geoCell(r) + '</td>' +
          '<td>' + geoSampleCell(r) + '</td>' +
        '</tr>'
      );
    }
    document.getElementById('emTableBody').innerHTML = rows.join('');
    return groups.length;
  }

  // ---- Facet panel -----------------------------------------------------------

  function toggleFacets() {
    document.getElementById('emFacetPanel').classList.toggle('collapsed');
  }

  function anyFacetSelected() {
    for (var k in selectedFacets) {
      if (Object.keys(selectedFacets[k]).length) return true;
    }
    return false;
  }

  function clearFacets() {
    selectedFacets = {};
    var boxes = document.querySelectorAll('#emFacetPanel input[type=checkbox]');
    for (var i = 0; i < boxes.length; i++) boxes[i].checked = false;
    reloadRecords();     // also re-renders the client facets (Sex / Life Stage) via applyClientFilters
  }

  // Show only facet items matching the typed text (matches label or accession id).
  function filterFacetItems(input) {
    var q = input.value.trim().toLowerCase();
    var items = input.parentNode.querySelectorAll('.em-facet-item');
    for (var i = 0; i < items.length; i++) {
      var hay = items[i].getAttribute('data-search') || '';
      items[i].style.display = (!q || hay.indexOf(q) !== -1) ? '' : 'none';
    }
  }

  function toggleGroup(el) {
    el.parentNode.classList.toggle('collapsed');
  }

  // TPM bands behind each expression level, shown beside the level name in the filter list so the
  // cutoffs are visible without leaving the panel. Keyed by the level value the index reports.
  var LEVEL_RANGES = {
    high:   'TPM > 1000',
    medium: '10 < TPM <= 1000',
    low:    '0.5 <= TPM <= 10'
  };

  // Build the checkbox groups from the /index/facets payload. Groups with a single
  // value are skipped (filtering to the only value would be a no-op).
  function renderFacets(facets) {
    var html = [];
    for (var g = 0; g < FACET_GROUPS.length; g++) {
      var group = FACET_GROUPS[g];
      if (group.client) continue; // client-computed groups are rendered by renderClientFacets
      var values = facets[group.key] || [];
      if (values.length < 2) continue;

      html.push('<div class="em-facet-group">');
      html.push('<div class="em-facet-group-title" onclick="toggleGroup(this)">' +
                '<span>' + esc(group.title) + '</span><span class="em-facet-caret">&#9662;</span></div>');
      html.push('<div class="em-facet-group-body">');
      // Without a gene list to constrain the query, the Gene facet only reflects the genes
      // present in the matching records -- not every gene. Flag that so it isn't read as complete.
      if (group.key === 'genes' && !HAS_GENES) {
        html.push('<div style="padding:6px 14px;font-size:11px;color:#7a8a9a;font-style:italic;">' +
                  'Note: without a gene list, this will not include all genes.</div>');
      }
      // Long lists (e.g. the full gene list) get a search box to find a value to check.
      if (values.length > FACET_SEARCH_THRESHOLD) {
        html.push('<input type="text" class="em-facet-search" oninput="filterFacetItems(this)" ' +
                  'placeholder="Search ' + esc(group.title.toLowerCase()) + '"/>');
      }
      for (var i = 0; i < values.length; i++) {
        var v = values[i];
        var label = v.label && v.label !== v.acc ? v.label : v.acc;
        // Expression levels get their TPM band shown next to the name (see LEVEL_RANGES).
        var range = (group.key === 'levels') ? LEVEL_RANGES[String(v.acc).toLowerCase()] : '';
        var hay = esc((label + ' ' + v.acc).toLowerCase());
        html.push(
          '<label class="em-facet-item" data-group="' + esc(group.key) + '" data-search="' + hay + '">' +
            '<input type="checkbox" onchange="onFacetChange(\'' + esc(group.key) + '\', this)" value="' + esc(v.acc) + '"/>' +
            '<span class="em-facet-label">' + esc(label) +
              (range ? ' <span class="em-level-range">' + esc(range) + '</span>' : '') +
            '</span>' +
            '<span class="em-facet-count">' + v.count + '</span>' +
          '</label>'
        );
      }
      html.push('</div></div>');
    }
    document.getElementById('emFacetGroups').innerHTML =
      html.length ? html.join('') : '<div style="padding:12px 14px;font-size:12px;color:#7a8a9a;">No filters available.</div>';
  }

  // Fetch the facet panel once, for the query the user entered the tool with. The options and counts
  // are then left alone for the life of the page: re-querying /index/facets with the current selection
  // would zero out every other value in the group the user just picked from, making it impossible to
  // select a second option. Counts therefore describe the ORIGINAL query, not the narrowed one.
  function loadFacets() {
    fetch(apiUrl + '/rgdws/expression/index/facets?' + facetsQueryString(), { headers: { 'Accept': 'application/json' } })
      .then(function (resp) { return resp.ok ? resp.json() : null; })
      .then(function (facets) { if (facets) renderFacets(facets); })
      .catch(function () { /* facets are optional; a failure just leaves the panel unchanged */ });
  }

  function checkedValues(groupKey) {
    return selectedFacets[groupKey] ? Object.keys(selectedFacets[groupKey]) : [];
  }

  // Values to send for a group: the checked ones, or the wizard's original filter when none checked.
  function selectedFor(groupKey, base) {
    var chosen = checkedValues(groupKey);
    return chosen.length ? chosen : base;
  }

  function facetsQueryString() {
    var params = [];
    var tissues = selectedFor('tissues', TISSUE_IDS);
    var strains = selectedFor('strains', STRAIN_IDS);
    var genes = selectedFor('genes', RGD_IDS.map(String));
    var conditions = selectedFor('conditions', CONDITION_IDS);
    if (tissues.length) params.push('tissueIds=' + encodeURIComponent(tissues.join(',')));
    if (strains.length) params.push('strainAccIds=' + encodeURIComponent(strains.join(',')));
    if (genes.length) params.push('rgdIds=' + encodeURIComponent(genes.join(',')));
    if (conditions.length) params.push('conditionIds=' + encodeURIComponent(conditions.join(',')));
    if (MAP_KEY) params.push('mapKey=' + MAP_KEY);
    var units = checkedValues('units');
    if (units.length) params.push('units=' + encodeURIComponent(units.join(',')));
    var levels = checkedValues('levels');
    if (levels.length) {
      params.push('expressionLevels=' + encodeURIComponent(levels.join(',')));
      if (levels.length === 1) params.push('expressionLevel=' + encodeURIComponent(levels[0]));
    }
    return params.join('&');
  }

  // Build the client-computed facet groups (Sex, Life Stage) from the loaded records. Each value's
  // count reflects the records passing every OTHER filter, so checking one value does not zero the
  // rest. Checked state comes from selectedFacets, so a rebuild preserves the user's choices.
  function renderClientFacets() {
    var container = document.getElementById('emClientFacetGroups');
    if (!container) return;
    var html = [];
    for (var g = 0; g < FACET_GROUPS.length; g++) {
      var group = FACET_GROUPS[g];
      if (!group.client) continue;

      var counts = {};
      var labels = {}; // accValue -> display label captured from a record (for recLabelOf groups)
      for (var i = 0; i < allRecords.length; i++) {
        var r = allRecords[i];
        if (!recordMatches(r, group.key)) continue;
        var val = group.accOf(r);
        if (!val) continue;
        counts[val] = (counts[val] || 0) + 1;
        if (group.recLabelOf && labels[val] === undefined) labels[val] = group.recLabelOf(r);
      }
      var labelFor = function (v) {
        if (labels[v] !== undefined && labels[v] !== '') return labels[v];
        return group.labelOf ? group.labelOf(v) : v;
      };
      var values = Object.keys(counts).sort(function (a, b) {
        return String(labelFor(a)).localeCompare(String(labelFor(b)));
      });
      var sel = selectedFacets[group.key] || {};
      // Keep a checked value visible even if it now counts 0, so it can still be unchecked.
      for (var s in sel) { if (values.indexOf(s) === -1) values.push(s); }
      if (values.length < 2) continue; // nothing meaningful to filter on

      html.push('<div class="em-facet-group">');
      html.push('<div class="em-facet-group-title" onclick="toggleGroup(this)">' +
                '<span>' + esc(group.title) + '</span><span class="em-facet-caret">&#9662;</span></div>');
      html.push('<div class="em-facet-group-body">');
      if (values.length > FACET_SEARCH_THRESHOLD) {
        html.push('<input type="text" class="em-facet-search" oninput="filterFacetItems(this)" ' +
                  'placeholder="Search ' + esc(group.title.toLowerCase()) + '"/>');
      }
      for (var k = 0; k < values.length; k++) {
        var v = values[k];
        var label = labelFor(v);
        var hay = esc((label + ' ' + v).toLowerCase());
        var checked = sel[v] ? ' checked' : '';
        var labelExtra = '';
        if (group.key === 'lifeStages') {
          var lsAge = lifeStageAge(v);
          if (lsAge) labelExtra = ' class="em-lifestage" title="Age: ' + esc(lsAge) + ' days"';
        }
        html.push(
          '<label class="em-facet-item" data-group="' + esc(group.key) + '" data-search="' + hay + '">' +
            '<input type="checkbox" onchange="onFacetChange(\'' + esc(group.key) + '\', this)" value="' + esc(v) + '"' + checked + '/>' +
            '<span class="em-facet-label"><span' + labelExtra + '>' + esc(label) + '</span></span>' +
            '<span class="em-facet-count">' + (counts[v] || 0) + '</span>' +
          '</label>'
        );
      }
      html.push('</div></div>');
    }
    container.innerHTML = html.join('');
  }

  function isClientFacet(groupKey) {
    for (var i = 0; i < FACET_GROUPS.length; i++) {
      if (FACET_GROUPS[i].key === groupKey) return !!FACET_GROUPS[i].client;
    }
    return false;
  }

  // Does a record satisfy the current selection, ignoring the facet group `exceptKey` (pass null to
  // apply them all)? Used both to drive the table and to count a client facet's own options without
  // that group filtering itself out.
  function recordMatches(r, exceptKey) {
    // Every server-applicable filter (assembly, tissue, strain, gene, condition, and a single expression
    // level) is enforced by /index/records/search, so the loaded set already respects those selections;
    // re-applying them here is a harmless no-op. This pass is what actually applies the facets the
    // endpoint can't: unit and multi-value level selections.
    for (var g = 0; g < FACET_GROUPS.length; g++) {
      var group = FACET_GROUPS[g];
      if (group.key === exceptKey) continue;
      var sel = selectedFacets[group.key];
      if (!sel) continue;
      var chosen = Object.keys(sel);
      if (chosen.length === 0) continue;
      var val = group.accOf(r);
      if (Array.isArray(val)) {
        // Multi-valued field (e.g. condition): the record matches if any of its values is checked.
        var hit = false;
        for (var v = 0; v < val.length; v++) { if (sel[val[v]]) { hit = true; break; } }
        if (!hit) return false;
      } else if (!sel[val]) {
        return false;
      }
    }
    return true;
  }

  // Client-side test: does a record satisfy every checked facet group? (Drives the table.)
  function recordPassesFilters(r) { return recordMatches(r, null); }

  function onFacetChange(groupKey, box) {
    if (!selectedFacets[groupKey]) selectedFacets[groupKey] = {};
    if (box.checked) selectedFacets[groupKey][box.value] = true;
    else delete selectedFacets[groupKey][box.value];

    // Sex / Life Stage are derived from records already loaded, so just re-filter -- no server round
    // trip. Server-backed facets narrow the query, so re-fetch the records.
    // The facet panel itself is deliberately NOT refreshed: its options and counts stay fixed at the
    // original query so every value remains selectable (re-querying /index/facets with the current
    // selection zeroes out every other value in the group, making multi-select impossible).
    if (isClientFacet(groupKey)) {
      applyClientFilters();
    } else {
      reloadRecords();
    }
  }

  function updateCount(rows, loaded, total) {
    // Show only the number of rows actually drawn in the table (capped at RENDER_CAP).
    var displayed = Math.min(rows, RENDER_CAP);
    var meta = '<strong>' + displayed + '</strong> row' + (displayed === 1 ? '' : 's');
    document.getElementById('emCount').innerHTML = meta;
  }

  // ---- Data loading ----------------------------------------------------------

  // Build the single unified records query. Every wizard and facet selection maps onto one call to
  // /index/records/search, which AND-combines the supplied filters (tissue, strain, gene, condition,
  // assembly, level) server-side and OR-combines the values within each. Filters this endpoint can't
  // express -- unit and multi-value level selections -- are enforced by the client-side pass below
  // (recordPassesFilters). At least one filter is always present (mapKey), so the request is never
  // rejected for being unfiltered.
  function serverRecordsUrl() {
    var params = [];
    var tissues = selectedFor('tissues', TISSUE_IDS);
    var strains = selectedFor('strains', STRAIN_IDS);
    var genes = selectedFor('genes', RGD_IDS.map(String));
    // Condition (XCO) is a server facet: checked conditions, or the wizard's base selection when none
    // are checked. The endpoint filters by them, so checking a box re-queries rather than filtering locally.
    var conditions = selectedFor('conditions', CONDITION_IDS);
    if (tissues.length) params.push('tissueIds=' + encodeURIComponent(tissues.join(',')));
    if (strains.length) params.push('strainAccIds=' + encodeURIComponent(strains.join(',')));
    if (genes.length) params.push('rgdIds=' + encodeURIComponent(genes.join(',')));
    if (conditions.length) params.push('conditionIds=' + encodeURIComponent(conditions.join(',')));
    if (MAP_KEY) params.push('mapKey=' + MAP_KEY);
    // Unit is a real server filter on this endpoint (verified against dev: units=FPKM returns 0 on an
    // all-TPM assembly), so push it down rather than only narrowing the loaded page client-side.
    var units = checkedValues('units');
    if (units.length) params.push('units=' + encodeURIComponent(units.join(',')));
    // The endpoint takes a single expressionLevel, so send it only when exactly one level is checked
    // (it then narrows server-side); multiple checked levels are applied client-side instead.
    var levels = checkedValues('levels');
    if (levels.length === 1) params.push('expressionLevel=' + encodeURIComponent(levels[0]));
    params.push('page=' + currentPage);
    params.push('size=' + PAGE_SIZE);
    return apiUrl + '/rgdws/expression/index/records/search?' + params.join('&');
  }

  function fetchRecordsJson(url) {
    return fetch(url, { headers: { 'Accept': 'application/json' } }).then(function (resp) {
      if (!resp.ok) throw new Error('Server returned ' + resp.status + ' ' + resp.statusText);
      return resp.json();
    });
  }

  // Empty-result message tailored to what the wizard actually queried.
  function noRecordsMessage() {
    if (HAS_GENES) {
      return 'No expression records for the selected gene' + (RGD_IDS.length === 1 ? '' : 's') + ' on this assembly.';
    }
    return 'No expression records match the selected tissues and strains on this assembly.';
  }

  // Re-query the server for the current facet selection, then draw the table (with a client-side
  // pass that enforces any facets the endpoint couldn't apply).
  // Re-query and redraw. A changed query (facet toggle, clear, initial load) starts back at page 0;
  // the pager passes keepPage=true so Prev/Next fetch the chosen page without snapping to the first.
  function reloadRecords(keepPage) {
    if (!keepPage) currentPage = 0;
    // Rapid facet clicks fire overlapping fetches that can resolve out of order. Stamp each request
    // and ignore any response that a newer reload has already superseded -- otherwise a stale record
    // set gets re-filtered against the current (newer) selection and every row fails, emptying the table.
    var seq = ++reloadSeq;
    setStatus('loading', 'Loading expression records&hellip;');
    document.getElementById('emTableCard').style.display = 'none';

    fetchRecordsJson(serverRecordsUrl())
      .then(function (data) {
        if (seq !== reloadSeq) return; // a newer reload is in flight; drop this stale response
        allRecords = data.records || [];
        serverTotal = (data.total != null) ? data.total : allRecords.length;

        if (allRecords.length === 0) {
          document.getElementById('emTableCard').style.display = 'none';
          filteredRecords = [];
          setStatus('empty', anyFacetSelected()
            ? 'No records match the selected filters. <a onclick="clearFacets()" style="cursor:pointer;text-decoration:underline;">Clear the filters</a>.'
            : noRecordsMessage());
          syncHeatmap();
          return;
        }
        applyClientFilters();
      })
      .catch(function (err) {
        if (seq !== reloadSeq) return; // superseded; the newer reload owns the status line
        setStatus('error', 'Could not load expression records: ' + esc(err.message));
      });
  }

  // Apply the checked facets to the loaded records (OR within a group, AND across groups), redraw
  // the table, and refresh the per-value counts. This is what makes the table track the filters.
  function applyClientFilters() {
    var filtered = allRecords.filter(recordPassesFilters);
    filteredRecords = filtered;
    renderClientFacets(); // (re)build Sex / Life Stage from the loaded records, self-excluded counts

    if (filtered.length === 0) {
      document.getElementById('emTableCard').style.display = 'none';
      setStatus('empty', anyFacetSelected()
        ? 'No records match the selected filters. <a onclick="clearFacets()" style="cursor:pointer;text-decoration:underline;">Clear the filters</a>.'
        : noRecordsMessage());
      syncHeatmap();
      return;
    }

    hideStatus();
    var rowCount = renderRows(filtered);
    updateCount(rowCount, filtered.length, serverTotal);
    syncHeatmap();
    renderPager();

    // With server-side paging the whole result set is reachable page by page, so the only thing left to
    // flag is when a client-side Sex / Life Stage (or unit / multi-level) filter is hiding rows on THIS
    // page -- those facets can't be pushed to the endpoint, so they narrow the loaded page only.
    document.getElementById('emTruncated').innerText =
      (filtered.length < allRecords.length) ? 'Sex / Life Stage filters applied to this page.' : '';

    document.getElementById('emTableCard').style.display = 'block';
  }

  // The endpoint uses offset paging capped by Elasticsearch's result window: from + size cannot exceed
  // MAX_RESULT_WINDOW, so only the first MAX_RESULT_WINDOW records are reachable however many match.
  var MAX_RESULT_WINDOW = 10000; // must mirror ExpressionWebService.MAX_RESULT_WINDOW

  // Pages the endpoint can actually serve for the current result: the smaller of "enough to cover every
  // matching record" and "as deep as the result window allows".
  function pageCount() {
    var byTotal = Math.ceil(serverTotal / PAGE_SIZE);
    var byWindow = Math.floor(MAX_RESULT_WINDOW / PAGE_SIZE);
    return Math.max(1, Math.min(byTotal, byWindow));
  }

  // Draw the Prev / page-of / Next controls under the table. Hidden when everything fits on one page.
  function renderPager() {
    var pager = document.getElementById('emPager');
    var pages = pageCount();
    var reachable = pages * PAGE_SIZE;
    var beyond = serverTotal > reachable; // matches exist past the result window we can page into
    if (pages <= 1 && !beyond) { pager.style.display = 'none'; return; }
    pager.style.display = 'flex';

    // Rebuild the jump-to-page dropdown (1..pages) and select the current page.
    var sel = document.getElementById('emPageSelect');
    var opts = '';
    for (var i = 0; i < pages; i++) opts += '<option value="' + i + '">' + (i + 1) + '</option>';
    sel.innerHTML = opts;
    sel.value = String(currentPage);

    var info = 'of <strong>' + pages + '</strong>';
    document.getElementById('emPageInfo').innerHTML = info;
    document.getElementById('emPagerPrev').disabled = currentPage <= 0;
    document.getElementById('emPagerNext').disabled = currentPage >= pages - 1;
  }

  function goToPage(p) {
    var pages = pageCount();
    p = Math.max(0, Math.min(p, pages - 1));
    if (p === currentPage) return;
    currentPage = p;
    reloadRecords(true);              // keepPage: fetch the chosen page, don't reset to 0
    try { window.scrollTo({ top: 0, behavior: 'smooth' }); } catch (e) {}
  }
  function prevPage() { goToPage(currentPage - 1); }
  function nextPage() { goToPage(currentPage + 1); }

  function loadResults() {
    // Valid queries:
    //  - a gene list, alone or with any tissues/strains (a single tissue or strain is enough), or
    //  - no gene list: at least one tissue AND one strain.
    var hasGenes = RGD_IDS.length > 0;
    var valid = hasGenes ? true : (TISSUE_IDS.length > 0 && STRAIN_IDS.length > 0);
    if (!valid) {
      setStatus('warn', 'This result view needs a <strong>gene list</strong> (on its own, or with a tissue or strain), ' +
        'or -- with no gene list -- at least one <strong>tissue</strong> and one <strong>strain</strong>. ' +
        'Go back and make a selection.');
      return;
    }

    loadFacets();      // build the facet panel once, from the original query
    reloadRecords();   // fetch the records for the current selection
  }

  document.addEventListener('DOMContentLoaded', loadResults);
</script>

<script>
  // ---- Edit / Add-to-selection modal --------------------------------------------------------------
  // Mirrors the strain/tissue/condition picker from strainTissue.jsp, pre-filled with the current
  // query, and re-posts to the results page to re-run. Globals (not an IIFE) so the inline onclick
  // handlers in the card markup can reach addManual()/addTerm().
  var ST_LISTS = {
    strainStaging: { type: 'strain', inputName: 'strainId', listId: 'strainList',
                     countId: 'strainCount', emptyId: 'strainEmpty', prefix: 'RS:',
                     inputId: 'strainInput', errorId: 'strainAddError' },
    tissueStaging: { type: 'tissue', inputName: 'tissueId', listId: 'tissueList',
                     countId: 'tissueCount', emptyId: 'tissueEmpty', prefix: 'UBERON:',
                     inputId: 'tissueInput', errorId: 'tissueAddError' },
    conditionStaging: { type: 'condition', inputName: 'conditionId', listId: 'conditionList',
                        countId: 'conditionCount', emptyId: 'conditionEmpty', prefix: 'XCO:',
                        inputId: 'conditionInput', errorId: 'conditionAddError' }
  };
  var selectedAcc = { strain: {}, tissue: {}, condition: {} };

  function toggleEditPanel() {
    document.getElementById('emEditOverlay').classList.toggle('collapsed');
  }

  // Post the revised selection back to the results page (symbols resolved server-side).
  function submitEditForm() {
    document.getElementById('emEditForm').submit();
  }

  // Resolve which list a selection belongs to: prefer the staging field the popup targeted, else the
  // accession prefix.
  function resolveCfg(accId, selAccId) {
    if (selAccId && ST_LISTS[selAccId]) return ST_LISTS[selAccId];
    var up = (accId || '').toUpperCase();
    if (up.indexOf('UBERON:') === 0) return ST_LISTS.tissueStaging;
    if (up.indexOf('RS:') === 0) return ST_LISTS.strainStaging;
    if (up.indexOf('XCO:') === 0) return ST_LISTS.conditionStaging;
    return null;
  }

  function updateMeta(cfg) {
    var count = Object.keys(selectedAcc[cfg.type]).length;
    document.getElementById(cfg.countId).innerText = count;
    document.getElementById(cfg.emptyId).style.display = count === 0 ? 'block' : 'none';
  }

  // Normalize a typed accession to PREFIX + digits (e.g. "681" or "rs:681" -> "RS:681").
  function normalizeAcc(raw, prefix) {
    var v = (raw || '').toUpperCase().replace(/\s+/g, '');
    if (/^[0-9]+$/.test(v)) v = prefix + v;
    if (v.indexOf(prefix) !== 0) return null;
    var rest = v.substring(prefix.length);
    if (!/^[0-9]+$/.test(rest)) return null;
    return v;
  }

  // One box per ontology handles both ways of picking a term: type a name and choose from the
  // autocomplete suggestions, or type an accession and press Enter / Add. On Enter we only take
  // over when the text actually looks like an accession -- otherwise Enter belongs to the
  // suggestion dropdown, which uses it to accept the highlighted term.
  function onPickerKey(ev, stagingId) {
    if (ev.key !== 'Enter') return;
    var cfg = ST_LISTS[stagingId];
    var el = document.getElementById(cfg.inputId);
    if (normalizeAcc((el.value || '').trim(), cfg.prefix)) {
      ev.preventDefault();
      addManual(stagingId);
    }
  }

  function addManual(stagingId) {
    var cfg = ST_LISTS[stagingId];
    var input = document.getElementById(cfg.inputId);
    var err = document.getElementById(cfg.errorId);
    err.innerText = '';

    var raw = (input.value || '').trim();
    if (!raw) return;

    var accId = normalizeAcc(raw, cfg.prefix);
    if (!accId) {
      err.innerText = 'Pick a term from the suggestions, or enter an accession (e.g. ' + cfg.prefix + '0000123).';
      return;
    }
    if (selectedAcc[cfg.type][accId]) {
      err.innerText = accId + ' is already in the list.';
      return;
    }

    // Look the accession up in the ontology: confirm it exists and grab the term name, so the list
    // shows "name (ACC)" instead of echoing the accession as its own label.
    var ont = cfg.prefix.replace(':', '');
    input.value = '';   // clear now so the autocomplete blur handler sees an empty box
    err.innerText = 'Looking up ' + accId + '...';
    fetch(apiUrl + '/rgdws/ontology/term/' + encodeURIComponent(accId), { headers: { 'Accept': 'application/json' } })
      .then(function (resp) { return resp.ok ? resp.text() : ''; })
      .then(function (text) {
        var term = null;
        try { term = text ? JSON.parse(text) : null; } catch (e) { term = null; }
        if (!term || !term.accId) {
          err.innerText = 'No ' + ont + ' term found for ' + accId + '.';
          input.value = raw;   // put the text back so it can be corrected
          return;
        }
        err.innerText = '';
        addTerm(term.accId, term.term || term.accId, cfg);
      })
      .catch(function () { input.value = raw; err.innerText = 'Could not look up ' + accId + '. Please try again.'; });
  }

  function addTerm(accId, term, cfg) {
    if (!accId || !cfg) return;
    if (selectedAcc[cfg.type][accId]) return; // already added

    selectedAcc[cfg.type][accId] = true;

    var li = document.createElement('li');
    li.className = 'st-row';
    li.setAttribute('data-acc', accId);

    var labelSpan = document.createElement('span');
    var name = document.createElement('span');
    name.className = 'st-row-label';
    name.innerText = term || accId;
    var acc = document.createElement('span');
    acc.className = 'st-row-acc';
    acc.innerText = '(' + accId + ')';
    labelSpan.appendChild(name);
    labelSpan.appendChild(acc);

    var hidden = document.createElement('input');
    hidden.type = 'hidden';
    hidden.name = cfg.inputName;
    hidden.value = accId;

    var remove = document.createElement('button');
    remove.type = 'button';
    remove.className = 'st-remove';
    remove.innerHTML = '&times;';
    remove.title = 'Remove';
    remove.onclick = function () {
      delete selectedAcc[cfg.type][accId];
      li.parentNode.removeChild(li);
      updateMeta(cfg);
    };

    li.appendChild(labelSpan);
    li.appendChild(hidden);
    li.appendChild(remove);
    document.getElementById(cfg.listId).appendChild(li);

    updateMeta(cfg);
  }

  // Global hook invoked by the shared ontology popup after a term is chosen.
  window.onOntTermSelected = function (accId, term, selAccId) {
    var cfg = resolveCfg(accId, selAccId);
    addTerm(accId, term, cfg);
    if (selAccId) {
      var s = document.getElementById(selAccId);
      if (s) s.value = '';
      var st = document.getElementById(selAccId + '_term');
      if (st) st.value = '';
    }
  };

  // A preloaded selection arrives as a bare accession (the wizard carries ids, not names), which would
  // render as "RS:0000681 (RS:0000681)". Resolve each one against the ontology in the background and
  // relabel the row in place so it reads "SD (RS:0000681)", matching what manual entry now produces.
  function relabelFromOntology(accId, cfg) {
    fetch(apiUrl + '/rgdws/ontology/term/' + encodeURIComponent(accId), { headers: { 'Accept': 'application/json' } })
      .then(function (resp) { return resp.ok ? resp.text() : ''; })
      .then(function (text) {
        var t = null;
        try { t = text ? JSON.parse(text) : null; } catch (e) { t = null; }
        if (!t || !t.term) return;
        var el = document.querySelector('#' + cfg.listId + ' li[data-acc="' + accId + '"] .st-row-label');
        if (el) el.innerText = t.term;
      })
      .catch(function () { /* leave the accession as the label */ });
  }

  // Pre-populate the picker from the current query, then resolve the names asynchronously.
  (function preloadEdit() {
    var seed = [
      [STRAIN_IDS, ST_LISTS.strainStaging],
      [TISSUE_IDS, ST_LISTS.tissueStaging],
      [CONDITION_IDS, ST_LISTS.conditionStaging]
    ];
    for (var s = 0; s < seed.length; s++) {
      var ids = seed[s][0], cfg = seed[s][1];
      for (var i = 0; i < ids.length; i++) {
        addTerm(ids[i], ids[i], cfg);
        relabelFromOntology(ids[i], cfg);
      }
    }
  })();

  // Term-name search for each ontology (shared component). Selecting adds the term with its real name.
  if (typeof setupOntologyAutocomplete === 'function') {
    setupOntologyAutocomplete('#strainInput', 'RS', {
      onSelect: function (term, accId) {
        addTerm(accId, term, ST_LISTS.strainStaging);
        var el = document.getElementById('strainInput'); if (el) el.value = '';
      }
    });
    setupOntologyAutocomplete('#tissueInput', 'UBERON', {
      onSelect: function (term, accId) {
        addTerm(accId, term, ST_LISTS.tissueStaging);
        var el = document.getElementById('tissueInput'); if (el) el.value = '';
      }
    });
    setupOntologyAutocomplete('#conditionInput', 'XCO', {
      onSelect: function (term, accId) {
        addTerm(accId, term, ST_LISTS.conditionStaging);
        var el = document.getElementById('conditionInput'); if (el) el.value = '';
      }
    });
  }
</script>

<%@ include file="/common/footerarea.jsp" %>
