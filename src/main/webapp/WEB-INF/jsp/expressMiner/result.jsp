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
    overflow: hidden;
  }

  .em-facet-panel.collapsed { display: none; }

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
    color: #3a7aba;
    font-size: 12px;
    cursor: pointer;
    text-decoration: none;
  }
  .em-facet-clear a:hover { text-decoration: underline; }

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

  /* Results toolbar */
  .em-toolbar {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
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

  .em-table-scroll { overflow-x: auto; }

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
    position: sticky;
    top: 0;
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
  String expressionLevel = (String) request.getAttribute("expressionLevel");

  List<Integer> rgdIds = (List<Integer>) request.getAttribute("rgdIds");
  if (rgdIds == null) rgdIds = new ArrayList<Integer>();
  List<String> unresolvedSymbols = (List<String>) request.getAttribute("unresolvedSymbols");
  if (unresolvedSymbols == null) unresolvedSymbols = new ArrayList<String>();
%>

<div class="typerMat">
  <div class="em-layout">

    <!-- Collapsible facet panel (populated from /index/facets) -->
    <aside id="emFacetPanel" class="em-facet-panel">
      <div class="em-facet-header">
        <span>Filter Results</span>
        <button type="button" class="em-facet-close" title="Hide filters" onclick="toggleFacets()">&times;</button>
      </div>
      <div class="em-facet-clear"><a onclick="clearFacets()">Clear all filters</a></div>
      <div id="emFacetGroups"></div>
    </aside>

    <div class="em-result-main">
      <div class="em-result-header">
        <div class="em-result-title">Expression Results</div>
        <% if (assemblyName != null) { %>
        <div class="em-result-assembly"><%=assemblyName%> assembly</div>
        <% } %>
      </div>

      <div class="em-toolbar">
        <button type="button" id="emFacetToggle" class="em-facet-toggle" onclick="toggleFacets()">&#9776; Filters</button>
      </div>

      <div class="em-filters">
        <strong>Query:</strong>
        <span>Tissues:</span>
        <% if (tissueIds.isEmpty()) { out.print("<em>none</em>"); }
           for (String t : tissueIds) { %><span class="chip"><%=t%></span><% } %>
        &nbsp;&nbsp;<span>Strains:</span>
        <% if (strainAccIds.isEmpty()) { out.print("<em>none</em>"); }
           for (String s : strainAccIds) { %><span class="chip"><%=s%></span><% } %>
        <% if (!rgdIds.isEmpty()) { %>
        &nbsp;&nbsp;<span>Genes:</span> <span class="chip"><%=rgdIds.size()%> gene<%=rgdIds.size()==1?"":"s"%></span>
        <% } %>
        <% if (expressionLevel != null && !expressionLevel.isBlank()) { %>
        &nbsp;&nbsp;<span>Level:</span> <span class="chip"><%=expressionLevel%></span>
        <% } %>
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
                <th>GEO</th>
              </tr>
            </thead>
            <tbody id="emTableBody"></tbody>
          </table>
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
  var MAP_KEY = <%=mapKey%>;
  var EXPRESSION_LEVEL = <%= (expressionLevel == null || expressionLevel.isBlank()) ? "null" : ("'" + expressionLevel.replace("'", "\\'") + "'") %>;
  var RGD_IDS = [<% for (int i = 0; i < rgdIds.size(); i++) { if (i>0) out.print(","); out.print(rgdIds.get(i)); } %>];

  var PAGE_SIZE = 10000; // page size requested per query (endpoint caps from+size at 10000)
  var RENDER_CAP = 2000; // max rows drawn at once (the query still returns up to PAGE_SIZE)
  var FACET_SEARCH_THRESHOLD = 8; // groups longer than this get a search box

  var GENES_ONLY = TISSUE_IDS.length === 0 && STRAIN_IDS.length === 0 && RGD_IDS.length > 0;
  var allRecords = [];   // the loaded records; all facet filtering runs against these
  var serverTotal = 0;   // total matching records reported by the server

  // Facet groups shown in the panel. Options and counts come from the server /index/facets call;
  // `accOf` maps a record to the value the facet keys on, used to filter the table client-side so
  // it updates immediately when a facet is checked.
  var FACET_GROUPS = [
    { key: 'levels',  title: 'Expression Level', accOf: function (r) { return r.expressionLevel; } },
    { key: 'units',   title: 'Unit',             accOf: function (r) { return r.expressionUnit; } },
    { key: 'genes',   title: 'Gene',             accOf: function (r) { return String(r.geneRgdId); } },
    { key: 'tissues', title: 'Tissue',           accOf: function (r) { return r.tissueAcc; } },
    { key: 'strains', title: 'Strain',           accOf: function (r) { return r.strainAcc; } }
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

  // Records that are identical on every displayed field except condition are the "duplicate"
  // rows -- collapse them into one group whose conditions are collected into a list.
  function groupRecords(records) {
    var byKey = {};
    var order = [];
    for (var i = 0; i < records.length; i++) {
      var r = records[i];
      var key = [
        r.geneRgdId, r.geneSymbol, r.tissueAcc, r.tissueTerm, r.strainAcc, r.strainTerm,
        r.expressionValue, r.expressionUnit, r.expressionLevel,
        (r.sex || r.computedSex || ''), r.lifeStage, r.species, r.studyId, r.geoSeriesAcc
      ].join('');
      var g = byKey[key];
      if (!g) { g = { rec: r, conditions: [] }; byKey[key] = g; order.push(key); }
      if (r.condition && g.conditions.indexOf(r.condition) === -1) g.conditions.push(r.condition);
    }
    return order.map(function (k) { return byKey[k]; });
  }

  function conditionCell(conditions) {
    if (!conditions || conditions.length === 0) return '';
    if (conditions.length === 1) return esc(conditions[0]);
    var items = conditions.slice().sort().map(function (c) { return '<li>' + esc(c) + '</li>'; });
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
          '<td>' + ontCell(r.tissueTerm, r.tissueAcc) + '</td>' +
          '<td>' + ontCell(r.strainTerm, r.strainAcc) + '</td>' +
          '<td class="num">' + num(r.expressionValue) + '</td>' +
          '<td>' + esc(r.expressionUnit) + '</td>' +
          '<td>' + levelBadge(r.expressionLevel) + '</td>' +
          '<td>' + esc(r.sex || r.computedSex || '') + '</td>' +
          '<td>' + esc(r.lifeStage) + '</td>' +
          '<td>' + conditionCell(groups[i].conditions) + '</td>' +
          '<td>' + esc(r.species) + '</td>' +
          '<td>' + studyCell(r) + '</td>' +
          '<td>' + geoCell(r) + '</td>' +
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
    var boxes = document.querySelectorAll('#emFacetGroups input[type=checkbox]');
    for (var i = 0; i < boxes.length; i++) boxes[i].checked = false;
    reloadRecords();
    loadFacets(false);
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

  // Build the checkbox groups from the /index/facets payload. Groups with a single
  // value are skipped (filtering to the only value would be a no-op).
  function renderFacets(facets) {
    var html = [];
    for (var g = 0; g < FACET_GROUPS.length; g++) {
      var group = FACET_GROUPS[g];
      var values = facets[group.key] || [];
      if (values.length < 2) continue;

      html.push('<div class="em-facet-group">');
      html.push('<div class="em-facet-group-title" onclick="toggleGroup(this)">' +
                '<span>' + esc(group.title) + '</span><span class="em-facet-caret">&#9662;</span></div>');
      html.push('<div class="em-facet-group-body">');
      // Long lists (e.g. the full gene list) get a search box to find a value to check.
      if (values.length > FACET_SEARCH_THRESHOLD) {
        html.push('<input type="text" class="em-facet-search" oninput="filterFacetItems(this)" ' +
                  'placeholder="Search ' + esc(group.title.toLowerCase()) + '"/>');
      }
      for (var i = 0; i < values.length; i++) {
        var v = values[i];
        var label = v.label && v.label !== v.acc ? v.label : v.acc;
        var hay = esc((label + ' ' + v.acc).toLowerCase());
        html.push(
          '<label class="em-facet-item" data-group="' + esc(group.key) + '" data-search="' + hay + '">' +
            '<input type="checkbox" onchange="onFacetChange(\'' + esc(group.key) + '\', this)" value="' + esc(v.acc) + '"/>' +
            '<span class="em-facet-label">' + esc(label) + '</span>' +
            '<span class="em-facet-count">' + v.count + '</span>' +
          '</label>'
        );
      }
      html.push('</div></div>');
    }
    document.getElementById('emFacetGroups').innerHTML =
      html.length ? html.join('') : '<div style="padding:12px 14px;font-size:12px;color:#7a8a9a;">No filters available.</div>';
  }

  // Fetch facets for the current selection from the server (accurate counts + resolved names).
  // First call builds the panel; later calls refresh the counts in place so numbers track filters.
  function loadFacets(initial) {
    fetch(apiUrl + '/rgdws/expression/index/facets?' + facetsQueryString(), { headers: { 'Accept': 'application/json' } })
      .then(function (resp) { return resp.ok ? resp.json() : null; })
      .then(function (facets) { if (!facets) return; if (initial) renderFacets(facets); else updateFacetCounts(facets); })
      .catch(function () { /* facets are optional; a failure just leaves the panel/counts unchanged */ });
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
    if (tissues.length) params.push('tissueIds=' + encodeURIComponent(tissues.join(',')));
    if (strains.length) params.push('strainAccIds=' + encodeURIComponent(strains.join(',')));
    if (genes.length) params.push('rgdIds=' + encodeURIComponent(genes.join(',')));
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

  // Update the count next to each rendered facet value from a fresh /index/facets response,
  // without rebuilding the panel (checked state, scroll and search text survive). Missing -> 0.
  function updateFacetCounts(facets) {
    for (var g = 0; g < FACET_GROUPS.length; g++) {
      var key = FACET_GROUPS[g].key;
      var vals = facets[key] || [];
      var map = {};
      for (var i = 0; i < vals.length; i++) map[vals[i].acc] = vals[i].count;
      var items = document.querySelectorAll('#emFacetGroups .em-facet-item[data-group="' + key + '"]');
      for (var j = 0; j < items.length; j++) {
        var box = items[j].querySelector('input[type=checkbox]');
        var cnt = items[j].querySelector('.em-facet-count');
        if (box && cnt) cnt.innerText = (map[box.value] != null ? map[box.value] : 0);
      }
    }
  }

  // Client-side test: does a record satisfy every checked facet group? (Drives the table.)
  function recordPassesFilters(r) {
    // Enforce the selected assembly. The genes endpoint (genes-only mode) does not yet filter by
    // mapKey, so it returns records for every assembly; keep only the one the facets are scoped to.
    if (MAP_KEY && Number(r.mapKey) !== Number(MAP_KEY)) return false;

    for (var g = 0; g < FACET_GROUPS.length; g++) {
      var group = FACET_GROUPS[g];
      var sel = selectedFacets[group.key];
      if (!sel) continue;
      var chosen = Object.keys(sel);
      if (chosen.length === 0) continue;
      if (!sel[group.accOf(r)]) return false;
    }
    return true;
  }

  function onFacetChange(groupKey, box) {
    if (!selectedFacets[groupKey]) selectedFacets[groupKey] = {};
    if (box.checked) selectedFacets[groupKey][box.value] = true;
    else delete selectedFacets[groupKey][box.value];
    reloadRecords();    // re-query the server for the full matching set
    loadFacets(false);  // refresh the facet counts
  }

  function updateCount(rows, loaded, total) {
    var meta = 'Showing <strong>' + rows + '</strong> row' + (rows === 1 ? '' : 's');
    if (loaded !== rows) meta += ' <span style="color:#7a8a9a;">(' + loaded + ' records)</span>';
    if (total != null && total !== loaded) meta += ' of <strong>' + total + '</strong> total';
    if (anyFacetSelected()) meta += ' <span style="color:#7a8a9a;">(filtered)</span>';
    document.getElementById('emCount').innerHTML = meta;
  }

  // ---- Data loading ----------------------------------------------------------

  // Records query with the checked facets folded in, so the server returns ALL matching records
  // (up to PAGE_SIZE) -- e.g. selecting level=high fetches every high record, not just the ones
  // already on screen. Facets the endpoint can't apply are handled by the client-side pass below.
  function serverRecordsUrl() {
    var params = [];
    if (GENES_ONLY) {
      // The genes endpoint supports gene + assembly + a single expression level.
      params.push('rgdIds=' + encodeURIComponent(selectedFor('genes', RGD_IDS.map(String)).join(',')));
      if (MAP_KEY) params.push('mapKey=' + MAP_KEY);
      var gLevels = checkedValues('levels');
      if (gLevels.length === 1) params.push('expressionLevel=' + encodeURIComponent(gLevels[0]));
      params.push('page=0');
      params.push('size=' + PAGE_SIZE);
      return apiUrl + '/rgdws/expression/index/records/genes?' + params.join('&');
    }
    params.push('tissueIds=' + encodeURIComponent(selectedFor('tissues', TISSUE_IDS).join(',')));
    params.push('strainAccIds=' + encodeURIComponent(selectedFor('strains', STRAIN_IDS).join(',')));
    var genes = selectedFor('genes', RGD_IDS.map(String));
    if (genes.length) params.push('rgdIds=' + encodeURIComponent(genes.join(',')));
    if (MAP_KEY) params.push('mapKey=' + MAP_KEY);
    var units = checkedValues('units');
    if (units.length) params.push('units=' + encodeURIComponent(units.join(',')));
    var levels = checkedValues('levels');
    if (levels.length) {
      params.push('expressionLevels=' + encodeURIComponent(levels.join(',')));
      // The deployed endpoint filters level via the single `expressionLevel` param, so send it too
      // when exactly one level is chosen -- this narrows server-side even before the multi param ships.
      if (levels.length === 1) params.push('expressionLevel=' + encodeURIComponent(levels[0]));
    }
    params.push('page=0');
    params.push('size=' + PAGE_SIZE);
    return apiUrl + '/rgdws/expression/index/records/tissues/strains?' + params.join('&');
  }

  // Re-query the server for the current facet selection, then draw the table (with a client-side
  // pass that enforces any facets the endpoint couldn't apply).
  function reloadRecords() {
    setStatus('loading', 'Loading expression records&hellip;');
    document.getElementById('emTableCard').style.display = 'none';

    fetch(serverRecordsUrl(), { headers: { 'Accept': 'application/json' } })
      .then(function (resp) {
        if (!resp.ok) throw new Error('Server returned ' + resp.status + ' ' + resp.statusText);
        return resp.json();
      })
      .then(function (data) {
        allRecords = data.records || [];
        serverTotal = (data.total !== undefined && data.total !== null) ? data.total : allRecords.length;

        if (allRecords.length === 0) {
          document.getElementById('emTableCard').style.display = 'none';
          setStatus('empty', anyFacetSelected()
            ? 'No records match the selected filters. <a onclick="clearFacets()" style="cursor:pointer;text-decoration:underline;">Clear the filters</a>.'
            : (GENES_ONLY
                ? ('No expression records for the selected gene' + (RGD_IDS.length === 1 ? '' : 's') + ' on this assembly.')
                : 'No expression records match the selected tissues and strains on this assembly.'));
          return;
        }
        applyClientFilters();
      })
      .catch(function (err) {
        setStatus('error', 'Could not load expression records: ' + esc(err.message));
      });
  }

  // Apply the checked facets to the loaded records (OR within a group, AND across groups), redraw
  // the table, and refresh the per-value counts. This is what makes the table track the filters.
  function applyClientFilters() {
    var filtered = allRecords.filter(recordPassesFilters);

    if (filtered.length === 0) {
      document.getElementById('emTableCard').style.display = 'none';
      setStatus('empty', anyFacetSelected()
        ? 'No records match the selected filters. <a onclick="clearFacets()" style="cursor:pointer;text-decoration:underline;">Clear the filters</a>.'
        : 'No expression records to show.');
      return;
    }

    hideStatus();
    var rowCount = renderRows(filtered);
    updateCount(rowCount, filtered.length, serverTotal);

    var note = '';
    if (rowCount > RENDER_CAP) {
      note = 'Showing first ' + RENDER_CAP + ' of ' + rowCount + ' rows -- refine filters to narrow.';
    } else if (serverTotal > allRecords.length) {
      note = 'Loaded first ' + allRecords.length + ' of ' + serverTotal + ' records -- refine filters for the full set.';
    }
    document.getElementById('emTruncated').innerText = note;

    document.getElementById('emTableCard').style.display = 'block';
  }

  function loadResults() {
    // Valid queries: a gene list (genes-only), or at least one tissue AND one strain.
    var hasTissuesAndStrains = TISSUE_IDS.length > 0 && STRAIN_IDS.length > 0;
    if (!hasTissuesAndStrains && !GENES_ONLY) {
      setStatus('warn', 'This result view needs a <strong>gene list</strong>, or at least one <strong>tissue</strong> and ' +
        'one <strong>strain</strong>. Go back and make a selection.');
      return;
    }

    loadFacets(true);  // build the facet panel from the server (accurate counts + names)
    reloadRecords();   // fetch the records for the current selection
  }

  document.addEventListener('DOMContentLoaded', loadResults);
</script>

<%@ include file="/common/footerarea.jsp" %>
