
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="static edu.mcw.rgd.web.RgdContext.getAPIHostname" %>
<%@ page import="java.util.List" %>

<%
  String pageTitle = "Expression Miner (Define Gene Symbol List)";
  String headContent = "";
  String pageDescription = "Define Gene Symbol List";

  HttpRequestFacade req = new HttpRequestFacade(request);
  DisplayMapper dm = new DisplayMapper(req,  new ArrayList());
%>
<%@ include file="/common/headerarea.jsp" %>

<style>
  /* Modern Gene List Page Styles - Light Theme */
  .typerTitle {
    margin-top: 20px;
  }

  .genelist-container {
    max-width: 900px;
    margin: 20px auto;
    padding: 0 20px 20px 20px;
  }

  .genelist-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid rgba(255,255,255,0.3);
  }

  .genelist-title {
    font-size: 18px;
    font-weight: bold;
    color: #ffffff;
  }

  .genelist-assembly {
    font-size: 14px;
    color: #b8d4f0;
  }

  .genelist-instructions {
    background: #e8f4fc;
    border-left: 4px solid #3a7aba;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #2a4a6a;
    font-size: 13px;
    line-height: 1.5;
  }

  .genelist-card {
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  }

  .card-title {
    font-size: 15px;
    font-weight: bold;
    color: #1a3a5a;
    margin-bottom: 15px;
    padding-bottom: 8px;
    border-bottom: 1px solid #dde5ef;
  }

  .gene-textarea {
    width: 100%;
    min-height: 250px;
    padding: 12px 15px;
    border: 1px solid #bccada;
    border-radius: 6px;
    background: #f8fafc;
    color: #333;
    font-size: 14px;
    font-family: 'Consolas', 'Monaco', monospace;
    line-height: 1.5;
    resize: vertical;
  }

  .gene-textarea:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 3px rgba(58, 122, 186, 0.15);
    background: #fff;
  }

  .gene-textarea::placeholder {
    color: #8899aa;
    font-family: inherit;
  }

  .form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 15px;
  }

  .backLink {
    color: #0052a1;
    text-decoration: none;
    font-size: 13px;
  }

  /* Continue Button */
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

  .continueButtonSecondary {
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

  .continueButtonSecondary:hover {
    background: linear-gradient(to bottom, #5a9ada 0%, #4a8ac9 100%);
    transform: translateY(-1px);
    box-shadow: 0 3px 6px rgba(0,0,0,0.2);
  }

  .gene-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .gene-action-buttons {
    display: flex;
    gap: 10px;
  }

  .gene-error {
    display: none;
    color: #b34747;
    font-size: 12px;
    text-align: right;
    margin-top: 8px;
  }

  /* Strains Selected Card */
  .strains-card {
    background: #dce8f4;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 15px 20px;
  }

  .strains-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
  }

  .strains-title {
    font-size: 14px;
    font-weight: bold;
    color: #1a3a5a;
  }

  .strains-count {
    font-size: 12px;
    color: white;
    background: #3a7aba;
    padding: 2px 8px;
    border-radius: 10px;
  }

  .strains-list {
    color: #445566;
    font-size: 13px;
    line-height: 1.6;
  }

  /* Example genes hint */
  .input-hint {
    font-size: 12px;
    color: #6a7a8a;
    margin-top: 8px;
  }

  /* Positional gene search */
  .pos-search-card {
    background: #eef4fb;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 16px 20px;
    margin-bottom: 16px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  }
  .pos-search-row {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: flex-end;
  }
  .pos-field { display: flex; flex-direction: column; }
  .pos-field label {
    font-size: 11px;
    font-weight: 600;
    color: #5a7a9a;
    margin-bottom: 3px;
    text-transform: uppercase;
    letter-spacing: 0.03em;
  }
  .pos-input {
    padding: 8px 10px;
    border: 1px solid #bccada;
    border-radius: 4px;
    background: #f8fafc;
    color: #333;
    font-size: 13px;
  }
  .pos-input:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 3px rgba(58, 122, 186, 0.15);
    background: #fff;
  }
  .pos-input.chr { width: 70px; }
  .pos-input.pos { width: 140px; }
  .pos-search-btn {
    font-size: 13px;
    font-weight: bold;
    background: linear-gradient(to bottom, #4a8ac9 0%, #3a7aba 100%);
    color: white;
    border: 1px solid #2f6699;
    border-radius: 4px;
    padding: 9px 18px;
    cursor: pointer;
    white-space: nowrap;
  }
  .pos-search-btn:hover { background: linear-gradient(to bottom, #5a9ada 0%, #4a8ac9 100%); }
  .pos-search-btn[disabled] { background: #aab8c5; border-color: #93a2b0; cursor: not-allowed; }
  .pos-search-status { font-size: 12px; margin-top: 8px; min-height: 14px; }
  .pos-search-status.err  { color: #b34747; }
  .pos-search-status.ok   { color: #1e7e34; }
  .pos-search-status.busy { color: #5a7a9a; }
</style>

<%
  String assemblyName = null;
  int mapKey = 0;
  try {
    mapKey = Integer.parseInt(request.getParameter("mapKey"));
    assemblyName = MapManager.getInstance().getMap(mapKey).getName();
  } catch (Exception ignore) {}

  // Count selected strains
  int strainCount = 0;
  for (int i = 1; i < 100; i++) {
    if (request.getParameter("sample" + i) != null) {
      strainCount++;
    }
  }

  List<String> selectedStudyIds = (List<String>) request.getAttribute("selectedStudyIds");
  Boolean studiesFirstObj = (Boolean) request.getAttribute("studiesFirst");
  boolean studiesFirst = studiesFirstObj != null && studiesFirstObj;

  List<String> selectedStrainIds = (List<String>) request.getAttribute("selectedStrainIds");
  if (selectedStrainIds == null) selectedStrainIds = new ArrayList<String>();
  List<String> selectedTissueIds = (List<String>) request.getAttribute("selectedTissueIds");
  if (selectedTissueIds == null) selectedTissueIds = new ArrayList<String>();
  List<String> selectedConditionIds = (List<String>) request.getAttribute("selectedConditionIds");
  if (selectedConditionIds == null) selectedConditionIds = new ArrayList<String>();

  String nextAction = (String) request.getAttribute("nextAction");
  if (nextAction == null) nextAction = "/rgdweb/expressMiner/config.html";

  Boolean genesEntryObj = (Boolean) request.getAttribute("genesEntry");
  boolean genesEntry = genesEntryObj != null && genesEntryObj;
%>

<script>
  // Submit the gene list to the chosen next step. When requireGenes is true (going straight
  // to the genes-only results), at least one gene symbol must be entered first.
  function proceedGeneList(action, requireGenes) {
    if (requireGenes) {
      var v = document.getElementById('geneList').value.trim();
      if (!v) {
        document.getElementById('geneListError').style.display = 'block';
        document.getElementById('geneList').focus();
        return;
      }
    }
    var form = document.optionForm;
    form.action = action;
    form.submit();
  }
</script>

<div class="typerMat">
  <div class="genelist-container">
    <!-- Header -->
    <div class="genelist-header">
      <div class="genelist-title">Enter Gene Symbols</div>
      <% if (assemblyName != null) { %>
      <div class="genelist-assembly"><%=assemblyName%> assembly</div>
      <% } %>
    </div>

    <!-- Instructions -->
    <div class="genelist-instructions">
      Enter one or more <strong>gene symbols</strong> to search for expression data.
      If entering multiple genes, separate them with <strong>commas</strong> or place each symbol on its own line.
      <% if (studiesFirst) { %>
      <br/><strong><%=selectedStudyIds.size()%></strong> <%=selectedStudyIds.size() == 1 ? "study" : "studies"%> selected on the previous step will be carried forward.
      <% } %>
      <% int stCount = selectedStrainIds.size() + selectedTissueIds.size() + selectedConditionIds.size();
         if (stCount > 0) { %>
      <br/><strong><%=stCount%></strong> strain/tissue/condition selection<%=stCount == 1 ? "" : "s"%> from the previous step will be carried forward.
      <% } %>
    </div>

    <!-- Gene List Input Card -->
    <form action="<%=nextAction%>" name="optionForm" method="post">
      <input type="hidden" name="mapKey" value="<%=mapKey%>"/>
      <% if (studiesFirst) {
           for (String sid : selectedStudyIds) { %>
      <input type="hidden" name="studyId" value="<%=sid%>"/>
      <% }
         } %>
      <% for (String strainId : selectedStrainIds) { %>
      <input type="hidden" name="strainId" value="<%=strainId%>"/>
      <% } %>
      <% for (String tissueId : selectedTissueIds) { %>
      <input type="hidden" name="tissueId" value="<%=tissueId%>"/>
      <% } %>
      <% for (String conditionId : selectedConditionIds) { %>
      <input type="hidden" name="conditionId" value="<%=conditionId%>"/>
      <% } %>

      <!-- Positional gene search: look up gene symbols in a genomic region on the current assembly and
           add them to the gene list below. Does not submit the form; it only populates the textarea. -->
      <div class="pos-search-card">
        <div class="card-title" style="border:none;padding:0;margin-bottom:10px;">Positional Gene Search<% if (assemblyName != null) { %>
          <span style="font-weight:normal;font-size:12px;color:#5a7a9a;">&mdash; <%=assemblyName%></span><% } %>
        </div>
        <div class="pos-search-row">
          <div class="pos-field">
            <label for="posChr">Chr</label>
            <input type="text" id="posChr" class="pos-input chr" placeholder="e.g. 1"
                   onkeydown="if(event.key==='Enter'){event.preventDefault(); positionalGeneSearch();}"/>
          </div>
          <div class="pos-field">
            <label for="posStart">Start</label>
            <input type="text" id="posStart" class="pos-input pos" inputmode="numeric" placeholder="e.g. 1000000"
                   onkeydown="if(event.key==='Enter'){event.preventDefault(); positionalGeneSearch();}"/>
          </div>
          <div class="pos-field">
            <label for="posStop">Stop</label>
            <input type="text" id="posStop" class="pos-input pos" inputmode="numeric" placeholder="e.g. 2000000"
                   onkeydown="if(event.key==='Enter'){event.preventDefault(); positionalGeneSearch();}"/>
          </div>
          <button type="button" id="posSearchBtn" class="pos-search-btn" onclick="positionalGeneSearch()">Find Genes</button>
        </div>
        <div id="posSearchStatus" class="pos-search-status"></div>
      </div>

      <div class="genelist-card">
        <div class="card-title">Gene Symbol List</div>
        <textarea
                class="gene-textarea"
                name="geneList"
                id="geneList"
                placeholder="Enter gene symbols here...&#10;&#10;Examples:&#10;Brca1&#10;Tp53, Egfr, Myc&#10;Pten"
        ><%=dm.out("geneList", req.getParameter("geneList"))%></textarea>
        <div class="input-hint">
          Tip: You can paste a list of genes directly from a spreadsheet or text file
        </div>
        <% if (genesEntry) { %>
        <div class="gene-actions">
          <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
          <div class="gene-action-buttons">
            <input class="continueButtonSecondary" type="button"
                   onClick="proceedGeneList('/rgdweb/expressMiner/strainTissue.html', false);"
                   value="Add Strains / Tissues..."/>
            <input class="continueButtonPrimary" type="button"
                   onClick="proceedGeneList('<%=nextAction%>', true);"
                   value="View Results"/>
          </div>
        </div>
        <div id="geneListError" class="gene-error">Enter at least one gene symbol to view results.</div>
        <% } else { %>
        <div class="form-actions">
          <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
          <input class="continueButtonPrimary" type="button"
                 onClick="proceedGeneList('<%=nextAction%>', false);" value="Continue..."/>
        </div>
        <% } %>
      </div>

    </form>

  </div>
</div>

<script>
  var POS_API_URL = "<%=getAPIHostname()%>";
  var POS_MAP_KEY = <%=mapKey%>;

  // Look up genes overlapping chr:start-stop on the current assembly and append their symbols to the
  // gene-list textarea. Uses the same /rgdws gene REST endpoint the rest of the site uses; the results
  // page still resolves symbols -> RGD ids server-side, so we only need the symbols here.
  function positionalGeneSearch() {
    var chrEl = document.getElementById('posChr');
    var startEl = document.getElementById('posStart');
    var stopEl = document.getElementById('posStop');
    var statusEl = document.getElementById('posSearchStatus');
    var btn = document.getElementById('posSearchBtn');

    function setStatus(cls, msg) { statusEl.className = 'pos-search-status ' + cls; statusEl.innerHTML = msg; }

    var chr = (chrEl.value || '').trim().replace(/^chr/i, '');   // accept "chr1" or "1"
    var start = (startEl.value || '').replace(/[,\s]/g, '');     // tolerate 1,000,000
    var stop = (stopEl.value || '').replace(/[,\s]/g, '');

    if (!chr) { setStatus('err', 'Enter a chromosome.'); chrEl.focus(); return; }
    if (!/^[0-9]+$/.test(start) || !/^[0-9]+$/.test(stop)) {
      setStatus('err', 'Start and stop must be whole numbers (base positions).'); return;
    }
    var s = parseInt(start, 10), e = parseInt(stop, 10);
    if (s > e) { setStatus('err', 'Start must be less than or equal to stop.'); return; }
    if (!POS_MAP_KEY) { setStatus('err', 'No assembly selected for this search.'); return; }

    var range = posEsc(chr) + ':' + s.toLocaleString() + '-' + e.toLocaleString();
    setStatus('busy', 'Searching ' + range + '&hellip;');
    btn.disabled = true;

    var url = POS_API_URL + '/rgdws/genes/' + encodeURIComponent(chr) + '/' + s + '/' + e + '/' + POS_MAP_KEY;
    fetch(url, { headers: { 'Accept': 'application/json' } })
      .then(function (resp) {
        if (!resp.ok) throw new Error('Server returned ' + resp.status + ' ' + resp.statusText);
        return resp.json();
      })
      .then(function (genes) {
        var symbols = [];
        (genes || []).forEach(function (g) {
          var sym = g && (g.symbol || g.geneSymbol);
          if (sym) symbols.push(sym);
        });
        if (!symbols.length) {
          setStatus('err', 'No genes found in ' + range + ' on this assembly.');
          return;
        }
        var added = addSymbolsToList(symbols);
        var dupes = symbols.length - added;
        setStatus('ok', 'Added ' + added + ' gene' + (added === 1 ? '' : 's') +
          (dupes > 0 ? ' (' + dupes + ' already in the list)' : '') + ' from ' + range + '.');
      })
      .catch(function (err) { setStatus('err', 'Positional search failed: ' + posEsc(err.message)); })
      .then(function () { btn.disabled = false; }); // runs on success or failure
  }

  // Merge symbols into the gene-list textarea, de-duplicating case-insensitively against what is already
  // there (whether typed by the user or added by a previous positional search). Returns the count added.
  function addSymbolsToList(symbols) {
    var ta = document.getElementById('geneList');
    var existing = (ta.value || '').split(/[\s,]+/).filter(function (t) { return t; });
    var seen = {};
    existing.forEach(function (t) { seen[t.toLowerCase()] = true; });
    var added = 0;
    symbols.forEach(function (sym) {
      var key = sym.toLowerCase();
      if (!seen[key]) { seen[key] = true; existing.push(sym); added++; }
    });
    ta.value = existing.join('\n');
    return added;
  }

  function posEsc(s) {
    if (s === null || s === undefined) return '';
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
</script>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>
<%@ include file="/common/footerarea.jsp" %>
