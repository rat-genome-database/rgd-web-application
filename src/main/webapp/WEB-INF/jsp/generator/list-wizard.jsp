<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
String pageTitle = "OLGA - Object List Generator & Analyzer";
String headContent = "";
String pageDescription = "Build lists based on RGD annotation";
%>
<%@ include file="/common/headerarea.jsp" %>

<%
try {
    Integer mapKey = (Integer) request.getAttribute("mapKey");
    if (mapKey == null) mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
    Integer oKey = (Integer) request.getAttribute("oKey");
    if (oKey == null) oKey = 1;
    Integer speciesTypeKey = SpeciesType.getSpeciesTypeKeyForMap(mapKey);

    String objectType = "Gene";
    if (oKey == 5) objectType = "Strain";
    if (oKey == 6) objectType = "QTL";

    ArrayList<String> accIds = (ArrayList<String>) request.getAttribute("accIds");
    if (accIds == null) accIds = new ArrayList<String>();
    List omLog = (List) request.getAttribute("omLog");
    if (omLog == null) omLog = new ArrayList();
    ArrayList<String> operators = (ArrayList<String>) request.getAttribute("operators");
    if (operators == null) operators = new ArrayList<String>();
    ArrayList<ArrayList<String>> objectSymbols = (ArrayList<ArrayList<String>>) request.getAttribute("objectSymbols");
    if (objectSymbols == null) objectSymbols = new ArrayList<ArrayList<String>>();
    LinkedHashMap<String,Object> resultSet = (LinkedHashMap<String,Object>) request.getAttribute("resultSet");
    if (resultSet == null) resultSet = new LinkedHashMap<String,Object>();
    HashMap messages = (HashMap) request.getAttribute("messages");
    if (messages == null) messages = new HashMap();

    String a = request.getParameter("a") != null ? request.getParameter("a") : "";
    String vv = request.getParameter("vv") != null ? request.getParameter("vv") : "";
    String ga = request.getParameter("ga") != null ? request.getParameter("ga") : "";

    // Determine current step based on state
    int currentStep = 1;
    if (accIds.size() > 0) {
        currentStep = 3; // Have results, show review
    }
    String stepParam = request.getParameter("step");
    if (stepParam != null) {
        try { currentStep = Integer.parseInt(stepParam); } catch (Exception e) {}
    }
%>

<style>
/* Wizard Styles */
.wizard-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
}

.wizard-header {
    text-align: center;
    margin-bottom: 30px;
}

.wizard-header h1 {
    color: #24609c;
    font-size: 28px;
    margin-bottom: 5px;
}

.wizard-header p {
    color: #666;
    font-size: 16px;
}

/* Progress Steps */
.wizard-progress {
    display: flex;
    justify-content: center;
    margin-bottom: 40px;
    position: relative;
}

.wizard-progress::before {
    content: '';
    position: absolute;
    top: 20px;
    left: 15%;
    right: 15%;
    height: 3px;
    background: #e0e0e0;
    z-index: 0;
}

.wizard-step {
    display: flex;
    flex-direction: column;
    align-items: center;
    position: relative;
    z-index: 1;
    flex: 1;
    max-width: 150px;
}

.step-circle {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: #e0e0e0;
    color: #999;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 16px;
    margin-bottom: 8px;
    transition: all 0.3s ease;
}

.wizard-step.active .step-circle {
    background: #24609c;
    color: white;
}

.wizard-step.completed .step-circle {
    background: #28a745;
    color: white;
}

.step-label {
    font-size: 13px;
    color: #666;
    text-align: center;
}

.wizard-step.active .step-label {
    color: #24609c;
    font-weight: 600;
}

/* Step Content */
.wizard-content {
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 30px;
    min-height: 400px;
}

.step-panel {
    display: none;
}

.step-panel.active {
    display: block;
}

/* Cards for selections */
.selection-cards {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    justify-content: center;
    margin: 20px 0;
}

.selection-card {
    background: #f8f9fa;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    padding: 25px 30px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s ease;
    min-width: 150px;
}

.selection-card:hover {
    border-color: #24609c;
    background: #f0f7ff;
    transform: translateY(-2px);
}

.selection-card.selected {
    border-color: #24609c;
    background: #e8f1fb;
}

.selection-card i {
    font-size: 32px;
    color: #24609c;
    margin-bottom: 10px;
    display: block;
}

.selection-card h4 {
    margin: 0;
    color: #333;
    font-size: 16px;
}

.selection-card p {
    margin: 5px 0 0;
    color: #666;
    font-size: 12px;
}

/* Form sections */
.form-section {
    margin-bottom: 25px;
}

.form-section label {
    display: block;
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
}

.form-section select,
.form-section input[type="text"],
.form-section textarea {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 14px;
}

.form-section select {
    height: auto;
    min-height: 44px;
    line-height: 1.4;
}

.form-section select:focus,
.form-section input[type="text"]:focus,
.form-section textarea:focus {
    outline: none;
    border-color: #24609c;
    box-shadow: 0 0 0 3px rgba(36, 96, 156, 0.1);
}

/* Criteria chips */
.criteria-list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin: 15px 0;
    min-height: 50px;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border: 1px dashed #ccc;
}

.criteria-chip {
    display: inline-flex;
    align-items: center;
    background: #24609c;
    color: white;
    padding: 8px 12px;
    border-radius: 20px;
    font-size: 13px;
}

