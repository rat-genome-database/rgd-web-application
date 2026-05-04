<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=windows-1252" %>
<%
    String pageTitle = "Web Genome Viewer - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.";
    
%>
<%@ include file="../common/headerarea.jsp" %>


    <!-- JKL.ParseXML removed - using jQuery for data loading -->
    <script type="text/javascript" src="/rgdweb/gviewer/script/dhtmlwindow.js">
    /***********************************************
    * DHTML Window script- � Dynamic Drive (http://www.dynamicdrive.com)
    * This notice MUST stay intact for legal use
    * Visit http://www.dynamicdrive.com/ for this script and 100s more.
    ***********************************************/
    </script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/util.js"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/gviewer.js?v=5"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/gviewer-renderer.js?v=7"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/domain.js?v=5"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/contextMenu.js">
    /***********************************************
    * Context Menu script- � Dynamic Drive (http://www.dynamicdrive.com)
    * This notice MUST stay intact for legal use
    * Visit http://www.dynamicdrive.com/ for this script and 100s more.
    ***********************************************/
    </script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/event.js"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/ZoomPane.js"></script>
    <link rel="stylesheet" type="text/css" href="/rgdweb/gviewer/css/gviewer.css?v=3" />

<script src="/rgdweb/js/sorttable.js"></script>
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-migrate-3.5.0.min.js"></script>
<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>
<script type="text/javascript" src="/rgdweb/common/ontologyAutocomplete.js"></script>

<!--#F0F6FF    #E3EEFF -->

<style type="text/css">
.gviewer-search-panel {
    background: #E3EEFF;
    border-radius: 8px;
    padding: 20px 24px;
}
.gviewer-search-panel .form-control {
    font-size: 15px;
    padding: 8px 12px;
    height: auto;
    min-height: 40px;
}
.gviewer-search-panel .btn {
    font-size: 15px;
    padding: 8px 16px;
}
.gv-criteria-row {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
    flex-wrap: wrap;
}
.gv-criteria-row .gv-operator {
    flex: 0 0 110px;
}
.gv-criteria-row .gv-term {
    flex: 1 1 260px;
}
.gv-criteria-row .gv-ontology {
    flex: 0 0 220px;
}
.gv-criteria-row .gv-browse {
    flex: 0 0 auto;
}
.gv-criteria-row .gv-remove {
    flex: 0 0 auto;
}
.gv-top-bar {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 14px;
    flex-wrap: wrap;
}
.gv-top-bar label,
.gv-top-bar .gv-species {
    font-size: 15px;
}
.gv-top-bar .gv-species {
    flex: 0 0 auto;
}
.gv-top-bar .gv-actions {
    flex: 0 0 auto;
    display: flex;
    gap: 6px;
    margin-left: auto;
}
.gv-examples {
    font-size: 11px;
    color: #666;
    margin-top: 6px;
}
.gv-examples a {
    font-size: 11px;
}
.gviewer-wrapper {
    overflow-x: auto;
    width: 100%;
}
</style>





<%
    String tutorialLink="/wg/home/rgd_rat_community_videos/gviewer_tutorial/";
%>
<style>
.gviewer-header {
    text-align: center;
    padding: 20px 0 10px;
    position: relative;
}
.gviewer-header h1 {
    color: #24609c;
    font-size: 28px;
    margin: 0 0 5px;
}
.gviewer-header p {
    color: #666;
    font-size: 14px;
    margin: 0;
}
.gviewer-header .tutorial-link {
    position: absolute;
    right: 20px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 13px;
    color: #24609c;
    text-decoration: none;
}
.gviewer-header .tutorial-link:hover {
    text-decoration: underline;
}
.gviewer-header .tutorial-link i {
    margin-right: 4px;
}
</style>
<div class="gviewer-header">
    <h1><i class="fa fa-dna"></i> GViewer</h1>
    <p>Genome Visualization - View genes and QTLs annotated to ontology terms across the genome</p>
    <a class="tutorial-link" href="<%=tutorialLink%>" title="Play the RGD Video Tutorial"><i class="fa fa-play-circle"></i> Video Tutorial</a>
