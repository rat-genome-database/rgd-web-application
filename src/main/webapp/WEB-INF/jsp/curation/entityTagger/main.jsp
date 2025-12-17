<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ontomation - Entity Recognition</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/entityTagger/curation-main.css">
    
    <!-- Toastr for notifications -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css">
</head>
<body>
    <!-- Navigation Header -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <img src="${pageContext.request.contextPath}/images/rgd-logo.png" alt="RGD" height="30" class="d-inline-block align-text-top">
                Ontomation
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="#" data-section="recognition">
                            <i class="fas fa-microscope"></i> Entity Recognition
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" data-section="validation">
                            <i class="fas fa-check-circle"></i> Validation
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" data-section="batch">
                            <i class="fas fa-tasks"></i> Batch Processing
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#" data-section="history">
                            <i class="fas fa-history"></i> History
                        </a>
                    </li>
                </ul>
                <div class="navbar-text">
                    <span class="me-3">
                        <i class="fas fa-user"></i> ${sessionScope.username != null ? sessionScope.username : 'Guest'}
                    </span>
                    <button class="btn btn-sm btn-outline-light" onclick="CurationUI.showSettings()">
                        <i class="fas fa-cog"></i> Settings
                    </button>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content Container -->
    <div class="container-fluid mt-3">
        <!-- Session Info Bar -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="card bg-light">
                    <div class="card-body py-2">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <strong>Session:</strong> 
                                <span id="sessionName">${sessionScope.curationSessionName != null ? sessionScope.curationSessionName : 'New Session'}</span>
                                <span class="badge bg-success ms-2" id="sessionStatus">Active</span>
                            </div>
                            <div class="col-md-6 text-end">
                                <button class="btn btn-sm btn-primary" onclick="CurationUI.createNewSession()">
                                    <i class="fas fa-plus"></i> New Session
                                </button>
                                <button class="btn btn-sm btn-secondary" onclick="CurationUI.loadSession()">
                                    <i class="fas fa-folder-open"></i> Load Session
                                </button>
                                <button class="btn btn-sm btn-success" onclick="CurationUI.saveSession()">
                                    <i class="fas fa-save"></i> Save Session
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Entity Recognition Section -->
        <div id="recognitionSection" class="content-section">
            <div class="row">
                <!-- Text Input Panel -->
                <div class="col-lg-6">
                    <div class="card h-100">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="fas fa-file-alt"></i> Input Text
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label for="inputMethod" class="form-label">Input Method:</label>
                                <div class="btn-group" role="group">
                                    <input type="radio" class="btn-check" name="inputMethod" id="textInput" checked>
                                    <label class="btn btn-outline-primary" for="textInput">
                                        <i class="fas fa-keyboard"></i> Text Input
                                    </label>
                                    <input type="radio" class="btn-check" name="inputMethod" id="fileInput">
                                    <label class="btn btn-outline-primary" for="fileInput">
                                        <i class="fas fa-file-upload"></i> File Upload
                                    </label>
                                </div>
                            </div>

                            <!-- Text Input Area -->
                            <div id="textInputArea">
                                <div class="mb-3">
                                    <textarea class="form-control" id="inputText" rows="15" 
                                              placeholder="Enter or paste biomedical text here..."></textarea>
                                    <div class="form-text">
                                        <span id="charCount">0</span> characters | 
                                        <span id="wordCount">0</span> words
                                    </div>
                                </div>
                            </div>

                            <!-- File Upload Area -->
                            <div id="fileUploadArea" style="display: none;">
                                <div class="mb-3">
                                    <input type="file" class="form-control" id="fileUpload" 
                                           accept=".txt,.pdf,.doc,.docx">
                                    <div class="form-text">
                                        Supported formats: TXT, PDF, DOC, DOCX (Max: 50MB)
                                    </div>
                                </div>
                                <div id="filePreview" class="border rounded p-3" style="display: none;">
                                    <h6>File Preview:</h6>
                                    <pre id="fileContent" class="file-preview-content"></pre>
                                </div>
                            </div>

                            <!-- Recognition Options -->
                            <div class="recognition-options">
                                <h6>Recognition Options:</h6>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="recognizeDiseases" checked>
                                            <label class="form-check-label" for="recognizeDiseases">
                                                Diseases & Conditions
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="recognizeGenes" checked>
                                            <label class="form-check-label" for="recognizeGenes">
                                                Genes & Proteins
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="recognizeDrugs" checked>
                                            <label class="form-check-label" for="recognizeDrugs">
                                                Drugs & Chemicals
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="recognizeAnatomy" checked>
                                            <label class="form-check-label" for="recognizeAnatomy">
                                                Anatomical Terms
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="recognizePhenotypes" checked>
                                            <label class="form-check-label" for="recognizePhenotypes">
                                                Phenotypes
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="recognizeOther">
                                            <label class="form-check-label" for="recognizeOther">
                                                Other Entities
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="mt-3">
                                <button class="btn btn-primary" onclick="CurationUI.recognizeEntities()">
                                    <i class="fas fa-play"></i> Recognize Entities
                                </button>
                                <button class="btn btn-secondary" onclick="CurationUI.clearInput()">
                                    <i class="fas fa-eraser"></i> Clear
                                </button>
                                <button class="btn btn-info" onclick="CurationUI.loadExample()">
                                    <i class="fas fa-file-alt"></i> Load Example
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Results Panel -->
                <div class="col-lg-6">
                    <div class="card h-100">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="fas fa-search"></i> Recognition Results
                                <span class="badge bg-info ms-2" id="entityCount">0 entities</span>
                            </h5>
                        </div>
                        <div class="card-body">
                            <!-- Results Summary -->
                            <div id="resultsSummary" class="alert alert-info" style="display: none;">
                                <h6>Summary:</h6>
                                <div class="row">
                                    <div class="col-6">
                                        <small>Processing Time: <span id="processingTime">0</span>ms</small>
                                    </div>
                                    <div class="col-6">
                                        <small>Confidence Threshold: <span id="confidenceThreshold">0.75</span></small>
                                    </div>
                                </div>
                            </div>

                            <!-- Annotated Text Display -->
                            <div id="annotatedTextContainer" class="annotated-text-container mb-3" style="display: none;">
                                <h6>Annotated Text:</h6>
                                <div id="annotatedText" class="border rounded p-3"></div>
                            </div>

                            <!-- Entity List -->
                            <div id="entityListContainer" style="display: none;">
                                <h6>Recognized Entities:</h6>
                                <div class="entity-filters mb-2">
                                    <button class="btn btn-sm btn-outline-primary active" data-filter="all">
                                        All
                                    </button>
                                    <button class="btn btn-sm btn-outline-primary" data-filter="DISEASE">
                                        Diseases
                                    </button>
                                    <button class="btn btn-sm btn-outline-primary" data-filter="GENE">
                                        Genes
                                    </button>
                                    <button class="btn btn-sm btn-outline-primary" data-filter="DRUG">
                                        Drugs
                                    </button>
                                    <button class="btn btn-sm btn-outline-primary" data-filter="ANATOMY">
                                        Anatomy
                                    </button>
                                    <button class="btn btn-sm btn-outline-primary" data-filter="PHENOTYPE">
                                        Phenotypes
                                    </button>
                                </div>
                                <div id="entityList" class="entity-list"></div>
                            </div>

                            <!-- No Results Message -->
                            <div id="noResultsMessage" class="text-center text-muted py-5">
                                <i class="fas fa-search fa-3x mb-3"></i>
                                <p>No entities recognized yet. Enter text and click "Recognize Entities" to start.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Validation Section (Hidden by default) -->
        <div id="validationSection" class="content-section" style="display: none;">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-check-circle"></i> Entity Validation
                    </h5>
                </div>
                <div class="card-body">
                    <div id="validationContainer"></div>
                </div>
            </div>
        </div>

        <!-- Batch Processing Section (Hidden by default) -->
        <div id="batchSection" class="content-section" style="display: none;">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-tasks"></i> Batch Processing
                    </h5>
                </div>
                <div class="card-body">
                    <div id="batchContainer"></div>
                </div>
            </div>
        </div>

        <!-- History Section (Hidden by default) -->
        <div id="historySection" class="content-section" style="display: none;">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-history"></i> Session History
                    </h5>
                </div>
                <div class="card-body">
                    <div id="historyContainer"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Entity Details Modal -->
    <div class="modal fade" id="entityDetailsModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Entity Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="entityDetailsContent"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" onclick="CurationUI.validateEntity()">
                        <i class="fas fa-check"></i> Validate
                    </button>
                    <button type="button" class="btn btn-danger" onclick="CurationUI.rejectEntity()">
                        <i class="fas fa-times"></i> Reject
                    </button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Settings Modal -->
    <div class="modal fade" id="settingsModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Curation Settings</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="settingsForm">
                        <div class="mb-3">
                            <label for="confidenceSlider" class="form-label">
                                Confidence Threshold: <span id="confidenceValue">0.75</span>
                            </label>
                            <input type="range" class="form-range" id="confidenceSlider" 
                                   min="0" max="1" step="0.05" value="0.75">
                        </div>
                        <div class="mb-3">
                            <label for="batchSize" class="form-label">Batch Size:</label>
                            <input type="number" class="form-control" id="batchSize" 
                                   value="100" min="10" max="1000">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Auto-save:</label>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="autoSave" checked>
                                <label class="form-check-label" for="autoSave">
                                    Enable auto-save every 5 minutes
                                </label>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" onclick="CurationUI.saveSettings()">
                        Save Settings
                    </button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Loading Overlay -->
    <div id="loadingOverlay" class="loading-overlay" style="display: none;">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
        <div class="loading-text mt-3">Processing...</div>
    </div>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
    
    <!-- Custom JavaScript -->
    <script src="${pageContext.request.contextPath}/js/entityTagger/curation-ui.js"></script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/entity-recognition.js"></script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/entity-highlighting.js"></script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/validation-ui.js"></script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/batch-processing.js"></script>
    
    <script>
        // Initialize on page load
        $(document).ready(function() {
            CurationUI.init();
            initImageHandling();
        });
    </script>
</body>
</html>