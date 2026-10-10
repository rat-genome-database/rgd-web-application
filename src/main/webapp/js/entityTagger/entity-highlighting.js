/**
 * RGD Curation Tool - Entity Highlighting Module
 * Handles interactive highlighting and visualization of recognized entities
 */

const EntityHighlighting = {
    // Configuration
    config: {
        highlightColors: {
            'DISEASE': '#ffebee',
            'GENE': '#e8f5e8',
            'DRUG': '#e3f2fd',
            'ANATOMY': '#fff3e0',
            'PHENOTYPE': '#f3e5f5',
            'OTHER': '#f5f5f5'
        },
        borderColors: {
            'DISEASE': '#f44336',
            'GENE': '#4caf50',
            'DRUG': '#2196f3',
            'ANATOMY': '#ff9800',
            'PHENOTYPE': '#9c27b0',
            'OTHER': '#9e9e9e'
        },
        textColors: {
            'DISEASE': '#c62828',
            'GENE': '#2e7d32',
            'DRUG': '#1565c0',
            'ANATOMY': '#ef6c00',
            'PHENOTYPE': '#7b1fa2',
            'OTHER': '#424242'
        },
        confidenceLevels: {
            high: 0.8,
            medium: 0.6
        },
        animationDuration: 300,
        tooltipDelay: 500
    },

    // State
    state: {
        highlightedEntities: [],
        selectedEntity: null,
        hoveredEntity: null,
        annotatedText: '',
        originalText: '',
        entityMap: new Map(),
        tooltipTimeout: null
    },

    /**
     * Initialize entity highlighting
     */
    init() {
        this.setupEventHandlers();
        this.initializeTooltips();
        console.log('EntityHighlighting module initialized');
    },

    /**
     * Process text with markdown-like formatting
     */
    processTextFormatting(text) {
        if (!text) return '';
        
        // Process line by line to handle headers and formatting
        const lines = text.split('\n');
        const processedLines = lines.map(line => {
            // Check if line is a header
            if (line.startsWith('# ')) {
                return '<h1 style="font-size: 28px; font-weight: bold; margin: 20px 0 16px 0;">' + 
                       this.escapeHtml(line.substring(2)) + '</h1>';
            } else if (line.startsWith('## ')) {
                return '<h2 style="font-size: 24px; font-weight: bold; margin: 18px 0 14px 0;">' + 
                       this.escapeHtml(line.substring(3)) + '</h2>';
            } else if (line.startsWith('### ')) {
                return '<h3 style="font-size: 20px; font-weight: bold; margin: 16px 0 12px 0;">' + 
                       this.escapeHtml(line.substring(4)) + '</h3>';
            } else {
                // Regular line - escape HTML
                let escaped = this.escapeHtml(line);
                // Convert bold text
                escaped = escaped.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
                return escaped;
            }
        });
        
        // Join lines and convert double newlines to paragraph breaks
        let result = processedLines.join('\n');
        
        // Handle paragraphs
        const paragraphs = result.split(/\n\n+/);
        result = paragraphs.map(p => {
            p = p.trim();
            // Don't wrap headers in paragraphs
            if (p.startsWith('<h') || p === '') return p;
            // Don't replace newlines with <br> tags to avoid interfering with entity highlighting
            return '<p style="margin-bottom: 12px; font-size: 16px; line-height: 1.8;">' + 
                   p + '</p>';
        }).join('\n');
        
        return result;
    },

    /**
     * Generate annotated text with entity highlights
     */
    generateAnnotatedText(originalText, entities) {
        if (!originalText) {
            return '';
        }
        
        // If no entities, just process formatting
        if (!entities || entities.length === 0) {
            return this.processTextFormatting(originalText);
        }

        // Sort entities by start position (reverse order for insertion)
        const sortedEntities = [...entities].sort((a, b) => b.startPosition - a.startPosition);
        
        let annotatedText = originalText;
        this.state.originalText = originalText;
        this.state.entityMap.clear();

        // Insert highlights from end to beginning to preserve positions
        sortedEntities.forEach((entity, index) => {
            const entityId = `entity-${Date.now()}-${index}`;
            const before = annotatedText.substring(0, entity.startPosition);
            const entityText = annotatedText.substring(entity.startPosition, entity.endPosition);
            const after = annotatedText.substring(entity.endPosition);

            // Create highlight span with special markers that won't interfere with markdown processing
            const highlightSpan = `__ENTITY_START_${entityId}__${entityText}__ENTITY_END_${entityId}__`;
            
            annotatedText = before + highlightSpan + after;
            
            // Store entity mapping
            this.state.entityMap.set(entityId, entity);
        });

        // Apply text formatting to convert markdown to HTML
        annotatedText = this.processTextFormatting(annotatedText);
        
        // Now replace the entity markers with actual highlight spans
        sortedEntities.forEach((entity, index) => {
            const entityId = `entity-${Date.now()}-${index}`;
            const entityText = originalText.substring(entity.startPosition, entity.endPosition);
            const highlightSpan = this.createHighlightSpan(entityText, entity, entityId);
            
            const markerRegex = new RegExp(`__ENTITY_START_${entityId}__(.+?)__ENTITY_END_${entityId}__`, 'g');
            annotatedText = annotatedText.replace(markerRegex, highlightSpan);
        });
        
        this.state.annotatedText = annotatedText;
        this.state.highlightedEntities = entities;

        return annotatedText;
    },

    /**
     * Create highlight span for entity
     */
    createHighlightSpan(text, entity, entityId) {
        const confidenceLevel = this.getConfidenceLevel(entity.confidenceScore);
        const typeClass = `entity-${entity.entityType.toLowerCase()}`;
        const confidenceClass = `entity-confidence-${confidenceLevel}`;
        
        const style = this.getEntityStyle(entity);
        const title = this.createTooltipText(entity);

        return `<span class="entity-highlight ${typeClass} ${confidenceClass}" 
                      id="${entityId}" 
                      data-entity-id="${entityId}"
                      data-entity-type="${entity.entityType}"
                      data-confidence="${entity.confidenceScore}"
                      data-start="${entity.startPosition}"
                      data-end="${entity.endPosition}"
                      style="${style}"
                      title="${this.escapeHtml(title)}"
                      tabindex="0"
                      role="button"
                      aria-label="Entity: ${this.escapeHtml(text)} (${entity.entityType})">${this.escapeHtml(text)}</span>`;
    },

    /**
     * Get entity style based on type and confidence
     */
    getEntityStyle(entity) {
        const backgroundColor = this.config.highlightColors[entity.entityType] || this.config.highlightColors.OTHER;
        const borderColor = this.config.borderColors[entity.entityType] || this.config.borderColors.OTHER;
        const textColor = this.config.textColors[entity.entityType] || this.config.textColors.OTHER;
        
        const confidenceLevel = this.getConfidenceLevel(entity.confidenceScore);
        let borderStyle = 'solid';
        let opacity = 1;

        switch (confidenceLevel) {
            case 'medium':
                borderStyle = 'dashed';
                break;
            case 'low':
                borderStyle = 'dotted';
                opacity = 0.7;
                break;
        }

        return `background-color: ${backgroundColor}; 
                border: 2px ${borderStyle} ${borderColor}; 
                color: ${textColor}; 
                opacity: ${opacity};`;
    },

    /**
     * Get confidence level category
     */
    getConfidenceLevel(score) {
        if (score >= this.config.confidenceLevels.high) return 'high';
        if (score >= this.config.confidenceLevels.medium) return 'medium';
        return 'low';
    },

    /**
     * Create tooltip text for entity
     */
    createTooltipText(entity) {
        let tooltip = `Entity: ${entity.entityText}\n`;
        tooltip += `Type: ${entity.entityType}\n`;
        tooltip += `Confidence: ${(entity.confidenceScore * 100).toFixed(1)}%\n`;
        tooltip += `Position: ${entity.startPosition}-${entity.endPosition}`;
        
        if (entity.matchedTermName) {
            tooltip += `\nMatched Term: ${entity.matchedTermName}`;
        }
        
        if (entity.validationStatus) {
            tooltip += `\nStatus: ${entity.validationStatus}`;
        }

        return tooltip;
    },

    /**
     * Setup event handlers for entity interactions
     */
    setupEventHandlers() {
        // Delegate event handlers for dynamically created highlights
        $(document).on('click', '.entity-highlight', (e) => {
            e.preventDefault();
            this.handleEntityClick(e.target);
        });

        $(document).on('mouseenter', '.entity-highlight', (e) => {
            this.handleEntityHover(e.target, true);
        });

        $(document).on('mouseleave', '.entity-highlight', (e) => {
            this.handleEntityHover(e.target, false);
        });

        $(document).on('keydown', '.entity-highlight', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.handleEntityClick(e.target);
            }
        });

        $(document).on('focus', '.entity-highlight', (e) => {
            this.handleEntityFocus(e.target);
        });

        $(document).on('blur', '.entity-highlight', (e) => {
            this.handleEntityBlur(e.target);
        });
    },

    /**
     * Initialize interactions after content is loaded
     */
    initializeInteractions() {
        // Add ARIA labels and keyboard navigation
        $('.entity-highlight').each((index, element) => {
            const $element = $(element);
            const entityId = $element.data('entity-id');
            const entity = this.state.entityMap.get(entityId);
            
            if (entity) {
                $element.attr('aria-describedby', `tooltip-${entityId}`);
            }
        });

        // Initialize custom tooltips
        this.initializeCustomTooltips();
    },

    /**
     * Initialize custom tooltips
     */
    initializeCustomTooltips() {
        $('.entity-highlight').each((index, element) => {
            const $element = $(element);
            const entityId = $element.data('entity-id');
            const entity = this.state.entityMap.get(entityId);
            
            if (entity) {
                this.createCustomTooltip(element, entity);
            }
        });
    },

    /**
     * Create custom tooltip for entity
     */
    createCustomTooltip(element, entity) {
        const $element = $(element);
        const tooltipId = `tooltip-${$element.data('entity-id')}`;
        
        const tooltipContent = `
            <div id="${tooltipId}" class="entity-tooltip" role="tooltip">
                <div class="tooltip-header">
                    <strong>${this.escapeHtml(entity.entityText)}</strong>
                    <span class="entity-type-badge badge ms-2" 
                          style="background-color: ${this.config.borderColors[entity.entityType]}">
                        ${entity.entityType}
                    </span>
                </div>
                <div class="tooltip-body">
                    <div class="tooltip-row">
                        <span class="tooltip-label">Confidence:</span>
                        <span class="tooltip-value">
                            ${(entity.confidenceScore * 100).toFixed(1)}%
                            <div class="confidence-bar-small">
                                <div class="confidence-fill-small confidence-${this.getConfidenceLevel(entity.confidenceScore)}" 
                                     style="width: ${entity.confidenceScore * 100}%"></div>
                            </div>
                        </span>
                    </div>
                    <div class="tooltip-row">
                        <span class="tooltip-label">Position:</span>
                        <span class="tooltip-value">${entity.startPosition}-${entity.endPosition}</span>
                    </div>
                    ${entity.matchedTermName ? `
                        <div class="tooltip-row">
                            <span class="tooltip-label">Matched Term:</span>
                            <span class="tooltip-value">${this.escapeHtml(entity.matchedTermName)}</span>
                        </div>
                    ` : ''}
                    ${entity.validationStatus ? `
                        <div class="tooltip-row">
                            <span class="tooltip-label">Status:</span>
                            <span class="tooltip-value validation-${entity.validationStatus.toLowerCase()}">
                                ${entity.validationStatus}
                            </span>
                        </div>
                    ` : ''}
                </div>
                <div class="tooltip-footer">
                    <small class="text-muted">Click for details</small>
                </div>
            </div>
        `;

        // Initialize Bootstrap tooltip with custom content
        $element.tooltip({
            html: true,
            title: tooltipContent,
            placement: 'top',
            trigger: 'manual',
            template: '<div class="tooltip entity-tooltip-wrapper" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
        });
    },

    /**
     * Handle entity click
     */
    handleEntityClick(element) {
        const $element = $(element);
        const entityId = $element.data('entity-id');
        const entity = this.state.entityMap.get(entityId);
        
        if (!entity) return;

        // Update selection state
        this.selectEntity(entity, element);
        
        // Trigger selection event
        $(document).trigger('entitySelected', [entity, element]);
        
        // Show in entity list
        this.scrollToEntityInList(entity);
        
        // Show entity details
        if (typeof CurationUI !== 'undefined') {
            CurationUI.showEntityDetails(entity);
        }
    },

    /**
     * Handle entity hover
     */
    handleEntityHover(element, isEntering) {
        const $element = $(element);
        const entityId = $element.data('entity-id');
        const entity = this.state.entityMap.get(entityId);
        
        if (!entity) return;

        if (isEntering) {
            this.state.hoveredEntity = entity;
            this.showEntityTooltip(element);
            this.highlightRelatedEntities(entity);
            $element.addClass('entity-hovered');
        } else {
            this.state.hoveredEntity = null;
            this.hideEntityTooltip(element);
            this.clearRelatedHighlights();
            $element.removeClass('entity-hovered');
        }
    },

    /**
     * Handle entity focus (keyboard navigation)
     */
    handleEntityFocus(element) {
        const $element = $(element);
        $element.addClass('entity-focused');
        this.showEntityTooltip(element);
    },

    /**
     * Handle entity blur
     */
    handleEntityBlur(element) {
        const $element = $(element);
        $element.removeClass('entity-focused');
        this.hideEntityTooltip(element);
    },

    /**
     * Show entity tooltip
     */
    showEntityTooltip(element) {
        const $element = $(element);
        
        // Clear existing timeout
        if (this.state.tooltipTimeout) {
            clearTimeout(this.state.tooltipTimeout);
        }

        // Show tooltip after delay
        this.state.tooltipTimeout = setTimeout(() => {
            $element.tooltip('show');
        }, this.config.tooltipDelay);
    },

    /**
     * Hide entity tooltip
     */
    hideEntityTooltip(element) {
        const $element = $(element);
        
        // Clear timeout
        if (this.state.tooltipTimeout) {
            clearTimeout(this.state.tooltipTimeout);
            this.state.tooltipTimeout = null;
        }

        $element.tooltip('hide');
    },

    /**
     * Select entity
     */
    selectEntity(entity, element) {
        // Clear previous selection
        $('.entity-highlight').removeClass('entity-selected');
        $('.entity-item').removeClass('selected');

        // Mark new selection
        this.state.selectedEntity = entity;
        $(element).addClass('entity-selected');

        // Scroll element into view
        this.scrollElementIntoView(element);
    },

    /**
     * Highlight entity by reference
     */
    highlightEntity(entity) {
        // Find the highlight element for this entity
        const $highlight = $(`.entity-highlight[data-start="${entity.startPosition}"][data-end="${entity.endPosition}"]`);
        
        if ($highlight.length > 0) {
            this.selectEntity(entity, $highlight[0]);
        }
    },

    /**
     * Clear all highlights
     */
    clearHighlight() {
        $('.entity-highlight').removeClass('entity-selected entity-hovered entity-focused');
        $('.entity-item').removeClass('selected');
        this.state.selectedEntity = null;
        this.state.hoveredEntity = null;
    },

    /**
     * Highlight related entities (same type or text)
     */
    highlightRelatedEntities(entity) {
        $('.entity-highlight').each((index, element) => {
            const $element = $(element);
            const entityId = $element.data('entity-id');
            const relatedEntity = this.state.entityMap.get(entityId);
            
            if (relatedEntity && relatedEntity !== entity) {
                if (relatedEntity.entityType === entity.entityType || 
                    relatedEntity.entityText.toLowerCase() === entity.entityText.toLowerCase()) {
                    $element.addClass('entity-related');
                }
            }
        });
    },

    /**
     * Clear related entity highlights
     */
    clearRelatedHighlights() {
        $('.entity-highlight').removeClass('entity-related');
    },

    /**
     * Scroll to entity in list
     */
    scrollToEntityInList(entity) {
        // Find corresponding entity in the list
        $('.entity-item').each((index, element) => {
            const $element = $(element);
            const listEntity = CurationUI.state.currentEntities[$element.data('index')];
            
            if (listEntity && 
                listEntity.startPosition === entity.startPosition && 
                listEntity.endPosition === entity.endPosition) {
                
                $element.addClass('selected');
                
                // Scroll into view
                const container = $('#entityList');
                const elementTop = $element.position().top;
                const containerHeight = container.height();
                
                if (elementTop < 0 || elementTop > containerHeight) {
                    container.animate({
                        scrollTop: container.scrollTop() + elementTop - containerHeight / 2
                    }, this.config.animationDuration);
                }
            }
        });
    },

    /**
     * Scroll element into view
     */
    scrollElementIntoView(element) {
        const $element = $(element);
        const container = $('#annotatedText');
        const elementTop = $element.position().top;
        const containerHeight = container.height();
        
        if (elementTop < 0 || elementTop > containerHeight) {
            container.animate({
                scrollTop: container.scrollTop() + elementTop - containerHeight / 2
            }, this.config.animationDuration);
        }
    },

    /**
     * Filter highlights by entity type
     */
    filterHighlights(entityType) {
        if (entityType === 'all') {
            $('.entity-highlight').show();
        } else {
            $('.entity-highlight').hide();
            $(`.entity-highlight[data-entity-type="${entityType}"]`).show();
        }
    },

    /**
     * Update highlight confidence threshold
     */
    updateConfidenceThreshold(threshold) {
        $('.entity-highlight').each((index, element) => {
            const $element = $(element);
            const confidence = parseFloat($element.data('confidence'));
            
            if (confidence < threshold) {
                $element.addClass('entity-below-threshold');
            } else {
                $element.removeClass('entity-below-threshold');
            }
        });
    },

    /**
     * Export highlighted text as HTML
     */
    exportHighlightedHTML() {
        const content = `
            <!DOCTYPE html>
            <html>
            <head>
                <title>RGD Curation - Annotated Text</title>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; }
                    .entity-highlight { padding: 2px 4px; border-radius: 3px; font-weight: 500; }
                    ${this.generateHighlightCSS()}
                </style>
            </head>
            <body>
                <h1>Annotated Text</h1>
                <div class="annotated-content">
                    ${this.state.annotatedText}
                </div>
                <div class="legend">
                    <h3>Legend</h3>
                    ${this.generateLegendHTML()}
                </div>
            </body>
            </html>
        `;

        return content;
    },

    /**
     * Generate CSS for highlights
     */
    generateHighlightCSS() {
        let css = '';
        
        Object.keys(this.config.highlightColors).forEach(type => {
            const bgColor = this.config.highlightColors[type];
            const borderColor = this.config.borderColors[type];
            const textColor = this.config.textColors[type];
            
            css += `.entity-${type.toLowerCase()} { 
                background-color: ${bgColor}; 
                border: 1px solid ${borderColor}; 
                color: ${textColor}; 
            }\n`;
        });

        return css;
    },

    /**
     * Generate legend HTML
     */
    generateLegendHTML() {
        let html = '<div class="legend-items">';
        
        Object.keys(this.config.highlightColors).forEach(type => {
            const style = this.getEntityStyle({ entityType: type, confidenceScore: 1.0 });
            html += `<div class="legend-item">
                <span class="entity-highlight" style="${style}">${type}</span>
                <span class="legend-label">${type.charAt(0) + type.slice(1).toLowerCase()}</span>
            </div>`;
        });

        html += '</div>';
        return html;
    },

    /**
     * Get entity statistics for highlighted text
     */
    getHighlightStatistics() {
        const stats = {
            totalEntities: this.state.highlightedEntities.length,
            byType: {},
            byConfidence: { high: 0, medium: 0, low: 0 },
            averageConfidence: 0,
            textCoverage: 0
        };

        let totalConfidence = 0;
        let totalCharsCovered = 0;

        this.state.highlightedEntities.forEach(entity => {
            // Count by type
            stats.byType[entity.entityType] = (stats.byType[entity.entityType] || 0) + 1;

            // Count by confidence
            const level = this.getConfidenceLevel(entity.confidenceScore);
            stats.byConfidence[level]++;

            // Sum for averages
            totalConfidence += entity.confidenceScore;
            totalCharsCovered += entity.endPosition - entity.startPosition;
        });

        stats.averageConfidence = stats.totalEntities > 0 ? totalConfidence / stats.totalEntities : 0;
        stats.textCoverage = this.state.originalText.length > 0 ? 
            (totalCharsCovered / this.state.originalText.length) * 100 : 0;

        return stats;
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
    escapeRegex(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    },

    /**
     * Get current state
     */
    getState() {
        return { ...this.state };
    },

    /**
     * Reset highlighting state
     */
    reset() {
        this.state.highlightedEntities = [];
        this.state.selectedEntity = null;
        this.state.hoveredEntity = null;
        this.state.annotatedText = '';
        this.state.originalText = '';
        this.state.entityMap.clear();
        
        if (this.state.tooltipTimeout) {
            clearTimeout(this.state.tooltipTimeout);
            this.state.tooltipTimeout = null;
        }
    }
};