package edu.mcw.rgd.entityTagger.model;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entity representing a batch processing job in the database.
 * Tracks the status and progress of batch entity recognition operations.
 */
public class BatchProcessingJob {
    
    private Long jobId;
    private String batchId;
    private Long sessionId;
    private String userId;
    private JobStatus status;
    private Integer totalItems;
    private Integer completedItems;
    private Integer failedItems;
    private String errorMessage;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastUpdateTime;
    
    private Long processingTimeMs;
    private String configuration;
    private String resultsSummary;
    private Integer priority;
    private String jobType;

    public enum JobStatus {
        PENDING,
        IN_PROGRESS,
        COMPLETED,
        FAILED,
        CANCELLED,
        PAUSED
    }

    public BatchProcessingJob() {
        this.startTime = LocalDateTime.now();
        this.lastUpdateTime = LocalDateTime.now();
        this.status = JobStatus.PENDING;
        this.totalItems = 0;
        this.completedItems = 0;
        this.failedItems = 0;
        this.processingTimeMs = 0L;
        this.priority = 5; // Default priority (1=highest, 10=lowest)
    }

    public BatchProcessingJob(String batchId, String userId, Integer totalItems) {
        this();
        this.batchId = batchId;
        this.userId = userId;
        this.totalItems = totalItems;
    }

    // Getters and Setters

    public Long getJobId() {
        return jobId;
    }

    public void setJobId(Long jobId) {
        this.jobId = jobId;
    }

    public String getBatchId() {
        return batchId;
    }

    public void setBatchId(String batchId) {
        this.batchId = batchId;
    }

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public JobStatus getStatus() {
        return status;
    }

    public void setStatus(JobStatus status) {
        this.status = status;
        this.lastUpdateTime = LocalDateTime.now();
    }

    public Integer getTotalItems() {
        return totalItems;
    }

    public void setTotalItems(Integer totalItems) {
        this.totalItems = totalItems;
    }

    public Integer getCompletedItems() {
        return completedItems;
    }

    public void setCompletedItems(Integer completedItems) {
        this.completedItems = completedItems;
        this.lastUpdateTime = LocalDateTime.now();
    }

    public Integer getFailedItems() {
        return failedItems;
    }

    public void setFailedItems(Integer failedItems) {
        this.failedItems = failedItems;
        this.lastUpdateTime = LocalDateTime.now();
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public LocalDateTime getLastUpdateTime() {
        return lastUpdateTime;
    }

    public void setLastUpdateTime(LocalDateTime lastUpdateTime) {
        this.lastUpdateTime = lastUpdateTime;
    }

    public Long getProcessingTimeMs() {
        return processingTimeMs;
    }

    public void setProcessingTimeMs(Long processingTimeMs) {
        this.processingTimeMs = processingTimeMs;
    }

    public String getConfiguration() {
        return configuration;
    }

    public void setConfiguration(String configuration) {
        this.configuration = configuration;
    }

    public String getResultsSummary() {
        return resultsSummary;
    }

    public void setResultsSummary(String resultsSummary) {
        this.resultsSummary = resultsSummary;
    }

    public Integer getPriority() {
        return priority;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public String getJobType() {
        return jobType;
    }

    public void setJobType(String jobType) {
        this.jobType = jobType;
    }

    // Utility methods

    /**
     * Start the job processing and update status.
     */
    public void start() {
        this.status = JobStatus.IN_PROGRESS;
        this.startTime = LocalDateTime.now();
        this.lastUpdateTime = LocalDateTime.now();
    }

    /**
     * Complete the job successfully.
     */
    public void complete() {
        this.status = JobStatus.COMPLETED;
        this.endTime = LocalDateTime.now();
        this.lastUpdateTime = LocalDateTime.now();
        calculateProcessingTime();
    }

    /**
     * Mark the job as failed with an error message.
     * 
     * @param errorMessage The error message describing the failure
     */
    public void fail(String errorMessage) {
        this.status = JobStatus.FAILED;
        this.errorMessage = errorMessage;
        this.endTime = LocalDateTime.now();
        this.lastUpdateTime = LocalDateTime.now();
        calculateProcessingTime();
    }

    /**
     * Cancel the job.
     */
    public void cancel() {
        this.status = JobStatus.CANCELLED;
        this.endTime = LocalDateTime.now();
        this.lastUpdateTime = LocalDateTime.now();
        calculateProcessingTime();
    }

    /**
     * Pause the job.
     */
    public void pause() {
        this.status = JobStatus.PAUSED;
        this.lastUpdateTime = LocalDateTime.now();
        calculateProcessingTime();
    }

    /**
     * Resume a paused job.
     */
    public void resume() {
        if (JobStatus.PAUSED.equals(this.status)) {
            this.status = JobStatus.IN_PROGRESS;
            this.lastUpdateTime = LocalDateTime.now();
        }
    }

    /**
     * Increment the completed items count.
     * 
     * @param count Number of items to add to completed count
     */
    public void addCompletedItems(int count) {
        this.completedItems += count;
        this.lastUpdateTime = LocalDateTime.now();
    }

    /**
     * Increment the failed items count.
     * 
     * @param count Number of items to add to failed count
     */
    public void addFailedItems(int count) {
        this.failedItems += count;
        this.lastUpdateTime = LocalDateTime.now();
    }

    /**
     * Calculate the processing time based on start and end times.
     */
    private void calculateProcessingTime() {
        if (this.startTime != null && this.endTime != null) {
            this.processingTimeMs = java.time.Duration.between(this.startTime, this.endTime).toMillis();
        }
    }

    /**
     * Get the progress percentage of the job.
     * 
     * @return Progress as a percentage (0.0 to 100.0)
     */
    public double getProgressPercentage() {
        if (totalItems == null || totalItems == 0) {
            return 0.0;
        }
        int processedItems = (completedItems != null ? completedItems : 0) + (failedItems != null ? failedItems : 0);
        return (double) processedItems / totalItems * 100.0;
    }

    /**
     * Check if the job is in a terminal state (completed, failed, or cancelled).
     * 
     * @return true if job is finished, false otherwise
     */
    public boolean isFinished() {
        return JobStatus.COMPLETED.equals(this.status) || 
               JobStatus.FAILED.equals(this.status) || 
               JobStatus.CANCELLED.equals(this.status);
    }

    /**
     * Check if the job is currently running.
     * 
     * @return true if job is in progress, false otherwise
     */
    public boolean isRunning() {
        return JobStatus.IN_PROGRESS.equals(this.status);
    }

    /**
     * Get the success rate of the job.
     * 
     * @return Success rate as a percentage (0.0 to 100.0)
     */
    public double getSuccessRate() {
        int processedItems = (completedItems != null ? completedItems : 0) + (failedItems != null ? failedItems : 0);
        if (processedItems == 0) {
            return 100.0;
        }
        return (double) (completedItems != null ? completedItems : 0) / processedItems * 100.0;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BatchProcessingJob that = (BatchProcessingJob) o;
        return Objects.equals(jobId, that.jobId) &&
               Objects.equals(batchId, that.batchId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(jobId, batchId);
    }

    @Override
    public String toString() {
        return "BatchProcessingJob{" +
                "jobId=" + jobId +
                ", batchId='" + batchId + '\'' +
                ", userId='" + userId + '\'' +
                ", status=" + status +
                ", totalItems=" + totalItems +
                ", completedItems=" + completedItems +
                ", failedItems=" + failedItems +
                ", progressPercentage=" + String.format("%.1f", getProgressPercentage()) + "%" +
                '}';
    }
}