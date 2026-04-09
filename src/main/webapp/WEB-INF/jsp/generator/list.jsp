<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<%
String pageTitle = "OLGA - Object List Generator & Analyzer";
String headContent = "";
String pageDescription = "Build lists based on RGD annotation";
%>
<%@ include file="/common/headerarea.jsp" %>



<script type="text/javascript" src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script>
    var jq14 = jQuery.noConflict(true);
</script>
<script type="text/javascript"  src="/rgdweb/common/jquery.autocomplete.custom.js"></script>
<link rel="stylesheet" href="/rgdweb/OntoSolr/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!--link rel="stylesheet" href="/rgdweb/generator/generator.css" type="text/css" /-->
<script type="text/javascript"  src="/rgdweb/generator/generator.js?v=2"></script>


<form name="submitForm" id="submitForm" action="list.html" method="post" target="_blank">
    <input type="hidden" name="a" id="a" value="" />
    <input type="hidden" name="mapKey" id="mapKey" value="<%= request.getAttribute("mapKey") != null ? request.getAttribute("mapKey") : "" %>" />
    <input type="hidden" name="oKey" id="oKey" value="<%= request.getAttribute("oKey") != null ? request.getAttribute("oKey") : "" %>" />
    <input type="hidden" name="vv" id="vv" value="" />
    <input type="hidden" name="ga" id="ga" value="" />
    <input type="hidden" name="act" id="act" value="" />

    <%
        int count = 1;
        String val = "";
        while ((val = request.getParameter("sample" + count)) != null) {
    %>
            <input type="hidden" name="sample<%=count%>" value="<%=StringEscapeUtils.escapeHtml4(val)%>"/>

        <%
            count++;
        }
    %>


</form>

<!-- Add Criteria Modal -->
<style>
.add-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.6);
    z-index: 9999;
    justify-content: center;
    align-items: center;
}
.add-modal-overlay.active {
    display: flex;
}
.add-modal-content {
    background: white;
    border-radius: 12px;
    width: 90%;
    max-width: 700px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
}
.add-modal-header {
    background: #24609c;
    color: white;
    padding: 20px;
    border-radius: 12px 12px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.add-modal-header h3 {
    margin: 0;
    font-size: 20px;
}
.add-modal-close {
    background: none;
    border: none;
    color: white;
    font-size: 24px;
    cursor: pointer;
    padding: 0;
    line-height: 1;
}
.add-modal-body {
    padding: 25px;
}
.ont-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
}
.ont-chip {
    padding: 8px 16px;
    background: #f0f0f0;
    border: 1px solid #ddd;
    border-radius: 20px;
    cursor: pointer;
    font-size: 13px;
    transition: all 0.2s;
}
.ont-chip:hover {
    background: #e0e0e0;
}
.ont-chip.active {
    background: #24609c;
    color: white;
    border-color: #24609c;
}
.add-modal-search {
    background: #f0f7ff;
    border: 2px solid #24609c;
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 20px;
}
.add-modal-search label {
    display: block;
    font-weight: 600;
    color: #24609c;
    margin-bottom: 10px;
}
.add-modal-search input[type="text"] {
    width: 100%;
    padding: 12px;
    font-size: 16px;
    border: 1px solid #ccc;
    border-radius: 6px;
    box-sizing: border-box;
}
.add-modal-search .browse-btn {
    margin-top: 10px;
    padding: 8px 16px;
    background: #24609c;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
}
.add-modal-form-group {
    margin-bottom: 15px;
}
.add-modal-form-group label {
    display: block;
    font-weight: 600;
    margin-bottom: 8px;
}
.add-modal-form-group input,
.add-modal-form-group select,
.add-modal-form-group textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 14px;
    box-sizing: border-box;
}
.add-modal-footer {
    padding: 15px 25px;
    background: #f8f9fa;
    border-radius: 0 0 12px 12px;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
}
.add-modal-btn {
    padding: 12px 24px;
    border: none;
    border-radius: 6px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
}
.add-modal-btn-cancel {
    background: #f0f0f0;
    color: #333;
}
.add-modal-btn-add {
    background: #28a745;
    color: white;
}
.add-modal-btn-add:hover {
    background: #218838;
}

/* Screen transitions */
.modal-screen {
    display: none;
}
.modal-screen.active {
    display: block;
}

