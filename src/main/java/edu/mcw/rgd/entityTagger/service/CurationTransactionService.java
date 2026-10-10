package edu.mcw.rgd.entityTagger.service;

import edu.mcw.rgd.entityTagger.dao.BatchProcessingJobDao;
import edu.mcw.rgd.entityTagger.dao.CurationSessionDao;
import edu.mcw.rgd.entityTagger.dao.RecognizedEntityDao;
import edu.mcw.rgd.entityTagger.model.BatchProcessingJob;
import edu.mcw.rgd.entityTagger.model.CurationSession;
import edu.mcw.rgd.entityTagger.model.RecognizedEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service demonstrating integrated transaction management for curation operations.
 * Shows how to coordinate multiple DAO operations within transactions and use
 * the TransactionService for complex scenarios.
 */
@Service
public class CurationTransactionService {

    private static final Logger logger = LoggerFactory.getLogger(CurationTransactionService.class);

    @Autowired
    private CurationSessionDao curationSessionDao;

    @Autowired
    private RecognizedEntityDao recognizedEntityDao;

    @Autowired
    private BatchProcessingJobDao batchProcessingJobDao;

    @Autowired
    private TransactionService transactionService;

    /**
     * Create a new curation session with initial setup.
     * Demonstrates basic transactional coordination between DAOs.
     */
    @Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_COMMITTED)
    public CurationSession createCurationSession(String userId, String sessionName, String description) {
        logger.info("Creating new curation session for user: {}", userId);

        CurationSession session = new CurationSession();
        session.setUserId(userId);
        session.setSessionName(sessionName);
        session.setDescription(description);
        session.setStatus(CurationSession.SessionStatus.ACTIVE);
        session.setStartTime(LocalDateTime.now());
        session.setLastActivity(LocalDateTime.now());

        // Save the session
        CurationSession savedSession = curationSessionDao.save(session);
        logger.debug("Created curation session with ID: {}", savedSession.getSessionId());

        return savedSession;
    }

    /**
     * Process a batch of entities within a curation session.
     * Demonstrates transaction coordination across multiple DAOs with error handling.
     */
    @Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_COMMITTED)
    public BatchProcessingJob processBatchEntities(Long sessionId, String batchId, List<RecognizedEntity> entities) {
        logger.info("Processing batch {} for session {} with {} entities", batchId, sessionId, entities.size());

        // Update session activity
        CurationSession session = curationSessionDao.findById(sessionId)
            .orElseThrow(() -> new IllegalArgumentException("Session not found: " + sessionId));
        
        session.setLastActivity(LocalDateTime.now());
        session.incrementEntitiesProcessed(entities.size());
        curationSessionDao.update(session);

        // Create batch processing job
        BatchProcessingJob job = new BatchProcessingJob();
        job.setBatchId(batchId);
        job.setSessionId(sessionId);
        job.setUserId(session.getUserId());
        job.setStatus(BatchProcessingJob.JobStatus.IN_PROGRESS);
        job.setTotalItems(entities.size());
        job.setStartTime(LocalDateTime.now());
        job.setJobType("ENTITY_RECOGNITION");

        BatchProcessingJob savedJob = batchProcessingJobDao.save(job);

        try {
            // Process entities in batches using TransactionService
            int processed = 0;
            int failed = 0;

            for (RecognizedEntity entity : entities) {
                try {
                    entity.setSessionId(sessionId);
                    entity.setBatchId(batchId);
                    recognizedEntityDao.save(entity);
                    processed++;
                } catch (Exception e) {
                    logger.error("Failed to save entity: {}", entity.getEntityText(), e);
                    failed++;
                }
            }

            // Update job progress
            batchProcessingJobDao.updateJobProgress(savedJob.getJobId(), processed, failed);
            
            if (failed == 0) {
                batchProcessingJobDao.completeJob(savedJob.getJobId(), 
                    String.format("Successfully processed %d entities", processed));
            } else {
                String errorMessage = String.format("Processed %d entities, %d failed", processed, failed);
                batchProcessingJobDao.failJob(savedJob.getJobId(), errorMessage);
            }

            logger.info("Batch processing completed: {} processed, {} failed", processed, failed);
            return batchProcessingJobDao.findById(savedJob.getJobId()).orElse(savedJob);

        } catch (Exception e) {
            logger.error("Batch processing failed for batch: {}", batchId, e);
            batchProcessingJobDao.failJob(savedJob.getJobId(), "Batch processing failed: " + e.getMessage());
            throw e; // Re-throw to trigger transaction rollback
        }
    }

    /**
     * Clean up old session data using complex transaction management.
     * Demonstrates use of TransactionService for custom transaction scenarios.
     */
    public void cleanupOldSessions(int daysOld) {
        logger.info("Starting cleanup of sessions older than {} days", daysOld);

        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(daysOld);

        // Use TransactionService for complex cleanup with retry logic
        transactionService.executeWithRetry(() -> {
            // Find old sessions to clean up
            List<CurationSession> oldSessions = curationSessionDao.findByStatusAndDateRange(
                CurationSession.SessionStatus.COMPLETED, null, cutoffDate);

            logger.info("Found {} old sessions to clean up", oldSessions.size());

            for (CurationSession session : oldSessions) {
                cleanupSessionData(session);
            }

            return oldSessions.size();
        }, 3, 1000);
    }

    /**
     * Clean up data for a specific session in a separate transaction.
     * Demonstrates REQUIRES_NEW propagation for cleanup operations.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW, isolation = Isolation.READ_COMMITTED)
    public void cleanupSessionData(CurationSession session) {
        logger.debug("Cleaning up data for session: {}", session.getSessionId());

        try {
            // Delete related entities first (foreign key constraints)
            List<RecognizedEntity> entities = recognizedEntityDao.findBySessionId(session.getSessionId());
            if (!entities.isEmpty()) {
                recognizedEntityDao.batchDelete(entities);
                logger.debug("Deleted {} entities for session {}", entities.size(), session.getSessionId());
            }

            // Delete batch processing jobs
            List<BatchProcessingJob> jobs = batchProcessingJobDao.findBySessionId(session.getSessionId());
            for (BatchProcessingJob job : jobs) {
                batchProcessingJobDao.deleteById(job.getJobId());
            }
            logger.debug("Deleted {} jobs for session {}", jobs.size(), session.getSessionId());

            // Finally delete the session
            curationSessionDao.delete(session);
            logger.debug("Deleted session: {}", session.getSessionId());

        } catch (Exception e) {
            logger.error("Failed to cleanup session: {}", session.getSessionId(), e);
            throw e; // Re-throw to trigger rollback of this transaction
        }
    }

    /**
     * Get comprehensive session statistics using read-only transaction.
     * Demonstrates read-only transaction optimization.
     */
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public SessionStatistics getSessionStatistics(Long sessionId) {
        logger.debug("Calculating statistics for session: {}", sessionId);

        CurationSession session = curationSessionDao.findById(sessionId)
            .orElseThrow(() -> new IllegalArgumentException("Session not found: " + sessionId));

        // Use TransactionService for read-only operations
        return transactionService.executeInReadOnlyTransaction(() -> {
            SessionStatistics stats = new SessionStatistics();
            stats.setSessionId(sessionId);
            stats.setSessionName(session.getSessionName());
            stats.setStatus(session.getStatus());
            stats.setStartTime(session.getStartTime());
            stats.setLastActivity(session.getLastActivity());

            // Count entities
            List<RecognizedEntity> entities = recognizedEntityDao.findBySessionId(sessionId);
            stats.setTotalEntities(entities.size());
            stats.setValidatedEntities((int) entities.stream().filter(e -> e.getValidationStatus() != null).count());

            // Count jobs
            List<BatchProcessingJob> jobs = batchProcessingJobDao.findBySessionId(sessionId);
            stats.setTotalJobs(jobs.size());
            stats.setCompletedJobs((int) jobs.stream()
                .filter(j -> j.getStatus() == BatchProcessingJob.JobStatus.COMPLETED).count());
            stats.setFailedJobs((int) jobs.stream()
                .filter(j -> j.getStatus() == BatchProcessingJob.JobStatus.FAILED).count());

            return stats;
        });
    }

    /**
     * Rollback a session to a previous state.
     * Demonstrates manual transaction control for complex rollback scenarios.
     */
    public void rollbackSession(Long sessionId, LocalDateTime rollbackTo) {
        logger.info("Rolling back session {} to {}", sessionId, rollbackTo);

        transactionService.executeWithManualTransaction(status -> {
            try {
                // Find entities created after rollback point
                List<RecognizedEntity> entitiesToRemove = recognizedEntityDao.findBySessionIdAndDateRange(
                    sessionId, rollbackTo, LocalDateTime.now());

                if (!entitiesToRemove.isEmpty()) {
                    recognizedEntityDao.batchDelete(entitiesToRemove);
                    logger.info("Removed {} entities created after rollback point", entitiesToRemove.size());
                }

                // Cancel jobs created after rollback point
                List<BatchProcessingJob> jobsToCancel = batchProcessingJobDao.findBySessionId(sessionId).stream()
                    .filter(job -> job.getStartTime().isAfter(rollbackTo))
                    .toList();

                for (BatchProcessingJob job : jobsToCancel) {
                    batchProcessingJobDao.cancelJob(job.getJobId());
                }
                logger.info("Cancelled {} jobs created after rollback point", jobsToCancel.size());

                // Update session
                CurationSession session = curationSessionDao.findById(sessionId)
                    .orElseThrow(() -> new IllegalArgumentException("Session not found: " + sessionId));
                
                session.setLastActivity(LocalDateTime.now());
                session.decrementEntitiesProcessed(entitiesToRemove.size());
                curationSessionDao.update(session);

                return null;

            } catch (Exception e) {
                logger.error("Rollback failed for session: {}", sessionId, e);
                status.setRollbackOnly();
                throw new RuntimeException("Rollback failed: " + e.getMessage(), e);
            }
        });
    }

    /**
     * Statistics holder for session information.
     */
    public static class SessionStatistics {
        private Long sessionId;
        private String sessionName;
        private CurationSession.SessionStatus status;
        private LocalDateTime startTime;
        private LocalDateTime lastActivity;
        private int totalEntities;
        private int validatedEntities;
        private int totalJobs;
        private int completedJobs;
        private int failedJobs;

        // Getters and setters
        public Long getSessionId() { return sessionId; }
        public void setSessionId(Long sessionId) { this.sessionId = sessionId; }

        public String getSessionName() { return sessionName; }
        public void setSessionName(String sessionName) { this.sessionName = sessionName; }

        public CurationSession.SessionStatus getStatus() { return status; }
        public void setStatus(CurationSession.SessionStatus status) { this.status = status; }

        public LocalDateTime getStartTime() { return startTime; }
        public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

        public LocalDateTime getLastActivity() { return lastActivity; }
        public void setLastActivity(LocalDateTime lastActivity) { this.lastActivity = lastActivity; }

        public int getTotalEntities() { return totalEntities; }
        public void setTotalEntities(int totalEntities) { this.totalEntities = totalEntities; }

        public int getValidatedEntities() { return validatedEntities; }
        public void setValidatedEntities(int validatedEntities) { this.validatedEntities = validatedEntities; }

        public int getTotalJobs() { return totalJobs; }
        public void setTotalJobs(int totalJobs) { this.totalJobs = totalJobs; }

        public int getCompletedJobs() { return completedJobs; }
        public void setCompletedJobs(int completedJobs) { this.completedJobs = completedJobs; }

        public int getFailedJobs() { return failedJobs; }
        public void setFailedJobs(int failedJobs) { this.failedJobs = failedJobs; }

        @Override
        public String toString() {
            return String.format("SessionStatistics{sessionId=%d, name='%s', entities=%d/%d, jobs=%d/%d/%d}", 
                               sessionId, sessionName, validatedEntities, totalEntities, 
                               completedJobs, failedJobs, totalJobs);
        }
    }
}