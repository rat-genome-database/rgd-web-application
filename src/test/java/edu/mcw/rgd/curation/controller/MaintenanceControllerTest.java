package edu.mcw.rgd.curation.controller;

import edu.mcw.rgd.curation.service.TempFileManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Unit tests for MaintenanceController.
 * Tests maintenance endpoints for temp file statistics and cleanup operations.
 */
@ExtendWith(MockitoExtension.class)
class MaintenanceControllerTest {

    @Mock
    private TempFileManager tempFileManager;

    @Mock
    private HttpServletRequest httpServletRequest;

    @InjectMocks
    private MaintenanceController maintenanceController;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(maintenanceController).build();
    }

    // ================================
    // Temp File Stats Tests
    // ================================

    @Test
    void testGetTempFileStats_Success() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(5, 1024000L, 3600000L);
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertTrue((Boolean) body.get("success"));
        assertEquals(5, body.get("totalFiles"));
        assertEquals(1024000L, body.get("totalSizeBytes"));
        assertEquals("1000.0 KB", body.get("totalSizeFormatted"));
        assertEquals(3600000L, body.get("oldestFileAgeMs"));
        assertEquals("1.0 hrs", body.get("oldestFileAgeFormatted"));
        
        verify(tempFileManager).getFileStats();
    }

    @Test
    void testGetTempFileStats_EmptyDirectory() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(0, 0L, 0L);
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertTrue((Boolean) body.get("success"));
        assertEquals(0, body.get("totalFiles"));
        assertEquals(0L, body.get("totalSizeBytes"));
        assertEquals("0 B", body.get("totalSizeFormatted"));
        assertEquals(0L, body.get("oldestFileAgeMs"));
        assertEquals("0 ms", body.get("oldestFileAgeFormatted"));
    }

    @Test
    void testGetTempFileStats_LargeFiles() {
        // Arrange
        long largeSize = 5L * 1024 * 1024 * 1024; // 5 GB
        TempFileManager.TempFileStats mockStats = createMockStats(100, largeSize, 86400000L * 7); // 7 days
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertTrue((Boolean) body.get("success"));
        assertEquals(100, body.get("totalFiles"));
        assertEquals(largeSize, body.get("totalSizeBytes"));
        assertEquals("5.0 GB", body.get("totalSizeFormatted"));
        assertEquals("7.0 days", body.get("oldestFileAgeFormatted"));
    }

    @Test
    void testGetTempFileStats_ServiceException() {
        // Arrange
        when(tempFileManager.getFileStats()).thenThrow(new RuntimeException("File system error"));

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertFalse((Boolean) body.get("success"));
        assertTrue(((String) body.get("message")).contains("Failed to get file statistics"));
        assertTrue(((String) body.get("message")).contains("File system error"));
        
        verify(tempFileManager).getFileStats();
    }

    // ================================
    // Temp File Cleanup Tests
    // ================================

    @Test
    void testCleanupTempFiles_Success() {
        // Arrange
        TempFileManager.TempFileStats beforeStats = createMockStats(10, 2048000L, 7200000L);
        TempFileManager.TempFileStats afterStats = createMockStats(3, 512000L, 1800000L);
        
        when(tempFileManager.getFileStats())
                .thenReturn(beforeStats)  // First call for "before" stats
                .thenReturn(afterStats);  // Second call for "after" stats
        when(tempFileManager.cleanupAllFiles()).thenReturn(7); // 7 files cleaned

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.cleanupTempFiles(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertTrue((Boolean) body.get("success"));
        assertEquals(7, body.get("filesRemoved"));
        assertTrue(((String) body.get("message")).contains("Cleanup completed successfully"));
        
        // Check before stats
        @SuppressWarnings("unchecked")
        Map<String, Object> beforeStatsMap = (Map<String, Object>) body.get("beforeStats");
        assertEquals(10, beforeStatsMap.get("totalFiles"));
        assertEquals(2048000L, beforeStatsMap.get("totalSizeBytes"));
        
        // Check after stats
        @SuppressWarnings("unchecked")
        Map<String, Object> afterStatsMap = (Map<String, Object>) body.get("afterStats");
        assertEquals(3, afterStatsMap.get("totalFiles"));
        assertEquals(512000L, afterStatsMap.get("totalSizeBytes"));
        
        verify(tempFileManager, times(2)).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    @Test
    void testCleanupTempFiles_NothingToClean() {
        // Arrange
        TempFileManager.TempFileStats emptyStats = createMockStats(0, 0L, 0L);
        
        when(tempFileManager.getFileStats()).thenReturn(emptyStats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(0); // No files cleaned

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.cleanupTempFiles(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertTrue((Boolean) body.get("success"));
        assertEquals(0, body.get("filesRemoved"));
        
        verify(tempFileManager, times(2)).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    @Test
    void testCleanupTempFiles_ServiceException() {
        // Arrange
        when(tempFileManager.getFileStats()).thenThrow(new RuntimeException("Cleanup failed"));

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.cleanupTempFiles(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertFalse((Boolean) body.get("success"));
        assertTrue(((String) body.get("message")).contains("Cleanup failed"));
        assertTrue(((String) body.get("message")).contains("Cleanup failed"));
        
        verify(tempFileManager).getFileStats();
        verify(tempFileManager, never()).cleanupAllFiles();
    }

    @Test
    void testCleanupTempFiles_CleanupException() {
        // Arrange
        TempFileManager.TempFileStats beforeStats = createMockStats(5, 1024000L, 3600000L);
        
        when(tempFileManager.getFileStats()).thenReturn(beforeStats);
        when(tempFileManager.cleanupAllFiles()).thenThrow(new RuntimeException("Permission denied"));

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.cleanupTempFiles(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        
        Map<String, Object> body = response.getBody();
        assertFalse((Boolean) body.get("success"));
        assertTrue(((String) body.get("message")).contains("Permission denied"));
        
        verify(tempFileManager).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    // ================================
    // Integration Tests with MockMvc
    // ================================

    @Test
    void testGetTempFileStats_MockMvc() throws Exception {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(3, 512000L, 1800000L);
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act & Assert
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalFiles").value(3))
                .andExpect(jsonPath("$.totalSizeBytes").value(512000))
                .andExpect(jsonPath("$.totalSizeFormatted").value("500.0 KB"));
    }

    @Test
    void testCleanupTempFiles_MockMvc() throws Exception {
        // Arrange
        TempFileManager.TempFileStats beforeStats = createMockStats(5, 1024000L, 3600000L);
        TempFileManager.TempFileStats afterStats = createMockStats(2, 512000L, 1800000L);
        
        when(tempFileManager.getFileStats())
                .thenReturn(beforeStats)
                .thenReturn(afterStats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(3);

        // Act & Assert
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.filesRemoved").value(3))
                .andExpect(jsonPath("$.beforeStats.totalFiles").value(5))
                .andExpect(jsonPath("$.afterStats.totalFiles").value(2));
    }

    // ================================
    // File Size Formatting Tests
    // ================================

    @Test
    void testFileSizeFormatting_Bytes() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 512L, 1000L);
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("512 B", body.get("totalSizeFormatted"));
    }

    @Test
    void testFileSizeFormatting_Kilobytes() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 1536L, 1000L); // 1.5 KB
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("1.5 KB", body.get("totalSizeFormatted"));
    }

    @Test
    void testFileSizeFormatting_Megabytes() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 2621440L, 1000L); // 2.5 MB
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("2.5 MB", body.get("totalSizeFormatted"));
    }

    @Test
    void testFileSizeFormatting_Gigabytes() {
        // Arrange
        long size = (long) (3.5 * 1024 * 1024 * 1024); // 3.5 GB
        TempFileManager.TempFileStats mockStats = createMockStats(1, size, 1000L);
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("3.5 GB", body.get("totalSizeFormatted"));
    }

    // ================================
    // Duration Formatting Tests
    // ================================

    @Test
    void testDurationFormatting_Milliseconds() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 1024L, 500L);
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("500 ms", body.get("oldestFileAgeFormatted"));
    }

    @Test
    void testDurationFormatting_Seconds() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 1024L, 30000L); // 30 seconds
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("30.0 sec", body.get("oldestFileAgeFormatted"));
    }

    @Test
    void testDurationFormatting_Minutes() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 1024L, 150000L); // 2.5 minutes
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("2.5 min", body.get("oldestFileAgeFormatted"));
    }

    @Test
    void testDurationFormatting_Hours() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 1024L, 7200000L); // 2 hours
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("2.0 hrs", body.get("oldestFileAgeFormatted"));
    }

    @Test
    void testDurationFormatting_Days() {
        // Arrange
        TempFileManager.TempFileStats mockStats = createMockStats(1, 1024L, 259200000L); // 3 days
        when(tempFileManager.getFileStats()).thenReturn(mockStats);

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.getTempFileStats(httpServletRequest);

        // Assert
        Map<String, Object> body = response.getBody();
        assertEquals("3.0 days", body.get("oldestFileAgeFormatted"));
    }

    // ================================
    // Edge Cases Tests
    // ================================

    @Test
    void testGetTempFileStats_NullStats() {
        // Arrange
        when(tempFileManager.getFileStats()).thenReturn(null);

        // Act & Assert
        assertThrows(NullPointerException.class, () -> {
            maintenanceController.getTempFileStats(httpServletRequest);
        });
    }

    @Test
    void testCleanupTempFiles_NegativeCleanupCount() {
        // Arrange - This scenario shouldn't happen in practice, but test defensive programming
        TempFileManager.TempFileStats stats = createMockStats(5, 1024000L, 3600000L);
        
        when(tempFileManager.getFileStats()).thenReturn(stats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(-1); // Unusual return value

        // Act
        ResponseEntity<Map<String, Object>> response = 
                maintenanceController.cleanupTempFiles(httpServletRequest);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        assertTrue((Boolean) body.get("success"));
        assertEquals(-1, body.get("filesRemoved")); // Should still return the value as-is
    }

    // ================================
    // Helper Methods
    // ================================

    private TempFileManager.TempFileStats createMockStats(int totalFiles, long totalSizeBytes, long oldestFileAge) {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(totalFiles);
        when(stats.getTotalSizeBytes()).thenReturn(totalSizeBytes);
        when(stats.getOldestFileAge()).thenReturn(oldestFileAge);
        return stats;
    }
}