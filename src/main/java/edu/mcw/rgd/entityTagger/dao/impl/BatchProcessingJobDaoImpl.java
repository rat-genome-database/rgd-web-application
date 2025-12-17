package edu.mcw.rgd.entityTagger.dao.impl;

import edu.mcw.rgd.entityTagger.dao.BatchProcessingJobDao;
import edu.mcw.rgd.entityTagger.model.BatchProcessingJob;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Implementation of BatchProcessingJobDao using JDBC.
 * Handles database operations for BatchProcessingJob entities.
 */
@Repository
public class BatchProcessingJobDaoImpl extends BaseDaoImpl<BatchProcessingJob, Long> implements BatchProcessingJobDao {

    private static final String TABLE_NAME = "BATCH_PROCESSING_JOBS";
    private static final String ID_COLUMN = "JOB_ID";

    public BatchProcessingJobDaoImpl(DataSource dataSource) {
        super(dataSource);
    }

    @Override
    protected String getTableName() {
        return TABLE_NAME;
    }

    @Override
    protected String getIdColumnName() {
        return ID_COLUMN;
    }

    @Override
    protected String getInsertSql() {
        return """
            INSERT INTO BATCH_PROCESSING_JOBS (
                BATCH_ID, SESSION_ID, USER_ID, STATUS, TOTAL_ITEMS,
                COMPLETED_ITEMS, FAILED_ITEMS, START_TIME, LAST_UPDATE_TIME,
                PROCESSING_TIME_MS, CONFIGURATION, PRIORITY, JOB_TYPE
            ) VALUES (
                :batchId, :sessionId, :userId, :status, :totalItems,
                :completedItems, :failedItems, :startTime, :lastUpdateTime,
                :processingTimeMs, :configuration, :priority, :jobType
            )
            """;
    }

    @Override
    protected String getUpdateSql() {
        return """
            UPDATE BATCH_PROCESSING_JOBS SET
                BATCH_ID = :batchId,
                SESSION_ID = :sessionId,
                USER_ID = :userId,
                STATUS = :status,
                TOTAL_ITEMS = :totalItems,
                COMPLETED_ITEMS = :completedItems,
                FAILED_ITEMS = :failedItems,
                ERROR_MESSAGE = :errorMessage,
                END_TIME = :endTime,
                LAST_UPDATE_TIME = :lastUpdateTime,
                PROCESSING_TIME_MS = :processingTimeMs,
                CONFIGURATION = :configuration,
                RESULTS_SUMMARY = :resultsSummary,
                PRIORITY = :priority,
                JOB_TYPE = :jobType
            WHERE JOB_ID = :jobId
            """;
    }

    @Override
    protected String getSelectByIdSql() {
        return "SELECT * FROM " + TABLE_NAME + " WHERE " + ID_COLUMN + " = :id";
    }

    @Override
    protected String getSelectAllSql() {
        return "SELECT * FROM " + TABLE_NAME + " ORDER BY START_TIME DESC";
    }

    @Override
    protected RowMapper<BatchProcessingJob> getRowMapper() {
        return new BatchProcessingJobRowMapper();
    }

    @Override
    protected Long extractId(BatchProcessingJob entity) {
        return entity.getJobId();
    }

    @Override
    protected void setId(BatchProcessingJob entity, Long id) {
        entity.setJobId(id);
    }