</div>

<div id="loading" aria-live="polite" aria-atomic="true"></div>
<div id="gvLoadingOverlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(255,255,255,0.8); z-index:99999; justify-content:center; align-items:center;">
    <div style="text-align:center;">
        <div class="spinner-border text-primary" role="status" style="width:3rem; height:3rem;"></div>
        <div style="margin-top:14px; font-size:16px; font-weight:600; color:#24609c;">Loading...</div>
    </div>
</div>
<div id="formAlert" class="alert alert-warning" role="alert" style="display:none;" aria-live="assertive"></div>

<form method="get" name="gviewerForm" action="javascript:runGviewer();void(0);" role="search" aria-label="Genome Viewer Search">

<div class="gviewer-search-panel">
    <div class="gv-top-bar">
        <div class="gv-species">
            <label for="assemblyVersion" style="font-weight:700;">Assembly:</label>
            <select id="assemblyVersion" class="form-control d-inline-block" style="width:auto;" aria-label="Select assembly version" onchange="document.getElementById('speciesType').value = this.selectedOptions[0].getAttribute('data-species');">
                <option value="380" data-species="3" selected>Rat - GRCr8</option>
                <option value="372" data-species="3">Rat - mRatBN7.2</option>
                <option value="360" data-species="3">Rat - Rnor_6.0</option>
                <option value="70"  data-species="3">Rat - Rnor_5.0</option>
                <option value="60"  data-species="3">Rat - RGSC_v3.4</option>
                <option value="38"  data-species="1">Human - GRCh38</option>
                <option value="17"  data-species="1">Human - GRCh37</option>
                <option value="239" data-species="2">Mouse - GRCm39</option>
                <option value="35"  data-species="2">Mouse - GRCm38</option>
                <option value="18"  data-species="2">Mouse - Build 37</option>
            </select>
            <input type="hidden" name="speciesType" id="speciesType" value="3"/>
        </div>
        <div class="gv-actions">
            <input type="submit" value="Run GViewer" class="btn btn-sm btn-primary"/>
            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="addCriteria()">+ Add Criteria</button>
        </div>
    </div>

    <div id="criteriaContainer">
        <div class="gv-criteria-row" id="criteria_0">
            <div class="gv-ontology">
                <select name="gv_ont" class="form-control form-control-sm" aria-label="Select ontology">
                    <option value="ALL" selected>All Ontologies</option>
                    <option value="CC,MF,BP">GO (Gene Ontology)</option>
                    <option value="RDO">Disease</option>
                    <option value="NBO">Behavioral</option>
                    <option value="MP">Phenotype</option>
                    <option value="PW">Pathway</option>
                    <option value="CMO">Clinical Measurement</option>
                    <option value="MMO">Measurement Method</option>
                    <option value="XCO">Experimental Condition</option>
                    <option value="RS">Strain</option>
                    <option value="VT">Trait</option>
                    <option value="CHEBI">ChEBI</option>
                </select>
            </div>
            <div class="gv-term">
                <input name="gv_term" class="ont-auto-complete form-control form-control-sm" value="" placeholder="Enter search term (e.g. hypertension)" aria-label="Search term"/>
                <input type="hidden" name="gv_acc_id" id="gv_acc_id_0" value=""/>
            </div>
            <div class="gv-browse">
                <button type="button" class="btn btn-sm btn-outline-primary" onclick="browseOntology(this)" title="Browse ontology tree"><i class="fa fa-sitemap"></i> Browse</button>
            </div>
        </div>
    </div>
</div>
</form>

