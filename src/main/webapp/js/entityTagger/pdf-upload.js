/**
 * RGD Curation Tool - PDF Upload JavaScript
 * Handles drag-and-drop file upload, progress tracking, and AJAX communication
 */

class PdfUploadManager {
    constructor() {
        this.selectedFile = null;
        this.uploadId = null;
        this.statusInterval = null;
        this.config = window.curationConfig || {};
        this.sessionRecoveryAttempted = false;
        
        this.initializeElements();
        this.attachEventListeners();
        this.setupDragAndDrop();
        this.checkSessionOnLoad();
    }

    initializeElements() {
        // DOM elements
        this.dropZone = document.getElementById('dropZone');
        this.fileInput = document.getElementById('fileInput');
        this.browseBtn = document.getElementById('browseBtn');
        this.fileInfo = document.getElementById('fileInfo');
        this.fileName = document.getElementById('fileName');
        this.fileSize = document.getElementById('fileSize');
        this.uploadBtn = document.getElementById('uploadBtn');
        this.clearBtn = document.getElementById('clearBtn');
        this.progressContainer = document.getElementById('progressContainer');
        this.progressBar = document.getElementById('progressBar');
        this.progressLabel = document.getElementById('progressLabel');
        this.progressPercent = document.getElementById('progressPercent');
        this.cancelBtn = document.getElementById('cancelBtn');
        this.alertContainer = document.getElementById('alertContainer');
        this.resultsCard = document.getElementById('resultsCard');
        
        // Result elements
        this.resultFileName = document.getElementById('resultFileName');
        this.resultFileSize = document.getElementById('resultFileSize');
        this.resultPageCount = document.getElementById('resultPageCount');
        this.resultProcessingTime = document.getElementById('resultProcessingTime');
        this.startCurationBtn = document.getElementById('startCurationBtn');
        this.uploadAnotherBtn = document.getElementById('uploadAnotherBtn');
    }

