/**
 * RGD Curation Tool - Batch Processing Dashboard Module
 * Handles batch entity recognition jobs, status monitoring, and queue management
 */

const BatchProcessing = {
    // Configuration
    config: {
        apiBaseUrl: '/rgd/curation',
        maxConcurrentJobs: 3,
        statusRefreshInterval: 2000, // 2 seconds
        maxBatchSize: 1000,
        maxFileSize: 100 * 1024 * 1024, // 100MB
        supportedFileTypes: ['.txt', '.pdf', '.doc', '.docx', '.csv', '.tsv'],
        jobStatuses: ['PENDING', 'RUNNING', 'PAUSED', 'COMPLETED', 'FAILED', 'CANCELLED'],
        priorities: ['LOW', 'NORMAL', 'HIGH', 'URGENT']
    },

    // State
    state: {
        activeJobs: new Map(),
        jobQueue: [],
        jobHistory: [],
        isMonitoring: false,
        statusInterval: null,
        selectedJobId: null,
        filterStatus: 'all',
        sortBy: 'created',
        sortOrder: 'desc',
        totalProcessed: 0,
        totalFailed: 0,
        totalEntities: 0
    },

    /**
     * Initialize batch processing dashboard
     */
    init() {
        this.setupEventHandlers();
        this.loadJobHistory();
        this.startStatusMonitoring();
        this.renderDashboard();
        console.log('BatchProcessing module initialized');
    },

    /**
     * Setup event handlers
     */
    setupEventHandlers() {
        // File upload for batch processing
        $(document).on('change', '#batchFileUpload', (e) => {
            this.handleBatchFileUpload(e.target.files);
        });

        // Text input for batch processing
        $(document).on('click', '#submitBatchText', () => {
            this.handleBatchTextSubmission();
        });

        // Job control buttons
        $(document).on('click', '.job-control-btn', (e) => {
            const action = $(e.target).data('action');
            const jobId = $(e.target).data('job-id');
            this.handleJobControl(action, jobId);
        });

        // Job selection
        $(document).on('click', '.job-item', (e) => {
            const jobId = $(e.currentTarget).data('job-id');
            this.selectJob(jobId);
        });

        // Filter and sort controls
        $(document).on('change', '#jobStatusFilter', (e) => {
            this.state.filterStatus = $(e.target).val();
            this.renderJobList();
        });

        $(document).on('change', '#jobSortBy', (e) => {
            this.state.sortBy = $(e.target).val();
            this.renderJobList();
        });

        $(document).on('change', '#jobSortOrder', (e) => {
            this.state.sortOrder = $(e.target).val();
            this.renderJobList();
        });

        // Batch settings
        $(document).on('click', '#saveBatchSettings', () => {
            this.saveBatchSettings();
        });

        // Export results
        $(document).on('click', '.export-job-results', (e) => {
            const jobId = $(e.target).data('job-id');
            const format = $(e.target).data('format');
            this.exportJobResults(jobId, format);
        });

        // Clear completed jobs
        $(document).on('click', '#clearCompletedJobs', () => {
            this.clearCompletedJobs();
        });

        // Refresh dashboard
        $(document).on('click', '#refreshDashboard', () => {
            this.refreshDashboard();
        });
    },

    /**
     * Render main dashboard
     */
    renderDashboard() {
        const container = $('#batchContainer');
        
        const html = `
            <div class="batch-processing-dashboard">
                ${this.renderDashboardHeader()}
                <div class="row">
                    <div class="col-lg-8">
                        ${this.renderJobQueue()}
                    </div>
                    <div class="col-lg-4">
                        ${this.renderJobDetails()}
                        ${this.renderBatchStatistics()}
                    </div>
                </div>
                ${this.renderBatchSubmission()}
            </div>
        `;

        container.html(html);
        this.initializeDashboardComponents();
    },

    /**
     * Render dashboard header
     */
    renderDashboardHeader() {
        const stats = this.getBatchStatistics();
        
        return `
            <div class="batch-header mb-4">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h5 class="mb-0">
                            <i class="fas fa-tasks"></i> Batch Processing Dashboard
                        </h5>
                        <small class="text-muted">
                            Monitor and manage entity recognition batch jobs
                        </small>
                    </div>
                    <div class="col-md-6 text-end">
                        <div class="btn-group" role="group">
                            <button class="btn btn-sm btn-outline-primary" id="refreshDashboard">
                                <i class="fas fa-sync-alt"></i> Refresh
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#batchSettingsModal">
                                <i class="fas fa-cog"></i> Settings
                            </button>
                            <button class="btn btn-sm btn-outline-danger" id="clearCompletedJobs">
                                <i class="fas fa-trash"></i> Clear Completed
                            </button>
                        </div>
                    </div>
                </div>
                
                <div class="batch-overview mt-3">
                    <div class="row">
                        <div class="col-md-3">
                            <div class="overview-stat">
                                <div class="stat-number text-primary">${stats.activeJobs}</div>
                                <div class="stat-label">Active Jobs</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="overview-stat">
                                <div class="stat-number text-info">${stats.queuedJobs}</div>
                                <div class="stat-label">Queued Jobs</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="overview-stat">
                                <div class="stat-number text-success">${stats.completedJobs}</div>
                                <div class="stat-label">Completed</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="overview-stat">
                                <div class="stat-number text-danger">${stats.failedJobs}</div>
                                <div class="stat-label">Failed</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render job queue
     */
    renderJobQueue() {
        return `
            <div class="job-queue-container">
                <div class="job-queue-header">
                    <div class="row align-items-center mb-3">
                        <div class="col-md-6">
                            <h6>Job Queue</h6>
                        </div>
                        <div class="col-md-6">
                            <div class="d-flex gap-2">
                                <select class="form-select form-select-sm" id="jobStatusFilter">
                                    <option value="all">All Statuses</option>
                                    <option value="PENDING">Pending</option>
                                    <option value="RUNNING">Running</option>
                                    <option value="PAUSED">Paused</option>
                                    <option value="COMPLETED">Completed</option>
                                    <option value="FAILED">Failed</option>
                                    <option value="CANCELLED">Cancelled</option>
                                </select>
                                <select class="form-select form-select-sm" id="jobSortBy">
                                    <option value="created">Created</option>
                                    <option value="priority">Priority</option>
                                    <option value="status">Status</option>
                                    <option value="progress">Progress</option>
                                </select>
                                <select class="form-select form-select-sm" id="jobSortOrder">
                                    <option value="desc">Desc</option>
                                    <option value="asc">Asc</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="job-list" id="jobList">
                    ${this.renderJobList()}
                </div>
            </div>
        `;
    },

    /**
     * Render job list
     */
    renderJobList() {
        const jobs = this.getFilteredAndSortedJobs();
        
        if (jobs.length === 0) {
            return `
                <div class="empty-job-list text-center py-4">
                    <i class="fas fa-clipboard-list fa-3x text-muted mb-3"></i>
                    <h6>No jobs found</h6>
                    <p class="text-muted">Submit a batch job to get started</p>
                </div>
            `;
        }

        let html = '';
        jobs.forEach(job => {
            html += this.renderJobItem(job);
        });

        return html;
    },

    /**
     * Render individual job item
     */
    renderJobItem(job) {
        const statusClass = this.getJobStatusClass(job.status);
        const progressPercent = this.calculateJobProgress(job);
        const isSelected = job.jobId === this.state.selectedJobId;
        
        return `
            <div class="job-item ${isSelected ? 'selected' : ''}" data-job-id="${job.jobId}">
                <div class="job-header">
                    <div class="job-info">
                        <div class="job-name">${this.escapeHtml(job.jobName)}</div>
                        <div class="job-meta">
                            <span class="job-id">#${job.jobId}</span>
                            <span class="job-created">${this.formatDateTime(job.createdAt)}</span>
                            <span class="job-priority priority-${job.priority.toLowerCase()}">${job.priority}</span>
                        </div>
                    </div>
                    <div class="job-status">
                        <span class="status-badge ${statusClass}">${job.status}</span>
                        <div class="job-controls">
                            ${this.renderJobControls(job)}
                        </div>
                    </div>
                </div>
                
                <div class="job-progress">
                    <div class="progress">
                        <div class="progress-bar ${this.getProgressBarClass(job.status)}" 
                             style="width: ${progressPercent}%"
                             title="${progressPercent.toFixed(1)}% complete"></div>
                    </div>
                    <div class="progress-info">
                        <span>${job.processedItems || 0}/${job.totalItems || 0} items</span>
                        <span>${progressPercent.toFixed(1)}%</span>
                    </div>
                </div>
                
                ${job.status === 'RUNNING' ? `
                    <div class="job-current-activity">
                        <small class="text-muted">
                            <i class="fas fa-spinner fa-spin"></i> 
                            ${job.currentActivity || 'Processing...'}
                        </small>
                    </div>
                ` : ''}
                
                ${job.errorMessage ? `
                    <div class="job-error">
                        <small class="text-danger">
                            <i class="fas fa-exclamation-triangle"></i> 
                            ${this.escapeHtml(job.errorMessage)}
                        </small>
                    </div>
                ` : ''}
            </div>
        `;
    },

    /**
     * Render job controls
     */
    renderJobControls(job) {
        let controls = [];
        
        switch (job.status) {
            case 'PENDING':
                controls.push(`<button class="btn btn-sm btn-outline-primary job-control-btn" data-action="start" data-job-id="${job.jobId}" title="Start Job">
                    <i class="fas fa-play"></i>
                </button>`);
                controls.push(`<button class="btn btn-sm btn-outline-danger job-control-btn" data-action="cancel" data-job-id="${job.jobId}" title="Cancel Job">
                    <i class="fas fa-times"></i>
                </button>`);
                break;
                
            case 'RUNNING':
                controls.push(`<button class="btn btn-sm btn-outline-warning job-control-btn" data-action="pause" data-job-id="${job.jobId}" title="Pause Job">
                    <i class="fas fa-pause"></i>
                </button>`);
                controls.push(`<button class="btn btn-sm btn-outline-danger job-control-btn" data-action="stop" data-job-id="${job.jobId}" title="Stop Job">
                    <i class="fas fa-stop"></i>
                </button>`);
                break;
                
            case 'PAUSED':
                controls.push(`<button class="btn btn-sm btn-outline-success job-control-btn" data-action="resume" data-job-id="${job.jobId}" title="Resume Job">
                    <i class="fas fa-play"></i>
                </button>`);
                controls.push(`<button class="btn btn-sm btn-outline-danger job-control-btn" data-action="cancel" data-job-id="${job.jobId}" title="Cancel Job">
                    <i class="fas fa-times"></i>
                </button>`);
                break;
                
            case 'COMPLETED':
                controls.push(`<button class="btn btn-sm btn-outline-primary export-job-results" data-job-id="${job.jobId}" data-format="json" title="Export Results">
                    <i class="fas fa-download"></i>
                </button>`);
                controls.push(`<button class="btn btn-sm btn-outline-secondary job-control-btn" data-action="rerun" data-job-id="${job.jobId}" title="Rerun Job">
                    <i class="fas fa-redo"></i>
                </button>`);
                break;
                
            case 'FAILED':
                controls.push(`<button class="btn btn-sm btn-outline-warning job-control-btn" data-action="retry" data-job-id="${job.jobId}" title="Retry Job">
                    <i class="fas fa-redo"></i>
                </button>`);
                controls.push(`<button class="btn btn-sm btn-outline-danger job-control-btn" data-action="remove" data-job-id="${job.jobId}" title="Remove Job">
                    <i class="fas fa-trash"></i>
                </button>`);
                break;
        }
        
        return controls.join('');
    },

    /**
     * Render job details panel
     */
    renderJobDetails() {
        const selectedJob = this.getSelectedJob();
        
        if (!selectedJob) {
            return `
                <div class="job-details-panel">
                    <h6>Job Details</h6>
                    <p class="text-muted">Select a job to view details</p>
                </div>
            `;
        }

        return `
            <div class="job-details-panel">
                <h6>Job Details</h6>
                <div class="job-detail-card">
                    <div class="detail-header">
                        <h6>${this.escapeHtml(selectedJob.jobName)}</h6>
                        <span class="status-badge ${this.getJobStatusClass(selectedJob.status)}">
                            ${selectedJob.status}
                        </span>
                    </div>
                    
                    <div class="detail-body">
                        <div class="detail-row">
                            <span class="detail-label">Job ID:</span>
                            <span class="detail-value">${selectedJob.jobId}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Created:</span>
                            <span class="detail-value">${this.formatDateTime(selectedJob.createdAt)}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Priority:</span>
                            <span class="detail-value priority-${selectedJob.priority.toLowerCase()}">${selectedJob.priority}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Total Items:</span>
                            <span class="detail-value">${selectedJob.totalItems || 0}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Processed:</span>
                            <span class="detail-value">${selectedJob.processedItems || 0}</span>
                        </div>
                        
                        ${selectedJob.entityTypes ? `
                            <div class="detail-row">
                                <span class="detail-label">Entity Types:</span>
                                <span class="detail-value">
                                    ${selectedJob.entityTypes.map(type => 
                                        `<span class="entity-type-badge badge me-1" style="background-color: ${CurationUI.getEntityTypeColor(type)}">${type}</span>`
                                    ).join('')}
                                </span>
                            </div>
                        ` : ''}
                        
                        ${selectedJob.confidenceThreshold ? `
                            <div class="detail-row">
                                <span class="detail-label">Confidence:</span>
                                <span class="detail-value">${(selectedJob.confidenceThreshold * 100).toFixed(1)}%</span>
                            </div>
                        ` : ''}
                        
                        ${selectedJob.startedAt ? `
                            <div class="detail-row">
                                <span class="detail-label">Started:</span>
                                <span class="detail-value">${this.formatDateTime(selectedJob.startedAt)}</span>
                            </div>
                        ` : ''}
                        
                        ${selectedJob.completedAt ? `
                            <div class="detail-row">
                                <span class="detail-label">Completed:</span>
                                <span class="detail-value">${this.formatDateTime(selectedJob.completedAt)}</span>
                            </div>
                        ` : ''}
                        
                        ${selectedJob.processingTime ? `
                            <div class="detail-row">
                                <span class="detail-label">Duration:</span>
                                <span class="detail-value">${this.formatDuration(selectedJob.processingTime)}</span>
                            </div>
                        ` : ''}
                        
                        ${selectedJob.recognizedEntities ? `
                            <div class="detail-row">
                                <span class="detail-label">Entities Found:</span>
                                <span class="detail-value">${selectedJob.recognizedEntities}</span>
                            </div>
                        ` : ''}
                    </div>
                    
                    ${selectedJob.description ? `
                        <div class="detail-description">
                            <span class="detail-label">Description:</span>
                            <p class="detail-value">${this.escapeHtml(selectedJob.description)}</p>
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
    },

    /**
     * Render batch statistics
     */
    renderBatchStatistics() {
        const stats = this.getDetailedStatistics();
        
        return `
            <div class="batch-statistics mt-4">
                <h6>Processing Statistics</h6>
                <div class="stats-card">
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-number text-primary">${stats.totalJobs}</div>
                            <div class="stat-label">Total Jobs</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number text-success">${stats.totalEntities}</div>
                            <div class="stat-label">Entities Found</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number text-info">${stats.totalItems}</div>
                            <div class="stat-label">Items Processed</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number text-warning">${stats.averageTime}</div>
                            <div class="stat-label">Avg. Time/Job</div>
                        </div>
                    </div>
                    
                    <div class="processing-rate mt-3">
                        <div class="rate-info">
                            <span class="rate-label">Processing Rate:</span>
                            <span class="rate-value">${stats.processingRate} items/min</span>
                        </div>
                        <div class="efficiency-info">
                            <span class="rate-label">Success Rate:</span>
                            <span class="rate-value">${stats.successRate}%</span>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render batch submission form
     */
    renderBatchSubmission() {
        return `
            <div class="batch-submission mt-4">
                <div class="card">
                    <div class="card-header">
                        <h6><i class="fas fa-plus"></i> Submit New Batch Job</h6>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="submission-method">
                                    <h6>File Upload</h6>
                                    <input type="file" class="form-control" id="batchFileUpload" 
                                           multiple accept=".txt,.pdf,.doc,.docx,.csv,.tsv">
                                    <div class="form-text">
                                        Supported formats: TXT, PDF, DOC, DOCX, CSV, TSV (max ${this.config.maxFileSize / (1024 * 1024)}MB each)
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="submission-method">
                                    <h6>Text Input</h6>
                                    <textarea class="form-control" id="batchTextInput" rows="4" 
                                              placeholder="Enter texts separated by newlines or paste delimited data"></textarea>
                                    <button class="btn btn-primary mt-2" id="submitBatchText">
                                        <i class="fas fa-play"></i> Submit Text Batch
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="batch-options mt-3">
                            <div class="row">
                                <div class="col-md-4">
                                    <label class="form-label">Job Name</label>
                                    <input type="text" class="form-control" id="batchJobName" 
                                           placeholder="Batch Job ${new Date().toISOString().split('T')[0]}">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Priority</label>
                                    <select class="form-select" id="batchPriority">
                                        <option value="NORMAL">Normal</option>
                                        <option value="HIGH">High</option>
                                        <option value="LOW">Low</option>
                                        <option value="URGENT">Urgent</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Batch Size</label>
                                    <input type="number" class="form-control" id="batchSize" 
                                           value="100" min="1" max="${this.config.maxBatchSize}">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Handle batch file upload
     */
    async handleBatchFileUpload(files) {
        if (!files || files.length === 0) return;

        const validFiles = [];
        const errors = [];

        // Validate files
        for (const file of files) {
            if (file.size > this.config.maxFileSize) {
                errors.push(`${file.name}: File size exceeds ${this.config.maxFileSize / (1024 * 1024)}MB limit`);
                continue;
            }

            const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
            if (!this.config.supportedFileTypes.includes(fileExtension)) {
                errors.push(`${file.name}: Unsupported file type`);
                continue;
            }

            validFiles.push(file);
        }

        if (errors.length > 0) {
            CurationUI.showError('File validation errors:\n' + errors.join('\n'));
        }

        if (validFiles.length === 0) return;

        try {
            const jobName = $('#batchJobName').val() || `Batch Upload ${new Date().toISOString().split('T')[0]}`;
            const priority = $('#batchPriority').val() || 'NORMAL';
            const batchSize = parseInt($('#batchSize').val()) || 100;

            const jobId = await this.submitBatchFileJob(validFiles, {
                jobName: jobName,
                priority: priority,
                batchSize: batchSize
            });

            CurationUI.showSuccess(`Batch job submitted successfully (ID: ${jobId})`);
            this.refreshDashboard();

        } catch (error) {
            CurationUI.showError('Failed to submit batch job: ' + error.message);
        }
    },

    /**
     * Handle batch text submission
     */
    async handleBatchTextSubmission() {
        const text = $('#batchTextInput').val().trim();
        if (!text) {
            CurationUI.showWarning('Please enter text for batch processing');
            return;
        }

        try {
            const texts = text.split('\n').filter(line => line.trim().length > 0);
            if (texts.length === 0) {
                CurationUI.showWarning('No valid text lines found');
                return;
            }

            const jobName = $('#batchJobName').val() || `Batch Text ${new Date().toISOString().split('T')[0]}`;
            const priority = $('#batchPriority').val() || 'NORMAL';
            const batchSize = parseInt($('#batchSize').val()) || 100;

            const jobId = await this.submitBatchTextJob(texts, {
                jobName: jobName,
                priority: priority,
                batchSize: batchSize
            });

            CurationUI.showSuccess(`Batch job submitted successfully (ID: ${jobId})`);
            $('#batchTextInput').val('');
            this.refreshDashboard();

        } catch (error) {
            CurationUI.showError('Failed to submit batch job: ' + error.message);
        }
    },

    /**
     * Submit batch file job to server
     */
    async submitBatchFileJob(files, options) {
        const formData = new FormData();
        
        files.forEach(file => {
            formData.append('files', file);
        });
        
        formData.append('jobName', options.jobName);
        formData.append('priority', options.priority);
        formData.append('batchSize', options.batchSize);
        formData.append('entityTypes', JSON.stringify(CurationUI.getSelectedEntityTypes()));
        formData.append('confidenceThreshold', CurationUI.config.confidenceThreshold);

        const response = await fetch(`${this.config.apiBaseUrl}/batch/files`, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error(`Server error: ${response.status}`);
        }

        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to submit batch job');
        }

        return result.jobId;
    },

    /**
     * Submit batch text job to server
     */
    async submitBatchTextJob(texts, options) {
        const request = {
            jobName: options.jobName,
            priority: options.priority,
            batchSize: options.batchSize,
            texts: texts,
            entityTypes: CurationUI.getSelectedEntityTypes(),
            confidenceThreshold: CurationUI.config.confidenceThreshold,
            sessionId: CurationUI.state.currentSession?.sessionId
        };

        const response = await fetch(`${this.config.apiBaseUrl}/batch/texts`, {
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
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to submit batch job');
        }

        return result.jobId;
    },

    /**
     * Handle job control actions
     */
    async handleJobControl(action, jobId) {
        if (!jobId) return;

        try {
            const response = await fetch(`${this.config.apiBaseUrl}/batch/jobs/${jobId}/${action}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                throw new Error(`Server error: ${response.status}`);
            }

            const result = await response.json();
            
            if (result.success) {
                CurationUI.showSuccess(`Job ${action} successful`);
                this.refreshJobStatus(jobId);
            } else {
                throw new Error(result.message || `Failed to ${action} job`);
            }

        } catch (error) {
            CurationUI.showError(`Failed to ${action} job: ` + error.message);
        }
    },

    /**
     * Select a job for detailed view
     */
    selectJob(jobId) {
        this.state.selectedJobId = jobId;
        
        // Update UI selection
        $('.job-item').removeClass('selected');
        $(`.job-item[data-job-id="${jobId}"]`).addClass('selected');
        
        // Update details panel
        const detailsHTML = this.renderJobDetails();
        $('.job-details-panel').replaceWith(detailsHTML);
    },

    /**
     * Export job results
     */
    async exportJobResults(jobId, format = 'json') {
        try {
            const response = await fetch(`${this.config.apiBaseUrl}/batch/jobs/${jobId}/export?format=${format}`);
            
            if (!response.ok) {
                throw new Error(`Export failed: ${response.status}`);
            }

            const blob = await response.blob();
            const job = this.getJobById(jobId);
            const filename = `${job.jobName}_results.${format}`;
            
            this.downloadBlob(blob, filename);
            CurationUI.showSuccess('Results exported successfully');

        } catch (error) {
            CurationUI.showError('Failed to export results: ' + error.message);
        }
    },

    /**
     * Download blob as file
     */
    downloadBlob(blob, filename) {
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
     * Start status monitoring
     */
    startStatusMonitoring() {
        if (this.state.isMonitoring) return;

        this.state.isMonitoring = true;
        this.state.statusInterval = setInterval(() => {
            this.refreshJobStatuses();
        }, this.config.statusRefreshInterval);
    },

    /**
     * Stop status monitoring
     */
    stopStatusMonitoring() {
        if (this.state.statusInterval) {
            clearInterval(this.state.statusInterval);
            this.state.statusInterval = null;
        }
        this.state.isMonitoring = false;
    },

    /**
     * Refresh job statuses from server
     */
    async refreshJobStatuses() {
        try {
            const activeJobIds = Array.from(this.state.activeJobs.keys());
            if (activeJobIds.length === 0) return;

            const response = await fetch(`${this.config.apiBaseUrl}/batch/jobs/status`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ jobIds: activeJobIds })
            });

            if (!response.ok) return;

            const statusUpdates = await response.json();
            
            statusUpdates.forEach(update => {
                this.updateJobStatus(update);
            });

            this.renderJobList();

        } catch (error) {
            console.warn('Failed to refresh job statuses:', error);
        }
    },

    /**
     * Update job status
     */
    updateJobStatus(statusUpdate) {
        const job = this.state.activeJobs.get(statusUpdate.jobId);
        if (!job) return;

        Object.assign(job, statusUpdate);

        // Move completed/failed jobs to history
        if (['COMPLETED', 'FAILED', 'CANCELLED'].includes(job.status)) {
            this.state.activeJobs.delete(job.jobId);
            this.state.jobHistory.unshift(job);
            
            // Keep only recent history
            if (this.state.jobHistory.length > 100) {
                this.state.jobHistory = this.state.jobHistory.slice(0, 100);
            }
        }
    },

    /**
     * Refresh single job status
     */
    async refreshJobStatus(jobId) {
        try {
            const response = await fetch(`${this.config.apiBaseUrl}/batch/jobs/${jobId}/status`);
            
            if (response.ok) {
                const statusUpdate = await response.json();
                this.updateJobStatus(statusUpdate);
                this.renderJobList();
            }

        } catch (error) {
            console.warn('Failed to refresh job status:', error);
        }
    },

    /**
     * Refresh entire dashboard
     */
    async refreshDashboard() {
        try {
            const response = await fetch(`${this.config.apiBaseUrl}/batch/jobs`);
            
            if (response.ok) {
                const jobs = await response.json();
                this.loadJobs(jobs);
                this.renderDashboard();
                CurationUI.showSuccess('Dashboard refreshed');
            }

        } catch (error) {
            CurationUI.showError('Failed to refresh dashboard: ' + error.message);
        }
    },

    /**
     * Load jobs into state
     */
    loadJobs(jobs) {
        this.state.activeJobs.clear();
        this.state.jobQueue = [];
        this.state.jobHistory = [];

        jobs.forEach(job => {
            if (['PENDING', 'RUNNING', 'PAUSED'].includes(job.status)) {
                this.state.activeJobs.set(job.jobId, job);
                this.state.jobQueue.push(job);
            } else {
                this.state.jobHistory.push(job);
            }
        });
    },

    /**
     * Get filtered and sorted jobs
     */
    getFilteredAndSortedJobs() {
        let jobs = [...this.state.jobQueue, ...this.state.jobHistory];

        // Apply status filter
        if (this.state.filterStatus !== 'all') {
            jobs = jobs.filter(job => job.status === this.state.filterStatus);
        }

        // Apply sorting
        jobs.sort((a, b) => {
            let aValue, bValue;
            
            switch (this.state.sortBy) {
                case 'priority':
                    const priorityOrder = { 'URGENT': 4, 'HIGH': 3, 'NORMAL': 2, 'LOW': 1 };
                    aValue = priorityOrder[a.priority] || 0;
                    bValue = priorityOrder[b.priority] || 0;
                    break;
                case 'status':
                    aValue = a.status;
                    bValue = b.status;
                    break;
                case 'progress':
                    aValue = this.calculateJobProgress(a);
                    bValue = this.calculateJobProgress(b);
                    break;
                case 'created':
                default:
                    aValue = new Date(a.createdAt);
                    bValue = new Date(b.createdAt);
                    break;
            }

            if (this.state.sortOrder === 'asc') {
                return aValue > bValue ? 1 : -1;
            } else {
                return aValue < bValue ? 1 : -1;
            }
        });

        return jobs;
    },

    /**
     * Get job by ID
     */
    getJobById(jobId) {
        return this.state.activeJobs.get(jobId) || 
               this.state.jobHistory.find(job => job.jobId === jobId);
    },

    /**
     * Get selected job
     */
    getSelectedJob() {
        return this.state.selectedJobId ? this.getJobById(this.state.selectedJobId) : null;
    },

    /**
     * Calculate job progress percentage
     */
    calculateJobProgress(job) {
        if (!job.totalItems || job.totalItems === 0) return 0;
        const processed = job.processedItems || 0;
        return Math.min((processed / job.totalItems) * 100, 100);
    },

    /**
     * Get job status CSS class
     */
    getJobStatusClass(status) {
        const classes = {
            'PENDING': 'status-pending',
            'RUNNING': 'status-running',
            'PAUSED': 'status-paused',
            'COMPLETED': 'status-completed',
            'FAILED': 'status-failed',
            'CANCELLED': 'status-cancelled'
        };
        return classes[status] || 'status-unknown';
    },

    /**
     * Get progress bar CSS class
     */
    getProgressBarClass(status) {
        const classes = {
            'PENDING': 'bg-secondary',
            'RUNNING': 'bg-primary',
            'PAUSED': 'bg-warning',
            'COMPLETED': 'bg-success',
            'FAILED': 'bg-danger',
            'CANCELLED': 'bg-secondary'
        };
        return classes[status] || 'bg-secondary';
    },

    /**
     * Get batch statistics
     */
    getBatchStatistics() {
        const allJobs = [...this.state.jobQueue, ...this.state.jobHistory];
        
        return {
            activeJobs: this.state.jobQueue.filter(job => job.status === 'RUNNING').length,
            queuedJobs: this.state.jobQueue.filter(job => job.status === 'PENDING').length,
            completedJobs: allJobs.filter(job => job.status === 'COMPLETED').length,
            failedJobs: allJobs.filter(job => job.status === 'FAILED').length
        };
    },

    /**
     * Get detailed statistics
     */
    getDetailedStatistics() {
        const allJobs = [...this.state.jobQueue, ...this.state.jobHistory];
        const completedJobs = allJobs.filter(job => job.status === 'COMPLETED');
        
        const totalJobs = allJobs.length;
        const totalEntities = completedJobs.reduce((sum, job) => sum + (job.recognizedEntities || 0), 0);
        const totalItems = completedJobs.reduce((sum, job) => sum + (job.processedItems || 0), 0);
        const totalTime = completedJobs.reduce((sum, job) => sum + (job.processingTime || 0), 0);
        
        const averageTime = completedJobs.length > 0 ? 
            this.formatDuration(totalTime / completedJobs.length) : '0s';
        
        const processingRate = totalTime > 0 ? 
            Math.round((totalItems / (totalTime / 60000)) || 0) : 0;
        
        const successRate = allJobs.length > 0 ? 
            Math.round((completedJobs.length / allJobs.length) * 100) : 100;

        return {
            totalJobs,
            totalEntities,
            totalItems,
            averageTime,
            processingRate,
            successRate
        };
    },

    /**
     * Clear completed jobs
     */
    async clearCompletedJobs() {
        const completedJobs = this.state.jobHistory.filter(job => 
            ['COMPLETED', 'FAILED', 'CANCELLED'].includes(job.status));
        
        if (completedJobs.length === 0) {
            CurationUI.showInfo('No completed jobs to clear');
            return;
        }

        const confirmed = confirm(`Clear ${completedJobs.length} completed jobs?`);
        if (!confirmed) return;

        try {
            const jobIds = completedJobs.map(job => job.jobId);
            
            const response = await fetch(`${this.config.apiBaseUrl}/batch/jobs/clear`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ jobIds })
            });

            if (response.ok) {
                this.state.jobHistory = this.state.jobHistory.filter(job => 
                    !jobIds.includes(job.jobId));
                this.renderJobList();
                CurationUI.showSuccess(`Cleared ${completedJobs.length} completed jobs`);
            }

        } catch (error) {
            CurationUI.showError('Failed to clear completed jobs: ' + error.message);
        }
    },

    /**
     * Save batch settings
     */
    saveBatchSettings() {
        const settings = {
            maxConcurrentJobs: parseInt($('#maxConcurrentJobs').val()),
            statusRefreshInterval: parseInt($('#statusRefreshInterval').val()) * 1000,
            maxBatchSize: parseInt($('#maxBatchSizeSettings').val()),
            defaultPriority: $('#defaultPriority').val()
        };

        Object.assign(this.config, settings);
        localStorage.setItem('batchProcessingSettings', JSON.stringify(settings));

        // Restart monitoring with new interval
        this.stopStatusMonitoring();
        this.startStatusMonitoring();

        CurationUI.showSuccess('Batch settings saved');
    },

    /**
     * Load batch settings
     */
    loadBatchSettings() {
        try {
            const saved = localStorage.getItem('batchProcessingSettings');
            if (saved) {
                const settings = JSON.parse(saved);
                Object.assign(this.config, settings);
            }
        } catch (error) {
            console.warn('Failed to load batch settings:', error);
        }
    },

    /**
     * Load job history from localStorage
     */
    loadJobHistory() {
        try {
            const saved = localStorage.getItem('batchJobHistory');
            if (saved) {
                this.state.jobHistory = JSON.parse(saved);
            }
        } catch (error) {
            console.warn('Failed to load job history:', error);
        }
    },

    /**
     * Save job history to localStorage
     */
    saveJobHistory() {
        try {
            localStorage.setItem('batchJobHistory', JSON.stringify(this.state.jobHistory));
        } catch (error) {
            console.warn('Failed to save job history:', error);
        }
    },

    /**
     * Initialize dashboard components
     */
    initializeDashboardComponents() {
        // Initialize tooltips
        $('[data-bs-toggle="tooltip"]').tooltip();
        
        // Load settings
        this.loadBatchSettings();
        
        // Auto-select first job if available
        const jobs = this.getFilteredAndSortedJobs();
        if (jobs.length > 0 && !this.state.selectedJobId) {
            this.selectJob(jobs[0].jobId);
        }
    },

    /**
     * Format date and time
     */
    formatDateTime(dateString) {
        if (!dateString) return 'N/A';
        
        const date = new Date(dateString);
        return date.toLocaleString();
    },

    /**
     * Format duration in milliseconds
     */
    formatDuration(ms) {
        if (!ms || ms < 0) return '0s';
        
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        
        if (hours > 0) {
            return `${hours}h ${minutes % 60}m`;
        } else if (minutes > 0) {
            return `${minutes}m ${seconds % 60}s`;
        } else {
            return `${seconds}s`;
        }
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
     * Cleanup when leaving batch processing mode
     */
    cleanup() {
        this.stopStatusMonitoring();
        this.saveJobHistory();
    }
};