/* Type selection cards */
.modal-type-cards {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 15px;
}
.modal-type-card {
    background: #f8f9fa;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    padding: 25px 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s ease;
}
.modal-type-card:hover {
    border-color: #24609c;
    background: #f0f7ff;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
.modal-type-card i {
    font-size: 36px;
    color: #24609c;
    margin-bottom: 12px;
}
.modal-type-card h5 {
    margin: 0 0 8px;
    color: #333;
    font-size: 16px;
}
.modal-type-card p {
    margin: 0;
    color: #666;
    font-size: 13px;
}

/* Operation cards */
.modal-operation-cards {
    display: flex;
    flex-direction: column;
    gap: 15px;
}
.modal-operation-card {
    display: flex;
    align-items: center;
    padding: 20px;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.2s ease;
    background: #f8f9fa;
}
.modal-operation-card:hover {
    transform: translateX(5px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
.modal-operation-card.union:hover {
    border-color: #28a745;
    background: #f0fff4;
}
.modal-operation-card.intersect:hover {
    border-color: #007bff;
    background: #f0f7ff;
}
.modal-operation-card.subtract:hover {
    border-color: #dc3545;
    background: #fff5f5;
}
.modal-operation-card i {
    font-size: 32px;
    margin-right: 20px;
    width: 40px;
    text-align: center;
}
.modal-operation-card.union i { color: #28a745; }
.modal-operation-card.intersect i { color: #007bff; }
.modal-operation-card.subtract i { color: #dc3545; }
.modal-operation-card h5 {
    margin: 0 0 5px;
    font-size: 18px;
    color: #333;
}
.modal-operation-card p {
    margin: 0;
    color: #666;
    font-size: 14px;
}

/* Input panels */
.modal-input-panel {
    min-height: 200px;
}

/* Preview count badges */
.preview-count {
    display: inline-block;
    background: #fff;
    color: #333;
    padding: 2px 10px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 700;
    margin-left: 8px;
    border: 1px solid #ddd;
}
.modal-operation-card.union .preview-count {
    background: #d4edda;
    color: #155724;
    border-color: #c3e6cb;
}
.modal-operation-card.intersect .preview-count {
    background: #cce5ff;
    color: #004085;
    border-color: #b8daff;
}
.modal-operation-card.subtract .preview-count {
    background: #f8d7da;
    color: #721c24;
    border-color: #f5c6cb;
}
.modal-operation-card.disabled {
    opacity: 0.4;
    cursor: not-allowed;
    pointer-events: none;
}
.modal-operation-card.disabled:hover {
    transform: none;
    box-shadow: none;
    border-color: #e0e0e0;
    background: #f8f9fa;
}
</style>

<div class="add-modal-overlay" id="addCriteriaModal">
    <div class="add-modal-content">
        <div class="add-modal-header">
            <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Add Criteria</h3>
            <button class="add-modal-close" onclick="closeAddModal()">&times;</button>
        </div>
        <div class="add-modal-body">

            <!-- SCREEN 1: Choose Type -->
            <div class="modal-screen active" id="modal-screen-1">
                <h4 style="text-align:center; color:#333; margin-bottom:25px;">What type of list would you like to add?</h4>
                <div class="modal-type-cards">
                    <div class="modal-type-card" onclick="goToScreen2('ont')">
                        <i class="fas fa-sitemap"></i>
                        <h5>Ontology Annotation</h5>
                        <p>Search by disease, phenotype, pathway, or GO terms</p>
                    </div>
                    <div class="modal-type-card" onclick="goToScreen2('region')">
                        <i class="fas fa-map-marked-alt"></i>
                        <h5>Genomic Region</h5>
                        <p>Specify chromosome and position range</p>
                    </div>
                    <div class="modal-type-card" onclick="goToScreen2('qtl')">
                        <i class="fas fa-crosshairs"></i>
                        <h5>QTL Region</h5>
                        <p>Find genes within a QTL region</p>
                    </div>
                    <div class="modal-type-card" onclick="goToScreen2('symbols')" id="card-symbol-list">
                        <i class="fas fa-list"></i>
                        <h5>Symbol List</h5>
                        <p id="card-symbol-desc">Enter a list of symbols</p>
                    </div>
                    <div class="modal-type-card" onclick="goToScreen2('rgdids')">
                        <i class="fas fa-hashtag"></i>
                        <h5>RGD ID List</h5>
                        <p>Enter a list of RGD IDs</p>
                    </div>
                </div>
            </div>

            <!-- SCREEN 2: Input Form -->
            <div class="modal-screen" id="modal-screen-2">
                <!-- Ontology Input -->
                <div class="modal-input-panel" id="input-panel-ont">
                    <div class="ont-chips" id="modalOntChips">
                        <span class="ont-chip active" data-ont="rdo">Disease</span>
                        <span class="ont-chip" data-ont="mp">Mammalian Phenotype</span>
                        <span class="ont-chip" data-ont="pw">Pathway</span>
                        <span class="ont-chip" data-ont="bp">GO: Biological Process</span>
                        <span class="ont-chip" data-ont="mf">GO: Molecular Function</span>
                        <span class="ont-chip" data-ont="cc">GO: Cellular Component</span>
                        <span class="ont-chip" data-ont="chebi">CHEBI</span>
                        <span class="ont-chip" data-ont="vt">Vertebrate Trait</span>
                        <span class="ont-chip" data-ont="hp">Human Phenotype</span>
                        <span class="ont-chip" data-ont="rs">Strain Ontology</span>
                        <span class="ont-chip" data-ont="cmo">Clinical Measurement</span>
                        <span class="ont-chip" data-ont="mmo">Measurement Method</span>
                        <span class="ont-chip" data-ont="xco">Experimental Condition</span>
                        <span class="ont-chip" data-ont="efo">Experimental Factor</span>
                    </div>
                    <div class="add-modal-search">
                        <label><i class="fas fa-search"></i> Search for Ontology Terms</label>
                        <input type="text" id="modal_ont_term" placeholder="Type to search..." />
                        <input type="hidden" id="modal_ont_acc_id" />
                        <button type="button" class="browse-btn" onclick="browseModalOntology()"><i class="fas fa-sitemap"></i> Browse Tree</button>
                    </div>
                </div>

                <!-- Region Input -->
                <div class="modal-input-panel" id="input-panel-region" style="display:none;">
                    <h4 style="margin-bottom:20px;"><i class="fas fa-map-marked-alt"></i> Enter Genomic Region</h4>
                    <div class="add-modal-form-group">
                        <label>Chromosome</label>
                        <select id="modal_chr"></select>
                    </div>
                    <div style="display: flex; gap: 15px;">
                        <div class="add-modal-form-group" style="flex:1;">
                            <label>Start Position</label>
                            <input type="text" id="modal_start" placeholder="Optional (default: 1)" />
                        </div>
                        <div class="add-modal-form-group" style="flex:1;">
                            <label>Stop Position</label>
                            <input type="text" id="modal_stop" placeholder="Optional (default: end)" />
                        </div>
                    </div>
                </div>

                <!-- QTL Input -->
                <div class="modal-input-panel" id="input-panel-qtl" style="display:none;">
                    <h4 style="margin-bottom:20px;"><i class="fas fa-crosshairs"></i> Enter QTL Symbol</h4>
                    <div class="add-modal-form-group">
                        <label>QTL Symbol</label>
                        <input type="text" id="modal_qtl" placeholder="e.g., Bp1, Gluco1" />
                    </div>
                    <p style="color:#666; font-size:13px; margin-top:10px;">
                        <i class="fas fa-info-circle"></i> Enter a QTL symbol to find all genes that overlap its genomic region
                    </p>
                </div>

                <!-- Symbol List Input -->
                <div class="modal-input-panel" id="input-panel-symbols" style="display:none;">
                    <h4 style="margin-bottom:20px;"><i class="fas fa-list"></i> Enter Gene Symbols</h4>
                    <div class="add-modal-form-group">
                        <label>Symbols (comma or line separated)</label>
                        <textarea id="modal_symbols" rows="8" placeholder="Enter gene symbols...&#10;&#10;Example:&#10;Ins1, Ins2, Insr&#10;Irs1&#10;Irs2"></textarea>
                    </div>
                </div>

                <!-- RGD ID List Input -->
                <div class="modal-input-panel" id="input-panel-rgdids" style="display:none;">
                    <h4 style="margin-bottom:20px;"><i class="fas fa-hashtag"></i> Enter RGD IDs</h4>
                    <div class="add-modal-form-group">
                        <label>RGD IDs (comma or line separated)</label>
                        <textarea id="modal_rgdids" rows="8" placeholder="Enter RGD IDs...&#10;&#10;Example:&#10;2325, 3000&#10;61999&#10;1359413"></textarea>
                    </div>
                </div>
            </div>

            <!-- SCREEN 3: Combine Operation -->
            <%
                Integer _oKey = (Integer) request.getAttribute("oKey");
                String _objLabel = "genes";
                if (_oKey != null && _oKey == 5) _objLabel = "strains";
                else if (_oKey != null && _oKey == 6) _objLabel = "QTLs";
            %>
            <div class="modal-screen" id="modal-screen-3">
                <h4 style="text-align:center; color:#333; margin-bottom:25px;">How should this combine with your existing list?</h4>
                <div id="previewLoading" style="text-align:center; padding:20px; display:none;">
                    <i class="fas fa-spinner fa-spin" style="font-size:24px; color:#24609c;"></i>
                    <p style="color:#666; margin-top:10px;">Calculating preview counts...</p>
                </div>
                <div class="modal-operation-cards" id="operationCards">
                    <div class="modal-operation-card union" onclick="selectOperationAndSubmit('~')">
                        <i class="fas fa-plus-circle"></i>
                        <div>
                            <h5>Union (OR) <span id="previewUnion" class="preview-count"></span></h5>
                            <p>Include <span class="obj-type-label"><%=_objLabel%></span> from <strong>either</strong> list</p>
                        </div>
                    </div>
                    <div class="modal-operation-card intersect" onclick="selectOperationAndSubmit('!')">
                        <i class="fas fa-compress-alt"></i>
                        <div>
                            <h5>Intersect (AND) <span id="previewIntersect" class="preview-count"></span></h5>
                            <p>Only <span class="obj-type-label"><%=_objLabel%></span> in <strong>both</strong> lists</p>
                        </div>
                    </div>
                    <div class="modal-operation-card subtract" onclick="selectOperationAndSubmit('^')">
                        <i class="fas fa-minus-circle"></i>
                        <div>
                            <h5>Subtract (NOT) <span id="previewSubtract" class="preview-count"></span></h5>
                            <p><strong>Remove</strong> <span class="obj-type-label"><%=_objLabel%></span> from new criteria</p>
                        </div>
                    </div>
                </div>
            </div>

        </div>
        <div class="add-modal-footer" id="modalFooter">
            <button class="add-modal-btn add-modal-btn-cancel" id="modalBackBtn" onclick="goBackScreen()" style="display:none;">
                <i class="fas fa-arrow-left"></i> Back
            </button>
            <button class="add-modal-btn add-modal-btn-cancel" onclick="closeAddModal()">Cancel</button>
            <button class="add-modal-btn add-modal-btn-add" id="modalNextBtn" onclick="goToNextScreen()" style="display:none;">
                Continue <i class="fas fa-arrow-right"></i>
            </button>
        </div>
    </div>
</div>

<script>
// Map keys to species type keys (always available for ontology filtering)
var mapKeyToSpecies = {
    '380': 3, '372': 3, '360': 3, '70': 3, '60': 3,  // Rat
    '38': 1, '17': 1, '13': 1,     // Human
    '239': 2, '35': 2, '18': 2,    // Mouse
    '44': 4,                        // Chinchilla
    '634': 5, '631': 5,            // Dog
    '511': 6, '513': 6,            // Bonobo
    '720': 7,                       // Squirrel
    '911': 9, '910': 9,            // Pig
    '1311': 13, '1313': 13,        // Green Monkey
    '1410': 14,                     // Naked Mole-Rat
    '1701': 17                      // Black Rat
};

var modalCurrentOnt = 'rdo';
var modalCurrentScreen = 1;
var modalSelectedType = '';
var modalPendingAccId = null;

function openAddModal() {
    document.getElementById('addCriteriaModal').classList.add('active');
    // Reset to screen 1
    modalCurrentScreen = 1;
    modalSelectedType = '';
    modalPendingAccId = null;
    showModalScreen(1);
    updateModalButtons();
    // Initialize autocomplete for default ontology
    setupModalAutocomplete();
    // Filter ontology chips based on species and object type
    filterOntologyChips();
    // Update object type labels (genes/QTLs/strains)
    updateObjectTypeLabels();
    // Populate chromosome dropdown - try existing #chr first, otherwise load via AJAX
    var chrSelect = document.getElementById('modal_chr');
    var existingChr = document.getElementById('chr');
    if (existingChr && existingChr.options.length > 0) {
        chrSelect.innerHTML = existingChr.innerHTML;
    } else {
        // Load chromosomes for current mapKey
        var mapKey = document.getElementById('mapKey').value || document.getElementById('setup_mapKey')?.value || '380';
        loadChromosomesForMapKey(mapKey);
    }
}

function loadChromosomesForMapKey(mapKey) {
    var chrSelect = document.getElementById('modal_chr');
    chrSelect.innerHTML = '<option value="">Loading...</option>';

    // Fetch chromosomes via AJAX
    fetch('/rgdweb/generator/chromosomes.html?mapKey=' + mapKey)
        .then(function(response) { return response.json(); })
        .then(function(chromosomes) {
            chrSelect.innerHTML = '';
            for (var i = 0; i < chromosomes.length; i++) {
                var opt = document.createElement('option');
                opt.value = chromosomes[i].name;
                opt.textContent = chromosomes[i].name;
                if (chromosomes[i].size) opt.setAttribute('data-size', chromosomes[i].size);
                chrSelect.appendChild(opt);
            }
        })
        .catch(function(error) {
            console.error('Error loading chromosomes:', error);
            chrSelect.innerHTML = '';
            var defaultChrs = ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','X','Y','MT'];
            for (var i = 0; i < defaultChrs.length; i++) {
                var opt = document.createElement('option');
                opt.value = defaultChrs[i];
                opt.textContent = defaultChrs[i];
                chrSelect.appendChild(opt);
            }
        });
}

function closeAddModal() {
    document.getElementById('addCriteriaModal').classList.remove('active');
    // Clear inputs
    document.getElementById('modal_ont_term').value = '';
    document.getElementById('modal_ont_acc_id').value = '';
    document.getElementById('modal_start').value = '';
    document.getElementById('modal_stop').value = '';
    document.getElementById('modal_qtl').value = '';
    document.getElementById('modal_symbols').value = '';
    document.getElementById('modal_rgdids').value = '';
}

function showModalScreen(num) {
    document.querySelectorAll('.modal-screen').forEach(function(s) {
        s.classList.remove('active');
    });
    document.getElementById('modal-screen-' + num).classList.add('active');
    modalCurrentScreen = num;

    // Update title
    var title = document.getElementById('modalTitle');
    if (num === 1) {
        title.innerHTML = '<i class="fas fa-plus-circle"></i> Add Criteria';
    } else if (num === 2) {
        var typeNames = {ont: 'Ontology Annotation', region: 'Genomic Region', qtl: 'QTL Region', symbols: 'Symbol List'};
        title.innerHTML = '<i class="fas fa-edit"></i> ' + (typeNames[modalSelectedType] || 'Enter Details');
    } else if (num === 3) {
        title.innerHTML = '<i class="fas fa-code-branch"></i> Combine Lists';
    }

    updateModalButtons();
}

function updateModalButtons() {
    var backBtn = document.getElementById('modalBackBtn');
    var nextBtn = document.getElementById('modalNextBtn');

    if (modalCurrentScreen === 1) {
        backBtn.style.display = 'none';
        nextBtn.style.display = 'none';
    } else if (modalCurrentScreen === 2) {
        backBtn.style.display = 'inline-block';
        nextBtn.style.display = 'inline-block';
        nextBtn.innerHTML = (aAccIds.length > 0) ? 'Continue <i class="fas fa-arrow-right"></i>' : '<i class="fas fa-plus"></i> Add to List';
    } else if (modalCurrentScreen === 3) {
        backBtn.style.display = 'inline-block';
        nextBtn.style.display = 'none';
    }
}

function goToScreen2(type) {
    modalSelectedType = type;

    // Hide all input panels, show selected one
    document.querySelectorAll('.modal-input-panel').forEach(function(p) {
        p.style.display = 'none';
    });
    document.getElementById('input-panel-' + type).style.display = 'block';

    // Update symbol list labels based on object type
    if (type === 'symbols') {
        var oKeyVal = document.getElementById('oKey').value || '1';
        var titleEl = document.querySelector('#input-panel-symbols h4');
        var textareaEl = document.getElementById('modal_symbols');
        if (oKeyVal === '5') {
            titleEl.innerHTML = '<i class="fas fa-list"></i> Enter Strain Symbols';
            textareaEl.placeholder = 'Enter strain symbols...\n\nExample:\nSHR, BN\nF344\nWKY';
        } else if (oKeyVal === '6') {
            titleEl.innerHTML = '<i class="fas fa-list"></i> Enter QTL Symbols';
            textareaEl.placeholder = 'Enter QTL symbols...\n\nExample:\nBp1, Bp2\nGluco1';
        } else {
            titleEl.innerHTML = '<i class="fas fa-list"></i> Enter Gene Symbols';
            textareaEl.placeholder = 'Enter gene symbols...\n\nExample:\nIns1, Ins2, Insr\nIrs1\nIrs2';
        }
    }

    showModalScreen(2);

    if (type === 'ont') {
        setupModalAutocomplete();
    }
}

function goBackScreen() {
    if (modalCurrentScreen === 2) {
        showModalScreen(1);
    } else if (modalCurrentScreen === 3) {
        showModalScreen(2);
    }
}

function goToNextScreen() {
    if (modalCurrentScreen === 2) {
        // Validate input and get accId
        var accId = getModalAccId();
        if (!accId) {
            alert('Please enter or select a valid criteria.');
            return;
        }
        modalPendingAccId = accId;

        // If there are existing criteria, go to screen 3 to choose operation
        if (aAccIds.length > 0) {
            // Show screen 3 with loading indicator
            showModalScreen(3);
            fetchPreviewCounts(accId);
        } else {
            // No existing criteria, add directly with default union
            submitWithOperation('~');
        }
    }
}

function fetchPreviewCounts(newAccId) {
    // Show loading, hide cards
    document.getElementById('previewLoading').style.display = 'block';
    document.getElementById('operationCards').style.opacity = '0.5';

    // Clear previous counts
    document.getElementById('previewUnion').textContent = '';
    document.getElementById('previewIntersect').textContent = '';
    document.getElementById('previewSubtract').textContent = '';

    // Get mapKey and oKey from the form
    var mapKey = document.getElementById('mapKey').value || document.getElementById('mapKey_tmp').value || '380';
    var oKey = document.getElementById('oKey').value || document.getElementById('oKey_tmp').value || '1';

    // Fetch genes for the new criteria
    var url = '/rgdweb/generator/process.html?act=json&mapKey=' + mapKey + '&oKey=' + oKey + '&a=~' + encodeURIComponent(newAccId);

    fetch(url)
        .then(function(response) { return response.json(); })
        .then(function(newGenes) {
            // newGenes is an object with gene symbols as keys
            var newGeneSet = Object.keys(newGenes);

            // Calculate preview counts
            // Union: count how many NEW genes would be added
            var genesAdded = newGeneSet.filter(function(g) {
                return currentResultSet.indexOf(g) === -1;
            });

            // Intersect: count genes in both lists
            var genesIntersect = currentResultSet.filter(function(g) {
                return newGeneSet.indexOf(g) !== -1;
            });

            // Subtract: count genes that would be removed (genes in new list that are also in current)
            var genesRemoved = currentResultSet.filter(function(g) {
                return newGeneSet.indexOf(g) !== -1;
            });

            // Display counts with descriptive text
            var objLabel = getObjectTypeLabel();
            document.getElementById('previewUnion').textContent = genesAdded.length + ' ' + objLabel + ' would be added';
            document.getElementById('previewIntersect').textContent = genesIntersect.length + ' ' + objLabel + ' intersect';
            document.getElementById('previewSubtract').textContent = genesRemoved.length + ' ' + objLabel + ' would be removed';

            // Get the operation card elements
            var intersectCard = document.querySelector('.modal-operation-card.intersect');
            var subtractCard = document.querySelector('.modal-operation-card.subtract');

            // Disable intersect if 0 genes intersect
            if (genesIntersect.length === 0) {
                intersectCard.classList.add('disabled');
            } else {
                intersectCard.classList.remove('disabled');
            }

            // Disable subtract if 0 genes would be removed
            if (genesRemoved.length === 0) {
                subtractCard.classList.add('disabled');
            } else {
                subtractCard.classList.remove('disabled');
            }

            // Hide loading, show cards
            document.getElementById('previewLoading').style.display = 'none';
            document.getElementById('operationCards').style.opacity = '1';
        })
        .catch(function(error) {
            console.error('Error fetching preview:', error);
            // Hide loading and show error message
            document.getElementById('previewLoading').style.display = 'none';
            document.getElementById('operationCards').style.opacity = '1';
            // Show counts as unavailable
            document.getElementById('previewUnion').textContent = 'preview unavailable';
            document.getElementById('previewIntersect').textContent = 'preview unavailable';
            document.getElementById('previewSubtract').textContent = 'preview unavailable';
        });
}

function getModalAccId() {
    var accId = null;

    if (modalSelectedType === 'ont') {
        accId = document.getElementById('modal_ont_acc_id').value;
    } else if (modalSelectedType === 'symbols') {
        var symbols = document.getElementById('modal_symbols').value.trim();
        if (symbols) {
            var genes = symbols.split(/[,\s\n]+/);
            var geneStr = '';
            for (var i = 0; i < genes.length; i++) {
                var g = genes[i].trim();
                if (g === '') continue;
                if (geneStr === '') {
                    geneStr = g;
                } else {
                    geneStr += '[' + g;
                }
            }
            accId = 'lst:' + geneStr;
        }
    } else if (modalSelectedType === 'qtl') {
        var qtl = document.getElementById('modal_qtl').value.trim();
        if (qtl) {
            accId = 'qtl:' + qtl;
        }
    } else if (modalSelectedType === 'rgdids') {
        var ids = document.getElementById('modal_rgdids').value.trim();
        if (ids) {
            var idList = ids.split(/[,\s\n]+/);
            var idStr = '';
            for (var i = 0; i < idList.length; i++) {
                var id = idList[i].trim();
                if (id === '') continue;
                if (idStr === '') {
                    idStr = id;
                } else {
                    idStr += '[' + id;
                }
            }
            accId = 'ids:' + idStr;
        }
    } else if (modalSelectedType === 'region') {
        var chr = document.getElementById('modal_chr').value;
        var start = document.getElementById('modal_start').value.trim();
        var stop = document.getElementById('modal_stop').value.trim();
        if (chr) {
            var selOpt = document.getElementById('modal_chr').selectedOptions[0];
            var chrSize = selOpt ? selOpt.getAttribute('data-size') : null;
            var startNum = 1;
            var stopNum = chrSize ? parseInt(chrSize, 10) : 0;
            if (start) {
                startNum = parseInt(start.replace(/,/g, ''), 10);
                if (isNaN(startNum) || startNum < 0) {
                    alert('Start position must be a positive number.');
                    return null;
                }
            }
            if (stop) {
                stopNum = parseInt(stop.replace(/,/g, ''), 10);
                if (isNaN(stopNum) || stopNum < 0) {
                    alert('Stop position must be a positive number.');
                    return null;
                }
            }
            if (!stop && !chrSize) {
                alert('Could not determine chromosome size. Please enter a stop position.');
                return null;
            }
            if (startNum >= stopNum) {
                alert('Start position must be less than stop position.');
                return null;
            }
            accId = 'chr' + chr + ':' + startNum + '..' + stopNum;
        }
    }

    return accId;
}

function selectOperationAndSubmit(operation) {
    submitWithOperation(operation);
}

function submitWithOperation(operation) {
    if (!modalPendingAccId) {
        modalPendingAccId = getModalAccId();
    }

    if (!modalPendingAccId) {
        alert('No criteria selected.');
        return;
    }

    // Add to arrays and reload
    aOperators.push(operation);
    aAccIds.push(modalPendingAccId);
    aSubGenes.push([]);

    closeAddModal();
    reloadPage();
}

function setupModalAutocomplete() {
    if (typeof jq14 !== 'undefined') {
        var ontPrefix = modalCurrentOnt.toUpperCase();
        if (modalCurrentOnt === 'rdo') ontPrefix = 'RDO';
        if (modalCurrentOnt === 'bp' || modalCurrentOnt === 'mf' || modalCurrentOnt === 'cc') ontPrefix = 'GO';

        // Remove any existing autocomplete
        jq14('#modal_ont_term').unautocomplete();

        // Set up autocomplete with Solr endpoint
        jq14('#modal_ont_term').autocomplete('/solr/OntoSolr/select', {
            extraParams: {
                'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
                'bf': 'term_len_l^.02',
                'fq': 'cat:(' + ontPrefix + ')',
                'wt': 'velocity',
                'v.template': 'termidselect'
            },
            max: 100
        });

        // Handle selection
        jq14('#modal_ont_term').result(function(data, value) {
            if (value && value[1]) {
                document.getElementById('modal_ont_acc_id').value = value[1];
            }
        });
    }
}

// Ontology chip clicks
document.querySelectorAll('#modalOntChips .ont-chip').forEach(function(chip) {
    chip.addEventListener('click', function() {
        document.querySelectorAll('#modalOntChips .ont-chip').forEach(function(c) {
            c.classList.remove('active');
        });
        this.classList.add('active');
        modalCurrentOnt = this.getAttribute('data-ont');
        document.getElementById('modal_ont_term').value = '';
        document.getElementById('modal_ont_acc_id').value = '';
        setupModalAutocomplete();
    });
});

function getObjectTypeLabel() {
    var oKeyEl = document.getElementById('oKey');
    var oKeyTmpEl = document.getElementById('oKey_tmp');
    var oKeyVal = parseInt((oKeyEl && oKeyEl.value) || (oKeyTmpEl && oKeyTmpEl.value) || '1');
    if (oKeyVal === 5) return 'strains';
    if (oKeyVal === 6) return 'QTLs';
    return 'genes';
}

function updateObjectTypeLabels() {
    var label = getObjectTypeLabel();
    var spans = document.querySelectorAll('.obj-type-label');
    spans.forEach(function(s) { s.textContent = label; });
}

function filterOntologyChips() {
    var mapKeyEl = document.getElementById('mapKey');
    var setupMapKeyEl = document.getElementById('setup_mapKey');
    var mapKey = (mapKeyEl && mapKeyEl.value) || (setupMapKeyEl && setupMapKeyEl.value) || '380';
    var speciesKey = mapKeyToSpecies[mapKey] || 0;
    var oKeyEl = document.getElementById('oKey');
    var oKeyTmpEl = document.getElementById('oKey_tmp');
    var oKeyVal = parseInt((oKeyEl && oKeyEl.value) || (oKeyTmpEl && oKeyTmpEl.value) || '1');

    // Build a key: speciesTypeKey + '_' + oKey
    // oKey: 1=Gene, 5=Strain, 6=QTL
    var allowed = {};

    // Rat (3)
    if (speciesKey === 3) {
        if (oKeyVal === 1) { // Rat Genes
            allowed = {rdo:1, mp:1, pw:1, bp:1, mf:1, cc:1, chebi:1, vt:1};
        } else if (oKeyVal === 5) { // Rat Strains
            allowed = {rdo:1, mp:1, vt:1, bp:1, rs:1};
        } else if (oKeyVal === 6) { // Rat QTLs
            allowed = {rdo:1, mp:1, vt:1, rs:1, cmo:1, mmo:1, xco:1};
        }
    }
    // Human (1)
    else if (speciesKey === 1) {
        if (oKeyVal === 1) { // Human Genes
            allowed = {rdo:1, pw:1, bp:1, mf:1, cc:1, chebi:1, vt:1, hp:1, mmo:1};
        } else if (oKeyVal === 6) { // Human QTLs
            allowed = {rdo:1, hp:1, vt:1, efo:1, cmo:1};
        }
    }
    // Mouse (2)
    else if (speciesKey === 2) {
        if (oKeyVal === 1) { // Mouse Genes
            allowed = {mp:1, rdo:1, pw:1, bp:1, mf:1, cc:1, chebi:1, vt:1};
        } else if (oKeyVal === 6) { // Mouse QTLs
            allowed = {mp:1};
        }
    }
    // Chinchilla (4), Dog (5), Squirrel (7), Green Monkey (13)
    else if (speciesKey === 4 || speciesKey === 5 || speciesKey === 7 || speciesKey === 13) {
        allowed = {rdo:1, pw:1, bp:1, mf:1, cc:1, vt:1};
    }
    // Bonobo (6), Pig (9), Naked Mole-Rat (14)
    else if (speciesKey === 6 || speciesKey === 9 || speciesKey === 14) {
        allowed = {rdo:1, mp:1, pw:1, bp:1, mf:1, cc:1, chebi:1, vt:1};
    }
    // Default fallback: show all
    else {
        allowed = {rdo:1, mp:1, pw:1, bp:1, mf:1, cc:1, chebi:1, vt:1, hp:1, rs:1, cmo:1, mmo:1, xco:1, efo:1};
    }

    var chips = document.querySelectorAll('#modalOntChips .ont-chip');
    var activeHidden = false;
    var firstVisible = null;

    chips.forEach(function(chip) {
        var ont = chip.getAttribute('data-ont');
        if (allowed[ont]) {
            chip.style.display = '';
            if (!firstVisible) firstVisible = chip;
        } else {
            chip.style.display = 'none';
            if (chip.classList.contains('active')) {
                activeHidden = true;
                chip.classList.remove('active');
            }
        }
    });

    // If the active chip was hidden, activate the first visible one
    if (activeHidden && firstVisible) {
        firstVisible.classList.add('active');
        modalCurrentOnt = firstVisible.getAttribute('data-ont');
        setupModalAutocomplete();
    }
}

function browseModalOntology() {
    var ontId = modalCurrentOnt.toUpperCase();
    var url = '/rgdweb/ontology/view.html?mode=popup&ont=' + ontId +
              '&sel_term=modal_ont_term&sel_acc_id=modal_ont_acc_id';
    window.open(url, 'ontBrowser', 'width=900,height=500,resizable=1,scrollbars=1');
}
</script>

<%

try {
    Integer mapKey = (Integer) request.getAttribute("mapKey");
    if (mapKey == null) mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
    Integer oKey= (Integer) request.getAttribute("oKey");
    if (oKey == null) oKey = 1;
    Integer speciesTypeKey = SpeciesType.getSpeciesTypeKeyForMap(mapKey);


    String objectType = "Gene";

    if (oKey==5) {
        objectType="Strain";
    }

    if (oKey==6) {
        objectType="QTL";
    }

    ArrayList<String> accIds = (ArrayList<String>) request.getAttribute("accIds");
    List omLog = (List) request.getAttribute("omLog");
    ArrayList<String> operators = (ArrayList<String>) request.getAttribute("operators");
    ArrayList<ArrayList<String>> objectSymbols = (ArrayList<ArrayList<String>>) request.getAttribute("objectSymbols");
    LinkedHashMap<String,Object> resultSet = (LinkedHashMap<String,Object>) request.getAttribute("resultSet");
    HashMap exclude = (HashMap) request.getAttribute("exclude");
    HashMap messages = (HashMap) request.getAttribute("messages");


    String url = "";
    String a="";
    String vv="";
    String ga="";

    if (request.getParameter("a") != null) {
        url = "?a=" + request.getParameter("a") + "&mapKey" + request.getParameter("mapKey") + "&oKey=" + request.getParameter("oKey");
        a = request.getParameter("a");
    }
    if (request.getParameter("vv") != null) {
        vv = request.getParameter("vv");
    }
    if (request.getParameter("ga") != null) {
        ga = request.getParameter("ga");
    }

%>


 <script>

     (function ($) {



$(document).ready(function(){

    <% String ontId = "rdo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "chebi"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "mp"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "pw"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "mf"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "bp"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "rs"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "hp"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "cmo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "mmo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "xco"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "efo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "cc"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "vt"; %>
    <%@ include file="ontPopupConfig.jsp" %>

});

     }(jq14));



 </script>



<script>
    var accIdTmp = new Array();

    if ("<%=StringEscapeUtils.escapeEcmaScript(a)%>" != "") {
        accIdTmp = "<%=StringEscapeUtils.escapeEcmaScript(a)%>".split("|");
    }

    if ("<%=StringEscapeUtils.escapeEcmaScript(vv)%>" != "") {
        alert("Welcome to the List Generator.  Upon completion, you will have the option to submit back to Variant Visualizer with your custom list")
    }

    if ("<%=StringEscapeUtils.escapeEcmaScript(ga)%>" != "") {
        alert("Welcome to the List Generator.  Upon completion, you will have the option to submit back to the GA Tool with your custom list")
    }

    var aOperators = new Array();
    var aAccIds = new Array();
    var aSubGenes = new Array();
    var screens = new Array();
    var currentResultSet = []; // Store current result set genes for preview calculations

    for (var i = 0; i< accIdTmp.length; i++) {

        var accIdBlock = accIdTmp[i];
        aOperators[i] = accIdBlock.substring(0,1);

        //get the minus genes
        var minGenes = accIdBlock.split("*");

        for (var j=0;j< minGenes.length; j++) {
            //alert(minGenes[j]);
        }

        aAccIds[i] = minGenes[0].substring(1);
        aSubGenes[i] = minGenes;
    }

</script>

<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Lato">

<!-- Setup Screen - shown when no criteria exist -->
<% if (accIds.size() == 0) { %>
<style>
.setup-container {
    max-width: 800px;
    margin: 30px auto;
    padding: 30px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}
.setup-header {
    text-align: center;
    margin-bottom: 30px;
}
.setup-header h1 {
    color: #24609c;
    font-size: 32px;
    margin-bottom: 10px;
}
.setup-header p {
    color: #666;
    font-size: 16px;
}
.setup-section {
    margin-bottom: 30px;
}
.setup-section label {
    display: block;
    font-weight: 600;
    color: #333;
    margin-bottom: 12px;
    font-size: 16px;
}
.setup-cards {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    justify-content: center;
}
.setup-card {
    background: #f8f9fa;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    padding: 25px 30px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s ease;
    min-width: 140px;
}
.setup-card:hover {
    border-color: #24609c;
    background: #f0f7ff;
    transform: translateY(-2px);
}
.setup-card.selected {
    border-color: #24609c;
    background: #e8f1fb;
}
.setup-card i {
    font-size: 36px;
    color: #24609c;
    margin-bottom: 10px;
    display: block;
}
.setup-card h4 {
    margin: 0;
    color: #333;
    font-size: 16px;
}
.setup-select {
    width: 100%;
    max-width: 400px;
    padding: 12px 15px;
    font-size: 15px;
    border: 2px solid #ccc;
    border-radius: 8px;
}
.setup-select:focus {
    border-color: #24609c;
    outline: none;
}
.setup-btn {
    display: block;
    width: 200px;
    margin: 30px auto 0;
    padding: 15px 30px;
    background: #24609c;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 18px;
    font-weight: 600;
    cursor: pointer;
}
.setup-btn:hover {
    background: #1a4a7a;
}
</style>

<div class="setup-container">
    <div class="setup-header">
        <h1><i class="fas fa-list-check"></i> OLGA</h1>
        <p>Object List Generator & Analyzer - Build customized lists of genes, QTLs, or strains</p>
    </div>

    <div class="setup-section">
        <label>Select Assembly Version</label>
        <select id="setup_mapKey" class="setup-select" onchange="updateObjectTypeOptions()">
            <option value="380" <% if (mapKey==380) out.print("selected");%>>Rat - GRCr8</option>
            <option value="372" <% if (mapKey==372) out.print("selected");%>>Rat - mRatBN7.2</option>
            <option value="360" <% if (mapKey==360) out.print("selected");%>>Rat - Rnor_6.0</option>
            <option value="70" <% if (mapKey==70) out.print("selected");%>>Rat - Rnor_5.0</option>
            <option value="60" <% if (mapKey==60) out.print("selected");%>>Rat - RGSC_v3.4</option>
            <option value="38" <% if (mapKey==38) out.print("selected");%>>Human - GRCh38</option>
            <option value="17" <% if (mapKey==17) out.print("selected");%>>Human - GRCh37</option>
            <option value="239" <% if (mapKey==239) out.print("selected");%>>Mouse - GRCm39</option>
            <option value="35" <% if (mapKey==35) out.print("selected");%>>Mouse - GRCm38</option>
            <option value="18" <% if (mapKey==18) out.print("selected");%>>Mouse - Build 37</option>
            <option value="44" <% if (mapKey==44) out.print("selected");%>>Chinchilla - ChiLan1.0</option>
            <option value="511" <% if (mapKey==511) out.print("selected");%>>Bonobo - panpan1.1</option>
            <option value="513" <% if (mapKey==513) out.print("selected");%>>Bonobo - Mhudiblu_PPA_v0</option>
            <option value="634" <% if (mapKey==634) out.print("selected");%>>Dog - ROS_Cfam_1.0</option>
            <option value="631" <% if (mapKey==631) out.print("selected");%>>Dog - CanFam3.1</option>
            <option value="720" <% if (mapKey==720) out.print("selected");%>>Squirrel - SpeTri2.0</option>
            <option value="910" <% if (mapKey==910) out.print("selected");%>>Pig - Sscrofa10.2</option>
            <option value="911" <% if (mapKey==911) out.print("selected");%>>Pig - Sscrofa11.1</option>
            <option value="1311" <% if (mapKey==1311) out.print("selected");%>>Green Monkey - Vero_WHO_p1.0</option>
            <option value="1313" <% if (mapKey==1313) out.print("selected");%>>Green Monkey - ChlSab1.1</option>
            <option value="1410" <% if (mapKey==1410) out.print("selected");%>>Naked Mole-Rat - HetGla_1.0</option>
        </select>
    </div>

    <div class="setup-section">
        <label>What type of list do you want to build?</label>
        <div class="setup-cards" id="objectTypeCards">
            <div class="setup-card" data-okey="1" id="card-genes" onclick="selectObjectType(this)">
                <i class="fas fa-dna"></i>
                <h4>Genes</h4>
            </div>
            <div class="setup-card" data-okey="6" id="card-qtls" onclick="selectObjectType(this)">
                <i class="fas fa-location-crosshairs"></i>
                <h4>QTLs</h4>
            </div>
            <div class="setup-card" data-okey="5" id="card-strains" onclick="selectObjectType(this)">
                <i class="fas fa-paw"></i>
                <h4>Strains</h4>
            </div>
        </div>
    </div>


</div>

<script>
var selectedOKey = 0;

// QTLs available for: Rat (3), Human (1), Mouse (2)
// Strains available for: Rat (3) only
function updateObjectTypeOptions() {
    var mapKey = document.getElementById('setup_mapKey').value;
    var speciesTypeKey = mapKeyToSpecies[mapKey] || 0;

    var qtlCard = document.getElementById('card-qtls');
    var strainCard = document.getElementById('card-strains');

    // QTLs: only for Rat (3), Human (1), and Mouse (2)
    if (speciesTypeKey === 3 || speciesTypeKey === 1 || speciesTypeKey === 2) {
        qtlCard.style.display = '';
        qtlCard.classList.remove('disabled');
    } else {
        qtlCard.style.display = 'none';
        qtlCard.classList.add('disabled');
        // If QTL was selected, deselect it
        if (selectedOKey === 6) {
            document.getElementById('card-qtls').classList.remove('selected');
            selectedOKey = 0;
        }
    }

    // Strains: only for Rat (3)
    if (speciesTypeKey === 3) {
        strainCard.style.display = '';
        strainCard.classList.remove('disabled');
    } else {
        strainCard.style.display = 'none';
        strainCard.classList.add('disabled');
        // If Strain was selected, deselect it
        if (selectedOKey === 5) {
            document.getElementById('card-strains').classList.remove('selected');
            selectedOKey = 0;
        }
    }
}

function selectObjectType(card) {
    if (card.classList.contains('disabled')) return;
    document.querySelectorAll('.setup-card').forEach(function(c) {
        c.classList.remove('selected');
    });
    card.classList.add('selected');
    selectedOKey = parseInt(card.getAttribute('data-okey'));
    startBuildingList();
}

function startBuildingList() {
    var mapKey = document.getElementById('setup_mapKey').value;
    // Open the add criteria modal with the selected settings
    document.getElementById('oKey').value = selectedOKey;
    document.getElementById('mapKey').value = mapKey;
    // Update dropdowns for compatibility
    if (document.getElementById('oKey_tmp')) {
        document.getElementById('oKey_tmp').value = selectedOKey;
    }
    if (document.getElementById('mapKey_tmp')) {
        document.getElementById('mapKey_tmp').value = mapKey;
    }
    openAddModal();
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    updateObjectTypeOptions();
});
</script>

<% } else { %>
<!-- Action bar when criteria exist -->
<style>
.action-bar {
    max-width: 900px;
    margin: 20px auto;
    padding: 20px;
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 20px;
    flex-wrap: wrap;
}
.action-btn {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 15px 30px;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    transition: all 0.2s ease;
}
.action-btn-primary {
    background: #28a745;
    color: white;
}
.action-btn-primary:hover {
    background: #218838;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(40,167,69,0.3);
}
.action-btn-secondary {
    background: #24609c;
    color: white;
}
.action-btn-secondary:hover {
    background: #1a4a7a;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(36,96,156,0.3);
}
.action-btn-outline {
    background: white;
    color: #666;
    border: 2px solid #ddd;
}
.action-btn-outline:hover {
    border-color: #999;
    background: #f8f9fa;
}
.olga-header {
    text-align: center;
    padding: 20px 0 10px;
}
.olga-header h1 {
    color: #24609c;
    font-size: 28px;
    margin: 0 0 5px;
}
.olga-header p {
    color: #666;
    font-size: 14px;
    margin: 0;
}
</style>

<div class="olga-header">
    <h1><i class="fas fa-list-check"></i> OLGA</h1>
    <p>Object List Generator & Analyzer - Build customized lists of genes, QTLs, or strains</p>
</div>

<div class="action-bar">
    <button class="action-btn action-btn-primary" onclick="openAddModal()">
        <i class="fas fa-plus-circle"></i> Add Another <%=objectType%> List
    </button>
    <button class="action-btn action-btn-secondary" ng-click="rgd.showTools('resultList',<%=speciesTypeKey%>,<%=mapKey%>,'<%=oKey%>','<%=StringEscapeUtils.escapeEcmaScript(a)%>')">
        <i class="fas fa-chart-bar"></i> Analyze Result Set
    </button>
    <a href="/rgdweb/generator/list.html" class="action-btn action-btn-outline">
        <i class="fas fa-redo"></i> Start Over
    </a>
</div>
<% } %>

<!-- Hidden dropdowns for form compatibility -->
<div style="display:none;">
    <select id="oKey_tmp" name="oKey_tmp">
        <option value='1' <% if (oKey==1) out.print("selected");%>>Gene</option>
        <option value='6' <% if (oKey==6) out.print("selected");%>>QTL</option>
        <option value='5' <% if (oKey==5) out.print("selected");%>>Strain</option>
    </select>
    <select id="mapKey_tmp" name="mapKey_tmp">
        <option value='380' <% if (mapKey==380) out.print("selected");%>>GRCr8</option>
        <option value='372' <% if (mapKey==372) out.print("selected");%>>v7.2</option>
        <option value='360' <% if (mapKey==360) out.print("selected");%>>v6.0</option>
        <option value='70' <% if (mapKey==70) out.print("selected");%>>v5.0</option>
        <option value='60' <% if (mapKey==60) out.print("selected");%>>v3.4</option>
        <option value='38' <% if (mapKey==38) out.print("selected");%>>GRCh38</option>
        <option value='17' <% if (mapKey==17) out.print("selected");%>>GRCh37</option>
        <option value='13' <% if (mapKey==13) out.print("selected");%>>NCBI36</option>
        <option value='239' <% if (mapKey==239) out.print("selected");%>>GRCm39</option>
        <option value='35' <% if (mapKey==35) out.print("selected");%>>GRCm38</option>
        <option value='18' <% if (mapKey==18) out.print("selected");%>>NCBI37</option>
        <option value='44' <% if (mapKey==44) out.print("selected");%>>ChiLan1.0</option>
        <option value='634' <% if (mapKey==634) out.print("selected");%>>ROS_Cfam_1.0</option>
        <option value='631' <% if (mapKey==631) out.print("selected");%>>CanFam3.1</option>
        <option value='511' <% if (mapKey==511) out.print("selected");%>>panpan1.1</option>
        <option value='513' <% if (mapKey==513) out.print("selected");%>>Mhudiblu_PPA_v0</option>
        <option value='720' <% if (mapKey==720) out.print("selected");%>>SpeTri2.0</option>
        <option value='911' <% if (mapKey==911) out.print("selected");%>>Sscrofa11.1</option>
        <option value='910' <% if (mapKey==910) out.print("selected");%>>Sscrofa10.2</option>
        <option value='1311' <% if (mapKey==1311) out.print("selected");%>>Vero_WHO_p1.0</option>
        <option value='1313' <% if (mapKey==1313) out.print("selected");%>>ChlSab1.1</option>
        <option value='1410' <% if (mapKey==1410) out.print("selected");%>>HetGla_1.0</option>
        <option value='1701' <% if (mapKey==1701) out.print("selected");%>>Rrattus_CSIRO_v1</option>
    </select>
</div>

<% if (accIds.size() > 0) { %>
<!-- Hidden chromosome dropdown for modal to copy from -->
<div style="display:none;">
    <select name="chr" id="chr">
        <%
            List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(mapKey);
            for (Chromosome ch: chromosomes) {
        %>
        <option value="<%=ch.getChromosome()%>" data-size="<%=ch.getSeqLength()%>"><%=ch.getChromosome()%></option>
        <%  } %>
    </select>
</div>


<%
    String[] colors = new String[8];

    colors[0] = "blue";
    colors[1] = "red";
    colors[2] = "green";
    colors[3] = "orange";
    colors[4] = "purple";
    colors[5] = "black";
    colors[6] = "gray";
    colors[7] = "yellow";

%>


<% if (accIds.size() > 0 ) { %>

<% if (omLog.size() > 0) { %>
<table align="center" style="margin-top: 15px; border: solid;border-color: black;border-width: thin;">
    <tr>
        <td align="left" >
            <div id="warningBox" class=info style="overflow: auto;height: 60px;margin: 3px;">
                <%
                    Iterator logIt = omLog.iterator();
                    String msg = "";
                    while (logIt.hasNext()) {
                        msg = logIt.next().toString();
//                        System.out.println(msg);
                        out.print(StringEscapeUtils.escapeHtml4(msg) + "<br>");
                    }
                %>
            </div>

        </td>
    </tr>

</table>
<hr>
<% } %>
<table width=100% border=0>
    <tr>
        <td>
            <div style="font-size:22;color:#1A456F;margin-top:10px;">WorkBench</div>
        </td>

    </tr>
</table>

<!--
<div style="width:100%; margin:0 auto; background-color:white; margin-bottom:10px;">
    <div style="float:left;margin-right:10px; margin-left:5px;font-weight:700;">{{ listName }}</div><div>{{ listDescription }}</div>
</div>
-->


<table border="0" style="margin-top:5px; margin-bottom:20px;">
    <tr>
        <td>

<%
    for (int i=0; i < accIds.size(); i++ ) {
        String accId = accIds.get(i);

        String identifier = null;

        if (accId.toLowerCase().startsWith("chr")) {
            identifier=accId;
        }else if (accId.toLowerCase().startsWith("lst")) {
            identifier = "User List";
        }else if (accId.toLowerCase().startsWith("ids")) {
            identifier = "RGD ID List";
        } else if (accId.toLowerCase().startsWith("qtl")) {
            identifier = accId.substring(4);
        } else {
            OntologyXDAO odao = new OntologyXDAO();
            Term t = odao.getTermByAccId(accId);
            if (t != null) identifier = t.getTerm();
            else identifier = accId;
        }

%>

    <% if (i !=0) { %>
        <b><%  if (operators.get(i).equals("~")) out.print("&nbsp;UNION&nbsp;"); %></b>
        <b><%  if (operators.get(i).equals("!")) out.print("&nbsp;INTERSECT&nbsp;"); %></b>
        <b><%  if (operators.get(i).equals("^")) out.print("&nbsp;SUBTRACT&nbsp;"); %></b>

    <% }else { %>
        <% for (int j=1; j< accIds.size(); j++) { %>
            <span style="font-weight:700; font-size:16px;">(</span>
        <% } %>

    <% } %>

    <span style="padding:3px; border-top:1px solid <%=colors[i % colors.length]%>; border-bottom: 1px solid <%=colors[i % colors.length]%>"><%=StringEscapeUtils.escapeHtml4(identifier)%></span>

    <% if (i !=0) { %>
        <b>)</b>
    <% } %>

<%
    }
%>
        </td>
    </tr>
</table>




<table border=0 cellpadding=0 cellspacing=0>
    <tr>

    <%
        for (int i=0; i < accIds.size(); i++ ) {
       %>
        <td>
            <%
            String accId = accIds.get(i);

            String op = "Union";
            if (operators.get(i).equals("^")) {
                op = "Subtract";
            }
            if (operators.get(i).equals("!")) {
                op = "Intersect";
            }

     %>
<% if (i > 0) { %>
    <td valign="top">
    <div style="float:left;">
        <br><br>
         <select id="op-<%=i%>" style="border:1px solid black;" onchange="updateOperation(this)">
            <option value="~" <%  if (operators.get(i).equals("~")) out.print("selected"); %>>Union</option>
            <option value="^" <%  if (operators.get(i).equals("^")) out.print("selected"); %>>Subtract</option>
            <option value="!" <%  if (operators.get(i).equals("!")) out.print("selected"); %>>Intersect</option>
        </select>
    </div>
</td>
<% } %>

<td valign="top">

<div style="padding-left:0px; border-top:1px solid <%=colors[i % colors.length]%>; border-right:1px solid <%=colors[i % colors.length]%>;  border-left:1px solid <%=colors[i % colors.length]%>; text-align:center;"><%=objectSymbols.get(i).size()%></div>
<div style="border-right:1px solid <%=colors[i % colors.length]%>; border-top:5px solid <%=colors[i % colors.length]%>; padding:5px; margin: 5px; display: inline-block;">
<div style="float:right; text-align:right;"><a href="javascript:removeTerm(<%=i%>)"><img src="/rgdweb/common/images/del.jpg" border=0 /></a> </div>

<%
    if (messages.containsKey(accIds.get(i))) {
    %>
        <div style="padding-top:5px;padding-bottom:5px;font-weight:700; color:red;">Empty</div><div><%=StringEscapeUtils.escapeHtml4((String)messages.get(accIds.get(i)))%></div>
    <%
    }else if (objectSymbols.get(i).size()==0) { %>
         <div style="text-decoration:underline; padding-top:5px;padding-bottom:5px;font-weight:700; color:red;">Empty</div>
<%
}

for (String gene: objectSymbols.get(i)) {
    if (!exclude.containsKey(gene)) {
%>
        <table cellpadding=0 cellspacing=0><tr><td><a href="javascript:removeGene('<%=StringEscapeUtils.escapeEcmaScript(accId)%>','<%=StringEscapeUtils.escapeEcmaScript(gene)%>')"><img height=10 width=10 src="/rgdweb/common/images/del.jpg" border=0 /></a>&nbsp;&nbsp;&nbsp;<% if (oKey != null && oKey == 5) { %><%=gene%><% } else { %><%=StringEscapeUtils.escapeHtml4(gene)%><% } %></td></tr></table>
<%
    }
}
%>
</div>
</td>

<%
    }

%>

<td style="width:15px;">&nbsp;&nbsp;</td>
<td valign="top" style="background-color:#3F3F3F; width:10px;">
      &nbsp;&nbsp;
</td>
 <td valign="top">
   <table cellpadding=0 cellspacing=0>
   <tr>
       <td><div style="font-weight:700; font-size:20px; background-color:#3F3F3F; color:white; padding-right:5px;">Result&nbsp;Set&nbsp;(<%=resultSet.keySet().size()%>)</div></td>
   </tr>
   <tr>
       <td>

           <div id="resultSet" style="border:0px solid black; float:left; padding:7px; margin-left:5px;">
               <%
                   if (resultSet.keySet().size() == 0) {
               %>
               Empty&nbsp;Set
               <%
                   }
                   Iterator it = resultSet.keySet().iterator();
                   while(it.hasNext()) {
                       String gene = (String)it.next();
               %>
               <span class="resultList"><% if (oKey != null && oKey == 5) { %><%=gene.trim()%><% } else { %><%=StringEscapeUtils.escapeHtml4(gene.trim())%><% } %></span><br>
               <%
                   }
               %>

           </div>
</td>


</tr>
</table>

       </td>
</tr>
</table>



<script>
// Populate currentResultSet with genes from result set for preview calculations
<%
    Iterator rsIt = resultSet.keySet().iterator();
    while(rsIt.hasNext()) {
        String gene = (String)rsIt.next();
%>
currentResultSet.push('<%=StringEscapeUtils.escapeEcmaScript(gene.trim())%>');
<%
    }
%>

<%
//if (accIds.size()==1 && messages.containsKey(accIds.get(0))) {
if (accIds.size()==1 && objectSymbols.get(0).size() == 0) {

    String mess = "";
    if (messages.get(accIds.get(0)) != null) {
        mess = (String)messages.get(accIds.get(0));
        mess = mess.replaceAll("<br>","\\\\n");
    }else {
        mess = "0 objects are annotated to this term or region.\\n\\nPlease select again.";
    }


%>
    alert("<%=StringEscapeUtils.escapeEcmaScript(mess)%>");
    aAccIds.length=0;
    aOperators.length=0;
    reloadPage();

<%
    }

%>

</script>

<% } %>
<% } %>

<%
} catch (Exception e) {
    e.printStackTrace();
}%>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>
</body>
</html>