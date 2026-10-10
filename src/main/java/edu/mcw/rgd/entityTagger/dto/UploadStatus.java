package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Status object for tracking PDF upload and processing progress.
 */
public class UploadStatus {
    
    @JsonProperty("uploadId")
    private Long uploadId;
    
    @JsonProperty("status")
    private String status; // UPLOADING, PROCESSING, COMPLETED, FAILED, CANCELLED
    
    @JsonProperty("message")
    private String message;
    
    @JsonProperty("progress")
    private Integer progress; // 0-100
    
    @JsonProperty("fileName")
    private String fileName;
    
    @JsonProperty("fileSize")
    private Long fileSize;
    
    @JsonProperty("extractedText")
    private String extractedText;
    
    @JsonProperty("pageCount")
    private Integer pageCount;
    
    @JsonProperty("processingTimeMs")
    private Long processingTimeMs;
    
    @JsonProperty("errorDetails")
    private String errorDetails;
    
    @JsonProperty("timestamp")
    private Long timestamp;

    public UploadStatus() {
        this.timestamp = System.currentTimeMillis();
    }

    // Getters and setters
    public Long getUploadId() {
        return uploadId;
    }

    public void setUploadId(Long uploadId) {
        this.uploadId = uploadId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getProgress() {
        return progress;
    }

    public void setProgress(Integer progress) {
        this.progress = progress;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getExtractedText() {
        return extractedText;
    }

    public void setExtractedText(String extractedText) {
        this.extractedText = extractedText;
    }

    public Integer getPageCount() {
        return pageCount;
    }

    public void setPageCount(Integer pageCount) {
        this.pageCount = pageCount;
    }

    public Long getProcessingTimeMs() {
        return processingTimeMs;
    }

    public void setProcessingTimeMs(Long processingTimeMs) {
        this.processingTimeMs = processingTimeMs;
    }

    public String getErrorDetails() {
        return errorDetails;
    }

    public void setErrorDetails(String errorDetails) {
        this.errorDetails = errorDetails;
    }

    public Long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Long timestamp) {
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "UploadStatus{" +
                "uploadId=" + uploadId +
                ", status='" + status + '\'' +
                ", message='" + message + '\'' +
                ", progress=" + progress +
                ", fileName='" + fileName + '\'' +
                ", fileSize=" + fileSize +
                ", pageCount=" + pageCount +
                ", processingTimeMs=" + processingTimeMs +
                ", timestamp=" + timestamp +
                '}';
    }
}