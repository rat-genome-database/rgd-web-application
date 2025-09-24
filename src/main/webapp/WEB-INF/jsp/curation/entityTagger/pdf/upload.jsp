<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ontomation - PDF Upload</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/css/entityTagger/upload.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <header class="mb-4">
                    <h1 class="display-4">
                        <i class="fas fa-file-pdf text-danger"></i>
                        Ontomation
                    </h1>
                    <p class="lead">Upload PDF documents for biological entity recognition and curation</p>
                </header>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-8 mx-auto">
                <!-- Upload Area -->
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h3 class="card-title mb-0">
                            <i class="fas fa-cloud-upload-alt"></i>
                            Upload PDF Document
                        </h3>
                    </div>
                    <div class="card-body">
                        <!-- File Drop Zone -->
                        <div id="dropZone" class="drop-zone">
                            <div class="drop-zone-content">
                                <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                                <h4>Drag & Drop PDF File Here</h4>
                                <p class="text-muted">or click to browse files</p>
                                <button type="button" class="btn btn-outline-primary" id="browseBtn">
                                    <i class="fas fa-folder-open"></i> Browse Files
                                </button>
                                <input type="file" id="fileInput" accept=".pdf,application/pdf" style="display: none;">
                            </div>
                        </div>

                        <!-- File Information -->
                        <div id="fileInfo" class="file-info d-none">
                            <div class="row align-items-center">
                                <div class="col-md-8">
                                    <div class="d-flex align-items-center">
                                        <i class="fas fa-file-pdf fa-2x text-danger me-3"></i>
                                        <div>
                                            <h6 class="mb-0" id="fileName">filename.pdf</h6>
                                            <small class="text-muted" id="fileSize">0 MB</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4 text-end">
                                    <button type="button" class="btn btn-success" id="uploadBtn">
                                        <i class="fas fa-upload"></i> Upload
                                    </button>
                                    <button type="button" class="btn btn-secondary" id="clearBtn">
                                        <i class="fas fa-times"></i> Clear
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Progress Bar -->
                        <div id="progressContainer" class="progress-container d-none">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span id="progressLabel">Uploading...</span>
                                <span id="progressPercent">0%</span>
                            </div>
                            <div class="progress">
                                <div id="progressBar" class="progress-bar progress-bar-striped progress-bar-animated" 
                                     role="progressbar" style="width: 0%"></div>
                            </div>
                            <div class="mt-2">
                                <button type="button" class="btn btn-sm btn-danger" id="cancelBtn">
                                    <i class="fas fa-stop"></i> Cancel
                                </button>
                            </div>
                        </div>

                        <!-- Alerts -->
                        <div id="alertContainer"></div>
                    </div>
                </div>

                <!-- Processing Results -->
                <div id="resultsCard" class="card shadow mt-4 d-none">
                    <div class="card-header bg-success text-white">
                        <h3 class="card-title mb-0">
                            <i class="fas fa-check-circle"></i>
                            Processing Complete
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Document Information</h6>
                                <table class="table table-sm">
                                    <tr>
                                        <td><strong>File Name:</strong></td>
                                        <td id="resultFileName">-</td>
                                    </tr>
                                    <tr>
                                        <td><strong>File Size:</strong></td>
                                        <td id="resultFileSize">-</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Pages:</strong></td>
                                        <td id="resultPageCount">-</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Processing Time:</strong></td>
                                        <td id="resultProcessingTime">-</td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <h6>Next Steps</h6>
                                <div class="mb-3">
                                    <label for="modelSelect" class="form-label">AI Model Selection:</label>
                                    <select class="form-select" id="modelSelect">
                                        <option value="llama3.3:70b">llama3.3:70b (Highest accuracy, ~30s per chunk)</option>
                                        <option value="deepseek-r1:32b">deepseek-r1:32b (High accuracy with reasoning, ~15s per chunk)</option>
                                        <option value="gpt-oss:20b">gpt-oss:20b (High accuracy, ~10s per chunk)</option>
                                        <option value="deepseek-r1:14b">deepseek-r1:14b (Good accuracy with reasoning, ~7s per chunk)</option>
                                        <option value="llama3.1:8b" selected>llama3.1:8b (Good accuracy, ~3s per chunk)</option>
                                    </select>
                                    <div class="form-text">Choose between accuracy and speed for entity recognition</div>
                                </div>
                                <div class="d-grid gap-2">
                                    <button type="button" class="btn btn-success" id="startCurationBtn">
                                        <i class="fas fa-play"></i> Start Entity Recognition
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary" id="uploadAnotherBtn">
                                        <i class="fas fa-plus"></i> Upload Another File
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Session Status (if active uploads exist) -->
                <c:if test="${hasActiveUploads}">
                    <div class="card mt-4">
                        <div class="card-header bg-info text-white">
                            <h5 class="card-title mb-0">
                                <i class="fas fa-clock"></i>
                                Session Status
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info">
                                <strong>Active Session:</strong> You have ${activeUploadsCount} active upload(s) in your current session.
                                These uploads will continue processing even if you refresh the page.
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary" onclick="refreshSessionStatus()">
                                <i class="fas fa-sync-alt"></i> Refresh Status
                            </button>
                        </div>
                    </div>
                </c:if>

                <!-- Instructions -->
                <div class="card mt-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-info-circle"></i>
                            Upload Guidelines
                        </h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled">
                            <li><i class="fas fa-check text-success"></i> Maximum file size: <strong>${maxFileSizeMB} MB</strong></li>
                            <li><i class="fas fa-check text-success"></i> Supported format: <strong>PDF only</strong></li>
                            <li><i class="fas fa-check text-success"></i> Best results with scientific/academic papers</li>
                            <li><i class="fas fa-check text-success"></i> Text-based PDFs work better than scanned images</li>
                            <li><i class="fas fa-info text-info"></i> Processing time varies based on document size and complexity</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script>
        // Pass server-side variables to JavaScript
        window.curationConfig = {
            sessionId: '${sessionId}',
            maxFileSize: ${maxFileSize},
            contextPath: '${pageContext.request.contextPath}',
            hasActiveUploads: ${hasActiveUploads},
            activeUploadsCount: ${activeUploadsCount}
        };
    </script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/pdf-upload.js"></script>
</body>
</html>