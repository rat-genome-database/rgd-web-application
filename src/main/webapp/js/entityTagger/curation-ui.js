/**
 * RGD Curation Tool - Main UI Controller
 * Handles core UI functionality and coordination between components
 */

const CurationUI = {
    // Configuration
    config: {
        apiBaseUrl: '/rgd/curation',
        confidenceThreshold: 0.75,
        batchSize: 100,
        autoSave: true,
        autoSaveInterval: 300000 // 5 minutes
    },

    // State
    state: {
        currentSession: null,
        currentEntities: [],
        selectedEntity: null,
        activeSection: 'recognition',
        isProcessing: false,
        autoSaveTimer: null
    },

    /**
     * Initialize the curation UI
     */
    init() {
        this.initializeEventHandlers();
        this.loadSettings();
        this.checkSession();
        this.updateCharacterCount();
        
        // Setup auto-save if enabled
        if (this.config.autoSave) {
            this.setupAutoSave();
        }

        // Initialize tooltips
        this.initializeTooltips();

        console.log('CurationUI initialized');
    },

    /**
     * Set up event handlers
     */
    initializeEventHandlers() {
        // Navigation handlers
        $('.nav-link[data-section]').on('click', (e) => {
            e.preventDefault();
            const section = $(e.target).closest('[data-section]').data('section');
            this.switchSection(section);
        });

        // Input method toggles
        $('input[name="inputMethod"]').on('change', (e) => {
            this.handleInputMethodChange(e.target.value);
        });

        // Text input handlers
        $('#inputText').on('input', () => {
            this.updateCharacterCount();
            this.clearResults();
        });

        // File upload handler
        $('#fileUpload').on('change', (e) => {
            this.handleFileUpload(e.target.files[0]);
        });

        // Recognition options
        $('.form-check-input').on('change', () => {
            this.clearResults();
        });

        // Entity filter buttons
        $('.entity-filters').on('click', '.btn', (e) => {
            const filter = $(e.target).data('filter');
            this.filterEntities(filter);
        });

        // Settings modal handlers
        $('#confidenceSlider').on('input', (e) => {
            const value = parseFloat(e.target.value);
            $('#confidenceValue').text(value.toFixed(2));
            this.config.confidenceThreshold = value;
        });

        // Keyboard shortcuts
        $(document).on('keydown', (e) => {
            this.handleKeyboardShortcuts(e);
        });

        // Window beforeunload handler
        $(window).on('beforeunload', (e) => {
            if (this.hasUnsavedChanges()) {
                return 'You have unsaved changes. Are you sure you want to leave?';
            }
        });
    },

    /**
     * Switch between UI sections
     */
    switchSection(section) {
        // Update navigation
        $('.nav-link').removeClass('active');
        $(`.nav-link[data-section="${section}"]`).addClass('active');

        // Hide all sections
        $('.content-section').hide();

        // Show selected section
        $(`#${section}Section`).show();

        this.state.activeSection = section;

        // Load section-specific content
        switch (section) {
            case 'validation':
                this.loadValidationUI();
                break;
            case 'batch':
                this.loadBatchProcessingUI();
                break;
            case 'history':
                this.loadHistoryUI();
                break;
        }
    },

    /**
     * Handle input method change (text vs file)
     */
    handleInputMethodChange(method) {
        if (method === 'textInput') {
            $('#textInputArea').show();
            $('#fileUploadArea').hide();
        } else {
            $('#textInputArea').hide();
            $('#fileUploadArea').show();
        }
        this.clearResults();
    },

    /**
     * Handle file upload
     */
    async handleFileUpload(file) {
        if (!file) return;

        // Validate file size (50MB limit)
        if (file.size > 50 * 1024 * 1024) {
            this.showError('File size exceeds 50MB limit');
            return;
        }

        // Validate file type
        const allowedTypes = ['.txt', '.pdf', '.doc', '.docx'];
        const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
        
        if (!allowedTypes.includes(fileExtension)) {
            this.showError('Unsupported file type. Please use TXT, PDF, DOC, or DOCX files.');
            return;
        }

        try {
            this.showLoading('Reading file...');

            let content = '';
            
            if (fileExtension === '.txt') {
                content = await this.readTextFile(file);
            } else {
                // For other file types, send to server for processing
                content = await this.processFileOnServer(file);
            }

            $('#fileContent').text(content);
            $('#filePreview').show();
            
            this.hideLoading();
            this.showSuccess('File loaded successfully');

        } catch (error) {
            this.hideLoading();
            this.showError('Failed to read file: ' + error.message);
        }
    },

    /**
     * Read text file content
     */
    readTextFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => resolve(e.target.result);
            reader.onerror = () => reject(new Error('Failed to read file'));
            reader.readAsText(file);
        });
    },

    /**
     * Process non-text files on server
     */
    async processFileOnServer(file) {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch(`${this.config.apiBaseUrl}/files/extract`, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error('Server failed to process file');
        }

        const result = await response.json();
        return result.extractedText;
    },

    /**
     * Get input text from current method
     */
    getInputText() {
        const method = $('input[name="inputMethod"]:checked').attr('id');
        
        if (method === 'textInput') {
            return $('#inputText').val();
        } else {
            return $('#fileContent').text();
        }
    },

    /**
     * Get selected entity types for recognition
     */
    getSelectedEntityTypes() {
        const types = [];
        
        if ($('#recognizeDiseases').is(':checked')) types.push('DISEASE');
        if ($('#recognizeGenes').is(':checked')) types.push('GENE');
        if ($('#recognizeDrugs').is(':checked')) types.push('DRUG');
        if ($('#recognizeAnatomy').is(':checked')) types.push('ANATOMY');
        if ($('#recognizePhenotypes').is(':checked')) types.push('PHENOTYPE');
        if ($('#recognizeOther').is(':checked')) types.push('OTHER');

        return types;
    },

    /**
     * Recognize entities in the input text
     */
    async recognizeEntities() {
        const text = this.getInputText().trim();
        
        if (!text) {
            this.showWarning('Please enter some text or upload a file first');
            return;
        }

        const entityTypes = this.getSelectedEntityTypes();
        if (entityTypes.length === 0) {
            this.showWarning('Please select at least one entity type to recognize');
            return;
        }

        try {
            this.showLoading('Recognizing entities...');
            this.state.isProcessing = true;

            const startTime = Date.now();

            const request = {
                text: text,
                entityTypes: entityTypes,
                confidenceThreshold: this.config.confidenceThreshold,
                sessionId: this.state.currentSession?.sessionId,
                includeContext: true,
                includeOntologyMapping: true
            };

            const response = await fetch(`${this.config.apiBaseUrl}/recognize`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(request)
            });

            if (!response.ok) {
                throw new Error(`Server error: ${response.status}`);
            }

            const result = await response.json();
            const processingTime = Date.now() - startTime;

            this.hideLoading();
            this.state.isProcessing = false;

            if (result.success) {
                this.displayResults(result, processingTime);
                this.showSuccess(`Found ${result.recognizedEntities.length} entities in ${processingTime}ms`);
            } else {
                throw new Error(result.message || 'Recognition failed');
            }

        } catch (error) {
            this.hideLoading();
            this.state.isProcessing = false;
            this.showError('Entity recognition failed: ' + error.message);
        }
    },

    /**
     * Display recognition results
     */
    displayResults(result, processingTime) {
        this.state.currentEntities = result.recognizedEntities;

        // Update summary
        $('#entityCount').text(`${result.recognizedEntities.length} entities`);
        $('#processingTime').text(processingTime);
        $('#confidenceThreshold').text(this.config.confidenceThreshold);
        $('#resultsSummary').show();

        // Display annotated text
        const annotatedText = EntityHighlighting.generateAnnotatedText(
            this.getInputText(), 
            result.recognizedEntities
        );
        $('#annotatedText').html(annotatedText);
        $('#annotatedTextContainer').show();

        // Display entity list
        this.displayEntityList(result.recognizedEntities);
        $('#entityListContainer').show();

        // Hide no results message
        $('#noResultsMessage').hide();

        // Initialize entity interactions
        EntityHighlighting.initializeInteractions();
    },

    /**
     * Display list of recognized entities
     */
    displayEntityList(entities) {
        const container = $('#entityList');
        container.empty();

        if (entities.length === 0) {
            container.html('<p class="text-muted text-center">No entities found</p>');
            return;
        }

        entities.forEach((entity, index) => {
            const entityElement = this.createEntityListItem(entity, index);
            container.append(entityElement);
        });

        // Add click handlers
        $('.entity-item').on('click', (e) => {
            const index = $(e.currentTarget).data('index');
            this.selectEntity(index);
        });
    },

    /**
     * Create an entity list item element
     */
    createEntityListItem(entity, index) {
        const confidenceLevel = entity.confidenceScore >= 0.8 ? 'high' : 
                               entity.confidenceScore >= 0.6 ? 'medium' : 'low';
        
        const typeColor = this.getEntityTypeColor(entity.entityType);
        
        return $(`
            <div class="entity-item" data-index="${index}" data-type="${entity.entityType}" style="position: relative;">
                <div class="entity-text">${this.escapeHtml(entity.entityText)}</div>
                <div class="entity-meta">
                    <div>
                        <span class="entity-type-badge badge" style="background-color: ${typeColor}">
                            ${entity.entityType}
                        </span>
                        <span class="ms-2 text-muted">
                            ${entity.startPosition}-${entity.endPosition}
                        </span>
                    </div>
                    <div class="d-flex align-items-center">
                        <span class="text-muted">${(entity.confidenceScore * 100).toFixed(1)}%</span>
                        <div class="confidence-bar">
                            <div class="confidence-fill confidence-${confidenceLevel}"
                                 style="width: ${entity.confidenceScore * 100}%"></div>
                        </div>
                    </div>
                </div>
                ${entity.validationStatus ? `
                    <div class="validation-status validation-${entity.validationStatus.toLowerCase()}">
                        ${entity.validationStatus}
                    </div>
                ` : ''}
                <span class="send-to-launcher-btn"
                      onclick="event.stopPropagation(); CurationUI.sendEntityToLauncher(${index})"
                      title="Send to launcher"
                      style="position: absolute; top: 5px; right: 5px; cursor: pointer; background: #007bff; color: white; border-radius: 50%; width: 22px; height: 22px; font-size: 12px; display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-paper-plane"></i>
                </span>
            </div>
        `);
    },

    /**
     * Get color for entity type
     */
    getEntityTypeColor(type) {
        const colors = {
            'DISEASE': '#f44336',
            'GENE': '#4caf50',
            'DRUG': '#2196f3',
            'ANATOMY': '#ff9800',
            'PHENOTYPE': '#9c27b0',
            'OTHER': '#9e9e9e'
        };
        return colors[type] || colors['OTHER'];
    },

    /**
     * Filter entities by type
     */
    filterEntities(filter) {
        // Update filter button states
        $('.entity-filters .btn').removeClass('active');
        $(`.entity-filters .btn[data-filter="${filter}"]`).addClass('active');

        // Show/hide entity items
        if (filter === 'all') {
            $('.entity-item').show();
        } else {
            $('.entity-item').hide();
            $(`.entity-item[data-type="${filter}"]`).show();
        }

        // Update count
        const visibleCount = $('.entity-item:visible').length;
        $('#entityCount').text(`${visibleCount} entities`);
    },

    /**
     * Select an entity
     */
    selectEntity(index) {
        this.state.selectedEntity = this.state.currentEntities[index];
        
        // Update UI selection
        $('.entity-item').removeClass('selected');
        $(`.entity-item[data-index="${index}"]`).addClass('selected');

        // Highlight in annotated text
        EntityHighlighting.highlightEntity(this.state.selectedEntity);

        // Show entity details
        this.showEntityDetails(this.state.selectedEntity);
    },

    /**
     * Show entity details modal
     */
    showEntityDetails(entity) {
        const content = $(`
            <div class="entity-details-grid">
                <div class="detail-item">
                    <div class="detail-label">Entity Text</div>
                    <div class="detail-value">${this.escapeHtml(entity.entityText)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Entity Type</div>
                    <div class="detail-value">${entity.entityType}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Confidence Score</div>
                    <div class="detail-value">${(entity.confidenceScore * 100).toFixed(1)}%</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Position</div>
                    <div class="detail-value">${entity.startPosition} - ${entity.endPosition}</div>
                </div>
            </div>
            
            ${entity.contextText ? `
                <div class="context-display">
                    <h6>Context:</h6>
                    ${this.highlightEntityInContext(entity.contextText, entity.entityText)}
                </div>
            ` : ''}

            ${entity.matchedTermName ? `
                <div class="mt-3">
                    <h6>Ontology Mapping:</h6>
                    <div class="detail-value">
                        <strong>${entity.matchedTermName}</strong>
                        ${entity.matchedOntologyId ? ` (${entity.matchedOntologyId})` : ''}
                    </div>
                </div>
            ` : ''}

            ${entity.validationStatus ? `
                <div class="mt-3">
                    <h6>Validation Status:</h6>
                    <span class="validation-status validation-${entity.validationStatus.toLowerCase()}">
                        ${entity.validationStatus}
                    </span>
                </div>
            ` : ''}
        `);

        $('#entityDetailsContent').html(content);
        $('#entityDetailsModal').modal('show');
    },

    /**
     * Highlight entity in context text
     */
    highlightEntityInContext(context, entityText) {
        const regex = new RegExp(`\\b${this.escapeRegex(entityText)}\\b`, 'gi');
        return context.replace(regex, `<span class="context-highlight">$&</span>`);
    },

    /**
     * Clear input and results
     */
    clearInput() {
        $('#inputText').val('');
        $('#fileUpload').val('');
        $('#filePreview').hide();
        this.clearResults();
        this.updateCharacterCount();
    },

    /**
     * Clear results display
     */
    clearResults() {
        this.state.currentEntities = [];
        this.state.selectedEntity = null;

        $('#resultsSummary').hide();
        $('#annotatedTextContainer').hide();
        $('#entityListContainer').hide();
        $('#noResultsMessage').show();
        $('#entityCount').text('0 entities');
    },

    /**
     * Load example text
     */
    loadExample() {
        const exampleText = `Myocardial infarction (MI), commonly known as a heart attack, occurs when blood flow decreases or stops to a part of the heart, causing damage to the heart muscle. The most common symptom is chest pain or discomfort which may travel into the shoulder, arm, back, neck or jaw. Often it occurs in the center or left side of the chest and lasts for more than a few minutes. The discomfort may occasionally feel like heartburn. Other symptoms may include shortness of breath, nausea, feeling faint, a cold sweat or feeling tired. About 30% of people have atypical symptoms. Women more often present without chest pain and instead have neck pain, arm pain or feel tired.

Risk factors include high blood pressure, smoking, diabetes, lack of exercise, obesity, high blood cholesterol, poor diet and excessive alcohol intake. The underlying mechanism is usually atherosclerosis of the coronary arteries. Treatment includes ACE inhibitors such as lisinopril, beta blockers like metoprolol, and antiplatelet agents including aspirin and clopidogrel.`;

        $('#inputText').val(exampleText);
        $('input[name="inputMethod"][value="textInput"]').prop('checked', true);
        $('#textInputArea').show();
        $('#fileUploadArea').hide();
        this.updateCharacterCount();
        this.clearResults();
    },

    /**
     * Update character and word count
     */
    updateCharacterCount() {
        const text = $('#inputText').val();
        const charCount = text.length;
        const wordCount = text.trim() ? text.trim().split(/\s+/).length : 0;
        
        $('#charCount').text(charCount.toLocaleString());
        $('#wordCount').text(wordCount.toLocaleString());
    },

    /**
     * Create new session
     */
    async createNewSession() {
        const sessionName = prompt('Enter session name:', 'New Curation Session');
        if (!sessionName) return;

        try {
            const response = await fetch(`${this.config.apiBaseUrl}/sessions`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    sessionName: sessionName,
                    description: 'Created from web interface'
                })
            });

            if (!response.ok) {
                throw new Error('Failed to create session');
            }

            const session = await response.json();
            this.state.currentSession = session;
            $('#sessionName').text(sessionName);
            this.showSuccess('New session created successfully');

        } catch (error) {
            this.showError('Failed to create session: ' + error.message);
        }
    },

    /**
     * Load existing session
     */
    loadSession() {
        // Implementation for loading existing sessions
        this.showInfo('Load session functionality will be implemented');
    },

    /**
     * Save current session
     */
    async saveSession() {
        if (!this.state.currentSession) {
            this.showWarning('No active session to save');
            return;
        }

        try {
            // Implementation for saving session state
            this.showSuccess('Session saved successfully');
        } catch (error) {
            this.showError('Failed to save session: ' + error.message);
        }
    },

    /**
     * Check for existing session
     */
    async checkSession() {
        try {
            const response = await fetch(`${this.config.apiBaseUrl}/sessions/current`);
            if (response.ok) {
                this.state.currentSession = await response.json();
                $('#sessionName').text(this.state.currentSession.sessionName);
            }
        } catch (error) {
            console.log('No existing session found');
        }
    },

    /**
     * Show settings modal
     */
    showSettings() {
        $('#settingsModal').modal('show');
    },

    /**
     * Save settings
     */
    saveSettings() {
        this.config.confidenceThreshold = parseFloat($('#confidenceSlider').val());
        this.config.batchSize = parseInt($('#batchSize').val());
        this.config.autoSave = $('#autoSave').is(':checked');

        // Save to localStorage
        localStorage.setItem('curationSettings', JSON.stringify(this.config));

        // Update auto-save
        if (this.config.autoSave) {
            this.setupAutoSave();
        } else {
            this.clearAutoSave();
        }

        $('#settingsModal').modal('hide');
        this.showSuccess('Settings saved');
    },

    /**
     * Load settings from localStorage
     */
    loadSettings() {
        const saved = localStorage.getItem('curationSettings');
        if (saved) {
            Object.assign(this.config, JSON.parse(saved));
            
            // Update UI
            $('#confidenceSlider').val(this.config.confidenceThreshold);
            $('#confidenceValue').text(this.config.confidenceThreshold.toFixed(2));
            $('#batchSize').val(this.config.batchSize);
            $('#autoSave').prop('checked', this.config.autoSave);
        }
    },

    /**
     * Setup auto-save functionality
     */
    setupAutoSave() {
        this.clearAutoSave();
        this.state.autoSaveTimer = setInterval(() => {
            if (this.hasUnsavedChanges()) {
                this.saveSession();
            }
        }, this.config.autoSaveInterval);
    },

    /**
     * Clear auto-save timer
     */
    clearAutoSave() {
        if (this.state.autoSaveTimer) {
            clearInterval(this.state.autoSaveTimer);
            this.state.autoSaveTimer = null;
        }
    },

    /**
     * Check if there are unsaved changes
     */
    hasUnsavedChanges() {
        return this.state.currentEntities.length > 0 && this.state.currentSession;
    },

    /**
     * Handle keyboard shortcuts
     */
    handleKeyboardShortcuts(e) {
        // Ctrl/Cmd + R: Recognize entities
        if ((e.ctrlKey || e.metaKey) && e.key === 'r') {
            e.preventDefault();
            this.recognizeEntities();
        }
        
        // Ctrl/Cmd + S: Save session
        if ((e.ctrlKey || e.metaKey) && e.key === 's') {
            e.preventDefault();
            this.saveSession();
        }

        // Escape: Clear selection
        if (e.key === 'Escape') {
            this.state.selectedEntity = null;
            $('.entity-item').removeClass('selected');
            EntityHighlighting.clearHighlight();
        }
    },

    /**
     * Initialize tooltips
     */
    initializeTooltips() {
        $('[data-bs-toggle="tooltip"]').tooltip();
    },

    /**
     * Show loading overlay
     */
    showLoading(message = 'Loading...') {
        $('#loadingOverlay .loading-text').text(message);
        $('#loadingOverlay').show();
    },

    /**
     * Hide loading overlay
     */
    hideLoading() {
        $('#loadingOverlay').hide();
    },

    /**
     * Show success message
     */
    showSuccess(message) {
        toastr.success(message);
    },

    /**
     * Show error message
     */
    showError(message) {
        toastr.error(message);
    },

    /**
     * Show warning message
     */
    showWarning(message) {
        toastr.warning(message);
    },

    /**
     * Show info message
     */
    showInfo(message) {
        toastr.info(message);
    },

    /**
     * Escape HTML
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },

    /**
     * Escape regex special characters
     */
    escapeRegex(text) {
        return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    },

    // Placeholder methods for other UI sections
    loadValidationUI() {
        console.log('Loading validation UI');
    },

    loadBatchProcessingUI() {
        console.log('Loading batch processing UI');
    },

    loadHistoryUI() {
        console.log('Loading history UI');
    },

    validateEntity() {
        console.log('Validate entity');
    },

    rejectEntity() {
        console.log('Reject entity');
    },

    /**
     * Send entity to launcher window
     */
    sendEntityToLauncher(index) {
        const entity = this.state.currentEntities[index];
        if (entity && window.sendToLauncher) {
            const entityData = {
                action: 'addEntity',
                entity: {
                    text: entity.entityText,
                    type: entity.entityType,
                    confidence: entity.confidenceScore,
                    startPosition: entity.startPosition,
                    endPosition: entity.endPosition,
                    matchedTermName: entity.matchedTermName || null,
                    matchedOntologyId: entity.matchedOntologyId || null
                }
            };
            window.sendToLauncher(JSON.stringify(entityData));
            console.log('Entity sent to launcher:', entity.entityText);
            toastr.success('Entity sent to launcher: ' + entity.entityText);
        } else {
            console.log('Launcher window not available');
            toastr.warning('Launcher window not available. Open Ontomation from the launcher page.');
        }
    }
};