<div id="content" style="width: 100%; visibility: hidden;" role="region" aria-label="Genome Visualization Results">
    <div class="gviewer-wrapper" style="margin-top:10px;">
        <div id="gviewer" class="gviewer" style="width:100%;" role="img" aria-label="Genome chromosome view with annotations"></div>
        <div id="zoomWrapper" class="zoom-pane" role="region" aria-label="Chromosome zoom pane"></div>
    </div>
    <div id="gviewerDiv" style="max-height:960px; overflow:auto;" role="region" aria-label="Annotation results table"></div>
</div>


<div>Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.</div>   


<script type="text/javascript">

var criteriaCount = 1;

// All ontology codes for "All Ontologies" option
var ALL_ONTS = "CC,MF,BP,RDO,NBO,MP,PW,CMO,MMO,XCO,RS,VT,CHEBI";

function addCriteria() {
    var container = document.getElementById("criteriaContainer");
    var id = "criteria_" + criteriaCount++;
    var html = '<div class="gv-criteria-row" id="' + id + '">';
    html += '<div class="gv-operator"><select name="gv_op" class="form-control form-control-sm" aria-label="Combine operation">';
    html += '<option value="OR" style="color:green;">OR (Union)</option>';
    html += '<option value="AND" style="color:blue;">AND (Intersect)</option>';
    html += '<option value="AND NOT" style="color:red;">NOT (Subtract)</option>';
    html += '</select></div>';
    html += '<div class="gv-ontology"><select name="gv_ont" class="form-control form-control-sm" aria-label="Select ontology">';
    html += '<option value="ALL" selected>All Ontologies</option>';
    html += '<option value="CC,MF,BP">GO (Gene Ontology)</option>';
    html += '<option value="RDO">Disease</option>';
    html += '<option value="NBO">Behavioral</option>';
    html += '<option value="MP">Phenotype</option>';
    html += '<option value="PW">Pathway</option>';
    html += '<option value="CMO">Clinical Measurement</option>';
    html += '<option value="MMO">Measurement Method</option>';
    html += '<option value="XCO">Experimental Condition</option>';
    html += '<option value="RS">Strain</option>';
    html += '<option value="VT">Trait</option>';
    html += '<option value="CHEBI">ChEBI</option>';
    html += '</select></div>';
    html += '<div class="gv-term"><input name="gv_term" class="ont-auto-complete form-control form-control-sm" value="" placeholder="Enter search term" aria-label="Search term"/>';
    html += '<input type="hidden" name="gv_acc_id" id="gv_acc_id_' + criteriaCount + '" value=""/></div>';
    html += '<div class="gv-browse"><button type="button" class="btn btn-sm btn-outline-primary" onclick="browseOntology(this)" title="Browse ontology tree"><i class="fa fa-sitemap"></i> Browse</button></div>';
    html += '<div class="gv-remove"><button type="button" class="btn btn-sm btn-outline-danger" onclick="removeCriteria(\'' + id + '\')" title="Remove criteria">&times;</button></div>';
    html += '</div>';
    container.insertAdjacentHTML('beforeend', html);
    setupAutoComplete();
}

function removeCriteria(id) {
    var el = document.getElementById(id);
    if (el) el.remove();
}

function showFormAlert(msg) {
    var el = document.getElementById("formAlert");
    el.innerHTML = msg;
    el.style.display = "block";
    setTimeout(function() { el.style.display = "none"; }, 5000);
}

function checkForm() {
    document.getElementById("formAlert").style.display = "none";
    var terms = document.querySelectorAll('input[name=gv_term]');
    var hasterm = false;
    for (var i = 0; i < terms.length; i++) {
        var val = terms[i].value.trim();
        if (val.length > 0 && val.replace(/\*/g, '').length < 3) {
            showFormAlert("Search terms must be at least 3 characters long.");
            return false;
        }
        if (val.length > 0) hasterm = true;
    }
    if (!hasterm) {
        showFormAlert("Please enter at least one search term.");
        return false;
    }
    return true;
}