    @Override
    public Optional<BatchProcessingJob> findByBatchId(String batchId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE BATCH_ID = :batchId";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("batchId", batchId);
        
        return queryForObject(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findByUserId(String userId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE USER_ID = :userId ORDER BY START_TIME DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("userId", userId);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findByStatus(BatchProcessingJob.JobStatus status) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE STATUS = :status ORDER BY START_TIME DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", status.name());
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findBySessionId(Long sessionId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE SESSION_ID = :sessionId ORDER BY START_TIME DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("sessionId", sessionId);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findByJobType(String jobType) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE JOB_TYPE = :jobType ORDER BY START_TIME DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobType", jobType);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE START_TIME >= :startDate AND START_TIME <= :endDate ORDER BY START_TIME DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findRunningJobs() {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE STATUS IN (:statuses) ORDER BY START_TIME";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("statuses", Arrays.asList(
            BatchProcessingJob.JobStatus.PENDING.name(),
            BatchProcessingJob.JobStatus.IN_PROGRESS.name(),
            BatchProcessingJob.JobStatus.PAUSED.name()
        ));
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findLongRunningJobs(int runningMinutes) {
        String sql = """
            SELECT * FROM BATCH_PROCESSING_JOBS 
            WHERE STATUS = :status 
                AND START_TIME < :cutoffTime
            ORDER BY START_TIME
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", BatchProcessingJob.JobStatus.IN_PROGRESS.name());
        parameterSource.addValue("cutoffTime", LocalDateTime.now().minusMinutes(runningMinutes));
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findPendingJobsByPriority(int limit) {
        String sql = """
            SELECT * FROM BATCH_PROCESSING_JOBS 
            WHERE STATUS = :status 
            ORDER BY PRIORITY ASC, START_TIME ASC
            FETCH FIRST :limit ROWS ONLY
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", BatchProcessingJob.JobStatus.PENDING.name());
        parameterSource.addValue("limit", limit);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findFailedJobsForRetry(int maxRetryAge) {
        String sql = """
            SELECT * FROM BATCH_PROCESSING_JOBS 
            WHERE STATUS = :status 
                AND END_TIME >= :minRetryTime
            ORDER BY END_TIME DESC
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", BatchProcessingJob.JobStatus.FAILED.name());
        parameterSource.addValue("minRetryTime", LocalDateTime.now().minusHours(maxRetryAge));
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public boolean updateJobStatus(Long jobId, BatchProcessingJob.JobStatus status) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                STATUS = :status,
                LAST_UPDATE_TIME = :now
            WHERE JOB_ID = :jobId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobId", jobId);
        parameterSource.addValue("status", status.name());
        parameterSource.addValue("now", LocalDateTime.now());
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean updateJobProgress(Long jobId, int completedItems, int failedItems) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                COMPLETED_ITEMS = :completedItems,
                FAILED_ITEMS = :failedItems,
                LAST_UPDATE_TIME = :now
            WHERE JOB_ID = :jobId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobId", jobId);
        parameterSource.addValue("completedItems", completedItems);
        parameterSource.addValue("failedItems", failedItems);
        parameterSource.addValue("now", LocalDateTime.now());
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean incrementJobProgress(Long jobId, int additionalCompleted, int additionalFailed) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                COMPLETED_ITEMS = COMPLETED_ITEMS + :additionalCompleted,
                FAILED_ITEMS = FAILED_ITEMS + :additionalFailed,
                LAST_UPDATE_TIME = :now
            WHERE JOB_ID = :jobId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobId", jobId);
        parameterSource.addValue("additionalCompleted", additionalCompleted);
        parameterSource.addValue("additionalFailed", additionalFailed);
        parameterSource.addValue("now", LocalDateTime.now());
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean completeJob(Long jobId, String resultsSummary) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                STATUS = :status,
                END_TIME = :now,
                LAST_UPDATE_TIME = :now,
                RESULTS_SUMMARY = :resultsSummary,
                PROCESSING_TIME_MS = EXTRACT(EPOCH FROM (:now - START_TIME)) * 1000
            WHERE JOB_ID = :jobId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobId", jobId);
        parameterSource.addValue("status", BatchProcessingJob.JobStatus.COMPLETED.name());
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("resultsSummary", resultsSummary);
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean failJob(Long jobId, String errorMessage) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                STATUS = :status,
                ERROR_MESSAGE = :errorMessage,
                END_TIME = :now,
                LAST_UPDATE_TIME = :now,
                PROCESSING_TIME_MS = EXTRACT(EPOCH FROM (:now - START_TIME)) * 1000
            WHERE JOB_ID = :jobId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobId", jobId);
        parameterSource.addValue("status", BatchProcessingJob.JobStatus.FAILED.name());
        parameterSource.addValue("errorMessage", errorMessage);
        parameterSource.addValue("now", LocalDateTime.now());
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean cancelJob(Long jobId) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                STATUS = :status,
                END_TIME = :now,
                LAST_UPDATE_TIME = :now
            WHERE JOB_ID = :jobId AND STATUS IN (:allowedStatuses)
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("jobId", jobId);
        parameterSource.addValue("status", BatchProcessingJob.JobStatus.CANCELLED.name());
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("allowedStatuses", Arrays.asList(
            BatchProcessingJob.JobStatus.PENDING.name(),
            BatchProcessingJob.JobStatus.IN_PROGRESS.name(),
            BatchProcessingJob.JobStatus.PAUSED.name()
        ));
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean pauseJob(Long jobId) {
        return updateJobStatus(jobId, BatchProcessingJob.JobStatus.PAUSED);
    }

    @Override
    public boolean resumeJob(Long jobId) {
        return updateJobStatus(jobId, BatchProcessingJob.JobStatus.IN_PROGRESS);
    }

    @Override
    public Map<String, Object> getJobStatistics(String userId) {
        String sql = """
            SELECT 
                COUNT(*) as total_jobs,
                SUM(CASE WHEN STATUS = 'COMPLETED' THEN 1 ELSE 0 END) as completed_jobs,
                SUM(CASE WHEN STATUS = 'FAILED' THEN 1 ELSE 0 END) as failed_jobs,
                SUM(CASE WHEN STATUS = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled_jobs,
                COALESCE(AVG(PROCESSING_TIME_MS), 0) as avg_processing_time
            FROM BATCH_PROCESSING_JOBS 
            WHERE USER_ID = :userId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("userId", userId);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getJobStatisticsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = """
            SELECT 
                COUNT(*) as total_jobs,
                COUNT(DISTINCT USER_ID) as unique_users,
                SUM(CASE WHEN STATUS = 'COMPLETED' THEN 1 ELSE 0 END) as completed_jobs,
                SUM(CASE WHEN STATUS = 'FAILED' THEN 1 ELSE 0 END) as failed_jobs,
                COALESCE(SUM(TOTAL_ITEMS), 0) as total_items_processed,
                COALESCE(AVG(PROCESSING_TIME_MS), 0) as avg_processing_time,
                COALESCE(SUM(PROCESSING_TIME_MS), 0) as total_processing_time
            FROM BATCH_PROCESSING_JOBS 
            WHERE START_TIME >= :startDate AND START_TIME <= :endDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getJobPerformanceMetrics(int days) {
        String sql = """
            SELECT 
                COUNT(*) as total_jobs,
                ROUND(SUM(CASE WHEN STATUS = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate,
                AVG(PROCESSING_TIME_MS) as avg_processing_time,
                AVG(TOTAL_ITEMS) as avg_items_per_job,
                COUNT(CASE WHEN STATUS IN ('PENDING', 'IN_PROGRESS') THEN 1 END) as active_jobs
            FROM BATCH_PROCESSING_JOBS 
            WHERE START_TIME >= :startDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", LocalDateTime.now().minusDays(days));
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public List<BatchProcessingJob> findJobsWithLowSuccessRate(double successRateThreshold, int minimumItems) {
        String sql = """
            SELECT * FROM BATCH_PROCESSING_JOBS 
            WHERE TOTAL_ITEMS >= :minimumItems
                AND STATUS IN ('COMPLETED', 'FAILED')
                AND COALESCE(COMPLETED_ITEMS, 0) * 1.0 / TOTAL_ITEMS < :threshold
            ORDER BY START_TIME DESC
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("minimumItems", minimumItems);
        parameterSource.addValue("threshold", successRateThreshold);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getQueueStatus() {
        String sql = """
            SELECT 
                COUNT(CASE WHEN STATUS = 'PENDING' THEN 1 END) as pending_count,
                COUNT(CASE WHEN STATUS = 'IN_PROGRESS' THEN 1 END) as running_count,
                COUNT(CASE WHEN STATUS = 'PAUSED' THEN 1 END) as paused_count,
                AVG(CASE WHEN STATUS = 'COMPLETED' AND PROCESSING_TIME_MS > 0 
                    THEN PROCESSING_TIME_MS END) as avg_completion_time
            FROM BATCH_PROCESSING_JOBS 
            WHERE START_TIME >= :recentDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("recentDate", LocalDateTime.now().minusHours(24));
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public int deleteOldCompletedJobs(int daysOld) {
        String sql = """
            DELETE FROM BATCH_PROCESSING_JOBS 
            WHERE STATUS IN ('COMPLETED', 'FAILED', 'CANCELLED')
                AND END_TIME < :cutoffDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("cutoffDate", LocalDateTime.now().minusDays(daysOld));
        
        return namedParameterJdbcTemplate.update(sql, parameterSource);
    }

    @Override
    public int resetStuckJobs(int stuckMinutes) {
        String sql = """
            UPDATE BATCH_PROCESSING_JOBS SET
                STATUS = 'FAILED',
                ERROR_MESSAGE = 'Job reset due to inactivity',
                END_TIME = :now,
                LAST_UPDATE_TIME = :now
            WHERE STATUS = 'IN_PROGRESS'
                AND LAST_UPDATE_TIME < :cutoffTime
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("cutoffTime", LocalDateTime.now().minusMinutes(stuckMinutes));
        
        return namedParameterJdbcTemplate.update(sql, parameterSource);
    }

    @Override
    public List<Map<String, Object>> getJobCompletionTrends(int days) {
        String sql = """
            SELECT 
                TO_CHAR(START_TIME, 'YYYY-MM-DD') as job_date,
                COUNT(*) as total_jobs,
                SUM(CASE WHEN STATUS = 'COMPLETED' THEN 1 ELSE 0 END) as completed_jobs,
                SUM(CASE WHEN STATUS = 'FAILED' THEN 1 ELSE 0 END) as failed_jobs,
                ROUND(SUM(CASE WHEN STATUS = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate
            FROM BATCH_PROCESSING_JOBS 
            WHERE START_TIME >= :startDate
            GROUP BY TO_CHAR(START_TIME, 'YYYY-MM-DD')
            ORDER BY job_date
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", LocalDateTime.now().minusDays(days));
        
        return namedParameterJdbcTemplate.queryForList(sql, parameterSource);
    }

    @Override
    public List<Map<String, Object>> findMostResourceIntensiveJobs(int limit, String orderBy) {
        String orderClause = "processing_time".equals(orderBy) ? "PROCESSING_TIME_MS" : "TOTAL_ITEMS";
        
        String sql = """
            SELECT 
                JOB_ID,
                BATCH_ID,
                USER_ID,
                TOTAL_ITEMS,
                PROCESSING_TIME_MS,
                STATUS,
                START_TIME
            FROM BATCH_PROCESSING_JOBS 
            ORDER BY %s DESC NULLS LAST
            FETCH FIRST :limit ROWS ONLY
            """.formatted(orderClause);
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("limit", limit);
        
        return namedParameterJdbcTemplate.queryForList(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getAverageProcessingTimeByType(int days) {
        String sql = """
            SELECT 
                COALESCE(JOB_TYPE, 'unknown') as job_type,
                COUNT(*) as job_count,
                AVG(PROCESSING_TIME_MS) as avg_processing_time,
                AVG(TOTAL_ITEMS) as avg_items_per_job
            FROM BATCH_PROCESSING_JOBS 
            WHERE START_TIME >= :startDate
                AND STATUS = 'COMPLETED'
                AND PROCESSING_TIME_MS > 0
            GROUP BY JOB_TYPE
            ORDER BY avg_processing_time DESC
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", LocalDateTime.now().minusDays(days));
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    /**
     * Row mapper for converting database rows to BatchProcessingJob objects.
     */
    private static class BatchProcessingJobRowMapper implements RowMapper<BatchProcessingJob> {
        @Override
        public BatchProcessingJob mapRow(ResultSet rs, int rowNum) throws SQLException {
            BatchProcessingJob job = new BatchProcessingJob();
            
            job.setJobId(rs.getLong("JOB_ID"));
            job.setBatchId(rs.getString("BATCH_ID"));
            job.setSessionId(rs.getLong("SESSION_ID"));
            job.setUserId(rs.getString("USER_ID"));
            
            String statusStr = rs.getString("STATUS");
            if (statusStr != null) {
                job.setStatus(BatchProcessingJob.JobStatus.valueOf(statusStr));
            }
            
            job.setTotalItems(rs.getInt("TOTAL_ITEMS"));
            job.setCompletedItems(rs.getInt("COMPLETED_ITEMS"));
            job.setFailedItems(rs.getInt("FAILED_ITEMS"));
            job.setErrorMessage(rs.getString("ERROR_MESSAGE"));
            
            if (rs.getTimestamp("START_TIME") != null) {
                job.setStartTime(rs.getTimestamp("START_TIME").toLocalDateTime());
            }
            if (rs.getTimestamp("END_TIME") != null) {
                job.setEndTime(rs.getTimestamp("END_TIME").toLocalDateTime());
            }
            if (rs.getTimestamp("LAST_UPDATE_TIME") != null) {
                job.setLastUpdateTime(rs.getTimestamp("LAST_UPDATE_TIME").toLocalDateTime());
            }
            
            job.setProcessingTimeMs(rs.getLong("PROCESSING_TIME_MS"));
            job.setConfiguration(rs.getString("CONFIGURATION"));
            job.setResultsSummary(rs.getString("RESULTS_SUMMARY"));
            job.setPriority(rs.getInt("PRIORITY"));
            job.setJobType(rs.getString("JOB_TYPE"));
            
            return job;
        }
    }
    
    // Missing implementation for new method
    @Override
    public void completeJob(Long jobId, String status, String result) {
        // TODO: Implement job completion
    }
}