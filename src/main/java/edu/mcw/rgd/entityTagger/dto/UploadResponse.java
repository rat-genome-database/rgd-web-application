package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Response object for PDF upload operations.
 * Contains upload status, metadata, and processing information.
 */
public class UploadResponse {
    
    @JsonProperty("success")
    private boolean success;
    
    @JsonProperty("message")
    private String message;
    
    @JsonProperty("uploadId")
    private Long uploadId;
    
    @JsonProperty("sessionId")
    private String sessionId;
    
    @JsonProperty("fileName")
    private String fileName;
    
    @JsonProperty("fileSize")
    private Long fileSize;
    
    @JsonProperty("timestamp")
    private Long timestamp;
    
    @JsonProperty("errorCode")
    private String errorCode;
    
    @JsonProperty("errorDetails")
    private String errorDetails;

    public UploadResponse() {
        this.timestamp = System.currentTimeMillis();
    }

    // Getters and setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Long getUploadId() {
        return uploadId;
    }

    public void setUploadId(Long uploadId) {
        this.uploadId = uploadId;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
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

    public Long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Long timestamp) {
        this.timestamp = timestamp;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorDetails() {
        return errorDetails;
    }

    public void setErrorDetails(String errorDetails) {
        this.errorDetails = errorDetails;
    }

    @Override
    public String toString() {
        return "UploadResponse{" +
                "success=" + success +
                ", message='" + message + '\'' +
                ", uploadId=" + uploadId +
                ", sessionId='" + sessionId + '\'' +
                ", fileName='" + fileName + '\'' +
                ", fileSize=" + fileSize +
                ", timestamp=" + timestamp +
                ", errorCode='" + errorCode + '\'' +
                ", errorDetails='" + errorDetails + '\'' +
                '}';
    }
}