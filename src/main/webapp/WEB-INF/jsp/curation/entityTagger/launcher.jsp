<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ontomation Launcher</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f9fa;
            min-height: 100vh;
            padding: 20px;
        }
        .launcher-section {
            max-width: 400px;
        }
        .entity-list-section {
            flex: 1;
            max-width: 600px;
        }
        .entity-list {
            max-height: 500px;
            overflow-y: auto;
        }
        .entity-card {
            border-left: 4px solid #6c757d;
            margin-bottom: 10px;
            transition: all 0.2s;
        }
        .entity-card:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }
        .entity-card.type-DISEASE { border-left-color: #f44336; }
        .entity-card.type-GENE { border-left-color: #4caf50; }
        .entity-card.type-DRUG { border-left-color: #2196f3; }
        .entity-card.type-ANATOMY { border-left-color: #ff9800; }
        .entity-card.type-PHENOTYPE { border-left-color: #9c27b0; }
        .entity-type-badge {
            font-size: 0.7rem;
            padding: 2px 6px;
        }
        .entity-type-badge.type-DISEASE { background-color: #f44336; }
        .entity-type-badge.type-GENE { background-color: #4caf50; }
        .entity-type-badge.type-DRUG { background-color: #2196f3; }
        .entity-type-badge.type-ANATOMY { background-color: #ff9800; }
        .entity-type-badge.type-PHENOTYPE { background-color: #9c27b0; }
        .confidence-bar {
            height: 4px;
            background-color: #e9ecef;
            border-radius: 2px;
            width: 60px;
        }
        .confidence-fill {
            height: 100%;
            border-radius: 2px;
            background-color: #28a745;
        }
        .remove-entity {
            cursor: pointer;
            opacity: 0.5;
        }
        .remove-entity:hover {
            opacity: 1;
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row justify-content-center">
            <!-- Launcher Section -->
            <div class="col-auto launcher-section">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">
                            <i class="fas fa-rocket"></i> Ontomation Launcher
                        </h4>
                    </div>
                    <div class="card-body text-center">
                        <p class="lead">Launch the Entity Tagger tool</p>

                        <button id="launchBtn" class="btn btn-lg btn-success mb-3" onclick="launchOntomation()">
                            <i class="fas fa-external-link-alt"></i> Open Ontomation
                        </button>

                        <div id="connectionStatus" class="alert alert-secondary" role="alert">
                            <i class="fas fa-circle text-secondary"></i> Not connected
                        </div>

                        <p class="text-muted small mt-3">
                            <i class="fas fa-info-circle"></i> Click the <i class="fas fa-paper-plane text-primary"></i> icon on entities in Ontomation to add them to the list.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Entity List Section -->
            <div class="col-auto entity-list-section">
                <div class="card shadow">
                    <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <i class="fas fa-list"></i> Selected Entities
                            <span class="badge bg-light text-dark ms-2" id="entityCount">0</span>
                        </h5>
                        <button class="btn btn-sm btn-outline-light" onclick="clearAllEntities()" title="Clear all">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                    <div class="card-body">
                        <div id="entityList" class="entity-list">
                            <div id="emptyMessage" class="text-center text-muted py-4">
                                <i class="fas fa-inbox fa-3x mb-3"></i>
                                <p>No entities selected yet.<br>Use Ontomation to send entities here.</p>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer" id="exportFooter" style="display: none;">
                        <button class="btn btn-primary btn-sm" onclick="exportEntities()">
                            <i class="fas fa-download"></i> Export List
                        </button>
                        <button class="btn btn-secondary btn-sm" onclick="copyToClipboard()">
                            <i class="fas fa-copy"></i> Copy to Clipboard
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let ontomationWindow = null;
        let selectedEntities = [];
        const contextPath = '${pageContext.request.contextPath}';

        function launchOntomation() {
            // Open Ontomation in a new tab
            const url = contextPath + '/curation/pdf/upload.html';
            ontomationWindow = window.open(url, '_blank');

            if (ontomationWindow) {
                updateStatus('connecting', 'Connecting...');

                // Check if window is still open
                const checkWindow = setInterval(function() {
                    if (ontomationWindow.closed) {
                        clearInterval(checkWindow);
                        updateStatus('disconnected', 'Window closed');
                        ontomationWindow = null;
                    }
                }, 1000);
            } else {
                updateStatus('error', 'Failed to open window (popup blocked?)');
            }
        }

        function updateStatus(status, message) {
            const statusEl = document.getElementById('connectionStatus');
            switch(status) {
                case 'connected':
                    statusEl.className = 'alert alert-success';
                    statusEl.innerHTML = '<i class="fas fa-circle text-success"></i> ' + message;
                    break;
                case 'connecting':
                    statusEl.className = 'alert alert-warning';
                    statusEl.innerHTML = '<i class="fas fa-spinner fa-spin"></i> ' + message;
                    break;
                case 'disconnected':
                    statusEl.className = 'alert alert-secondary';
                    statusEl.innerHTML = '<i class="fas fa-circle text-secondary"></i> ' + message;
                    break;
                case 'error':
                    statusEl.className = 'alert alert-danger';
                    statusEl.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + message;
                    break;
            }
        }

        // Listen for messages from Ontomation window
        window.addEventListener('message', function(event) {
            if (event.data && event.data.type === 'ontomation-message') {
                updateStatus('connected', 'Connected to Ontomation');

                // Try to parse entity data
                try {
                    const data = JSON.parse(event.data.data);
                    if (data.action === 'addEntity' && data.entity) {
                        addEntityToList(data.entity);
                    }
                } catch (e) {
                    // Not JSON, just a regular message
                    console.log('Received message:', event.data.data);
                }
            } else if (event.data && event.data.type === 'ontomation-ready') {
                updateStatus('connected', 'Ontomation ready');
            }
        });

        function addEntityToList(entity) {
            // Check for duplicates
            const isDuplicate = selectedEntities.some(e =>
                e.text === entity.text &&
                e.type === entity.type &&
                e.startPosition === entity.startPosition
            );

            if (isDuplicate) {
                console.log('Entity already in list:', entity.text);
                return;
            }

            selectedEntities.push(entity);
            renderEntityList();
        }

        function removeEntity(index) {
            selectedEntities.splice(index, 1);
            renderEntityList();
        }

        function clearAllEntities() {
            if (selectedEntities.length > 0 && confirm('Clear all entities from the list?')) {
                selectedEntities = [];
                renderEntityList();
            }
        }

        function renderEntityList() {
            const container = document.getElementById('entityList');
            const emptyMessage = document.getElementById('emptyMessage');
            const exportFooter = document.getElementById('exportFooter');
            const countBadge = document.getElementById('entityCount');

            countBadge.textContent = selectedEntities.length;

            if (selectedEntities.length === 0) {
                container.innerHTML = '';
                container.appendChild(emptyMessage.cloneNode(true));
                emptyMessage.style.display = 'block';
                exportFooter.style.display = 'none';
                return;
            }

            exportFooter.style.display = 'block';

            let html = '';
            selectedEntities.forEach(function(entity, index) {
                const confidencePercent = (entity.confidence * 100).toFixed(1);
                let cardHtml = '<div class="card entity-card type-' + entity.type + '">';
                cardHtml += '<div class="card-body py-2 px-3">';
                cardHtml += '<div class="d-flex justify-content-between align-items-start">';
                cardHtml += '<div class="flex-grow-1">';
                cardHtml += '<div class="fw-bold">' + escapeHtml(entity.text) + '</div>';
                cardHtml += '<div class="d-flex align-items-center gap-2 mt-1">';
                cardHtml += '<span class="badge entity-type-badge type-' + entity.type + ' text-white">' + entity.type + '</span>';
                cardHtml += '<span class="text-muted small">' + confidencePercent + '%</span>';
                cardHtml += '<div class="confidence-bar"><div class="confidence-fill" style="width: ' + confidencePercent + '%"></div></div>';
                cardHtml += '</div>';
                if (entity.matchedTermName) {
                    cardHtml += '<div class="text-muted small mt-1"><i class="fas fa-link"></i> ' + escapeHtml(entity.matchedTermName) + '</div>';
                }
                cardHtml += '</div>';
                cardHtml += '<span class="remove-entity" onclick="removeEntity(' + index + ')" title="Remove"><i class="fas fa-times"></i></span>';
                cardHtml += '</div></div></div>';
                html += cardHtml;
            });

            container.innerHTML = html;
        }

        function exportEntities() {
            if (selectedEntities.length === 0) return;

            const data = selectedEntities.map(e => ({
                text: e.text,
                type: e.type,
                confidence: e.confidence,
                matchedTerm: e.matchedTermName || '',
                ontologyId: e.matchedOntologyId || ''
            }));

            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'selected-entities.json';
            a.click();
            URL.revokeObjectURL(url);
        }

        function copyToClipboard() {
            if (selectedEntities.length === 0) return;

            const text = selectedEntities.map(e => `${e.text} (${e.type})`).join('\n');
            navigator.clipboard.writeText(text).then(() => {
                alert('Entities copied to clipboard!');
            });
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>
