package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for service status and health information.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ServiceStatusResponse {

    private boolean success;
    private LocalDateTime timestamp;
    
    private boolean overallHealthy;
    private boolean aiServiceHealthy;
    private String aiServiceStatus;
    
    private boolean ontologyLoaded;
    private Integer ontologyTermCount;
    private List<String> ontologyNamespaces;
    
    private boolean updateInProgress;
    private LocalDateTime lastUpdateCheck;
    
    private boolean cacheEnabled;
    private Double cacheHitRate;
    
    private String systemVersion;
    private Long uptimeMs;
    private String errorMessage;

    /**
     * Default constructor
     */
    public ServiceStatusResponse() {
        this.timestamp = LocalDateTime.now();
    }

    /**
     * Create error response
     */
    public static ServiceStatusResponse error(String errorMessage) {
        ServiceStatusResponse response = new ServiceStatusResponse();
        response.setSuccess(false);
        response.setErrorMessage(errorMessage);
        response.setOverallHealthy(false);
        return response;
    }

    // Getters and Setters

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public boolean isOverallHealthy() {
        return overallHealthy;
    }

    public void setOverallHealthy(boolean overallHealthy) {
        this.overallHealthy = overallHealthy;
    }

    public boolean isAiServiceHealthy() {
        return aiServiceHealthy;
    }

    public void setAiServiceHealthy(boolean aiServiceHealthy) {
        this.aiServiceHealthy = aiServiceHealthy;
    }

    public String getAiServiceStatus() {
        return aiServiceStatus;
    }

    public void setAiServiceStatus(String aiServiceStatus) {
        this.aiServiceStatus = aiServiceStatus;
    }

    public boolean isOntologyLoaded() {
        return ontologyLoaded;
    }

    public void setOntologyLoaded(boolean ontologyLoaded) {
        this.ontologyLoaded = ontologyLoaded;
    }

    public Integer getOntologyTermCount() {
        return ontologyTermCount;
    }

    public void setOntologyTermCount(Integer ontologyTermCount) {
        this.ontologyTermCount = ontologyTermCount;
    }

    public List<String> getOntologyNamespaces() {
        return ontologyNamespaces;
    }

    public void setOntologyNamespaces(List<String> ontologyNamespaces) {
        this.ontologyNamespaces = ontologyNamespaces;
    }

    public boolean isUpdateInProgress() {
        return updateInProgress;
    }

    public void setUpdateInProgress(boolean updateInProgress) {
        this.updateInProgress = updateInProgress;
    }

    public LocalDateTime getLastUpdateCheck() {
        return lastUpdateCheck;
    }

    public void setLastUpdateCheck(LocalDateTime lastUpdateCheck) {
        this.lastUpdateCheck = lastUpdateCheck;
    }

    public boolean isCacheEnabled() {
        return cacheEnabled;
    }

    public void setCacheEnabled(boolean cacheEnabled) {
        this.cacheEnabled = cacheEnabled;
    }

    public Double getCacheHitRate() {
        return cacheHitRate;
    }

    public void setCacheHitRate(Double cacheHitRate) {
        this.cacheHitRate = cacheHitRate;
    }

    public String getSystemVersion() {
        return systemVersion;
    }

    public void setSystemVersion(String systemVersion) {
        this.systemVersion = systemVersion;
    }

    public Long getUptimeMs() {
        return uptimeMs;
    }

    public void setUptimeMs(Long uptimeMs) {
        this.uptimeMs = uptimeMs;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return String.format("ServiceStatusResponse{overallHealthy=%s, aiServiceHealthy=%s, " +
                           "ontologyLoaded=%s, termCount=%d, cacheEnabled=%s, updateInProgress=%s}",
                overallHealthy, aiServiceHealthy, ontologyLoaded, ontologyTermCount, 
                cacheEnabled, updateInProgress);
    }
}