/**
 * RGD Curation Tool - Entity Recognition JavaScript Module
 * Handles entity recognition functionality and API interactions
 */

const EntityRecognition = {
    // Configuration
    config: {
        apiBaseUrl: '/rgd/curation',
        defaultEntityTypes: ['DISEASE', 'GENE', 'DRUG', 'ANATOMY', 'PHENOTYPE'],
        maxTextLength: 1000000, // 1MB text limit
        maxFileSize: 50 * 1024 * 1024, // 50MB file limit
        supportedFileTypes: ['.txt', '.pdf', '.doc', '.docx'],
        defaultConfidenceThreshold: 0.75,
        batchSize: 1000
    },

    // State
    state: {
        isProcessing: false,
        currentBatchId: null,
        recognitionHistory: [],
        lastRequest: null,
        lastResult: null
    },

    /**
     * Initialize entity recognition module
     */
    init() {
        this.setupValidation();
        this.loadRecognitionHistory();
        console.log('EntityRecognition module initialized');
    },

    /**
     * Setup input validation
     */
    setupValidation() {
        // Text length validation
        $('#inputText').on('input', (e) => {
            const text = e.target.value;
            if (text.length > this.config.maxTextLength) {
                CurationUI.showWarning(`Text exceeds maximum length of ${this.config.maxTextLength.toLocaleString()} characters`);
                e.target.value = text.substring(0, this.config.maxTextLength);
            }
        });

        // File size validation
        $('#fileUpload').on('change', (e) => {
            const file = e.target.files[0];
            if (file && file.size > this.config.maxFileSize) {
                CurationUI.showError(`File size exceeds ${this.config.maxFileSize / (1024 * 1024)}MB limit`);
                e.target.value = '';
            }
        });
    },

    /**
     * Recognize entities in text
     */
    async recognizeEntities(text, options = {}) {
        if (this.state.isProcessing) {
            CurationUI.showWarning('Recognition already in progress');
            return null;
        }

        // Validate input
        if (!text || text.trim().length === 0) {
            CurationUI.showError('Please provide text for entity recognition');
            return null;
        }

        if (text.length > this.config.maxTextLength) {
            CurationUI.showError(`Text exceeds maximum length of ${this.config.maxTextLength.toLocaleString()} characters`);
            return null;
        }

        const request = this.buildRecognitionRequest(text, options);

        try {
            this.state.isProcessing = true;
            this.state.lastRequest = request;

            // Show progress
            CurationUI.showLoading('Recognizing entities...');
            
            const startTime = performance.now();
            const response = await this.callRecognitionAPI(request);
            const endTime = performance.now();
            
            CurationUI.hideLoading();

            if (response.success) {
                response.processingTime = endTime - startTime;
                this.state.lastResult = response;
                this.addToHistory(request, response);
                return response;
            } else {
                throw new Error(response.message || 'Recognition failed');
            }

        } catch (error) {
            CurationUI.hideLoading();
            CurationUI.showError('Entity recognition failed: ' + error.message);
            console.error('Recognition error:', error);
            return null;
        } finally {
            this.state.isProcessing = false;
        }
    },

    /**
     * Build recognition request object
     */
    buildRecognitionRequest(text, options) {
        const request = {
            text: text,
            entityTypes: options.entityTypes || this.getSelectedEntityTypes(),
            confidenceThreshold: options.confidenceThreshold || CurationUI.config.confidenceThreshold,
            includeContext: options.includeContext !== false,
            includeOntologyMapping: options.includeOntologyMapping !== false,
            maxEntitiesPerType: options.maxEntitiesPerType || 1000,
            contextWindowSize: options.contextWindowSize || 50,
            sessionId: CurationUI.state.currentSession?.sessionId,
            batchId: this.generateBatchId(),
            metadata: {
                source: 'web-interface',
                timestamp: new Date().toISOString(),
                userAgent: navigator.userAgent,
                ...options.metadata
            }
        };

        // Add advanced options if specified
        if (options.ontologyIds) {
            request.ontologyIds = options.ontologyIds;
        }

        if (options.customRules) {
            request.customRules = options.customRules;
        }

        if (options.excludeTerms) {
            request.excludeTerms = options.excludeTerms;
        }

        return request;
    },

    /**
     * Get selected entity types from UI
     */
    getSelectedEntityTypes() {
        const types = [];
        
        $('.recognition-options input[type="checkbox"]:checked').each(function() {
            const id = this.id;
            switch (id) {
                case 'recognizeDiseases':
                    types.push('DISEASE');
                    break;
                case 'recognizeGenes':
                    types.push('GENE');
                    break;
                case 'recognizeDrugs':
                    types.push('DRUG');
                    break;
                case 'recognizeAnatomy':
                    types.push('ANATOMY');
                    break;
                case 'recognizePhenotypes':
                    types.push('PHENOTYPE');
                    break;
                case 'recognizeOther':
                    types.push('OTHER');
                    break;
            }
        });

        return types.length > 0 ? types : this.config.defaultEntityTypes;
    },

    /**
     * Call the recognition API
     */
    async callRecognitionAPI(request) {
        const response = await fetch(`${this.config.apiBaseUrl}/recognize`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(request)
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API error ${response.status}: ${errorText}`);
        }

        return await response.json();
    },

    /**
     * Process batch recognition
     */
    async processBatchRecognition(texts, options = {}) {
        if (!Array.isArray(texts) || texts.length === 0) {
            throw new Error('Invalid batch input');
        }

        const batchId = this.generateBatchId();
        const results = [];
        let processed = 0;
        const total = texts.length;

        CurationUI.showLoading(`Processing batch: 0/${total}`);

        try {
            // Process in smaller chunks to avoid overwhelming the server
            const chunkSize = options.chunkSize || 10;
            
            for (let i = 0; i < texts.length; i += chunkSize) {
                const chunk = texts.slice(i, i + chunkSize);
                const chunkPromises = chunk.map(async (text, index) => {
                    const chunkOptions = {
                        ...options,
                        metadata: {
                            ...options.metadata,
                            batchId: batchId,
                            batchIndex: i + index,
                            batchTotal: total
                        }
                    };
                    
                    try {
                        const result = await this.recognizeEntities(text, chunkOptions);
                        processed++;
                        
                        // Update progress
                        CurationUI.showLoading(`Processing batch: ${processed}/${total}`);
                        
                        return {
                            index: i + index,
                            text: text,
                            result: result,
                            success: true
                        };
                    } catch (error) {
                        processed++;
                        return {
                            index: i + index,
                            text: text,
                            error: error.message,
                            success: false
                        };
                    }
                });

                const chunkResults = await Promise.all(chunkPromises);
                results.push(...chunkResults);

                // Small delay between chunks to avoid overwhelming the server
                if (i + chunkSize < texts.length) {
                    await this.delay(100);
                }
            }

            CurationUI.hideLoading();
            
            return {
                batchId: batchId,
                total: total,
                processed: processed,
                successful: results.filter(r => r.success).length,
                failed: results.filter(r => !r.success).length,
                results: results
            };

        } catch (error) {
            CurationUI.hideLoading();
            throw error;
        }
    },

    /**
     * Recognize entities from file
     */
    async recognizeFromFile(file, options = {}) {
        try {
            // Extract text from file
            let text;
            const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
            
            if (fileExtension === '.txt') {
                text = await this.readTextFile(file);
            } else {
                text = await this.extractTextFromFile(file);
            }

            // Add file metadata
            const fileOptions = {
                ...options,
                metadata: {
                    ...options.metadata,
                    fileName: file.name,
                    fileSize: file.size,
                    fileType: file.type,
                    lastModified: file.lastModified
                }
            };

            return await this.recognizeEntities(text, fileOptions);

        } catch (error) {
            throw new Error(`Failed to process file: ${error.message}`);
        }
    },

    /**
     * Extract text from non-text files
     */
    async extractTextFromFile(file) {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch(`${this.config.apiBaseUrl}/files/extract`, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error(`File extraction failed: ${response.status}`);
        }

        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'File extraction failed');
        }

        return result.extractedText;
    },

    /**
     * Read text file content
     */
    readTextFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => resolve(e.target.result);
            reader.onerror = () => reject(new Error('Failed to read file'));
            reader.readAsText(file, 'UTF-8');
        });
    },

    /**
     * Get recognition suggestions based on text analysis
     */
    async getRecognitionSuggestions(text) {
        try {
            const response = await fetch(`${this.config.apiBaseUrl}/recognize/suggestions`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ text: text })
            });

            if (!response.ok) {
                throw new Error(`API error ${response.status}`);
            }

            return await response.json();

        } catch (error) {
            console.warn('Failed to get recognition suggestions:', error);
            return {
                suggestions: [],
                entityTypes: this.config.defaultEntityTypes,
                confidence: this.config.defaultConfidenceThreshold
            };
        }
    },

    /**
     * Validate entities against ontologies
     */
    async validateEntities(entities, options = {}) {
        try {
            const response = await fetch(`${this.config.apiBaseUrl}/validate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    entities: entities,
                    strictMode: options.strictMode || false,
                    ontologyIds: options.ontologyIds,
                    validationRules: options.validationRules
                })
            });

            if (!response.ok) {
                throw new Error(`Validation API error ${response.status}`);
            }

            return await response.json();

        } catch (error) {
            console.error('Entity validation failed:', error);
            throw error;
        }
    },

    /**
     * Get entity statistics
     */
    getEntityStatistics(entities) {
        const stats = {
            total: entities.length,
            byType: {},
            byConfidence: {
                high: 0,    // >= 0.8
                medium: 0,  // >= 0.6
                low: 0      // < 0.6
            },
            byValidation: {
                validated: 0,
                pending: 0,
                rejected: 0,
                needsReview: 0
            },
            averageConfidence: 0,
            uniqueEntities: new Set()
        };

        let totalConfidence = 0;

        entities.forEach(entity => {
            // Count by type
            stats.byType[entity.entityType] = (stats.byType[entity.entityType] || 0) + 1;

            // Count by confidence
            if (entity.confidenceScore >= 0.8) {
                stats.byConfidence.high++;
            } else if (entity.confidenceScore >= 0.6) {
                stats.byConfidence.medium++;
            } else {
                stats.byConfidence.low++;
            }

            // Count by validation status
            const validationStatus = entity.validationStatus?.toLowerCase() || 'pending';
            if (stats.byValidation.hasOwnProperty(validationStatus)) {
                stats.byValidation[validationStatus]++;
            }

            // Track unique entities
            stats.uniqueEntities.add(entity.entityText.toLowerCase());

            // Sum confidence for average
            totalConfidence += entity.confidenceScore;
        });

        stats.averageConfidence = entities.length > 0 ? totalConfidence / entities.length : 0;
        stats.uniqueCount = stats.uniqueEntities.size;

        return stats;
    },

    /**
     * Export recognition results
     */
    exportResults(entities, format = 'json', options = {}) {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = options.filename || `entities_${timestamp}`;

        let content, mimeType, extension;

        switch (format.toLowerCase()) {
            case 'json':
                content = JSON.stringify(entities, null, 2);
                mimeType = 'application/json';
                extension = 'json';
                break;

            case 'csv':
                content = this.convertToCSV(entities);
                mimeType = 'text/csv';
                extension = 'csv';
                break;

            case 'tsv':
                content = this.convertToTSV(entities);
                mimeType = 'text/tab-separated-values';
                extension = 'tsv';
                break;

            case 'txt':
                content = this.convertToText(entities);
                mimeType = 'text/plain';
                extension = 'txt';
                break;

            default:
                throw new Error('Unsupported export format: ' + format);
        }

        this.downloadFile(content, `${filename}.${extension}`, mimeType);
    },

    /**
     * Convert entities to CSV format
     */
    convertToCSV(entities) {
        const headers = [
            'Entity Text', 'Entity Type', 'Start Position', 'End Position',
            'Confidence Score', 'Matched Term', 'Ontology ID', 'Validation Status'
        ];

        const rows = entities.map(entity => [
            this.escapeCSV(entity.entityText),
            entity.entityType,
            entity.startPosition,
            entity.endPosition,
            entity.confidenceScore,
            this.escapeCSV(entity.matchedTermName || ''),
            entity.matchedOntologyId || '',
            entity.validationStatus || 'PENDING'
        ]);

        return [headers, ...rows].map(row => row.join(',')).join('\n');
    },

    /**
     * Convert entities to TSV format
     */
    convertToTSV(entities) {
        return this.convertToCSV(entities).replace(/,/g, '\t');
    },

    /**
     * Convert entities to text format
     */
    convertToText(entities) {
        return entities.map(entity => {
            return `${entity.entityText} (${entity.entityType}) - Confidence: ${(entity.confidenceScore * 100).toFixed(1)}%`;
        }).join('\n');
    },

    /**
     * Escape CSV values
     */
    escapeCSV(value) {
        if (typeof value !== 'string') return value;
        if (value.includes(',') || value.includes('"') || value.includes('\n')) {
            return '"' + value.replace(/"/g, '""') + '"';
        }
        return value;
    },

    /**
     * Download file
     */
    downloadFile(content, filename, mimeType) {
        const blob = new Blob([content], { type: mimeType });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    },

    /**
     * Add recognition to history
     */
    addToHistory(request, result) {
        const historyItem = {
            id: Date.now(),
            timestamp: new Date().toISOString(),
            request: request,
            result: result,
            entityCount: result.recognizedEntities?.length || 0,
            processingTime: result.processingTime
        };

        this.state.recognitionHistory.unshift(historyItem);
        
        // Keep only last 50 items
        if (this.state.recognitionHistory.length > 50) {
            this.state.recognitionHistory = this.state.recognitionHistory.slice(0, 50);
        }

        this.saveRecognitionHistory();
    },

    /**
     * Load recognition history from localStorage
     */
    loadRecognitionHistory() {
        try {
            const saved = localStorage.getItem('curationRecognitionHistory');
            if (saved) {
                this.state.recognitionHistory = JSON.parse(saved);
            }
        } catch (error) {
            console.warn('Failed to load recognition history:', error);
            this.state.recognitionHistory = [];
        }
    },

    /**
     * Save recognition history to localStorage
     */
    saveRecognitionHistory() {
        try {
            localStorage.setItem('curationRecognitionHistory', 
                JSON.stringify(this.state.recognitionHistory));
        } catch (error) {
            console.warn('Failed to save recognition history:', error);
        }
    },

    /**
     * Clear recognition history
     */
    clearHistory() {
        this.state.recognitionHistory = [];
        localStorage.removeItem('curationRecognitionHistory');
    },

    /**
     * Generate unique batch ID
     */
    generateBatchId() {
        return 'batch_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    },

    /**
     * Utility delay function
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    },

    /**
     * Get last recognition result
     */
    getLastResult() {
        return this.state.lastResult;
    },

    /**
     * Get recognition history
     */
    getHistory() {
        return this.state.recognitionHistory;
    },

    /**
     * Check if recognition is in progress
     */
    isProcessing() {
        return this.state.isProcessing;
    }
};

/**
 * Image handling functions for Marker-extracted PDFs
 */
function showImageModal(imgElement) {
    // Create modal if it doesn't exist
    let modal = document.getElementById('imageModal');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'imageModal';
        modal.className = 'modal fade';
        modal.innerHTML = `
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="imageModalTitle">Figure</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center">
                        <img id="modalImage" class="img-fluid" style="max-height: 70vh;" alt="Figure">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="downloadImage()">
                            <i class="fas fa-download"></i> Download
                        </button>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }
    
    // Update modal content
    const modalImage = document.getElementById('modalImage');
    const modalTitle = document.getElementById('imageModalTitle');
    
    modalImage.src = imgElement.src;
    modalImage.alt = imgElement.alt;
    modalTitle.textContent = imgElement.alt || 'Figure';
    
    // Store current image for download
    window.currentModalImage = imgElement;
    
    // Show modal
    const bsModal = new bootstrap.Modal(modal);
    bsModal.show();
}

/**
 * Download current modal image
 */
function downloadImage() {
    if (window.currentModalImage) {
        const img = window.currentModalImage;
        const link = document.createElement('a');
        link.href = img.src;
        link.download = img.alt.replace(/[^a-zA-Z0-9]/g, '_') + '.png';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}

/**
 * Initialize image handling
 */
function initImageHandling() {
    // Add CSS for figure containers if not already present
    if (!document.getElementById('figureStyles')) {
        const style = document.createElement('style');
        style.id = 'figureStyles';
        style.textContent = `
            .figure-container {
                margin: 20px 0;
                padding: 10px;
                border: 1px solid #e0e0e0;
                border-radius: 8px;
                background: #fafafa;
            }
            
            .figure-image {
                cursor: pointer;
                transition: transform 0.2s ease;
            }
            
            .figure-image:hover {
                transform: scale(1.02);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }
            
            .figure-caption {
                font-style: italic;
                padding: 8px 0;
                border-top: 1px solid #e0e0e0;
                margin-top: 10px;
            }
            
            .figure-placeholder {
                background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
                border: 2px dashed #ccc;
                min-height: 120px;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
            }
            
            .placeholder-icon {
                opacity: 0.6;
            }
            
            .placeholder-text {
                text-align: center;
            }
            
            .annotated-text-container {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
            }
            
            .annotated-text-container h1,
            .annotated-text-container h2,
            .annotated-text-container h3 {
                color: #2c3e50;
                margin-top: 20px;
                margin-bottom: 10px;
            }
            
            .annotated-text-container p {
                margin-bottom: 15px;
                text-align: justify;
            }
        `;
        document.head.appendChild(style);
    }
}