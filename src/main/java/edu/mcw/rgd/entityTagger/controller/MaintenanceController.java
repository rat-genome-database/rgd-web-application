package edu.mcw.rgd.entityTagger.controller;

import edu.mcw.rgd.entityTagger.service.TempFileManager;
import edu.mcw.rgd.entityTagger.service.TempFileManager.TempFileStats;
import edu.mcw.rgd.entityTagger.service.SessionService;
import edu.mcw.rgd.entityTagger.util.CurationLogger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * Controller for maintenance operations like file cleanup and system status.
 * These endpoints are intended for administrative use.
 */
@Controller
@RequestMapping("/curation/maintenance")
public class MaintenanceController {

    @Autowired
    private TempFileManager tempFileManager;
    
    @Autowired
    private SessionService sessionService;

    /**
     * Get temporary file statistics
     */
    @RequestMapping(value = "/temp-files/stats.html", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getTempFileStats(HttpServletRequest request) {
        CurationLogger.entering(MaintenanceController.class, "getTempFileStats");
        
        try {
            TempFileStats stats = tempFileManager.getFileStats();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("totalFiles", stats.getTotalFiles());
            response.put("totalSizeBytes", stats.getTotalSizeBytes());
            response.put("totalSizeFormatted", formatFileSize(stats.getTotalSizeBytes()));
            response.put("oldestFileAgeMs", stats.getOldestFileAge());
            response.put("oldestFileAgeFormatted", formatDuration(stats.getOldestFileAge()));
            
            CurationLogger.info("Temp file stats requested: {} files, {} bytes", 
                    stats.getTotalFiles(), stats.getTotalSizeBytes());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            CurationLogger.error("Error getting temp file stats", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Failed to get file statistics: " + e.getMessage());
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * Trigger manual cleanup of temporary files
     */
    @RequestMapping(value = "/temp-files/cleanup.html", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> cleanupTempFiles(HttpServletRequest request) {
        CurationLogger.entering(MaintenanceController.class, "cleanupTempFiles");
        
        try {
            // Get stats before cleanup
            TempFileStats beforeStats = tempFileManager.getFileStats();
            
            // Perform cleanup
            int cleanedCount = tempFileManager.cleanupAllFiles();
            
            // Get stats after cleanup
            TempFileStats afterStats = tempFileManager.getFileStats();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("filesRemoved", cleanedCount);
            response.put("beforeStats", createStatsMap(beforeStats));
            response.put("afterStats", createStatsMap(afterStats));
            response.put("message", "Cleanup completed successfully");
            
            CurationLogger.info("Manual temp file cleanup completed: {} files removed", cleanedCount);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            CurationLogger.error("Error during manual temp file cleanup", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Cleanup failed: " + e.getMessage());
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    // Helper methods
    
    private Map<String, Object> createStatsMap(TempFileStats stats) {
        Map<String, Object> statsMap = new HashMap<>();
        statsMap.put("totalFiles", stats.getTotalFiles());
        statsMap.put("totalSizeBytes", stats.getTotalSizeBytes());
        statsMap.put("totalSizeFormatted", formatFileSize(stats.getTotalSizeBytes()));
        statsMap.put("oldestFileAgeMs", stats.getOldestFileAge());
        statsMap.put("oldestFileAgeFormatted", formatDuration(stats.getOldestFileAge()));
        return statsMap;
    }
    
    private String formatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        if (bytes < 1024 * 1024 * 1024) return String.format("%.1f MB", bytes / (1024.0 * 1024));
        return String.format("%.1f GB", bytes / (1024.0 * 1024 * 1024));
    }
    
    private String formatDuration(long milliseconds) {
        if (milliseconds < 1000) return milliseconds + " ms";
        if (milliseconds < 60000) return String.format("%.1f sec", milliseconds / 1000.0);
        if (milliseconds < 3600000) return String.format("%.1f min", milliseconds / 60000.0);
        if (milliseconds < 86400000) return String.format("%.1f hrs", milliseconds / 3600000.0);
        return String.format("%.1f days", milliseconds / 86400000.0);
    }
}