<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>

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
<script type="text/javascript"  src="/rgdweb/generator/generator.js"></script>


<form name="submitForm" id="submitForm" action="list.html" method="post" target="_blank">
    <input type="hidden" name="a" id="a" value="" />
    <input type="hidden" name="mapKey" id="mapKey" value="" />
    <input type="hidden" name="oKey" id="oKey" value="" />
    <input type="hidden" name="vv" id="vv" value="" />
    <input type="hidden" name="ga" id="ga" value="" />
    <input type="hidden" name="act" id="act" value="" />

    <%
        int count = 1;
        String val = "";
        while ((val = request.getParameter("sample" + count)) != null) {
    %>
            <input type="hidden" name="sample<%=count%>" value="<%=val%>"/>

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
                    <div class="modal-type-card" onclick="goToScreen2('symbols')">
                        <i class="fas fa-list"></i>
                        <h5>Symbol List</h5>
                        <p>Enter a list of gene symbols</p>
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
                            <input type="text" id="modal_start" placeholder="e.g., 1000000" />
                        </div>
                        <div class="add-modal-form-group" style="flex:1;">
                            <label>Stop Position</label>
                            <input type="text" id="modal_stop" placeholder="e.g., 5000000" />
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
            </div>

            <!-- SCREEN 3: Combine Operation -->
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
                            <p>Include genes from <strong>either</strong> list</p>
                        </div>
                    </div>
                    <div class="modal-operation-card intersect" onclick="selectOperationAndSubmit('!')">
                        <i class="fas fa-compress-alt"></i>
                        <div>
                            <h5>Intersect (AND) <span id="previewIntersect" class="preview-count"></span></h5>
                            <p>Only genes in <strong>both</strong> lists</p>
                        </div>
                    </div>
                    <div class="modal-operation-card subtract" onclick="selectOperationAndSubmit('^')">
                        <i class="fas fa-minus-circle"></i>
                        <div>
                            <h5>Subtract (NOT) <span id="previewSubtract" class="preview-count"></span></h5>
                            <p><strong>Remove</strong> genes from new criteria</p>
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
    showScreen(1);
    updateModalButtons();
    // Populate chromosome dropdown
    var chrSelect = document.getElementById('modal_chr');
    if (chrSelect.options.length === 0) {
        var existingChr = document.getElementById('chr');
        if (existingChr) {
            chrSelect.innerHTML = existingChr.innerHTML;
        }
    }
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
}

function showScreen(num) {
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

    showScreen(2);

    if (type === 'ont') {
        setupModalAutocomplete();
    }
}