// Builds the query string in the format the server expects (term[], op[], go[], do[], etc.)
function getFormString() {
    var rows = document.querySelectorAll('.gv-criteria-row');
    var parts = [];
    var speciesType = document.getElementById('speciesType').value;

    for (var i = 0; i < rows.length; i++) {
        var term = rows[i].querySelector('input[name=gv_term]').value.trim();
        var ontSel = rows[i].querySelector('select[name=gv_ont]').value;
        var opSel = rows[i].querySelector('select[name=gv_op]');

        // Add operator for rows after the first
        if (opSel) {
            parts.push(encodeURIComponent('op[]') + '=' + encodeURIComponent(opSel.value));
        }

        // Add term
        parts.push(encodeURIComponent('term[]') + '=' + encodeURIComponent(term));

        // Translate ontology dropdown to the checkbox params the server expects
        var onts = (ontSel === 'ALL') ? ALL_ONTS : ontSel;
        var allOntKeys = {
            'go[]': 'CC,MF,BP', 'do[]': 'RDO', 'bo[]': 'NBO', 'po[]': 'MP',
            'wo[]': 'PW', 'cmo[]': 'CMO', 'mmo[]': 'MMO', 'xco[]': 'XCO',
            'rs[]': 'RS', 'vt[]': 'VT', 'chebi[]': 'CHEBI'
        };
        for (var key in allOntKeys) {
            var val = allOntKeys[key];
            // Check if any of the codes in this key match the selected ontology
            var codes = val.split(',');
            var match = false;
            for (var c = 0; c < codes.length; c++) {
                if (onts.indexOf(codes[c]) !== -1) { match = true; break; }
            }
            parts.push(encodeURIComponent(key) + '=' + (match ? encodeURIComponent(val) : '-1'));
        }
    }

    parts.push(encodeURIComponent('speciesType') + '=' + encodeURIComponent(speciesType));
    var assemblySelect = document.getElementById('assemblyVersion');
    if (assemblySelect) {
        parts.push(encodeURIComponent('mapKey') + '=' + encodeURIComponent(assemblySelect.value));
    }
    return parts.join('&');
}

var gviewer = null;
var lastSpecies = null;
var lastMapKey = null;

// Map mapKey -> ideogram xml file. Keys without a specific file fall through to the species default.
var MAPKEY_TO_IDEO = {
    '17':  '/rgdweb/gviewer/data/17_ideo.xml',
    '38':  '/rgdweb/gviewer/data/38_ideo.xml',
    '18':  '/rgdweb/gviewer/data/18_ideo.xml',
    '35':  '/rgdweb/gviewer/data/35_ideo.xml',
    '60':  '/rgdweb/gviewer/data/60_ideo.xml',
    '70':  '/rgdweb/gviewer/data/70_ideo.xml',
    '360': '/rgdweb/gviewer/data/360_ideo.xml'
};

function getIdeoUrl(species, mapKey) {
    if (mapKey && MAPKEY_TO_IDEO[mapKey]) return MAPKEY_TO_IDEO[mapKey];
    if (species == "1") return "/rgdweb/gviewer/data/human_ideo.xml";
    if (species == "2") return "/rgdweb/gviewer/data/mouse_ideo.xml";
    return "/rgdweb/gviewer/data/rgd_rat_ideo.xml";
}

// mapKey -> JBrowse 2 assembly name (matches names in /jbrowse2/config.json)
var MAPKEY_TO_JBROWSE2 = {
    '380': 'GRCr8',         // Rat - GRCr8
    '372': 'mRatBN7.2',     // Rat - mRatBN7.2
    '360': 'Rnor_6.0',      // Rat - Rnor_6.0
    '70':  'Rnor_5.0',      // Rat - Rnor_5.0
    '60':  'RGSC_v3.4',     // Rat - RGSC_v3.4
    '38':  'GRCh38.p14',    // Human - GRCh38
    '17':  'GRCh37.p13',    // Human - GRCh37
    '239': 'GRCm39',        // Mouse - GRCm39
    '35':  'GRCm38.p6',     // Mouse - GRCm38
    '18':  'MGSCv37'        // Mouse - Build 37
};

