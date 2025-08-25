package edu.mcw.rgd.curation.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.mcw.rgd.curation.config.CurationConfig;
import edu.mcw.rgd.curation.config.TestConfig;
import edu.mcw.rgd.curation.service.TempFileManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests for MaintenanceController.
 * Tests maintenance operations in a full Spring context with realistic scenarios.
 */
@SpringJUnitConfig
@WebAppConfiguration
@Import({CurationConfig.class, TestConfig.class})
@ActiveProfiles("test")
class MaintenanceControllerIntegrationTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private TempFileManager tempFileManager;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
    }

    // ================================
    // Temp File Statistics Integration Tests
    // ================================

    @Test
    void testTempFileStats_RealWorldScenario() throws Exception {
        // Arrange - Simulate realistic file statistics
        TempFileManager.TempFileStats stats = createRealisticStats();
        when(tempFileManager.getFileStats()).thenReturn(stats);

        // Act & Assert
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalFiles").value(15))
                .andExpect(jsonPath("$.totalSizeBytes").value(52428800L)) // 50MB
                .andExpect(jsonPath("$.totalSizeFormatted").value("50.0 MB"))
                .andExpect(jsonPath("$.oldestFileAgeMs").value(7200000L)) // 2 hours
                .andExpect(jsonPath("$.oldestFileAgeFormatted").value("2.0 hrs"));

        verify(tempFileManager).getFileStats();
    }

    @Test
    void testTempFileStats_EmptyDirectory() throws Exception {
        // Arrange - No temporary files
        TempFileManager.TempFileStats emptyStats = createEmptyStats();
        when(tempFileManager.getFileStats()).thenReturn(emptyStats);

        // Act & Assert
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalFiles").value(0))
                .andExpect(jsonPath("$.totalSizeBytes").value(0L))
                .andExpect(jsonPath("$.totalSizeFormatted").value("0 B"))
                .andExpect(jsonPath("$.oldestFileAgeMs").value(0L))
                .andExpect(jsonPath("$.oldestFileAgeFormatted").value("0 ms"));
    }

    @Test
    void testTempFileStats_LargeFiles() throws Exception {
        // Arrange - Simulate large file scenario
        TempFileManager.TempFileStats largeStats = createLargeFileStats();
        when(tempFileManager.getFileStats()).thenReturn(largeStats);

        // Act & Assert
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalFiles").value(100))
                .andExpect(jsonPath("$.totalSizeBytes").value(5368709120L)) // 5GB
                .andExpect(jsonPath("$.totalSizeFormatted").value("5.0 GB"))
                .andExpect(jsonPath("$.oldestFileAgeMs").value(604800000L)) // 7 days
                .andExpect(jsonPath("$.oldestFileAgeFormatted").value("7.0 days"));
    }

    @Test
    void testTempFileStats_ServiceException() throws Exception {
        // Arrange - Simulate file system error
        when(tempFileManager.getFileStats())
                .thenThrow(new RuntimeException("File system access denied"));

        // Act & Assert
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("Failed to get file statistics")))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("File system access denied")));
    }

    // ================================
    // Temp File Cleanup Integration Tests
    // ================================

    @Test
    void testTempFileCleanup_SuccessfulCleanup() throws Exception {
        // Arrange - Before and after cleanup stats
        TempFileManager.TempFileStats beforeStats = createRealisticStats();
        TempFileManager.TempFileStats afterStats = createPostCleanupStats();
        
        when(tempFileManager.getFileStats())
                .thenReturn(beforeStats)   // First call for "before" stats
                .thenReturn(afterStats);   // Second call for "after" stats
        when(tempFileManager.cleanupAllFiles()).thenReturn(12); // 12 files cleaned

        // Act & Assert
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.filesRemoved").value(12))
                .andExpect(jsonPath("$.message").value("Cleanup completed successfully"))
                .andExpect(jsonPath("$.beforeStats.totalFiles").value(15))
                .andExpect(jsonPath("$.beforeStats.totalSizeBytes").value(52428800L))
                .andExpect(jsonPath("$.afterStats.totalFiles").value(3))
                .andExpect(jsonPath("$.afterStats.totalSizeBytes").value(5242880L)); // 5MB remaining

        verify(tempFileManager, times(2)).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    @Test
    void testTempFileCleanup_NothingToClean() throws Exception {
        // Arrange - Empty directory scenario
        TempFileManager.TempFileStats emptyStats = createEmptyStats();
        
        when(tempFileManager.getFileStats()).thenReturn(emptyStats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(0);

        // Act & Assert
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.filesRemoved").value(0))
                .andExpect(jsonPath("$.message").value("Cleanup completed successfully"))
                .andExpect(jsonPath("$.beforeStats.totalFiles").value(0))
                .andExpect(jsonPath("$.afterStats.totalFiles").value(0));
    }

    @Test
    void testTempFileCleanup_PartialCleanup() throws Exception {
        // Arrange - Some files couldn't be cleaned (e.g., in use)
        TempFileManager.TempFileStats beforeStats = createLargeFileStats();
        TempFileManager.TempFileStats afterStats = createPartialCleanupStats();
        
        when(tempFileManager.getFileStats())
                .thenReturn(beforeStats)
                .thenReturn(afterStats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(75); // 75 out of 100 files cleaned

        // Act & Assert
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.filesRemoved").value(75))
                .andExpect(jsonPath("$.beforeStats.totalFiles").value(100))
                .andExpect(jsonPath("$.afterStats.totalFiles").value(25)); // 25 files remaining
    }

    @Test
    void testTempFileCleanup_CleanupException() throws Exception {
        // Arrange - Cleanup operation fails
        TempFileManager.TempFileStats beforeStats = createRealisticStats();
        
        when(tempFileManager.getFileStats()).thenReturn(beforeStats);
        when(tempFileManager.cleanupAllFiles())
                .thenThrow(new RuntimeException("Permission denied: cannot delete files"));

        // Act & Assert
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("Cleanup failed")))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("Permission denied")));

        verify(tempFileManager).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    @Test
    void testTempFileCleanup_StatsRetrievalFailure() throws Exception {
        // Arrange - Stats retrieval fails during cleanup
        when(tempFileManager.getFileStats())
                .thenThrow(new RuntimeException("Disk I/O error"));

        // Act & Assert
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("Cleanup failed")))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("Disk I/O error")));

        verify(tempFileManager).getFileStats();
        verify(tempFileManager, never()).cleanupAllFiles();
    }

    // ================================
    // Realistic Maintenance Workflow Tests
    // ================================

    @Test
    void testMaintenanceWorkflow_MonitorAndCleanup() throws Exception {
        // Simulate a realistic maintenance workflow:
        // 1. Check stats to see if cleanup is needed
        // 2. Perform cleanup if threshold is exceeded
        // 3. Verify cleanup results

        // Step 1: Check initial stats (high usage)
        TempFileManager.TempFileStats highUsageStats = createHighUsageStats();
        when(tempFileManager.getFileStats()).thenReturn(highUsageStats);

        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalFiles").value(250))
                .andExpect(jsonPath("$.totalSizeBytes").value(1073741824L)); // 1GB

        // Step 2: Perform cleanup (threshold exceeded)
        TempFileManager.TempFileStats afterCleanupStats = createPostMajorCleanupStats();
        
        when(tempFileManager.getFileStats())
                .thenReturn(highUsageStats)
                .thenReturn(afterCleanupStats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(200);

        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.filesRemoved").value(200))
                .andExpect(jsonPath("$.beforeStats.totalFiles").value(250))
                .andExpect(jsonPath("$.afterStats.totalFiles").value(50));

        // Step 3: Verify final stats
        when(tempFileManager.getFileStats()).thenReturn(afterCleanupStats);

        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalFiles").value(50))
                .andExpect(jsonPath("$.totalSizeBytes").value(52428800L)); // 50MB

        verify(tempFileManager, times(4)).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    // ================================
    // Security and Authorization Tests
    // ================================

    @Test
    void testMaintenanceEndpoints_GET_AccessControl() throws Exception {
        // These endpoints should be accessible for monitoring
        TempFileManager.TempFileStats stats = createRealisticStats();
        when(tempFileManager.getFileStats()).thenReturn(stats);

        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void testMaintenanceEndpoints_POST_AccessControl() throws Exception {
        // POST operations should also be accessible in test environment
        TempFileManager.TempFileStats stats = createRealisticStats();
        when(tempFileManager.getFileStats()).thenReturn(stats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(5);

        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    // ================================
    // Content Type and Response Format Tests
    // ================================

    @Test
    void testMaintenanceEndpoints_ResponseFormat() throws Exception {
        // Ensure consistent JSON response format
        TempFileManager.TempFileStats stats = createRealisticStats();
        when(tempFileManager.getFileStats()).thenReturn(stats);

        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").exists())
                .andExpect(jsonPath("$.totalFiles").exists())
                .andExpect(jsonPath("$.totalSizeBytes").exists())
                .andExpect(jsonPath("$.totalSizeFormatted").exists())
                .andExpect(jsonPath("$.oldestFileAgeMs").exists())
                .andExpect(jsonPath("$.oldestFileAgeFormatted").exists());
    }

    // ================================
    // Helper Methods
    // ================================

    private TempFileManager.TempFileStats createRealisticStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(15);
        when(stats.getTotalSizeBytes()).thenReturn(52428800L); // 50MB
        when(stats.getOldestFileAge()).thenReturn(7200000L); // 2 hours
        return stats;
    }

    private TempFileManager.TempFileStats createEmptyStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(0);
        when(stats.getTotalSizeBytes()).thenReturn(0L);
        when(stats.getOldestFileAge()).thenReturn(0L);
        return stats;
    }

    private TempFileManager.TempFileStats createLargeFileStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(100);
        when(stats.getTotalSizeBytes()).thenReturn(5368709120L); // 5GB
        when(stats.getOldestFileAge()).thenReturn(604800000L); // 7 days
        return stats;
    }

    private TempFileManager.TempFileStats createPostCleanupStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(3);
        when(stats.getTotalSizeBytes()).thenReturn(5242880L); // 5MB
        when(stats.getOldestFileAge()).thenReturn(1800000L); // 30 minutes
        return stats;
    }

    private TempFileManager.TempFileStats createPartialCleanupStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(25);
        when(stats.getTotalSizeBytes()).thenReturn(1342177280L); // 1.25GB
        when(stats.getOldestFileAge()).thenReturn(86400000L); // 1 day
        return stats;
    }

    private TempFileManager.TempFileStats createHighUsageStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(250);
        when(stats.getTotalSizeBytes()).thenReturn(1073741824L); // 1GB
        when(stats.getOldestFileAge()).thenReturn(259200000L); // 3 days
        return stats;
    }

    private TempFileManager.TempFileStats createPostMajorCleanupStats() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(50);
        when(stats.getTotalSizeBytes()).thenReturn(52428800L); // 50MB
        when(stats.getOldestFileAge()).thenReturn(3600000L); // 1 hour
        return stats;
    }
}