<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
  String pageTitle = "Expression Miner (Select Strains and Tissues)";
  String headContent = "";
  String pageDescription = "Select strains (RS) and tissues (UBERON) through the ontology browser";
%>
<%@ include file="/common/headerarea.jsp" %>

<style>
  .st-container {
    max-width: 900px;
    margin: 20px auto;
    padding: 0 20px 20px 20px;
  }

  .st-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid rgba(255,255,255,0.3);
  }

  .st-title {
    font-size: 18px;
    font-weight: bold;
    color: #ffffff;
  }

  .st-assembly {
    font-size: 14px;
    color: #b8d4f0;
  }

  .st-instructions {
    background: #e8f4fc;
    border-left: 4px solid #3a7aba;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #2a4a6a;
    font-size: 13px;
    line-height: 1.5;
  }

  .st-card {
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  }

  .st-card-title {
    font-size: 15px;
    font-weight: bold;
    color: #1a3a5a;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid #dde5ef;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .st-count {
    font-size: 12px;
    color: white;
    background: #3a7aba;
    padding: 2px 9px;
    border-radius: 10px;
  }

  .st-browse-btn {
    font-size: 13px;
    font-weight: bold;
    background: linear-gradient(to bottom, #4a8ac9 0%, #3a7aba 100%);
    color: white;
    border: 1px solid #2f6699;
    border-radius: 4px;
    padding: 8px 18px;
    cursor: pointer;
    box-shadow: 0 1px 3px rgba(0,0,0,0.15);
    transition: all 0.2s ease;
  }

  .st-browse-btn:hover {
    background: linear-gradient(to bottom, #5a9ada 0%, #4a8ac9 100%);
    transform: translateY(-1px);
  }

  .st-list {
    list-style: none;
    margin: 14px 0 0 0;
    padding: 0;
  }

  .st-list-empty {
    color: #6a7a8a;
    font-size: 13px;
    font-style: italic;
    margin-top: 12px;
  }

  .st-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    background: #f8fafc;
    border: 1px solid #dde5ef;
    border-radius: 4px;
    margin-bottom: 6px;
  }

  .st-row-label {
    font-size: 13px;
    color: #1a3a5a;
  }

  .st-row-acc {
    font-size: 12px;
    color: #5a7a9a;
    margin-left: 6px;
  }

  .st-remove {
    background: none;
    border: none;
    color: #b34747;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    line-height: 1;
    padding: 0 4px;
  }

  .st-remove:hover {
    color: #e05050;
  }

  .form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 15px;
  }

  .continueButtonPrimary {
    font-size: 14px;
    font-weight: bold;
    background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
    color: white;
    border: 1px solid #1e7e34;
    border-radius: 4px;
    padding: 10px 24px;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    transition: all 0.2s ease;
  }

  .continueButtonPrimary:hover {
    background: linear-gradient(to bottom, #34ce57 0%, #28a745 100%);
    transform: translateY(-1px);
    box-shadow: 0 3px 6px rgba(0,0,0,0.2);
  }

  .backLink {
    color: #0052a1;
    text-decoration: none;
    font-size: 13px;
  }

  .backLink:hover {
    color: #bd80ff;
    text-decoration: underline;
  }
</style>

<%
  int mapKey = 380;
  try {
    mapKey = (Integer) request.getAttribute("mapKey");
  } catch (Exception ignore) {}

  String assemblyName = null;
  try {
    assemblyName = MapManager.getInstance().getMap(mapKey).getName();
  } catch (Exception ignore) {}

  String geneList = (String) request.getAttribute("geneList");

  List<String> selectedStrainIds = (List<String>) request.getAttribute("selectedStrainIds");
  if (selectedStrainIds == null) selectedStrainIds = new ArrayList<String>();
  List<String> selectedTissueIds = (List<String>) request.getAttribute("selectedTissueIds");
  if (selectedTissueIds == null) selectedTissueIds = new ArrayList<String>();

  String nextAction = (String) request.getAttribute("nextAction");
  if (nextAction == null) nextAction = "/rgdweb/expressMiner/config.html";
%>

<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>

<div class="typerMat">
  <div class="st-container">
    <div class="st-header">
      <div class="st-title">Select Strains and Tissues</div>
      <% if (assemblyName != null) { %>
      <div class="st-assembly"><%=assemblyName%> assembly</div>
      <% } %>
    </div>

    <div class="st-instructions">
      Use the <strong>ontology browser</strong> to add one or more <strong>strains</strong> (RS) and/or
      <strong>tissues</strong> (UBERON). You may choose either, both, or neither &mdash; selections are optional.
      Click <em>Browse Ontology Tree</em>, find a term, and it will be added to the list below.
    </div>

    <form action="<%=nextAction%>" name="optionForm" id="optionForm" method="post">
      <input type="hidden" name="mapKey" value="<%=mapKey%>"/>
      <% if (geneList != null && !geneList.trim().isEmpty()) { %>
      <input type="hidden" name="geneList" value="<%= geneList.replace("\"","&quot;") %>"/>
      <% } %>

      <!-- Staging inputs the ontology popup writes to before our hook fires -->
      <input type="hidden" id="strainStaging"/>
      <input type="hidden" id="strainStaging_term"/>
      <input type="hidden" id="tissueStaging"/>
      <input type="hidden" id="tissueStaging_term"/>

      <!-- Strains (RS) -->
      <div class="st-card">
        <div class="st-card-title">
          <span>Strains (RS) <span id="strainCount" class="st-count">0</span></span>
          <button type="button" class="st-browse-btn"
                  onclick="ontPopup('strainStaging','rs','strainStaging_term'); return false;">Browse Ontology Tree</button>
        </div>
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
        <ul id="tissueList" class="st-list"></ul>
        <div id="tissueEmpty" class="st-list-empty">No tissues selected yet.</div>
      </div>

      <div class="form-actions">
        <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
        <input class="continueButtonPrimary" type="submit" value="Continue..."/>
      </div>
    </form>
  </div>