function getJBrowse2Url(species, mapKey) {
    var assembly = MAPKEY_TO_JBROWSE2[mapKey];
    if (!assembly) {
        // Fall back to species default if mapKey isn't recognized
        if (species == "1") assembly = "GRCh38.p14";
        else if (species == "2") assembly = "GRCm39";
        else assembly = "mRatBN7.2";
    }
    return "/jbrowse2/?assembly=" + encodeURIComponent(assembly) + "&tracklist=true";
}

function runGviewer() {
    if (checkForm()) {
        // Close any open autocomplete dropdowns
        var dropdowns = document.querySelectorAll('.ont-ac-results');
        for (var d = 0; d < dropdowns.length; d++) {
            dropdowns[d].style.display = 'none';
        }

        document.getElementById("content").style.visibility = "visible";
        document.getElementById("gvLoadingOverlay").style.display = "flex";

        var species = document.getElementById("speciesType").value;
        var assemblySelect = document.getElementById("assemblyVersion");
        var mapKey = assemblySelect ? assemblySelect.value : null;
        var ideoUrl = getIdeoUrl(species, mapKey);

        if (!gviewer) {
            var MIN_VIEWER_WIDTH = 1200;
            var viewerWidth = Math.max(MIN_VIEWER_WIDTH,
                document.getElementById('gviewer').parentElement.offsetWidth);
            gviewer = new Gviewer("gviewer", 300, viewerWidth);

            gviewer.imagePath = "/rgdweb/gviewer/images";
            gviewer.exportURL = "/rgdweb/report/format.html";
            gviewer.annotationTypes = new Array("gene","qtl","strain");
            // Send to JBrowse 2 button hidden for now — leave URL empty
            gviewer.genomeBrowserURL = "";
            gviewer.genomeBrowserName = "JBrowse 2";
            gviewer.regionPadding=2;
            gviewer.annotationPadding = 1;

            gviewer.loadBands(ideoUrl);
            gviewer.addZoomPane("zoomWrapper", 250, viewerWidth);
            gviewer.mapKey = mapKey;
            lastSpecies = species;
            lastMapKey = mapKey;
        }else {
            if (species != lastSpecies || mapKey != lastMapKey) {
                gviewer.genomeBrowserURL = "";
                gviewer.reset(ideoUrl, species);
                gviewer.mapKey = mapKey;
                lastSpecies = species;
                lastMapKey = mapKey;
            } else {
                gviewer.reset();
            }
        }
        gviewer.loadAnnotationsGET("/rgdweb/gviewer/getAnnotationJson.html?" + getFormString());

        var toolUrl = "/rgdweb/gviewer/getXmlTool.html?" + getFormString();
        setTimeout(function() { pageRequest(toolUrl, 'gviewerDiv'); }, 500);
    }
    return false;
}

function pageRequest(url, divId) {
    $.ajax({
        url: url,
        type: 'GET',
        data: { s: new Date().getTime() },
        success: function(responseText) {
            document.getElementById(divId).innerHTML = responseText;
            document.getElementById("loading").innerHTML = "";
            // Init sorttable on any dynamically loaded tables
            var tables = document.getElementById(divId).querySelectorAll('table.sortable');
            for (var i = 0; i < tables.length; i++) {
                if (typeof sorttable !== 'undefined') sorttable.makeSortable(tables[i]);
            }
        },
        error: function() {
            alert('There was a problem with the request.');
            document.getElementById("loading").innerHTML = "";
        }
    });
}




function init() {
    runGviewer();
}

// Legacy functions - no longer needed with dropdown UI
function selectAllOntologies(obj) {}
function unselectAllOntologies(obj) {}

