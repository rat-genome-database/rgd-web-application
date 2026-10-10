package edu.mcw.rgd.entityTagger.dao;

import edu.mcw.rgd.entityTagger.model.BatchProcessingJob;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Data Access Object interface for BatchProcessingJob entities.
 * Provides methods for managing batch processing jobs in the database.
 */
public interface BatchProcessingJobDao extends BaseDao<BatchProcessingJob, Long> {

    /**
     * Find a batch processing job by its batch ID.
     * 
     * @param batchId The unique batch ID
     * @return Optional containing the job if found, empty otherwise
     */
    Optional<BatchProcessingJob> findByBatchId(String batchId);

    /**
     * Find all jobs for a specific user.
     * 
     * @param userId The user ID
     * @return List of jobs for the user
     */
    List<BatchProcessingJob> findByUserId(String userId);

    /**
     * Find jobs by status.
     * 
     * @param status The job status
     * @return List of jobs with the specified status
     */
    List<BatchProcessingJob> findByStatus(BatchProcessingJob.JobStatus status);

    /**
     * Find jobs associated with a specific session.
     * 
     * @param sessionId The session ID
     * @return List of jobs for the session
     */
    List<BatchProcessingJob> findBySessionId(Long sessionId);

    /**
     * Find jobs by job type.
     * 
     * @param jobType The job type
     * @return List of jobs of the specified type
     */
    List<BatchProcessingJob> findByJobType(String jobType);

    /**
     * Find jobs started within a date range.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return List of jobs started in the date range
     */
    List<BatchProcessingJob> findByDateRange(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Find running jobs (in progress or pending).
     * 
     * @return List of currently running jobs
     */
    List<BatchProcessingJob> findRunningJobs();

    /**
     * Find jobs that have been running longer than the specified minutes.
     * 
     * @param runningMinutes Number of minutes a job has been running
     * @return List of long-running jobs
     */
    List<BatchProcessingJob> findLongRunningJobs(int runningMinutes);

    /**
     * Find pending jobs ordered by priority.
     * 
     * @param limit Maximum number of jobs to return
     * @return List of pending jobs ordered by priority (highest first)
     */
    List<BatchProcessingJob> findPendingJobsByPriority(int limit);

    /**
     * Find failed jobs that can be retried.
     * 
     * @param maxRetryAge Maximum age in hours for jobs to be considered for retry
     * @return List of failed jobs that can be retried
     */
    List<BatchProcessingJob> findFailedJobsForRetry(int maxRetryAge);

    /**
     * Update job status and last update time.
     * 
     * @param jobId The job ID
     * @param status The new status
     * @return true if update was successful, false otherwise
     */
    boolean updateJobStatus(Long jobId, BatchProcessingJob.JobStatus status);

    /**
     * Update job progress (completed and failed items).
     * 
     * @param jobId The job ID
     * @param completedItems Number of completed items
     * @param failedItems Number of failed items
     * @return true if update was successful, false otherwise
     */
    boolean updateJobProgress(Long jobId, int completedItems, int failedItems);

    /**
     * Update job progress incrementally.
     * 
     * @param jobId The job ID
     * @param additionalCompleted Additional completed items to add
     * @param additionalFailed Additional failed items to add
     * @return true if update was successful, false otherwise
     */
    boolean incrementJobProgress(Long jobId, int additionalCompleted, int additionalFailed);

    /**
     * Complete a job and set end time.
     * 
     * @param jobId The job ID
     * @param resultsSummary Optional results summary
     * @return true if update was successful, false otherwise
     */
    boolean completeJob(Long jobId, String resultsSummary);

    /**
     * Mark a job as failed with error message.
     * 
     * @param jobId The job ID
     * @param errorMessage The error message
     * @return true if update was successful, false otherwise
     */
    boolean failJob(Long jobId, String errorMessage);

    /**
     * Cancel a job.
     * 
     * @param jobId The job ID
     * @return true if cancellation was successful, false otherwise
     */
    boolean cancelJob(Long jobId);

    /**
     * Pause a job.
     * 
     * @param jobId The job ID
     * @return true if pause was successful, false otherwise
     */
    boolean pauseJob(Long jobId);

    /**
     * Resume a paused job.
     * 
     * @param jobId The job ID
     * @return true if resume was successful, false otherwise
     */
    boolean resumeJob(Long jobId);

    /**
     * Get job statistics for a user.
     * 
     * @param userId The user ID
     * @return Map containing statistics (total_jobs, completed_jobs, failed_jobs, avg_processing_time)
     */
    Map<String, Object> getJobStatistics(String userId);

    /**
     * Get job statistics for a date range.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return Map containing statistics for the date range
     */
    Map<String, Object> getJobStatisticsByDateRange(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get job performance metrics.
     * 
     * @param days Number of days to look back
     * @return Map containing performance metrics
     */
    Map<String, Object> getJobPerformanceMetrics(int days);

    /**
     * Find jobs with low success rates.
     * 
     * @param successRateThreshold Minimum success rate threshold (0.0 to 1.0)
     * @param minimumItems Minimum number of items processed to be considered
     * @return List of jobs with low success rates
     */
    List<BatchProcessingJob> findJobsWithLowSuccessRate(double successRateThreshold, int minimumItems);

    /**
     * Get queue status information.
     * 
     * @return Map containing queue statistics (pending_count, running_count, estimated_wait_time)
     */
    Map<String, Object> getQueueStatus();

    /**
     * Clean up old completed jobs.
     * 
     * @param daysOld Number of days after which completed jobs should be deleted
     * @return Number of jobs deleted
     */
    int deleteOldCompletedJobs(int daysOld);

    /**
     * Reset stuck jobs (jobs that appear to be running but haven't been updated recently).
     * 
     * @param stuckMinutes Number of minutes without update to consider a job stuck
     * @return Number of jobs reset
     */
    int resetStuckJobs(int stuckMinutes);

    /**
     * Get daily job completion trends.
     * 
     * @param days Number of days to look back
     * @return List of daily completion counts and success rates
     */
    List<Map<String, Object>> getJobCompletionTrends(int days);

    /**
     * Find the most resource-intensive jobs (by processing time or item count).
     * 
     * @param limit Maximum number of results to return
     * @param orderBy Sort criteria ("processing_time" or "total_items")
     * @return List of resource-intensive jobs
     */
    List<Map<String, Object>> findMostResourceIntensiveJobs(int limit, String orderBy);

    /**
     * Get average processing time by job type.
     * 
     * @param days Number of days to look back
     * @return Map of job types and their average processing times
     */
    Map<String, Object> getAverageProcessingTimeByType(int days);
    
    // Additional methods used by CurationTransactionService
    BatchProcessingJob save(BatchProcessingJob job);
    void completeJob(Long jobId, String status, String result);
    void deleteById(Long jobId);
}