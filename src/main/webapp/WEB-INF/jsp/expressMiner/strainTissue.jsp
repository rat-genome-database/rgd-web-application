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

  .st-add {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-top: 12px;
  }

  .st-add-input {
    flex: 1;
    padding: 8px 12px;
    border: 1px solid #bccada;
    border-radius: 4px;
    background: #f8fafc;
    color: #333;
    font-size: 13px;
  }

  .st-add-input:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 3px rgba(58, 122, 186, 0.15);
    background: #fff;
  }

  .st-add-btn {
    font-size: 13px;
    font-weight: bold;
    background: #eef4fb;
    color: #2f6699;
    border: 1px solid #bccada;
    border-radius: 4px;
    padding: 8px 16px;
    cursor: pointer;
    white-space: nowrap;
  }

  .st-add-btn:hover {
    background: #dce8f4;
    border-color: #3a7aba;
  }

  .st-add-error {
    color: #b34747;
    font-size: 12px;
    margin-top: 6px;
    min-height: 14px;
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

  .action-buttons {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .st-secondary-btn {
    font-size: 14px;
    font-weight: bold;
    background: linear-gradient(to bottom, #4a8ac9 0%, #3a7aba 100%);
    color: white;
    border: 1px solid #2f6699;
    border-radius: 4px;
    padding: 10px 20px;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    transition: all 0.2s ease;
  }

  .st-secondary-btn:hover {
    background: linear-gradient(to bottom, #5a9ada 0%, #4a8ac9 100%);
    transform: translateY(-1px);
    box-shadow: 0 3px 6px rgba(0,0,0,0.2);
  }

  .continueButtonPrimary[disabled], .st-secondary-btn[disabled] {
    background: #aab8c5;
    border-color: #93a2b0;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  .st-selection-hint {
    text-align: right;
    color: #8a6d1a;
    font-size: 12px;
    margin-top: 8px;
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
      Add one or more <strong>strains</strong> (RS) and/or <strong>tissues</strong> (UBERON). You may choose either,
      both, or neither &mdash; selections are optional. Either click <em>Browse Ontology Tree</em> to find a term, or
      type an accession id directly (e.g. <em>RS:0000681</em> or <em>UBERON:0002107</em>) and click <em>Add</em>.
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
        <div class="st-add">
          <input type="text" id="strainManualInput" class="st-add-input"
                 placeholder="Enter a strain accession, e.g. RS:0000681"
                 onkeydown="if(event.key==='Enter'){event.preventDefault(); addManual('strainStaging');}"/>
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
          <input type="text" id="tissueManualInput" class="st-add-input"
                 placeholder="Enter a tissue accession, e.g. UBERON:0002107"
                 onkeydown="if(event.key==='Enter'){event.preventDefault(); addManual('tissueStaging');}"/>
          <button type="button" class="st-add-btn" onclick="addManual('tissueStaging')">Add</button>
        </div>
        <div id="tissueAddError" class="st-add-error"></div>
        <ul id="tissueList" class="st-list"></ul>
        <div id="tissueEmpty" class="st-list-empty">No tissues selected yet.</div>
      </div>

      <div class="form-actions">
        <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
        <div class="action-buttons">
          <button type="button" id="addGeneBtn" class="st-secondary-btn"
                  onclick="proceed('/rgdweb/expressMiner/geneList.html')" disabled>Add Gene List&hellip;</button>
          <button type="button" id="continueBtn" class="continueButtonPrimary"
                  onclick="proceed('<%=nextAction%>')" disabled>Continue&hellip;</button>
        </div>
      </div>
      <div id="selectionHint" class="st-selection-hint">Select at least one strain or tissue to continue.</div>
    </form>
  </div>
</div>

<script>
  // Configuration for the two list builders, keyed by the staging input id the
  // ontology popup was pointed at.
  var ST_LISTS = {
    strainStaging: { type: 'strain', inputName: 'strainId', listId: 'strainList',
                     countId: 'strainCount', emptyId: 'strainEmpty', prefix: 'RS:',
                     manualInputId: 'strainManualInput', errorId: 'strainAddError' },
    tissueStaging: { type: 'tissue', inputName: 'tissueId', listId: 'tissueList',
                     countId: 'tissueCount', emptyId: 'tissueEmpty', prefix: 'UBERON:',
                     manualInputId: 'tissueManualInput', errorId: 'tissueAddError' }
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
    updateProceedState();
  }

  // Normalize a typed accession to PREFIX + digits (e.g. "681" or "rs:681" -> "RS:681"),
  // returning null if it can't be coerced into the expected prefix.
  function normalizeAcc(raw, prefix) {
    var v = (raw || '').toUpperCase().replace(/\s+/g, '');
    if (/^[0-9]+$/.test(v)) v = prefix + v;   // bare number -> prepend the expected prefix
    if (v.indexOf(prefix) !== 0) return null;
    var rest = v.substring(prefix.length);
    if (!/^[0-9]+$/.test(rest)) return null;
    return v;
  }

  // Add a term by typed accession, no ontology tree needed. The name is shown as the
  // accession here; the results page resolves the real term name server-side.
  function addManual(stagingId) {
    var cfg = ST_LISTS[stagingId];
    var input = document.getElementById(cfg.manualInputId);
    var err = document.getElementById(cfg.errorId);
    err.innerText = '';

    var raw = (input.value || '').trim();
    if (!raw) return;

    var accId = normalizeAcc(raw, cfg.prefix);
    if (!accId) {
      err.innerText = 'Enter a valid ' + cfg.prefix + ' accession (e.g. ' + cfg.prefix + '0000123).';
      return;
    }
    if (selectedAcc[cfg.type][accId]) {
      err.innerText = accId + ' is already in the list.';
      return;
    }
    addTerm(accId, accId, cfg);
    input.value = '';
  }

  // Require at least one strain or tissue before either action is allowed.
  function updateProceedState() {
    var total = Object.keys(selectedAcc.strain).length + Object.keys(selectedAcc.tissue).length;
    var has = total > 0;
    document.getElementById('continueBtn').disabled = !has;
    document.getElementById('addGeneBtn').disabled = !has;
    document.getElementById('selectionHint').style.display = has ? 'none' : 'block';
  }

  // Submit the shared form to the chosen next step (results, or the gene-list step).
  function proceed(action) {
    var form = document.getElementById('optionForm');
    form.action = action;
    form.submit();
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
    updateProceedState();
  })();
</script>

<%@ include file="/common/footerarea.jsp" %>
