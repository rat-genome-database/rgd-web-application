/**
 * RGD Curation Tool - Entity Validation UI Module
 * Handles entity validation workflows and user interface
 */

const ValidationUI = {
    // Configuration
    config: {
        apiBaseUrl: '/rgd/curation',
        validationStatuses: ['PENDING', 'VALIDATED', 'REJECTED', 'NEEDS_REVIEW'],
        batchSize: 50,
        autoSaveInterval: 30000, // 30 seconds
        validationColors: {
            'PENDING': '#ffc107',
            'VALIDATED': '#28a745',
            'REJECTED': '#dc3545',
            'NEEDS_REVIEW': '#6c757d'
        }
    },

    // State
    state: {
        currentEntities: [],
        validationQueue: [],
        currentEntityIndex: 0,
        validationChanges: new Map(),
        isValidating: false,
        validationStats: {},
        autoSaveTimer: null
    },

    /**
     * Initialize validation UI
     */
    init() {
        this.setupEventHandlers();
        this.loadValidationQueue();
        this.setupAutoSave();
        console.log('ValidationUI module initialized');
    },

    /**
     * Setup event handlers
     */
    setupEventHandlers() {
        // Validation action buttons
        $(document).on('click', '.validation-action', (e) => {
            const action = $(e.target).data('action');
            const entityId = $(e.target).data('entity-id');
            this.handleValidationAction(action, entityId, e.target);
        });

        // Bulk validation actions
        $(document).on('click', '.bulk-validation-action', (e) => {
            const action = $(e.target).data('action');
            this.handleBulkValidation(action);
        });

        // Entity selection in validation queue
        $(document).on('click', '.validation-entity-item', (e) => {
            const index = $(e.target).closest('.validation-entity-item').data('index');
            this.selectValidationEntity(index);
        });

        // Validation notes
        $(document).on('blur', '.validation-notes', (e) => {
            const entityId = $(e.target).data('entity-id');
            const notes = $(e.target).val();
            this.updateValidationNotes(entityId, notes);
        });

        // Quick validation keyboard shortcuts
        $(document).on('keydown', (e) => {
            if (this.state.isValidating) {
                this.handleValidationShortcuts(e);
            }
        });

        // Filter controls
        $(document).on('change', '.validation-filter', (e) => {
            this.filterValidationEntities();
        });

        // Sort controls
        $(document).on('change', '#validationSort', (e) => {
            this.sortValidationEntities($(e.target).val());
        });
    },

    /**
     * Load entities for validation
     */
    loadValidationEntities(entities) {
        this.state.currentEntities = entities || [];
        this.state.validationQueue = [...this.state.currentEntities];
        this.state.currentEntityIndex = 0;
        this.state.validationChanges.clear();

        this.renderValidationInterface();
        this.updateValidationStats();
    },

    /**
     * Render validation interface
     */
    renderValidationInterface() {
        const container = $('#validationContainer');
        
        if (this.state.validationQueue.length === 0) {
            container.html(this.renderEmptyState());
            return;
        }

        const html = `
            <div class="validation-interface">
                ${this.renderValidationHeader()}
                <div class="row">
                    <div class="col-lg-8">
                        ${this.renderValidationQueue()}
                    </div>
                    <div class="col-lg-4">
                        ${this.renderValidationDetails()}
                        ${this.renderValidationStats()}
                    </div>
                </div>
            </div>
        `;

        container.html(html);
        this.initializeValidationComponents();
    },

    /**
     * Render validation header
     */
    renderValidationHeader() {
        const stats = this.getValidationStats();
        
        return `
            <div class="validation-header mb-4">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h5 class="mb-0">Entity Validation</h5>
                        <small class="text-muted">
                            ${stats.pending} pending, ${stats.validated} validated, ${stats.rejected} rejected
                        </small>
                    </div>
                    <div class="col-md-6 text-end">
                        <div class="btn-group me-2" role="group">
                            <button class="btn btn-sm btn-success bulk-validation-action" data-action="validate-all-high">
                                <i class="fas fa-check-double"></i> Validate High Confidence
                            </button>
                            <button class="btn btn-sm btn-warning bulk-validation-action" data-action="review-all-low">
                                <i class="fas fa-eye"></i> Review Low Confidence
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                            <button class="btn btn-sm btn-outline-primary" onclick="ValidationUI.exportValidation()">
                                <i class="fas fa-download"></i> Export
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="ValidationUI.saveValidation()">
                                <i class="fas fa-save"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
                
                <div class="validation-filters mt-3">
                    <div class="row">
                        <div class="col-md-3">
                            <select class="form-select form-select-sm validation-filter" id="statusFilter">
                                <option value="">All Statuses</option>
                                <option value="PENDING">Pending</option>
                                <option value="VALIDATED">Validated</option>
                                <option value="REJECTED">Rejected</option>
                                <option value="NEEDS_REVIEW">Needs Review</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select form-select-sm validation-filter" id="typeFilter">
                                <option value="">All Types</option>
                                <option value="DISEASE">Diseases</option>
                                <option value="GENE">Genes</option>
                                <option value="DRUG">Drugs</option>
                                <option value="ANATOMY">Anatomy</option>
                                <option value="PHENOTYPE">Phenotypes</option>
                                <option value="OTHER">Other</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select form-select-sm validation-filter" id="confidenceFilter">
                                <option value="">All Confidence</option>
                                <option value="high">High (≥80%)</option>
                                <option value="medium">Medium (60-79%)</option>
                                <option value="low">Low (<60%)</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select form-select-sm" id="validationSort">
                                <option value="position">By Position</option>
                                <option value="confidence">By Confidence</option>
                                <option value="type">By Type</option>
                                <option value="status">By Status</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render validation queue
     */
    renderValidationQueue() {
        const entities = this.getFilteredEntities();
        
        let html = `
            <div class="validation-queue">
                <div class="validation-queue-header">
                    <h6>Validation Queue (${entities.length} items)</h6>
                </div>
                <div class="validation-queue-list">
        `;

        entities.forEach((entity, index) => {
            html += this.renderValidationEntityItem(entity, index);
        });

        html += `
                </div>
            </div>
        `;

        return html;
    },

    /**
     * Render validation entity item
     */
    renderValidationEntityItem(entity, index) {
        const status = entity.validationStatus || 'PENDING';
        const statusColor = this.config.validationColors[status];
        const confidenceLevel = this.getConfidenceLevel(entity.confidenceScore);
        const isSelected = index === this.state.currentEntityIndex;

        return `
            <div class="validation-entity-item ${isSelected ? 'selected' : ''}" 
                 data-index="${index}" 
                 data-entity-id="${entity.entityId || index}">
                <div class="entity-item-header">
                    <div class="entity-text">
                        <strong>${this.escapeHtml(entity.entityText)}</strong>
                        <span class="entity-type-badge badge ms-2" 
                              style="background-color: ${CurationUI.getEntityTypeColor(entity.entityType)}">
                            ${entity.entityType}
                        </span>
                    </div>
                    <div class="entity-status">
                        <span class="validation-status-badge" 
                              style="background-color: ${statusColor}; color: white;">
                            ${status}
                        </span>
                    </div>
                </div>
                
                <div class="entity-item-body">
                    <div class="entity-meta">
                        <span class="confidence-info">
                            Confidence: ${(entity.confidenceScore * 100).toFixed(1)}%
                            <div class="confidence-bar-small">
                                <div class="confidence-fill-small confidence-${confidenceLevel}" 
                                     style="width: ${entity.confidenceScore * 100}%"></div>
                            </div>
                        </span>
                        <span class="position-info">
                            Position: ${entity.startPosition}-${entity.endPosition}
                        </span>
                    </div>
                    
                    ${entity.matchedTermName ? `
                        <div class="matched-term">
                            <small class="text-muted">
                                <i class="fas fa-link"></i> ${this.escapeHtml(entity.matchedTermName)}
                            </small>
                        </div>
                    ` : ''}
                    
                    <div class="validation-actions mt-2">
                        <div class="btn-group btn-group-sm" role="group">
                            <button class="btn btn-outline-success validation-action" 
                                    data-action="validate" 
                                    data-entity-id="${entity.entityId || index}">
                                <i class="fas fa-check"></i> Validate
                            </button>
                            <button class="btn btn-outline-danger validation-action" 
                                    data-action="reject" 
                                    data-entity-id="${entity.entityId || index}">
                                <i class="fas fa-times"></i> Reject
                            </button>
                            <button class="btn btn-outline-warning validation-action" 
                                    data-action="review" 
                                    data-entity-id="${entity.entityId || index}">
                                <i class="fas fa-eye"></i> Review
                            </button>
                        </div>
                        
                        <div class="validation-notes mt-2">
                            <textarea class="form-control form-control-sm validation-notes" 
                                      data-entity-id="${entity.entityId || index}"
                                      placeholder="Add validation notes..."
                                      rows="2">${entity.validationNotes || ''}</textarea>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render validation details panel
     */
    renderValidationDetails() {
        const currentEntity = this.getCurrentEntity();
        
        if (!currentEntity) {
            return `
                <div class="validation-details">
                    <h6>Entity Details</h6>
                    <p class="text-muted">Select an entity to view details</p>
                </div>
            `;
        }

        return `
            <div class="validation-details">
                <h6>Entity Details</h6>
                <div class="entity-detail-card">
                    <div class="detail-header">
                        <h6>${this.escapeHtml(currentEntity.entityText)}</h6>
                        <span class="entity-type-badge badge" 
                              style="background-color: ${CurationUI.getEntityTypeColor(currentEntity.entityType)}">
                            ${currentEntity.entityType}
                        </span>
                    </div>
                    
                    <div class="detail-body">
                        <div class="detail-row">
                            <strong>Confidence:</strong> ${(currentEntity.confidenceScore * 100).toFixed(1)}%
                        </div>
                        <div class="detail-row">
                            <strong>Position:</strong> ${currentEntity.startPosition}-${currentEntity.endPosition}
                        </div>
                        
                        ${currentEntity.contextText ? `
                            <div class="detail-row">
                                <strong>Context:</strong>
                                <div class="context-preview">
                                    ${this.highlightEntityInContext(currentEntity.contextText, currentEntity.entityText)}
                                </div>
                            </div>
                        ` : ''}
                        
                        ${currentEntity.matchedTermName ? `
                            <div class="detail-row">
                                <strong>Matched Term:</strong> ${this.escapeHtml(currentEntity.matchedTermName)}
                            </div>
                        ` : ''}
                        
                        ${currentEntity.matchedOntologyId ? `
                            <div class="detail-row">
                                <strong>Ontology:</strong> ${currentEntity.matchedOntologyId}
                            </div>
                        ` : ''}
                    </div>
                    
                    <div class="detail-actions">
                        <div class="btn-group d-grid gap-2" role="group">
                            <button class="btn btn-success validation-action" 
                                    data-action="validate" 
                                    data-entity-id="${currentEntity.entityId || this.state.currentEntityIndex}">
                                <i class="fas fa-check"></i> Validate
                            </button>
                            <button class="btn btn-danger validation-action" 
                                    data-action="reject" 
                                    data-entity-id="${currentEntity.entityId || this.state.currentEntityIndex}">
                                <i class="fas fa-times"></i> Reject
                            </button>
                            <button class="btn btn-warning validation-action" 
                                    data-action="review" 
                                    data-entity-id="${currentEntity.entityId || this.state.currentEntityIndex}">
                                <i class="fas fa-eye"></i> Needs Review
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render validation statistics
     */
    renderValidationStats() {
        const stats = this.getValidationStats();
        
        return `
            <div class="validation-stats mt-4">
                <h6>Validation Progress</h6>
                <div class="stats-card">
                    <div class="progress mb-3">
                        <div class="progress-bar bg-success" 
                             style="width: ${stats.percentageValidated}%"
                             title="Validated: ${stats.validated}"></div>
                        <div class="progress-bar bg-danger" 
                             style="width: ${stats.percentageRejected}%"
                             title="Rejected: ${stats.rejected}"></div>
                        <div class="progress-bar bg-warning" 
                             style="width: ${stats.percentageNeedsReview}%"
                             title="Needs Review: ${stats.needsReview}"></div>
                    </div>
                    
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-number text-muted">${stats.total}</div>
                            <div class="stat-label">Total</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number text-warning">${stats.pending}</div>
                            <div class="stat-label">Pending</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number text-success">${stats.validated}</div>
                            <div class="stat-label">Validated</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number text-danger">${stats.rejected}</div>
                            <div class="stat-label">Rejected</div>
                        </div>
                    </div>
                    
                    <div class="completion-rate mt-3">
                        <strong>Completion: ${stats.percentageCompleted.toFixed(1)}%</strong>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render empty state
     */
    renderEmptyState() {
        return `
            <div class="validation-empty-state text-center py-5">
                <i class="fas fa-clipboard-check fa-3x text-muted mb-3"></i>
                <h5>No entities to validate</h5>
                <p class="text-muted">
                    Recognize entities first to start the validation process.
                </p>
                <button class="btn btn-primary" onclick="CurationUI.switchSection('recognition')">
                    <i class="fas fa-arrow-left"></i> Back to Recognition
                </button>
            </div>
        `;
    },

    /**
     * Handle validation action
     */
    handleValidationAction(action, entityId, buttonElement) {
        const entity = this.getEntityById(entityId);
        if (!entity) return;

        let newStatus;
        switch (action) {
            case 'validate':
                newStatus = 'VALIDATED';
                break;
            case 'reject':
                newStatus = 'REJECTED';
                break;
            case 'review':
                newStatus = 'NEEDS_REVIEW';
                break;
            default:
                return;
        }

        // Update entity status
        entity.validationStatus = newStatus;
        entity.validatorId = CurationUI.state.currentSession?.userId || 'unknown';
        entity.validationDate = new Date().toISOString();

        // Track changes
        this.state.validationChanges.set(entityId, {
            entityId: entityId,
            status: newStatus,
            timestamp: new Date().toISOString(),
            action: action
        });

        // Update UI
        this.updateEntityStatusInUI(entityId, newStatus);
        this.updateValidationStats();

        // Auto-advance to next entity
        if (this.shouldAutoAdvance()) {
            this.advanceToNextEntity();
        }

        // Show feedback
        this.showValidationFeedback(action, entity.entityText);
    },

    /**
     * Handle bulk validation actions
     */
    async handleBulkValidation(action) {
        let entitiesToUpdate = [];

        switch (action) {
            case 'validate-all-high':
                entitiesToUpdate = this.state.validationQueue.filter(
                    entity => entity.confidenceScore >= 0.8 && 
                    (!entity.validationStatus || entity.validationStatus === 'PENDING')
                );
                break;
            case 'review-all-low':
                entitiesToUpdate = this.state.validationQueue.filter(
                    entity => entity.confidenceScore < 0.6 && 
                    (!entity.validationStatus || entity.validationStatus === 'PENDING')
                );
                break;
            default:
                return;
        }

        if (entitiesToUpdate.length === 0) {
            CurationUI.showInfo('No entities match the criteria for bulk action');
            return;
        }

        const confirmed = confirm(
            `This will ${action.replace('-', ' ')} ${entitiesToUpdate.length} entities. Continue?`
        );

        if (!confirmed) return;

        try {
            CurationUI.showLoading(`Processing ${entitiesToUpdate.length} entities...`);

            entitiesToUpdate.forEach(entity => {
                const entityId = entity.entityId || this.getEntityIndex(entity);
                const newStatus = action.includes('validate') ? 'VALIDATED' : 'NEEDS_REVIEW';
                
                entity.validationStatus = newStatus;
                entity.validatorId = CurationUI.state.currentSession?.userId || 'unknown';
                entity.validationDate = new Date().toISOString();

                this.state.validationChanges.set(entityId, {
                    entityId: entityId,
                    status: newStatus,
                    timestamp: new Date().toISOString(),
                    action: action
                });
            });

            this.renderValidationInterface();
            CurationUI.hideLoading();
            CurationUI.showSuccess(`Updated ${entitiesToUpdate.length} entities`);

        } catch (error) {
            CurationUI.hideLoading();
            CurationUI.showError('Bulk validation failed: ' + error.message);
        }
    },

    /**
     * Update entity status in UI
     */
    updateEntityStatusInUI(entityId, newStatus) {
        const $entityItem = $(`.validation-entity-item[data-entity-id="${entityId}"]`);
        const statusColor = this.config.validationColors[newStatus];
        
        $entityItem.find('.validation-status-badge')
            .css('background-color', statusColor)
            .text(newStatus);

        $entityItem.addClass('status-updated');
        setTimeout(() => {
            $entityItem.removeClass('status-updated');
        }, 1000);
    },

    /**
     * Show validation feedback
     */
    showValidationFeedback(action, entityText) {
        const messages = {
            validate: `✓ Validated "${entityText}"`,
            reject: `✗ Rejected "${entityText}"`,
            review: `⚠ Marked "${entityText}" for review`
        };

        const types = {
            validate: 'success',
            reject: 'error',
            review: 'warning'
        };

        toastr[types[action]](messages[action]);
    },

    /**
     * Select validation entity
     */
    selectValidationEntity(index) {
        this.state.currentEntityIndex = index;
        
        // Update selection in UI
        $('.validation-entity-item').removeClass('selected');
        $(`.validation-entity-item[data-index="${index}"]`).addClass('selected');

        // Update details panel
        const detailsHTML = this.renderValidationDetails();
        $('.validation-details').replaceWith(detailsHTML);

        // Highlight in annotated text if available
        const entity = this.state.validationQueue[index];
        if (entity && typeof EntityHighlighting !== 'undefined') {
            EntityHighlighting.highlightEntity(entity);
        }
    },

    /**
     * Advance to next entity
     */
    advanceToNextEntity() {
        const nextIndex = this.findNextPendingEntity();
        if (nextIndex !== -1) {
            this.selectValidationEntity(nextIndex);
        }
    },

    /**
     * Find next pending entity
     */
    findNextPendingEntity() {
        for (let i = this.state.currentEntityIndex + 1; i < this.state.validationQueue.length; i++) {
            const entity = this.state.validationQueue[i];
            if (!entity.validationStatus || entity.validationStatus === 'PENDING') {
                return i;
            }
        }
        return -1;
    },

    /**
     * Handle validation keyboard shortcuts
     */
    handleValidationShortcuts(e) {
        if (e.target.tagName === 'TEXTAREA' || e.target.tagName === 'INPUT') {
            return; // Don't handle shortcuts when typing in inputs
        }

        const currentEntity = this.getCurrentEntity();
        if (!currentEntity) return;

        const entityId = currentEntity.entityId || this.state.currentEntityIndex;

        switch (e.key.toLowerCase()) {
            case 'v':
                e.preventDefault();
                this.handleValidationAction('validate', entityId);
                break;
            case 'r':
                e.preventDefault();
                this.handleValidationAction('reject', entityId);
                break;
            case 'n':
                e.preventDefault();
                this.handleValidationAction('review', entityId);
                break;
            case 'arrowdown':
            case 'j':
                e.preventDefault();
                this.navigateToEntity(1);
                break;
            case 'arrowup':
            case 'k':
                e.preventDefault();
                this.navigateToEntity(-1);
                break;
            case 's':
                if (e.ctrlKey || e.metaKey) {
                    e.preventDefault();
                    this.saveValidation();
                }
                break;
        }
    },

    /**
     * Navigate between entities
     */
    navigateToEntity(direction) {
        const newIndex = this.state.currentEntityIndex + direction;
        
        if (newIndex >= 0 && newIndex < this.state.validationQueue.length) {
            this.selectValidationEntity(newIndex);
        }
    },

    /**
     * Filter validation entities
     */
    filterValidationEntities() {
        const statusFilter = $('#statusFilter').val();
        const typeFilter = $('#typeFilter').val();
        const confidenceFilter = $('#confidenceFilter').val();

        $('.validation-entity-item').each((index, element) => {
            const $element = $(element);
            const entityIndex = $element.data('index');
            const entity = this.state.validationQueue[entityIndex];
            
            let show = true;

            // Status filter
            if (statusFilter && entity.validationStatus !== statusFilter) {
                show = false;
            }

            // Type filter
            if (typeFilter && entity.entityType !== typeFilter) {
                show = false;
            }

            // Confidence filter
            if (confidenceFilter) {
                const confidence = entity.confidenceScore;
                const level = this.getConfidenceLevel(confidence);
                if (confidenceFilter !== level) {
                    show = false;
                }
            }

            $element.toggle(show);
        });

        this.updateFilterStats();
    },

    /**
     * Sort validation entities
     */
    sortValidationEntities(sortBy) {
        const sortedEntities = [...this.state.validationQueue];

        switch (sortBy) {
            case 'confidence':
                sortedEntities.sort((a, b) => b.confidenceScore - a.confidenceScore);
                break;
            case 'type':
                sortedEntities.sort((a, b) => a.entityType.localeCompare(b.entityType));
                break;
            case 'status':
                sortedEntities.sort((a, b) => {
                    const statusA = a.validationStatus || 'PENDING';
                    const statusB = b.validationStatus || 'PENDING';
                    return statusA.localeCompare(statusB);
                });
                break;
            case 'position':
            default:
                sortedEntities.sort((a, b) => a.startPosition - b.startPosition);
                break;
        }

        this.state.validationQueue = sortedEntities;
        this.renderValidationInterface();
    },

    /**
     * Get filtered entities
     */
    getFilteredEntities() {
        // This method would apply current filters
        return this.state.validationQueue;
    },

    /**
     * Update filter stats
     */
    updateFilterStats() {
        const visible = $('.validation-entity-item:visible').length;
        const total = $('.validation-entity-item').length;
        
        $('.validation-queue-header h6').text(`Validation Queue (${visible}/${total} items)`);
    },

    /**
     * Get validation statistics
     */
    getValidationStats() {
        const stats = {
            total: this.state.validationQueue.length,
            validated: 0,
            rejected: 0,
            needsReview: 0,
            pending: 0
        };

        this.state.validationQueue.forEach(entity => {
            const status = entity.validationStatus || 'PENDING';
            switch (status) {
                case 'VALIDATED':
                    stats.validated++;
                    break;
                case 'REJECTED':
                    stats.rejected++;
                    break;
                case 'NEEDS_REVIEW':
                    stats.needsReview++;
                    break;
                default:
                    stats.pending++;
            }
        });

        stats.completed = stats.validated + stats.rejected + stats.needsReview;
        stats.percentageCompleted = stats.total > 0 ? (stats.completed / stats.total) * 100 : 0;
        stats.percentageValidated = stats.total > 0 ? (stats.validated / stats.total) * 100 : 0;
        stats.percentageRejected = stats.total > 0 ? (stats.rejected / stats.total) * 100 : 0;
        stats.percentageNeedsReview = stats.total > 0 ? (stats.needsReview / stats.total) * 100 : 0;

        return stats;
    },

    /**
     * Save validation results
     */
    async saveValidation() {
        if (this.state.validationChanges.size === 0) {
            CurationUI.showInfo('No validation changes to save');
            return;
        }

        try {
            CurationUI.showLoading('Saving validation results...');

            const changes = Array.from(this.state.validationChanges.values());
            
            const response = await fetch(`${this.config.apiBaseUrl}/validate/save`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    sessionId: CurationUI.state.currentSession?.sessionId,
                    validationChanges: changes
                })
            });

            if (!response.ok) {
                throw new Error(`Save failed: ${response.status}`);
            }

            this.state.validationChanges.clear();
            CurationUI.hideLoading();
            CurationUI.showSuccess('Validation results saved successfully');

        } catch (error) {
            CurationUI.hideLoading();
            CurationUI.showError('Failed to save validation: ' + error.message);
        }
    },

    /**
     * Export validation results
     */
    exportValidation() {
        const format = prompt('Export format (json, csv, tsv):', 'csv');
        if (!format) return;

        try {
            const stats = this.getValidationStats();
            const exportData = {
                metadata: {
                    exportDate: new Date().toISOString(),
                    totalEntities: stats.total,
                    validationStats: stats
                },
                entities: this.state.validationQueue
            };

            EntityRecognition.exportResults(this.state.validationQueue, format, {
                filename: `validation_results_${new Date().toISOString().split('T')[0]}`
            });

        } catch (error) {
            CurationUI.showError('Export failed: ' + error.message);
        }
    },

    /**
     * Setup auto-save functionality
     */
    setupAutoSave() {
        if (this.state.autoSaveTimer) {
            clearInterval(this.state.autoSaveTimer);
        }

        this.state.autoSaveTimer = setInterval(() => {
            if (this.state.validationChanges.size > 0) {
                this.saveValidation();
            }
        }, this.config.autoSaveInterval);
    },

    /**
     * Load validation queue from storage
     */
    loadValidationQueue() {
        try {
            const saved = localStorage.getItem('curationValidationQueue');
            if (saved) {
                const data = JSON.parse(saved);
                this.state.validationQueue = data.queue || [];
                this.state.currentEntityIndex = data.currentIndex || 0;
            }
        } catch (error) {
            console.warn('Failed to load validation queue:', error);
        }
    },

    /**
     * Save validation queue to storage
     */
    saveValidationQueue() {
        try {
            const data = {
                queue: this.state.validationQueue,
                currentIndex: this.state.currentEntityIndex,
                timestamp: new Date().toISOString()
            };
            localStorage.setItem('curationValidationQueue', JSON.stringify(data));
        } catch (error) {
            console.warn('Failed to save validation queue:', error);
        }
    },

    /**
     * Initialize validation components
     */
    initializeValidationComponents() {
        this.state.isValidating = true;
        
        // Initialize tooltips
        $('[data-bs-toggle="tooltip"]').tooltip();
        
        // Focus on first pending entity
        const firstPending = this.findNextPendingEntity();
        if (firstPending !== -1) {
            this.selectValidationEntity(firstPending);
        }
    },

    /**
     * Helper methods
     */
    getCurrentEntity() {
        return this.state.validationQueue[this.state.currentEntityIndex];
    },

    getEntityById(entityId) {
        return this.state.validationQueue.find((entity, index) => 
            (entity.entityId || index) == entityId);
    },

    getEntityIndex(entity) {
        return this.state.validationQueue.indexOf(entity);
    },

    getConfidenceLevel(score) {
        if (score >= 0.8) return 'high';
        if (score >= 0.6) return 'medium';
        return 'low';
    },

    shouldAutoAdvance() {
        return true; // Could be made configurable
    },

    highlightEntityInContext(context, entityText) {
        const regex = new RegExp(`\\b${this.escapeRegex(entityText)}\\b`, 'gi');
        return context.replace(regex, `<mark>$&</mark>`);
    },

    updateValidationNotes(entityId, notes) {
        const entity = this.getEntityById(entityId);
        if (entity) {
            entity.validationNotes = notes;
        }
    },

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },

    escapeRegex(text) {
        return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    },

    /**
     * Cleanup when leaving validation mode
     */
    cleanup() {
        this.state.isValidating = false;
        
        if (this.state.autoSaveTimer) {
            clearInterval(this.state.autoSaveTimer);
            this.state.autoSaveTimer = null;
        }

        this.saveValidationQueue();
    }
};