.criteria-chip .chip-type {
    background: rgba(255,255,255,0.2);
    padding: 2px 8px;
    border-radius: 10px;
    margin-right: 8px;
    font-size: 11px;
}

.criteria-chip .remove-chip {
    margin-left: 8px;
    cursor: pointer;
    opacity: 0.7;
}

.criteria-chip .remove-chip:hover {
    opacity: 1;
}

.operator-badge {
    background: #ffc107;
    color: #333;
    padding: 4px 12px;
    border-radius: 4px;
    font-weight: 600;
    font-size: 12px;
}

/* Results section */
.results-summary {
    background: #e8f5e9;
    border: 1px solid #c8e6c9;
    border-radius: 8px;
    padding: 15px 20px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.results-count {
    font-size: 24px;
    font-weight: bold;
    color: #2e7d32;
}

.results-list {
    max-height: 300px;
    overflow-y: auto;
    background: #f8f9fa;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 15px;
}

.results-list .result-item {
    display: inline-block;
    background: white;
    border: 1px solid #ddd;
    padding: 4px 10px;
    margin: 3px;
    border-radius: 4px;
    font-size: 13px;
}

/* Tool cards */
.tool-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.tool-card {
    background: white;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s ease;
}

.tool-card:hover {
    border-color: #24609c;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    transform: translateY(-2px);
}

.tool-card img {
    width: 80px;
    height: 80px;
    object-fit: contain;
    margin-bottom: 10px;
}

.tool-card h4 {
    margin: 0 0 5px;
    color: #333;
}

.tool-card p {
    margin: 0;
    color: #666;
    font-size: 12px;
}

/* Navigation buttons */
.wizard-nav {
    display: flex;
    justify-content: space-between;
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px solid #eee;
}

.btn-wizard {
    padding: 12px 30px;
    border: none;
    border-radius: 6px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-wizard-prev {
    background: #f0f0f0;
    color: #333;
}

.btn-wizard-prev:hover {
    background: #e0e0e0;
}

.btn-wizard-next {
    background: #24609c;
    color: white;
}

.btn-wizard-next:hover {
    background: #1a4a7a;
}

.btn-wizard:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

/* Ontology tabs */
.ontology-tabs {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
}

.ontology-tab {
    padding: 8px 16px;
    background: #f0f0f0;
    border: 1px solid #ddd;
    border-radius: 20px;
    cursor: pointer;
    font-size: 13px;
    transition: all 0.2s ease;
}

.ontology-tab:hover {
    background: #e0e0e0;
}

.ontology-tab.active {
    background: #24609c;
    color: white;
    border-color: #24609c;
}

/* Input method tabs */
.input-method-tabs {
    display: flex;
    border-bottom: 2px solid #e0e0e0;
    margin-bottom: 20px;
}

.input-method-tab {
    padding: 12px 24px;
    background: none;
    border: none;
    cursor: pointer;
    font-size: 14px;
    color: #666;
    position: relative;
}

.input-method-tab.active {
    color: #24609c;
    font-weight: 600;
}

.input-method-tab.active::after {
    content: '';
    position: absolute;
    bottom: -2px;
    left: 0;
    right: 0;
    height: 2px;
    background: #24609c;
}

.input-panel {
    display: none;
    padding: 20px 0;
}

.input-panel.active {
    display: block;
}

/* Search with autocomplete */
.search-container {
    position: relative;
    background: #f0f7ff;
    border: 3px solid #24609c;
    border-radius: 12px;
    padding: 20px;
    margin: 20px 0;
}

.search-container input {
    width: 100%;
    padding: 16px 140px 16px 20px;
    font-size: 18px;
    border: 2px solid #ccc;
    border-radius: 8px;
    box-sizing: border-box;
}

.search-container input:focus {
    border-color: #24609c;
    outline: none;
    box-shadow: 0 0 0 4px rgba(36, 96, 156, 0.2);
}

.search-container input::placeholder {
    color: #888;
    font-size: 16px;
}

.search-container .browse-btn {
    position: absolute;
    right: 28px;
    top: 50%;
    transform: translateY(-50%);
    padding: 12px 20px;
    background: #24609c;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
}

.search-container .browse-btn:hover {
    background: #1a4a7a;
}

/* Set operation selector */
.operation-selector {
    background: #fff8e1;
    border: 1px solid #ffe082;
    border-radius: 8px;
    padding: 15px;
    margin: 20px 0;
}

.operation-selector h5 {
    margin: 0 0 10px;
    color: #f57c00;
}

.operation-options {
    display: flex;
    gap: 20px;
}

.operation-option {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
}

.operation-option input[type="radio"] {
    width: 18px;
    height: 18px;
}

/* Modal styles */
.modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 1000;
    justify-content: center;
    align-items: center;
}

.modal-overlay.active {
    display: flex;
}

.modal-content {
    background: white;
    border-radius: 16px;
    padding: 30px;
    max-width: 500px;
    width: 90%;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
    animation: modalSlideIn 0.3s ease;
}

@keyframes modalSlideIn {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.modal-header {
    text-align: center;
    margin-bottom: 25px;
}

.modal-header i {
    font-size: 48px;
    color: #28a745;
    margin-bottom: 15px;
}

.modal-header h3 {
    margin: 0;
    color: #333;
    font-size: 22px;
}

.modal-header p {
    color: #666;
    margin: 10px 0 0;
}

.modal-body {
    margin-bottom: 25px;
}

.modal-operation-choice {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.modal-operation-btn {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    background: #f8f9fa;
    cursor: pointer;
    transition: all 0.2s ease;
}

.modal-operation-btn:hover {
    border-color: #24609c;
    background: #f0f7ff;
}

.modal-operation-btn i {
    font-size: 24px;
    margin-right: 15px;
    width: 30px;
    text-align: center;
}

.modal-operation-btn.union i { color: #28a745; }
.modal-operation-btn.intersect i { color: #007bff; }
.modal-operation-btn.subtract i { color: #dc3545; }

.modal-operation-btn .op-label {
    font-weight: 600;
    font-size: 16px;
    color: #333;
}

.modal-operation-btn .op-desc {
    font-size: 13px;
    color: #666;
    margin-left: auto;
}

.modal-footer {
    display: flex;
    gap: 15px;
    justify-content: center;
}

.modal-btn {
    padding: 12px 30px;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}

.modal-btn-primary {
    background: #24609c;
    color: white;
}

.modal-btn-primary:hover {
    background: #1a4a7a;
}

.modal-btn-secondary {
    background: #28a745;
    color: white;
}

.modal-btn-secondary:hover {
    background: #218838;
}

.modal-btn-outline {
    background: white;
    color: #666;
    border: 2px solid #ddd;
}

.modal-btn-outline:hover {
    background: #f0f0f0;
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 40px;
    color: #999;
}

.empty-state i {
    font-size: 48px;
    margin-bottom: 15px;
}
</style>

<!-- Font Awesome for icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- Autocomplete plugin (jQuery already loaded in headerarea.jsp) -->
<script src="/rgdweb/common/jquery.autocomplete.custom.js"></script>

<!-- Hidden form for submissions -->
<form name="submitForm" id="submitForm" action="wizard.html" method="post">
    <input type="hidden" name="a" id="a" value="<%=a%>" />
    <input type="hidden" name="mapKey" id="mapKey" value="<%=mapKey%>" />
    <input type="hidden" name="oKey" id="oKey" value="<%=oKey%>" />
    <input type="hidden" name="step" id="step" value="<%=currentStep%>" />
    <input type="hidden" name="vv" id="vv" value="<%=vv%>" />
    <input type="hidden" name="ga" id="ga" value="<%=ga%>" />
    <input type="hidden" name="act" id="act" value="" />
</form>

<div class="wizard-container">
    <!-- Header -->
    <div class="wizard-header">
        <h1><i class="fas fa-list-check"></i> OLGA</h1>
        <p>Object List Generator & Analyzer - Build customized lists of genes, QTLs, or strains</p>
    </div>

    <!-- Progress Steps -->
    <div class="wizard-progress">
        <div class="wizard-step <%= currentStep >= 1 ? (currentStep > 1 ? "completed" : "active") : "" %>" data-step="1">
            <div class="step-circle"><%= currentStep > 1 ? "<i class='fas fa-check'></i>" : "1" %></div>
            <div class="step-label">Setup</div>
        </div>
        <div class="wizard-step <%= currentStep >= 2 ? (currentStep > 2 ? "completed" : "active") : "" %>" data-step="2">
            <div class="step-circle"><%= currentStep > 2 ? "<i class='fas fa-check'></i>" : "2" %></div>
            <div class="step-label">Build List</div>
        </div>
        <div class="wizard-step <%= currentStep >= 3 ? (currentStep > 3 ? "completed" : "active") : "" %>" data-step="3">
            <div class="step-circle"><%= currentStep > 3 ? "<i class='fas fa-check'></i>" : "3" %></div>
            <div class="step-label">Review</div>
        </div>
        <div class="wizard-step <%= currentStep >= 4 ? "active" : "" %>" data-step="4">
            <div class="step-circle">4</div>
            <div class="step-label">Analyze</div>
        </div>
    </div>

    <!-- Wizard Content -->
    <div class="wizard-content">

        <!-- Step 1: Setup -->
        <div class="step-panel <%= currentStep == 1 ? "active" : "" %>" id="step1">
            <h3>Step 1: Choose Your Settings</h3>

            <div class="form-section">
                <label>What type of list do you want to build?</label>
                <div class="selection-cards">
                    <div class="selection-card <%= oKey == 1 ? "selected" : "" %>" data-okey="1">
                        <i class="fas fa-dna"></i>
                        <h4>Genes</h4>
                        <p>Build a list of genes</p>
                    </div>
                    <% if (speciesTypeKey == 3 || speciesTypeKey == 2 || speciesTypeKey == 1) { %>
                    <div class="selection-card <%= oKey == 6 ? "selected" : "" %>" data-okey="6">
                        <i class="fas fa-map-marker-alt"></i>
                        <h4>QTLs</h4>
                        <p>Build a list of QTLs</p>
                    </div>
                    <% } %>
                    <% if (speciesTypeKey == 3) { %>
                    <div class="selection-card <%= oKey == 5 ? "selected" : "" %>" data-okey="5">
                        <i class="fas fa-flask"></i>
                        <h4>Strains</h4>
                        <p>Build a list of strains</p>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="form-section">
                <label>Select Assembly Version</label>
                <select id="mapKey_select" class="form-control">
                    <optgroup label="Rat">
                        <option value="380" <%= mapKey == 380 ? "selected" : "" %>>GRCr8</option>
                        <option value="372" <%= mapKey == 372 ? "selected" : "" %>>Rnor_6.0 (v7.2)</option>
                        <option value="360" <%= mapKey == 360 ? "selected" : "" %>>RGSC_v3.4 (v6.0)</option>
                        <option value="70" <%= mapKey == 70 ? "selected" : "" %>>RGSC_v3.4 (v5.0)</option>
                        <option value="60" <%= mapKey == 60 ? "selected" : "" %>>RGSC_v3.4 (v3.4)</option>
                    </optgroup>
                    <optgroup label="Human">
                        <option value="38" <%= mapKey == 38 ? "selected" : "" %>>GRCh38</option>
                        <option value="17" <%= mapKey == 17 ? "selected" : "" %>>GRCh37</option>
                    </optgroup>
                    <optgroup label="Mouse">
                        <option value="239" <%= mapKey == 239 ? "selected" : "" %>>GRCm39</option>
                        <option value="35" <%= mapKey == 35 ? "selected" : "" %>>GRCm38</option>
                        <option value="18" <%= mapKey == 18 ? "selected" : "" %>>Build 37</option>
                    </optgroup>
                    <optgroup label="Other Species">
                        <option value="44" <%= mapKey == 44 ? "selected" : "" %>>Chinchilla ChiLan1.0</option>
                        <option value="634" <%= mapKey == 634 ? "selected" : "" %>>Dog ROS_Cfam_1.0</option>
                        <option value="631" <%= mapKey == 631 ? "selected" : "" %>>Dog CanFam3.1</option>
                        <option value="911" <%= mapKey == 911 ? "selected" : "" %>>Pig Sscrofa11.1</option>
                        <option value="910" <%= mapKey == 910 ? "selected" : "" %>>Pig Sscrofa10.2</option>
                    </optgroup>
                </select>
            </div>
        </div>

        <!-- Step 2: Build List -->
        <div class="step-panel <%= currentStep == 2 ? "active" : "" %>" id="step2">
            <h3>Step 2: Add Criteria to Your List</h3>

            <!-- Input Method Tabs -->
            <div class="input-method-tabs">
                <button class="input-method-tab active" data-panel="ontology-panel">
                    <i class="fas fa-sitemap"></i> Ontology Annotation
                </button>
                <button class="input-method-tab" data-panel="region-panel">
                    <i class="fas fa-map-marked-alt"></i> Genomic Region
                </button>
                <button class="input-method-tab" data-panel="qtl-panel">
                    <i class="fas fa-crosshairs"></i> QTL Region
                </button>
                <button class="input-method-tab" data-panel="symbols-panel">
                    <i class="fas fa-list"></i> Symbol List
                </button>
            </div>

            <!-- Ontology Panel -->
            <div class="input-panel active" id="ontology-panel">
                <div class="ontology-tabs" id="ontologyTabs">
                    <span class="ontology-tab active" data-ont="rdo">Disease</span>
                    <span class="ontology-tab" data-ont="mp">Mammalian Phenotype</span>
                    <span class="ontology-tab" data-ont="pw">Pathway</span>
                    <span class="ontology-tab" data-ont="bp">GO: Biological Process</span>
                    <span class="ontology-tab" data-ont="mf">GO: Molecular Function</span>
                    <span class="ontology-tab" data-ont="cc">GO: Cellular Component</span>
                    <span class="ontology-tab" data-ont="chebi">Chemical (CHEBI)</span>
                    <span class="ontology-tab" data-ont="vt">Vertebrate Trait</span>
                    <span class="ontology-tab" data-ont="hp">Human Phenotype</span>
                    <span class="ontology-tab" data-ont="rs">Strain Ontology</span>
                    <span class="ontology-tab" data-ont="cmo">Clinical Measurement</span>
                </div>

                <div class="search-container">
                    <label style="display: block; font-size: 16px; font-weight: 600; color: #24609c; margin-bottom: 12px;">
                        <i class="fas fa-search"></i> Search for Ontology Terms
                    </label>
                    <input type="text" id="ontology_term" placeholder="Type disease name, phenotype, pathway, or GO term..." />
                    <input type="hidden" id="ontology_acc_id" value="" />
                    <button type="button" class="browse-btn" id="browseOntology"><i class="fas fa-sitemap"></i> Browse Tree</button>
                </div>
            </div>

            <!-- Region Panel -->
            <div class="input-panel" id="region-panel">
                <div class="form-section">
                    <label>Chromosome</label>
                    <select id="chr">
                        <%
                        List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(mapKey);
                        for (Chromosome ch: chromosomes) { %>
                            <option value="<%=ch.getChromosome()%>"><%=ch.getChromosome()%></option>
                        <% } %>
                    </select>
                </div>
                <div style="display: flex; gap: 20px;">
                    <div class="form-section" style="flex: 1;">
                        <label>Start Position</label>
                        <input type="text" id="start" placeholder="e.g., 1000000" />
                    </div>
                    <div class="form-section" style="flex: 1;">
                        <label>Stop Position</label>
                        <input type="text" id="stop" placeholder="e.g., 5000000" />
                    </div>
                </div>
            </div>

            <!-- QTL Panel -->
            <div class="input-panel" id="qtl-panel">
                <div class="form-section">
                    <label>Enter QTL Symbol</label>
                    <input type="text" id="qtl" placeholder="e.g., Bp1, Gluco1" />
                </div>
                <p style="color: #666; font-size: 12px;">
                    <i class="fas fa-info-circle"></i> Enter a QTL symbol to find all <%=objectType.toLowerCase()%>s that overlap its genomic region
                </p>
            </div>

            <!-- Symbol List Panel -->
            <div class="input-panel" id="symbols-panel">
                <div class="form-section">
                    <label>Enter <%=objectType%> Symbols</label>
                    <textarea id="geneSelectList" rows="6" placeholder="Enter symbols separated by commas or new lines&#10;&#10;Example:&#10;Ins1, Ins2, Insr&#10;Irs1&#10;Irs2"></textarea>
                </div>
            </div>

            <div style="text-align: center; margin-top: 20px;">
                <button class="btn-wizard btn-wizard-next" id="addCriteriaBtn" style="background: #28a745;">
                    <i class="fas fa-plus"></i> Add to List
                </button>
            </div>

            <!-- Current Criteria -->
            <div style="margin-top: 30px;">
                <h4>Current Criteria</h4>
                <div class="criteria-list" id="criteriaList">
                    <% if (accIds.size() == 0) { %>
                        <div class="empty-state" style="width: 100%; padding: 20px;">
                            <i class="fas fa-filter"></i>
                            <p>No criteria added yet. Use the options above to add criteria.</p>
                        </div>
                    <% } else {
                        for (int i = 0; i < accIds.size(); i++) {
                            String accId = accIds.get(i);
                            String identifier = "";
                            String chipType = "Term";

                            if (accId.toLowerCase().startsWith("chr")) {
                                identifier = accId;
                                chipType = "Region";
                            } else if (accId.toLowerCase().startsWith("lst")) {
                                identifier = "User List";
                                chipType = "Symbols";
                            } else if (accId.toLowerCase().startsWith("qtl")) {
                                identifier = accId.substring(4);
                                chipType = "QTL";
                            } else {
                                OntologyXDAO odao = new OntologyXDAO();
                                Term t = odao.getTermByAccId(accId);
                                if (t != null) identifier = t.getTerm();
                                else identifier = accId;
                            }

                            if (i > 0) {
                                String op = operators.get(i);
                                String opName = "UNION";
                                if (op.equals("!")) opName = "INTERSECT";
                                if (op.equals("^")) opName = "SUBTRACT";
                    %>
                        <span class="operator-badge"><%=opName%></span>
                    <%      } %>
                        <span class="criteria-chip">
                            <span class="chip-type"><%=chipType%></span>
                            <%=identifier%>
                            <span class="remove-chip" data-index="<%=i%>"><i class="fas fa-times"></i></span>
                        </span>
                    <%  }
                    } %>
                </div>
            </div>

            <!-- Set Operation Selector (shown when adding 2nd+ criteria) -->
            <div class="operation-selector" id="operationSelector" style="display: <%= accIds.size() > 0 ? "block" : "none" %>;">
                <h5><i class="fas fa-code-branch"></i> How should the next criteria combine with existing?</h5>
                <div class="operation-options">
                    <label class="operation-option">
                        <input type="radio" name="setOperation" value="~" checked />
                        <strong>Union</strong> - Include items from either list
                    </label>
                    <label class="operation-option">
                        <input type="radio" name="setOperation" value="!" />
                        <strong>Intersect</strong> - Only items in both lists
                    </label>
                    <label class="operation-option">
                        <input type="radio" name="setOperation" value="^" />
                        <strong>Subtract</strong> - Remove items in new criteria
                    </label>
                </div>
            </div>

            <% if (accIds.size() > 0) { %>
            <div class="results-summary">
                <div>
                    <span class="results-count"><%=resultSet.keySet().size()%></span>
                    <span style="color: #666; margin-left: 10px;"><%=objectType.toLowerCase()%>s in current result</span>
                </div>
            </div>
            <% } %>
        </div>

        <!-- Step 3: Review -->
        <div class="step-panel <%= currentStep == 3 ? "active" : "" %>" id="step3">
            <h3>Step 3: Review Your Results</h3>

            <% if (accIds.size() > 0) { %>
            <!-- Query Summary -->
            <div style="background: #f0f7ff; border: 1px solid #b3d4fc; border-radius: 8px; padding: 15px; margin-bottom: 20px;">
                <h5 style="margin: 0 0 10px; color: #24609c;"><i class="fas fa-search"></i> Your Query</h5>
                <div style="font-family: monospace; font-size: 14px;">
                    <% for (int i = 0; i < accIds.size(); i++) {
                        String accId = accIds.get(i);
                        String identifier = "";

                        if (accId.toLowerCase().startsWith("chr")) {
                            identifier = accId;
                        } else if (accId.toLowerCase().startsWith("lst")) {
                            identifier = "User List";
                        } else if (accId.toLowerCase().startsWith("qtl")) {
                            identifier = accId.substring(4);
                        } else {
                            OntologyXDAO odao = new OntologyXDAO();
                            Term t = odao.getTermByAccId(accId);
                            if (t != null) identifier = t.getTerm();
                            else identifier = accId;
                        }

                        if (i > 0) {
                            String op = operators.get(i);
                            if (op.equals("~")) out.print(" <strong style='color:#28a745'>UNION</strong> ");
                            if (op.equals("!")) out.print(" <strong style='color:#007bff'>INTERSECT</strong> ");
                            if (op.equals("^")) out.print(" <strong style='color:#dc3545'>SUBTRACT</strong> ");
                        }
                        out.print("<span style='background:#fff;padding:2px 8px;border-radius:4px;border:1px solid #ddd;'>" + identifier + "</span>");
                    } %>
                </div>
            </div>

            <div class="results-summary">
                <div>
                    <span class="results-count"><%=resultSet.keySet().size()%></span>
                    <span style="color: #666; margin-left: 10px;"><%=objectType.toLowerCase()%>s found</span>
                </div>
                <button class="btn-wizard" style="background: #6c757d; color: white; padding: 8px 16px;" onclick="goToStep(2)">
                    <i class="fas fa-edit"></i> Modify Query
                </button>
            </div>

            <h4>Results</h4>
            <div class="results-list" id="resultsList">
                <% if (resultSet.keySet().size() == 0) { %>
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p>No results found. Try adjusting your criteria.</p>
                    </div>
                <% } else {
                    Iterator it = resultSet.keySet().iterator();
                    while(it.hasNext()) {
                        String gene = (String)it.next();
                %>
                    <span class="result-item"><%=gene.trim()%></span>
                <% }
                } %>
            </div>
            <% } else { %>
            <div class="empty-state">
                <i class="fas fa-filter"></i>
                <p>No criteria added yet. Go back to Step 2 to build your list.</p>
            </div>
            <% } %>
        </div>

        <!-- Step 4: Analyze -->
        <div class="step-panel <%= currentStep == 4 ? "active" : "" %>" id="step4">
            <h3>Step 4: Analyze Your Results</h3>

            <% if (resultSet != null && resultSet.keySet().size() > 0) { %>
            <div class="results-summary" style="margin-bottom: 30px;">
                <div>
                    <span class="results-count"><%=resultSet.keySet().size()%></span>
                    <span style="color: #666; margin-left: 10px;"><%=objectType.toLowerCase()%>s ready for analysis</span>
                </div>
            </div>

            <h4>Choose an Analysis Tool</h4>
            <div class="tool-cards">
                <% if (oKey == 1) { %>
                <div class="tool-card" onclick="toolSubmit('ga', <%=speciesTypeKey%>)">
                    <img src="/rgdweb/common/images/gaTool.png" alt="Gene Annotator" />
                    <h4>Gene Annotator</h4>
                    <p>Functional annotation analysis</p>
                </div>
                <% } %>

                <% if (speciesTypeKey == 3 && oKey == 1) { %>
                <div class="tool-card" onclick="toolSubmit('vv', <%=speciesTypeKey%>)">
                    <img src="/rgdweb/common/images/variantVisualizer.png" alt="Variant Visualizer" />
                    <h4>Variant Visualizer</h4>
                    <p>Explore genomic variants</p>
                </div>
                <% } %>

                <div class="tool-card" onclick="toolSubmit('gv', <%=speciesTypeKey%>)">
                    <img src="/rgdweb/common/images/gviewer.png" alt="Genome Viewer" />
                    <h4>Genome Viewer</h4>
                    <p>Visualize on the genome</p>
                </div>

                <div class="tool-card" onclick="toolSubmit('interviewer', <%=speciesTypeKey%>)">
                    <img src="/rgdweb/common/images/interviewer.png" alt="Interviewer" />
                    <h4>Protein Interactions</h4>
                    <p>Explore protein networks</p>
                </div>

                <div class="tool-card" onclick="toolSubmit('excel', <%=speciesTypeKey%>)">
                    <img src="/rgdweb/common/images/excel.png" alt="Excel" />
                    <h4>Download Excel</h4>
                    <p>Export results to spreadsheet</p>
                </div>
            </div>
            <% } else { %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <p>No results to analyze. Go back and build your list first.</p>
            </div>
            <% } %>
        </div>

        <!-- Navigation Buttons -->
        <div class="wizard-nav">
            <button class="btn-wizard btn-wizard-prev" id="prevBtn" onclick="prevStep()" <%= currentStep == 1 ? "style='visibility:hidden'" : "" %>>
                <i class="fas fa-arrow-left"></i> Back
            </button>
            <button class="btn-wizard btn-wizard-next" id="nextBtn" onclick="nextStep()">
                <%= currentStep == 4 ? "Start Over" : "Next" %> <i class="fas fa-arrow-right"></i>
            </button>
        </div>
    </div>
</div>

<!-- Modal for adding another term -->
<div class="modal-overlay" id="addTermModal">
    <div class="modal-content">
        <div class="modal-header">
            <i class="fas fa-check-circle"></i>
            <h3>Term Added Successfully!</h3>
            <p id="modalTermName">Your criteria has been added to the list.</p>
        </div>
        <div class="modal-body">
            <p style="text-align: center; color: #333; font-weight: 600; margin-bottom: 15px;">
                Would you like to add another term?
            </p>
            <div class="modal-operation-choice">
                <div class="modal-operation-btn union" onclick="addAnotherTerm('~')">
                    <i class="fas fa-plus-circle"></i>
                    <span class="op-label">Union (OR)</span>
                    <span class="op-desc">Include items from either list</span>
                </div>
                <div class="modal-operation-btn intersect" onclick="addAnotherTerm('!')">
                    <i class="fas fa-compress-alt"></i>
                    <span class="op-label">Intersect (AND)</span>
                    <span class="op-desc">Only items in both lists</span>
                </div>
                <div class="modal-operation-btn subtract" onclick="addAnotherTerm('^')">
                    <i class="fas fa-minus-circle"></i>
                    <span class="op-label">Subtract (NOT)</span>
                    <span class="op-desc">Remove items from new criteria</span>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="modal-btn modal-btn-outline" onclick="closeModalAndStay()">
                <i class="fas fa-times"></i> Done Adding
            </button>
            <button class="modal-btn modal-btn-primary" onclick="closeModalAndReview()">
                <i class="fas fa-arrow-right"></i> Review Results
            </button>
        </div>
    </div>
</div>

<script>
var currentStep = <%=currentStep%>;
var mapKey = <%=mapKey%>;
var oKey = <%=oKey%>;
var speciesTypeKey = <%=speciesTypeKey%>;
var currentOntology = 'rdo';

// Arrays to track query state
var aOperators = [];
var aAccIds = [];
var aSubGenes = [];

<% if (a != null && !a.isEmpty()) { %>
// Parse existing query
var accIdTmp = "<%=a%>".split("|");
for (var i = 0; i < accIdTmp.length; i++) {
    var accIdBlock = accIdTmp[i];
    aOperators[i] = accIdBlock.substring(0,1);
    var minGenes = accIdBlock.split("*");
    aAccIds[i] = minGenes[0].substring(1);
    aSubGenes[i] = minGenes;
}
<% } %>

// Global navigation functions (must be outside IIFE for onclick handlers)
function goToStep(step) {
    currentStep = step;
    jQuery('.step-panel').removeClass('active');
    jQuery('#step' + step).addClass('active');

    // Update progress
    jQuery('.wizard-step').each(function() {
        var stepNum = jQuery(this).data('step');
        jQuery(this).removeClass('active completed');
        if (stepNum < currentStep) jQuery(this).addClass('completed');
        if (stepNum == currentStep) jQuery(this).addClass('active');
    });

    // Update nav buttons
    jQuery('#prevBtn').css('visibility', step == 1 ? 'hidden' : 'visible');
    jQuery('#nextBtn').html(step == 4 ? 'Start Over <i class="fas fa-redo"></i>' : 'Next <i class="fas fa-arrow-right"></i>');
}

function nextStep() {
    if (currentStep == 1) {
        // Validate and go to step 2
        jQuery('#mapKey').val(jQuery('#mapKey_select').val());
        goToStep(2);
    } else if (currentStep == 2) {
        if (aAccIds.length == 0) {
            alert('Please add at least one criteria before proceeding.');
            return;
        }
        goToStep(3);
    } else if (currentStep == 3) {
        goToStep(4);
    } else if (currentStep == 4) {
        // Start over
        window.location.href = 'wizard.html';
    }
}

function prevStep() {
    if (currentStep > 1) {
        goToStep(currentStep - 1);
    }
}

var pendingAccId = null;
var pendingOperator = '~';

function addCriteria() {
    var accId = getUserSelectedAccId();
    if (!accId) {
        alert('Please enter or select a valid criteria.');
        return;
    }

    // Get operation if this isn't the first criteria
    var operator = '~';
    if (aAccIds.length > 0) {
        operator = jQuery('input[name="setOperation"]:checked').val();
    }

    // Add to arrays
    aOperators.push(operator);
    aAccIds.push(accId);
    aSubGenes.push([]);

    // Get term name for display
    var termName = jQuery('#ontology_term').val() || accId;
    jQuery('#modalTermName').text('"' + termName + '" has been added to your list.');

    // Show the modal
    jQuery('#addTermModal').addClass('active');

    // Clear inputs
    jQuery('#ontology_term').val('');
    jQuery('#ontology_acc_id').val('');
    jQuery('#geneSelectList').val('');
    jQuery('#qtl').val('');
    jQuery('#start').val('');
    jQuery('#stop').val('');
}

function addAnotherTerm(operation) {
    // Set the operation for the next term
    jQuery('input[name="setOperation"][value="' + operation + '"]').prop('checked', true);

    // Close modal and stay on step 2
    jQuery('#addTermModal').removeClass('active');

    // Submit to refresh the page with the new term, staying on step 2
    reloadPage();
}

function closeModalAndStay() {
    jQuery('#addTermModal').removeClass('active');
    // Submit to refresh with the new term
    reloadPage();
}

function closeModalAndReview() {
    jQuery('#addTermModal').removeClass('active');
    // Submit and go to step 3
    jQuery('#step').val(3);
    reloadPage();
}

function getUserSelectedAccId() {
    var accId = jQuery('#ontology_acc_id').val();
    if (accId) return accId;

    var geneList = jQuery('#geneSelectList').val();
    if (geneList) {
        var genes = geneList.split(/[,\s\n]+/);
        var geneStr = '';
        for (var i = 0; i < genes.length; i++) {
            if (genes[i].trim() == '') continue;
            if (geneStr == '') {
                geneStr = genes[i].trim();
            } else {
                geneStr += '[' + genes[i].trim();
            }
        }
        return 'lst:' + geneStr;
    }

    var qtl = jQuery('#qtl').val();
    if (qtl) return 'qtl:' + qtl;

    var chr = jQuery('#chr').val();
    var start = jQuery('#start').val();
    var stop = jQuery('#stop').val();
    if (chr && start && stop) {
        return 'chr' + chr + ':' + start.trim() + '..' + stop.trim();
    }

    return null;
}

function removeTerm(index) {
    aOperators.splice(index, 1);
    aAccIds.splice(index, 1);
    aSubGenes.splice(index, 1);
    reloadPage();
}

function reloadPage() {
    var urlString = '';
    for (var i = 0; i < aOperators.length; i++) {
        if (i != 0) urlString += '|';
        urlString += aOperators[i] + aAccIds[i];
        for (var j = 1; j < aSubGenes[i].length; j++) {
            urlString += '*' + aSubGenes[i][j];
        }
    }

    jQuery('#a').val(urlString);
    jQuery('#mapKey').val(mapKey);
    jQuery('#oKey').val(oKey);
    jQuery('#step').val(2);
    document.submitForm.submit();
}

function getResultSet() {
    var results = [];
    jQuery('#resultsList .result-item').each(function() {
        results.push(jQuery(this).text().trim());
    });
    return encodeURIComponent(results.join('\n'));
}

function toolSubmit(tool, speciesTypeKey) {
    var resultSet = getResultSet();
    if (!resultSet) {
        alert('No results to analyze.');
        return;
    }

    var url = '';
    if (tool == 'vv') {
        url = '/rgdweb/front/geneList.html?chr=&start=&stop=&geneStart=&geneStop=';
        url += '&mapKey=' + mapKey;
        url += '&geneList=' + resultSet;
        window.open(url);
    } else if (tool == 'ga') {
        url = '/rgdweb/ga/start.jsp?o=D&o=W&o=N&o=P&o=C&o=F&o=E&species=' + speciesTypeKey;
        url += '&mapKey=' + mapKey;
        url += '&genes=' + resultSet;
        window.open(url);
    } else if (tool == 'excel') {
        jQuery('#act').val('excel');
        document.submitForm.action = 'process.html';
        document.submitForm.submit();
    } else if (tool == 'gv') {
        jQuery('#act').val('browse');
        document.submitForm.action = 'process.html';
        document.submitForm.submit();
    } else if (tool == 'interviewer') {
        url = '/rgdweb/cytoscape/cy.html?browser=12&species=' + speciesTypeKey + '&identifiers=' + resultSet;
        window.open(url);
    }
}

// jQuery-specific initialization
jQuery(document).ready(function($) {
    // List type card selection
    $('.selection-card').click(function() {
        $('.selection-card').removeClass('selected');
        $(this).addClass('selected');
        oKey = $(this).data('okey');
        $('#oKey').val(oKey);
    });

    // Assembly selection
    $('#mapKey_select').change(function() {
        mapKey = $(this).val();
        $('#mapKey').val(mapKey);
    });

    // Input method tabs
    $('.input-method-tab').click(function() {
        $('.input-method-tab').removeClass('active');
        $(this).addClass('active');
        $('.input-panel').removeClass('active');
        $('#' + $(this).data('panel')).addClass('active');
    });

    // Ontology tabs
    $('.ontology-tab').click(function() {
        $('.ontology-tab').removeClass('active');
        $(this).addClass('active');
        currentOntology = $(this).data('ont');
        $('#ontology_term').val('');
        $('#ontology_acc_id').val('');
        setupAutocomplete(currentOntology);
    });

    // Setup initial autocomplete
    setupAutocomplete('rdo');

    // Add criteria button
    $('#addCriteriaBtn').click(function() {
        addCriteria();
    });

    // Remove criteria chip
    $(document).on('click', '.remove-chip', function() {
        var index = $(this).data('index');
        removeTerm(index);
    });

    // Browse ontology button
    $('#browseOntology').click(function() {
        var ontId = currentOntology.toUpperCase();
        var termValue = $('#ontology_term').val() || '';
        var url = '/rgdweb/ontology/view.html?mode=popup&ont=' + ontId +
                  '&sel_term=ontology_term&sel_acc_id=ontology_acc_id&term=' + encodeURIComponent(termValue);
        window.open(url, 'ontBrowser', 'width=900,height=500,resizable=1,scrollbars=1');
        return false;
    });

    function setupAutocomplete(ont) {
        var ontPrefix = ont.toUpperCase();
        if (ont == 'rdo') ontPrefix = 'DOID,RDO';
        if (ont == 'bp') ontPrefix = 'GO';
        if (ont == 'mf') ontPrefix = 'GO';
        if (ont == 'cc') ontPrefix = 'GO';
        if (ont == 'chebi') ontPrefix = 'CHEBI';
        if (ont == 'pw') ontPrefix = 'PW';
        if (ont == 'mp') ontPrefix = 'MP';
        if (ont == 'hp') ontPrefix = 'HP';
        if (ont == 'rs') ontPrefix = 'RS';
        if (ont == 'cmo') ontPrefix = 'CMO';
        if (ont == 'vt') ontPrefix = 'VT';

        $('#ontology_term').autocomplete({
            serviceUrl: '/rgdweb/OntoSolr/searchAutoComplete.html',
            params: {ontFilter: ontPrefix},
            minChars: 2,
            maxHeight: 400,
            width: 500,
            deferRequestBy: 100,
            onSelect: function(value, data) {
                $('#ontology_acc_id').val(data);
            }
        });
    }
});
</script>

<% } catch (Exception e) {
    e.printStackTrace();
} %>

<%@ include file="/common/footerarea.jsp" %>
