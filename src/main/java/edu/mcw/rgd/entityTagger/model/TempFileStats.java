package edu.mcw.rgd.entityTagger.model;

/**
 * Statistics model for temporary file operations
 */
public class TempFileStats {
    private long totalFiles;
    private long totalSize;
    private long oldestFileAge;
    
    // Constructors
    public TempFileStats() {}
    
    // Getters and setters
    public long getTotalFiles() { return totalFiles; }
    public void setTotalFiles(long totalFiles) { this.totalFiles = totalFiles; }
    
    public long getTotalSize() { return totalSize; }
    public void setTotalSize(long totalSize) { this.totalSize = totalSize; }
    
    public long getOldestFileAge() { return oldestFileAge; }
    public void setOldestFileAge(long oldestFileAge) { this.oldestFileAge = oldestFileAge; }
}