$(document).ready(function(){
    setupAutoComplete();

    // Auto-run from shareable URL parameters
    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('autorun') == '1') {
        var term = urlParams.get('term%5B%5D') || urlParams.get('term[]') || urlParams.get('gv_term');
        if (term) {
            $("input[name='gv_term']:first").val(term);
        }
        var species = urlParams.get('speciesType');
        if (species) {
            $('#speciesType').val(species);
        }
        // Uncheck/check ontologies based on URL params
        // (the form string includes all checkbox states, defaults are fine for auto-run)
        setTimeout(function() { runGviewer(); }, 500);
    }
});

// Map accession ID prefix to the ontology dropdown value
var ACC_TO_ONT = {
    'DOID': 'RDO', 'GO': 'CC,MF,BP', 'MP': 'MP', 'PW': 'PW',
    'NBO': 'NBO', 'CMO': 'CMO', 'MMO': 'MMO', 'XCO': 'XCO',
    'RS': 'RS', 'VT': 'VT', 'CHEBI': 'CHEBI', 'EFO': 'ALL',
    'HP': 'ALL'
};

function setupAutoComplete() {
    $("input[name='gv_term']").each(function() {
        var input = this;
        var row = $(input).closest('.gv-criteria-row');
        var ontSelect = row.find('select[name=gv_ont]');
        var accIdField = row.find('input[name=gv_acc_id]');
        var accIdSelector = accIdField.length && accIdField.attr('id') ? '#' + accIdField.attr('id') : null;
        var ont = ontSelect.length ? ontSelect.val() : 'ALL';
        // Skip if already set up
        if ($(input).data('ontAc')) return;
        var ac = setupOntologyAutocomplete(input, ont, {
            accIdField: accIdSelector,
            max: 100,
            onSelect: function(termName, accId) {
                // Update ontology dropdown based on selected term's accession prefix
                if (accId && ontSelect.length) {
                    var prefix = accId.split(':')[0];
                    var ontVal = ACC_TO_ONT[prefix];
                    if (ontVal) {
                        ontSelect.val(ontVal);
                    }
                }
            }
        });
        $(input).data('ontAc', ac);
        // Update autocomplete when ontology dropdown changes
        ontSelect.off('change.ontAc').on('change.ontAc', function() {
            var prevAc = $(input).data('ontAc');
            if (prevAc) prevAc.destroy();
            var newOnt = $(this).val();
            var newAc = setupOntologyAutocomplete(input, newOnt, {
                accIdField: accIdSelector,
                max: 100,
                onSelect: function(termName, accId) {
                    if (accId && ontSelect.length) {
                        var prefix = accId.split(':')[0];
                        var ontVal = ACC_TO_ONT[prefix];
                        if (ontVal) {
                            ontSelect.val(ontVal);
                        }
                    }
                }
            });
            $(input).data('ontAc', newAc);
        });
    });
}

function browseOntology(btn) {
    var row = $(btn).closest('.gv-criteria-row');
    var ontSelect = row.find('select[name=gv_ont]');
    var termInput = row.find('input[name=gv_term]');
    var ontVal = ontSelect.length ? ontSelect.val() : 'RDO';
    // For "ALL" or multi-value, default to RDO for browsing
    if (ontVal === 'ALL' || ontVal.indexOf(',') >= 0) {
        ontVal = 'RDO';
    }
    var termValue = termInput.val() || '';
    var url = '/rgdweb/ontology/view.html?mode=popup&ont=' + ontVal +
              '&sel_term=' + termInput.attr('name') + '&sel_acc_id=' + row.find('input[name=gv_acc_id]').attr('name') +
              '&term=' + encodeURIComponent(termValue);
    window.open(url, 'ontBrowser', 'width=900,height=500,resizable=1,scrollbars=1');
}
</script>

<jsp:include page="../common/footerarea.jsp" flush="true"/>