    attachEventListeners() {
        // File input events
        if (this.browseBtn) {
            this.browseBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.fileInput.click();
            });
        }
        
        if (this.fileInput) {
            this.fileInput.addEventListener('change', (e) => this.handleFileSelect(e));
        }
        
        // Action button events
        if (this.uploadBtn) {
            this.uploadBtn.addEventListener('click', () => this.uploadFile());
        }
        
        if (this.clearBtn) {
            this.clearBtn.addEventListener('click', () => this.clearFile());
        }
        
        if (this.cancelBtn) {
            this.cancelBtn.addEventListener('click', () => this.cancelUpload());
        }
        
        // Result button events
        if (this.startCurationBtn) {
            this.startCurationBtn.addEventListener('click', () => this.startEntityRecognition());
        }
        
        if (this.uploadAnotherBtn) {
            this.uploadAnotherBtn.addEventListener('click', () => this.resetUpload());
        }
    }

    setupDragAndDrop() {
        if (!this.dropZone) {
            console.error('Drop zone element not found!');
            return;
        }

        // Prevent default drag behaviors on document body
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            document.body.addEventListener(eventName, (e) => this.preventDefaults(e), false);
        });

        // Handle drag events on drop zone
        this.dropZone.addEventListener('dragenter', (e) => {
            this.preventDefaults(e);
            this.highlight();
        });

        this.dropZone.addEventListener('dragover', (e) => {
            this.preventDefaults(e);
            this.highlight();
        });

        this.dropZone.addEventListener('dragleave', (e) => {
            this.preventDefaults(e);
            this.unhighlight();
        });

        this.dropZone.addEventListener('drop', (e) => {
            this.preventDefaults(e);
            this.unhighlight();
            this.handleDrop(e);
        });
        
        // Click to browse
        this.dropZone.addEventListener('click', () => this.fileInput.click());
    }

    /**
     * Check session status and attempt recovery on page load
     */
    async checkSessionOnLoad() {
        try {
            // Check if we have active uploads or need session recovery
            const sessionInfo = await this.getSessionInfo();
            if (sessionInfo && sessionInfo.activeUploadsCount > 0) {
                this.showAlert('info', `Found ${sessionInfo.activeUploadsCount} active upload(s) from previous session. Checking status...`);
                // Could implement logic to resume showing progress for active uploads
            }
        } catch (error) {
            // Try session recovery if we have a recovery token in local storage
            this.attemptSessionRecovery();
        }
    }

    /**
     * Get session information
     */
    async getSessionInfo() {
        if (!this.config.sessionId) return null;
        
        try {
            const response = await fetch(`${this.config.contextPath}/curation/pdf/session-info.html?sessionId=${this.config.sessionId}`);
            if (response.ok) {
                return await response.json();
            }
        } catch (error) {
            console.warn('Failed to get session info:', error);
        }
        return null;
    }

    /**
     * Attempt to recover session using recovery token
     */
    async attemptSessionRecovery() {
        if (this.sessionRecoveryAttempted) return;
        this.sessionRecoveryAttempted = true;

        const recoveryToken = localStorage.getItem('curationRecoveryToken');
        if (!recoveryToken) return;

        try {
            const response = await fetch(`${this.config.contextPath}/curation/pdf/recover-session.html`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `recoveryToken=${encodeURIComponent(recoveryToken)}`
            });

            const result = await response.json();
            if (result.success) {
                this.config.sessionId = result.sessionId;
                this.showAlert('success', 'Session recovered successfully!');
                
                // Check for active uploads
                if (result.activeUploads && result.activeUploads.length > 0) {
                    this.showAlert('info', `Found ${result.activeUploads.length} active upload(s). Status will be checked automatically.`);
                }
            } else {
                // Clear invalid recovery token
                localStorage.removeItem('curationRecoveryToken');
            }
        } catch (error) {
            console.warn('Session recovery failed:', error);
            localStorage.removeItem('curationRecoveryToken');
        }
    }

    /**
     * Store recovery token for session recovery
     */
    storeRecoveryToken() {
        // This would be called when session is first created
        // The token should be provided by the server
        const recoveryToken = this.config.recoveryToken;
        if (recoveryToken) {
            localStorage.setItem('curationRecoveryToken', recoveryToken);
        }
    }

    preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    highlight() {
        this.dropZone.classList.add('dragover');
    }

    unhighlight() {
        this.dropZone.classList.remove('dragover');
    }

    handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0) {
            this.handleFileSelect({ target: { files: files } });
        }
    }

    handleFileSelect(e) {
        const files = e.target.files;
        if (files.length === 0) return;

        const file = files[0];
        
        // Validate file
        const validation = this.validateFile(file);
        if (!validation.valid) {
            this.showAlert('danger', validation.message);
            return;
        }

        this.selectedFile = file;
        this.displayFileInfo(file);
        this.hideElement(this.dropZone);
        this.showElement(this.fileInfo);
    }

    validateFile(file) {
        // Check file type
        if (file.type !== 'application/pdf' && !file.name.toLowerCase().endsWith('.pdf')) {
            return { valid: false, message: 'Only PDF files are allowed.' };
        }

        // Check file size
        if (file.size > this.config.maxFileSize) {
            const maxSizeMB = Math.round(this.config.maxFileSize / (1024 * 1024));
            return { valid: false, message: `File size exceeds maximum limit of ${maxSizeMB}MB.` };
        }

        // Check if file is empty
        if (file.size === 0) {
            return { valid: false, message: 'File appears to be empty.' };
        }

        return { valid: true };
    }

    displayFileInfo(file) {
        this.fileName.textContent = file.name;
        this.fileSize.textContent = this.formatFileSize(file.size);
    }

    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    async uploadFile() {
        if (!this.selectedFile) {
            this.showAlert('warning', 'Please select a file first.');
            return;
        }

        const formData = new FormData();
        formData.append('file', this.selectedFile);
        formData.append('sessionId', this.config.sessionId);

        try {
            this.showProgress('Uploading file...', 0);
            this.uploadBtn.disabled = true;

            const response = await fetch(`${this.config.contextPath}/curation/pdf/upload.html`, {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                this.uploadId = result.uploadId;
                this.showAlert('success', result.message);
                this.startStatusPolling();
            } else {
                // Enhanced error handling with error codes
                let errorMessage = result.message;
                if (result.errorCode) {
                    errorMessage += ` (Error Code: ${result.errorCode})`;
                }
                
                this.showAlert('danger', errorMessage);
                
                // Show additional error details if available
                if (result.errorDetails && result.errorDetails !== result.message) {
                    console.error('Detailed error information:', result.errorDetails);
                }
                
                this.hideProgress();
                this.uploadBtn.disabled = false;
            }

        } catch (error) {
            console.error('Upload error:', error);
            this.showAlert('danger', 'An error occurred during upload. Please try again.');
            this.hideProgress();
            this.uploadBtn.disabled = false;
        }
    }

    startStatusPolling() {
        this.statusInterval = setInterval(() => {
            this.checkUploadStatus();
        }, 1000);
    }

    async checkUploadStatus() {
        if (!this.uploadId) return;

        try {
            const response = await fetch(
                `${this.config.contextPath}/curation/pdf/status.html?uploadId=${this.uploadId}&sessionId=${this.config.sessionId}`
            );

            if (!response.ok) {
                throw new Error('Failed to get status');
            }

            const status = await response.json();
            this.updateProgress(status);

            if (status.status === 'COMPLETED') {
                this.handleUploadComplete(status);
            } else if (status.status === 'PARTIAL') {
                this.handlePartialComplete(status);
            } else if (status.status === 'FAILED' || status.status === 'CANCELLED') {
                this.handleUploadError(status);
            }

        } catch (error) {
            console.error('Status check error:', error);
            this.showAlert('warning', 'Unable to check upload status. Please refresh the page.');
        }
    }

    updateProgress(status) {
        const progress = status.progress || 0;
        let label = 'Processing...';
        
        switch (status.status) {
            case 'UPLOADING':
                label = 'Uploading file...';
                break;
            case 'PROCESSING':
                label = 'Extracting text from PDF...';
                break;
            case 'COMPLETED':
                label = 'Processing complete!';
                break;
            case 'PARTIAL':
                label = 'Partially processed';
                break;
            case 'FAILED':
                label = 'Processing failed';
                break;
            case 'CANCELLED':
                label = 'Processing cancelled';
                break;
        }

        this.updateProgressBar(progress, label);
    }

    updateProgressBar(progress, label) {
        this.progressBar.style.width = `${progress}%`;
        this.progressBar.setAttribute('aria-valuenow', progress);
        this.progressLabel.textContent = label;
        this.progressPercent.textContent = `${progress}%`;

        if (progress >= 100) {
            this.progressBar.classList.remove('progress-bar-animated');
        }
    }

    handleUploadComplete(status) {
        clearInterval(this.statusInterval);
        this.hideProgress();
        this.showUploadResults(status);
        this.showAlert('success', 'PDF processing completed successfully!');
    }

    handlePartialComplete(status) {
        clearInterval(this.statusInterval);
        this.hideProgress();
        this.showUploadResults(status);
        this.showAlert('warning', 'PDF was partially processed due to file issues. Some content may be missing.');
        
        // Show additional warning about partial processing
        if (status.errorDetails) {
            console.warn('Partial processing details:', status.errorDetails);
        }
    }

    handleUploadError(status) {
        clearInterval(this.statusInterval);
        this.hideProgress();
        this.uploadBtn.disabled = false;
        
        const message = status.errorDetails || status.message || 'Processing failed';
        this.showAlert('danger', message);
    }

    showUploadResults(status) {
        this.resultFileName.textContent = status.fileName || this.selectedFile.name;
        this.resultFileSize.textContent = this.formatFileSize(status.fileSize || this.selectedFile.size);
        this.resultPageCount.textContent = status.pageCount || 'Unknown';
        this.resultProcessingTime.textContent = status.processingTimeMs ? 
            `${(status.processingTimeMs / 1000).toFixed(1)}s` : 'Unknown';

        this.showElement(this.resultsCard);
        this.resultsCard.scrollIntoView({ behavior: 'smooth' });
    }

    async cancelUpload() {
        if (!this.uploadId) return;

        try {
            const response = await fetch(`${this.config.contextPath}/curation/pdf/cancel.html`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `uploadId=${this.uploadId}&sessionId=${this.config.sessionId}`
            });

            const result = await response.json();
            
            if (result.success) {
                clearInterval(this.statusInterval);
                this.hideProgress();
                this.uploadBtn.disabled = false;
                this.showAlert('info', 'Upload cancelled successfully.');
            } else {
                this.showAlert('warning', result.message || 'Could not cancel upload.');
            }

        } catch (error) {
            console.error('Cancel error:', error);
            this.showAlert('danger', 'Error cancelling upload.');
        }
    }

    clearFile() {
        this.selectedFile = null;
        this.uploadId = null;
        this.fileInput.value = '';
        
        this.hideElement(this.fileInfo);
        this.showElement(this.dropZone);
        this.clearAlerts();
    }

    resetUpload() {
        this.clearFile();
        this.hideElement(this.resultsCard);
        this.hideProgress();
        this.uploadBtn.disabled = false;
        
        if (this.statusInterval) {
            clearInterval(this.statusInterval);
        }
    }

    startEntityRecognition() {
        if (this.uploadId) {
            const url = `${this.config.contextPath}/curation/entity/recognize.html?uploadId=${this.uploadId}`;
            window.location.href = url;
        }
    }

    showProgress(label, progress) {
        this.updateProgressBar(progress, label);
        this.showElement(this.progressContainer);
        this.hideElement(this.fileInfo);
    }

    hideProgress() {
        this.hideElement(this.progressContainer);
    }

    showAlert(type, message) {
        const alertId = 'alert-' + Date.now();
        const alertHtml = `
            <div id="${alertId}" class="alert alert-${type} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        `;
        
        this.alertContainer.insertAdjacentHTML('beforeend', alertHtml);
        
        // Auto-dismiss success alerts after 5 seconds
        if (type === 'success') {
            setTimeout(() => {
                const alert = document.getElementById(alertId);
                if (alert) {
                    const bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                }
            }, 5000);
        }
    }

    clearAlerts() {
        this.alertContainer.innerHTML = '';
    }

    showElement(element) {
        element.classList.remove('d-none');
        element.classList.add('fade-in');
    }

    hideElement(element) {
        element.classList.add('d-none');
        element.classList.remove('fade-in');
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    window.pdfUploadManager = new PdfUploadManager();
});

// Global function for refreshing session status
window.refreshSessionStatus = async function() {
    if (window.pdfUploadManager) {
        const sessionInfo = await window.pdfUploadManager.getSessionInfo();
        if (sessionInfo && sessionInfo.success) {
            const message = `Session Status: ${sessionInfo.activeUploadsCount} active uploads, ` +
                          `${sessionInfo.totalUploads} total uploads (${sessionInfo.successfulUploads} successful, ${sessionInfo.failedUploads} failed)`;
            window.pdfUploadManager.showAlert('info', message);
        } else {
            window.pdfUploadManager.showAlert('warning', 'Unable to retrieve session status');
        }
    }
};

// Handle page visibility for status polling
document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
        // Pause status polling when page is hidden
        // Implementation can be added here if needed
    } else {
        // Resume status polling when page becomes visible
        // Implementation can be added here if needed
    }
});