</div>

<script>
  // Configuration for the two list builders, keyed by the staging input id the
  // ontology popup was pointed at.
  var ST_LISTS = {
    strainStaging: { type: 'strain', inputName: 'strainId', listId: 'strainList',
                     countId: 'strainCount', emptyId: 'strainEmpty', prefix: 'RS:' },
    tissueStaging: { type: 'tissue', inputName: 'tissueId', listId: 'tissueList',
                     countId: 'tissueCount', emptyId: 'tissueEmpty', prefix: 'UBERON:' }
  };

  // Track selected accession ids per type to avoid duplicates.
  var selectedAcc = { strain: {}, tissue: {} };

  // Resolve which list a selection belongs to. Prefer the staging field the
  // popup targeted; fall back to the accession id prefix.
  function resolveCfg(accId, selAccId) {
    if (selAccId && ST_LISTS[selAccId]) return ST_LISTS[selAccId];
    var up = (accId || '').toUpperCase();
    if (up.indexOf('UBERON:') === 0) return ST_LISTS.tissueStaging;
    if (up.indexOf('RS:') === 0) return ST_LISTS.strainStaging;
    return null;
  }

  function updateMeta(cfg) {
    var count = Object.keys(selectedAcc[cfg.type]).length;
    document.getElementById(cfg.countId).innerText = count;
    document.getElementById(cfg.emptyId).style.display = count === 0 ? 'block' : 'none';
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

  // Global hook invoked by the shared ontology popup (tree_popup.jsp) after a
  // term is chosen. Instead of overwriting a single input, we append to a list.
  window.onOntTermSelected = function (accId, term, selAccId) {
    var cfg = resolveCfg(accId, selAccId);
    addTerm(accId, term, cfg);
    // Clear the staging fields so the next browse starts fresh.
    if (selAccId) {
      var s = document.getElementById(selAccId);
      if (s) s.value = '';
      var st = document.getElementById(selAccId + '_term');
      if (st) st.value = '';
    }
  };

  // Pre-populate any selections carried forward from a previous step. Term names
  // are not resolved server-side (no SQL in the web app), so the accession id is
  // shown as the label until the user browses for a friendlier name.
  (function preload() {
    <% for (String accId : selectedStrainIds) { %>
    addTerm('<%= accId.replace("'", "\\'") %>', '<%= accId.replace("'", "\\'") %>', ST_LISTS.strainStaging);
    <% } %>
    <% for (String accId : selectedTissueIds) { %>
    addTerm('<%= accId.replace("'", "\\'") %>', '<%= accId.replace("'", "\\'") %>', ST_LISTS.tissueStaging);
    <% } %>
  })();
</script>

<%@ include file="/common/footerarea.jsp" %>