function goBackScreen() {
    if (modalCurrentScreen === 2) {
        showScreen(1);
    } else if (modalCurrentScreen === 3) {
        showScreen(2);
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
            showScreen(3);
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
            document.getElementById('previewUnion').textContent = genesAdded.length + ' genes would be added';
            document.getElementById('previewIntersect').textContent = genesIntersect.length + ' genes intersect';
            document.getElementById('previewSubtract').textContent = genesRemoved.length + ' genes would be removed';

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
            // Hide loading even on error
            document.getElementById('previewLoading').style.display = 'none';
            document.getElementById('operationCards').style.opacity = '1';
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
    } else if (modalSelectedType === 'region') {
        var chr = document.getElementById('modal_chr').value;
        var start = document.getElementById('modal_start').value.trim();
        var stop = document.getElementById('modal_stop').value.trim();
        if (chr && start && stop) {
            accId = 'chr' + chr + ':' + start + '..' + stop;
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
        if (modalCurrentOnt === 'rdo') ontPrefix = 'DOID,RDO';
        if (modalCurrentOnt === 'bp' || modalCurrentOnt === 'mf' || modalCurrentOnt === 'cc') ontPrefix = 'GO';

        jq14('#modal_ont_term').autocomplete({
            serviceUrl: '/rgdweb/OntoSolr/searchAutoComplete.html',
            params: {ontFilter: ontPrefix},
            minChars: 2,
            maxHeight: 300,
            width: 400,
            deferRequestBy: 100,
            onSelect: function(value, data) {
                jq14('#modal_ont_acc_id').val(data);
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
    Integer oKey= (Integer) request.getAttribute("oKey");
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
    <% ontId = "cc"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "vt"; %>
    <%@ include file="ontPopupConfig.jsp" %>

});

     }(jq14));



 </script>



<script>
    var accIdTmp = new Array();

    if ("<%=a%>" != "") {
        accIdTmp = "<%=a%>".split("|");
    }

    if ("<%=vv%>" != "") {
        alert("Welcome to the List Generator.  Upon completion, you will have the option to submit back to Variant Visualizer with your custom list")
    }

    if ("<%=ga%>" != "") {
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

<link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Lato">

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
            <optgroup label="Rat">
                <option value="380" selected>Rat - GRCr8</option>
                <option value="372">Rat - Rnor_6.0 (v7.2)</option>
                <option value="360">Rat - RGSC_v3.4 (v6.0)</option>
            </optgroup>
            <optgroup label="Human">
                <option value="38">Human - GRCh38</option>
                <option value="17">Human - GRCh37</option>
            </optgroup>
            <optgroup label="Mouse">
                <option value="239">Mouse - GRCm39</option>
                <option value="35">Mouse - GRCm38</option>
            </optgroup>
            <optgroup label="Other Species">
                <option value="44">Chinchilla - ChiLan1.0</option>
                <option value="634">Dog - ROS_Cfam_1.0</option>
                <option value="631">Dog - CanFam3.1</option>
                <option value="911">Pig - Sscrofa11.1</option>
            </optgroup>
        </select>
    </div>

    <div class="setup-section">
        <label>What type of list do you want to build?</label>
        <div class="setup-cards" id="objectTypeCards">
            <div class="setup-card selected" data-okey="1" id="card-genes" onclick="selectObjectType(this)">
                <i class="fas fa-dna"></i>
                <h4>Genes</h4>
            </div>
            <div class="setup-card" data-okey="6" id="card-qtls" onclick="selectObjectType(this)">
                <i class="fas fa-map-marker-alt"></i>
                <h4>QTLs</h4>
            </div>
            <div class="setup-card" data-okey="5" id="card-strains" onclick="selectObjectType(this)">
                <i class="fas fa-flask"></i>
                <h4>Strains</h4>
            </div>
        </div>
    </div>

    <button class="setup-btn" onclick="startBuildingList()">
        Get Started <i class="fas fa-arrow-right"></i>
    </button>
</div>

<script>
var selectedOKey = 1;

// Map keys to species type keys
// Rat = 3, Human = 1, Mouse = 2, Chinchilla = 4, Dog = 5, Pig = 9
var mapKeyToSpecies = {
    '380': 3, '372': 3, '360': 3,  // Rat
    '38': 1, '17': 1,              // Human
    '239': 2, '35': 2,             // Mouse
    '44': 4,                        // Chinchilla
    '634': 5, '631': 5,            // Dog
    '911': 9                        // Pig
};

// QTLs available for: Rat (3), Human (1)
// Strains available for: Rat (3) only
function updateObjectTypeOptions() {
    var mapKey = document.getElementById('setup_mapKey').value;
    var speciesTypeKey = mapKeyToSpecies[mapKey] || 0;

    var qtlCard = document.getElementById('card-qtls');
    var strainCard = document.getElementById('card-strains');

    // QTLs: only for Rat (3) and Human (1)
    if (speciesTypeKey === 3 || speciesTypeKey === 1) {
        qtlCard.style.display = '';
        qtlCard.classList.remove('disabled');
    } else {
        qtlCard.style.display = 'none';
        qtlCard.classList.add('disabled');
        // If QTL was selected, switch to Genes
        if (selectedOKey === 6) {
            selectObjectType(document.getElementById('card-genes'));
        }
    }

    // Strains: only for Rat (3)
    if (speciesTypeKey === 3) {
        strainCard.style.display = '';
        strainCard.classList.remove('disabled');
    } else {
        strainCard.style.display = 'none';
        strainCard.classList.add('disabled');
        // If Strain was selected, switch to Genes
        if (selectedOKey === 5) {
            selectObjectType(document.getElementById('card-genes'));
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
    <button class="action-btn action-btn-secondary" ng-click="rgd.showTools('resultList',<%=speciesTypeKey%>,<%=mapKey%>,'<%=oKey%>','<%=a%>')">
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
        <option value='38' <% if (mapKey==38) out.print("selected");%>>GRCh38</option>
        <option value='17' <% if (mapKey==17) out.print("selected");%>>GRCh37</option>
        <option value='239' <% if (mapKey==239) out.print("selected");%>>GRCm39</option>
        <option value='35' <% if (mapKey==35) out.print("selected");%>>GRCm38</option>
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
        <option value="<%=ch.getChromosome()%>"><%=ch.getChromosome()%></option>
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
                        out.print(msg + "<br>");
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
            identifier = "User&nbsp;List";
        } else if (accId.toLowerCase().startsWith("qtl")) {
            identifier = accId.substring(4);
        } else {
            OntologyXDAO odao = new OntologyXDAO();
            Term t = odao.getTermByAccId(accId);
            identifier = t.getTerm();
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

    <span style="padding:3px; border-top:1px solid <%=colors[i]%>; border-bottom: 1px solid <%=colors[i]%>"><%=identifier%></span>

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

<div style="padding-left:0px; border-top:1px solid <%=colors[i]%>; border-right:1px solid <%=colors[i]%>;  border-left:1px solid <%=colors[i]%>; text-align:center;"><%=objectSymbols.get(i).size()%></div>
<div style="border-right:1px solid <%=colors[i]%>; border-top:5px solid <%=colors[i]%>; padding:5px; margin: 5px; display: inline-block;">
<div style="float:right; text-align:right;"><a href="javascript:removeTerm(<%=i%>)"><img src="/rgdweb/common/images/del.jpg" border=0 /></a> </div>

<%
    if (messages.containsKey(accIds.get(i))) {
    %>
        <div style="padding-top:5px;padding-bottom:5px;font-weight:700; color:red;">Empty</div><div><%=messages.get(accIds.get(i))%></div>
    <%
    }else if (objectSymbols.get(i).size()==0) { %>
         <div style="text-decoration:underline; padding-top:5px;padding-bottom:5px;font-weight:700; color:red;">Empty</div>
<%
}

for (String gene: objectSymbols.get(i)) {
    if (!exclude.containsKey(gene)) {
%>
        <table cellpadding=0 cellspacing=0><tr><td><a href="javascript:removeGene('<%=accId%>','<%=gene%>')"><img height=10 width=10 src="/rgdweb/common/images/del.jpg" border=0 /></a>&nbsp;&nbsp;&nbsp;<%=gene%></td></tr></table>
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
               <span class="resultList"><%=gene.trim()%></span><br>
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
currentResultSet.push('<%=gene.trim()%>');
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
    hideAll();
    showScreen("actionBox","Welcome!  To get started, select a list type from the options below" );
    alert("<%=mess%>");
    aAccIds.length=0;
    aOperators.length=0;
    reloadPage();

<%
    }

%>

</script>

<% }

} catch (Exception e) {
    e.printStackTrace();
}%>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>
</body>
</html>