package edu.mcw.rgd.entityTagger.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.PropertySources;

/**
 * Environment-specific configuration loader for the RGD Curation Tool.
 * Loads properties based on the active Spring profile.
 */
@Configuration
@PropertySources({
    @PropertySource("classpath:application.properties"),
    @PropertySource(value = "classpath:application-${spring.profiles.active}.properties", ignoreResourceNotFound = true)
})
@ConfigurationProperties(prefix = "curation")
public class EnvironmentConfig {
    
    private String tempDir;
    private String uploadDir;
    
    private OllamaConfig ollama = new OllamaConfig();
    private OntologyConfig ontology = new OntologyConfig();
    private EntityRecognitionConfig entityRecognition = new EntityRecognitionConfig();
    private SessionConfig session = new SessionConfig();
    private PerformanceConfig performance = new PerformanceConfig();
    private SecurityConfig security = new SecurityConfig();
    
    // Getters and setters
    public String getTempDir() {
        return tempDir;
    }
    
    public void setTempDir(String tempDir) {
        this.tempDir = tempDir;
    }
    
    public String getUploadDir() {
        return uploadDir;
    }
    
    public void setUploadDir(String uploadDir) {
        this.uploadDir = uploadDir;
    }
    
    public OllamaConfig getOllama() {
        return ollama;
    }
    
    public void setOllama(OllamaConfig ollama) {
        this.ollama = ollama;
    }
    
    public OntologyConfig getOntology() {
        return ontology;
    }
    
    public void setOntology(OntologyConfig ontology) {
        this.ontology = ontology;
    }
    
    public EntityRecognitionConfig getEntityRecognition() {
        return entityRecognition;
    }
    
    public void setEntityRecognition(EntityRecognitionConfig entityRecognition) {
        this.entityRecognition = entityRecognition;
    }
    
    public SessionConfig getSession() {
        return session;
    }
    
    public void setSession(SessionConfig session) {
        this.session = session;
    }
    
    public PerformanceConfig getPerformance() {
        return performance;
    }
    
    public void setPerformance(PerformanceConfig performance) {
        this.performance = performance;
    }
    
    public SecurityConfig getSecurity() {
        return security;
    }
    
    public void setSecurity(SecurityConfig security) {
        this.security = security;
    }
    
    // Nested configuration classes
    public static class OllamaConfig {
        private String url;
        private String model;
        private int connectTimeout;
        private int readTimeout;
        private int retryAttempts;
        private int retryDelay;
        
        // Getters and setters
        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = url; }
        public String getModel() { return model; }
        public void setModel(String model) { this.model = model; }
        public int getConnectTimeout() { return connectTimeout; }
        public void setConnectTimeout(int connectTimeout) { this.connectTimeout = connectTimeout; }
        public int getReadTimeout() { return readTimeout; }
        public void setReadTimeout(int readTimeout) { this.readTimeout = readTimeout; }
        public int getRetryAttempts() { return retryAttempts; }
        public void setRetryAttempts(int retryAttempts) { this.retryAttempts = retryAttempts; }
        public int getRetryDelay() { return retryDelay; }
        public void setRetryDelay(int retryDelay) { this.retryDelay = retryDelay; }
    }
    
    public static class OntologyConfig {
        private String rdoFile;
        private String goFile;
        private long cacheRefresh;
        private boolean cacheEnabled;
        
        // Getters and setters
        public String getRdoFile() { return rdoFile; }
        public void setRdoFile(String rdoFile) { this.rdoFile = rdoFile; }
        public String getGoFile() { return goFile; }
        public void setGoFile(String goFile) { this.goFile = goFile; }
        public long getCacheRefresh() { return cacheRefresh; }
        public void setCacheRefresh(long cacheRefresh) { this.cacheRefresh = cacheRefresh; }
        public boolean isCacheEnabled() { return cacheEnabled; }
        public void setCacheEnabled(boolean cacheEnabled) { this.cacheEnabled = cacheEnabled; }
    }
    
    public static class EntityRecognitionConfig {
        private int chunkSize;
        private int chunkOverlap;
        private double confidenceThreshold;
        private int batchSize;
        
        // Getters and setters
        public int getChunkSize() { return chunkSize; }
        public void setChunkSize(int chunkSize) { this.chunkSize = chunkSize; }
        public int getChunkOverlap() { return chunkOverlap; }
        public void setChunkOverlap(int chunkOverlap) { this.chunkOverlap = chunkOverlap; }
        public double getConfidenceThreshold() { return confidenceThreshold; }
        public void setConfidenceThreshold(double confidenceThreshold) { this.confidenceThreshold = confidenceThreshold; }
        public int getBatchSize() { return batchSize; }
        public void setBatchSize(int batchSize) { this.batchSize = batchSize; }
    }
    
    public static class SessionConfig {
        private long timeout;
        private long cleanupInterval;
        
        // Getters and setters
        public long getTimeout() { return timeout; }
        public void setTimeout(long timeout) { this.timeout = timeout; }
        public long getCleanupInterval() { return cleanupInterval; }
        public void setCleanupInterval(long cleanupInterval) { this.cleanupInterval = cleanupInterval; }
    }
    
    public static class PerformanceConfig {
        private boolean monitoringEnabled;
        private boolean monitoringVerbose;
        private long slowQueryThreshold;
        
        // Getters and setters
        public boolean isMonitoringEnabled() { return monitoringEnabled; }
        public void setMonitoringEnabled(boolean monitoringEnabled) { this.monitoringEnabled = monitoringEnabled; }
        public boolean isMonitoringVerbose() { return monitoringVerbose; }
        public void setMonitoringVerbose(boolean monitoringVerbose) { this.monitoringVerbose = monitoringVerbose; }
        public long getSlowQueryThreshold() { return slowQueryThreshold; }
        public void setSlowQueryThreshold(long slowQueryThreshold) { this.slowQueryThreshold = slowQueryThreshold; }
    }
    
    public static class SecurityConfig {
        private boolean xssProtectionEnabled;
        private boolean csrfProtectionEnabled;
        private boolean headersEnabled;
        
        // Getters and setters
        public boolean isXssProtectionEnabled() { return xssProtectionEnabled; }
        public void setXssProtectionEnabled(boolean xssProtectionEnabled) { this.xssProtectionEnabled = xssProtectionEnabled; }
        public boolean isCsrfProtectionEnabled() { return csrfProtectionEnabled; }
        public void setCsrfProtectionEnabled(boolean csrfProtectionEnabled) { this.csrfProtectionEnabled = csrfProtectionEnabled; }
        public boolean isHeadersEnabled() { return headersEnabled; }
        public void setHeadersEnabled(boolean headersEnabled) { this.headersEnabled = headersEnabled; }
    }
}