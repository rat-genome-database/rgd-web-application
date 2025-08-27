package edu.mcw.rgd.entityTagger.service;

import edu.mcw.rgd.entityTagger.exception.PdfProcessingException;
import edu.mcw.rgd.entityTagger.util.CurationLogger;
import edu.mcw.rgd.entityTagger.util.MarkdownProcessor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Service for PDF processing operations using Marker
 */
@Service
public class PdfProcessingService {
    
    private static final int MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
    private static final ExecutorService executor = Executors.newFixedThreadPool(5);
    // Dedicated executor for Python processes to avoid thread blocking from database operations
    private static final ExecutorService pythonExecutor = Executors.newFixedThreadPool(2);
    private static final String IMAGES_DIR = "/Users/jdepons/apache-tomcat-10.1.13/webapps/rgdweb/images/";
    
    @Value("${python.executable:python3}")
    private String pythonExecutable;
    
    @Value("${python.script.pdf.marker}")
    private String pythonScriptPath;
    
    private long maxFileSize = MAX_FILE_SIZE;
    
    public long getMaxFileSize() {
        return maxFileSize;
    }
    
    public void setMaxFileSize(long maxFileSize) {
        this.maxFileSize = maxFileSize;
    }
    
    // In-memory storage for demo purposes - in production, use database
    private static final ConcurrentHashMap<Long, String> extractedTextCache = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<Long, List<String>> extractedImagesCache = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<Long, String> processingStatusCache = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<Long, Future<?>> processingTasks = new ConcurrentHashMap<>();
    
    /**
     * Extract text from PDF file bytes using Marker
     */
    public String extractText(String filename, String contentType, byte[] fileBytes) throws PdfProcessingException {
        CurationLogger.entering(PdfProcessingService.class, "extractText");
        
        if (fileBytes == null || fileBytes.length == 0) {
            throw new PdfProcessingException("File bytes are empty or null");
        }
        
        CurationLogger.info("Extracting text with Marker for file: {}", filename);
        String markerText = extractTextWithMarker(filename, fileBytes);
        
        if (markerText == null) {
            CurationLogger.error("Marker extraction failed for file: {}", filename);
            throw new PdfProcessingException("Marker text extraction failed for file: " + filename);
        }
        
        CurationLogger.info("Successfully extracted text using Marker for file: {}", filename);
        CurationLogger.exiting(PdfProcessingService.class, "extractText");
        return markerText;
    }

    /**
     * Extract text from PDF file using Marker
     */
    public String extractText(MultipartFile file) throws PdfProcessingException {
        CurationLogger.entering(PdfProcessingService.class, "extractText");
        
        if (file == null || file.isEmpty()) {
            throw new PdfProcessingException("File is empty or null");
        }
        
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new PdfProcessingException("File size exceeds maximum limit of 50MB");
        }
        
        if (!isPdfFile(file)) {
            throw new PdfProcessingException("File is not a valid PDF");
        }
        
        try {
            byte[] fileBytes = file.getBytes();
            return extractText(file.getOriginalFilename(), file.getContentType(), fileBytes);
        } catch (IOException e) {
            CurationLogger.error("Error reading file: " + file.getOriginalFilename(), e);
            throw new PdfProcessingException("Failed to read PDF file: " + e.getMessage());
        }
    }
    
    /**
     * Extract images from PDF using Marker and copy to web-accessible location
     */
    public List<String> extractImages(String filename, String contentType, byte[] fileBytes, Long uploadId) throws PdfProcessingException {
        try {
            CurationLogger.info("Extracting images with Marker for file: {} with {} bytes", filename, fileBytes.length);
            
            // Create temporary file for PDF
            File tempPdf = File.createTempFile("pdf_extract_", ".pdf");
            tempPdf.deleteOnExit();
            
            try (FileOutputStream fos = new FileOutputStream(tempPdf)) {
                fos.write(fileBytes);
            }
            
            // Get the Python script path from configuration
            // Resolve paths with user.home
            String resolvedPythonExecutable = pythonExecutable.replace("${user.home}", System.getProperty("user.home"));
            String resolvedScriptPath = pythonScriptPath.replace("${user.home}", System.getProperty("user.home"));
            
            CurationLogger.info("Executing Python script: {} {} {}", resolvedPythonExecutable, resolvedScriptPath, tempPdf.getAbsolutePath());
            
            // Execute Python script
            ProcessBuilder pb = new ProcessBuilder(
                resolvedPythonExecutable, resolvedScriptPath, tempPdf.getAbsolutePath()
            );
            pb.redirectErrorStream(false);
            
            Process process = pb.start();
            
            // Read stdout (JSON output)
            StringBuilder output = new StringBuilder();
            StringBuilder errorOutput = new StringBuilder();
            
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.trim().startsWith("{") || line.contains("\"success\"")) {
                        output.append(line).append("\n");
                    }
                    CurationLogger.debug("Python stdout: {}", line);
                }
            }
            
            // Capture stderr for debugging
            try (BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
                String line;
                while ((line = errorReader.readLine()) != null) {
                    errorOutput.append(line).append("\n");
                    CurationLogger.warn("Python stderr: {}", line);
                }
            }
            
            // Wait for process with timeout (90 seconds max)
            boolean finished = process.waitFor(90, java.util.concurrent.TimeUnit.SECONDS);
            if (!finished) {
                System.out.println("DEBUG: Image extraction Python process timed out after 90 seconds, killing it");
                process.destroyForcibly();
                tempPdf.delete();
                throw new PdfProcessingException("Python script timed out after 90 seconds");
            }
            int exitCode = process.exitValue();
            tempPdf.delete();
            
            if (exitCode != 0) {
                CurationLogger.warn("Marker image extraction failed with exit code: {}. Error output: {}", exitCode, errorOutput.toString());
                throw new PdfProcessingException("Python script failed with exit code: " + exitCode + ". Error: " + errorOutput.toString());
            }
            
            // Parse JSON response
            ObjectMapper mapper = new ObjectMapper();
            JsonNode result = mapper.readTree(output.toString());
            
            if (result.get("success").asBoolean()) {
                JsonNode imagePathsNode = result.get("image_paths");
                List<String> webImageUrls = new ArrayList<>();
                
                if (imagePathsNode != null && imagePathsNode.isArray()) {
                    // Ensure the images directory exists
                    File imagesDir = new File(IMAGES_DIR);
                    if (!imagesDir.exists()) {
                        imagesDir.mkdirs();
                    }
                    
                    // Copy images to web-accessible location
                    for (JsonNode pathNode : imagePathsNode) {
                        String imagePath = pathNode.asText();
                        File sourceImage = new File(imagePath);
                        
                        if (sourceImage.exists()) {
                            String fileName = uploadId + "_" + sourceImage.getName();
                            File destImage = new File(IMAGES_DIR + fileName);
                            
                            // Copy the image file
                            Files.copy(sourceImage.toPath(), destImage.toPath(), 
                                     java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                            
                            // Add web URL
                            String webUrl = "/rgdweb/images/" + fileName;
                            webImageUrls.add(webUrl);
                            
                            CurationLogger.info("Copied image {} to {}", imagePath, destImage.getAbsolutePath());
                        }
                    }
                }
                
                CurationLogger.info("Extracted {} images using Marker for file: {}", webImageUrls.size(), filename);
                return webImageUrls;
            } else {
                String error = result.get("error").asText();
                CurationLogger.warn("Marker image extraction failed: {}", error);
                return new ArrayList<>();
            }
            
        } catch (Exception e) {
            CurationLogger.warn("Error extracting images with Marker: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    /**
     * Extract images from PDF (legacy method) using Marker
     */
    public List<String> extractImages(MultipartFile file, Long uploadId) throws PdfProcessingException {
        try {
            byte[] fileBytes = file.getBytes();
            return extractImages(file.getOriginalFilename(), file.getContentType(), fileBytes, uploadId);
        } catch (IOException e) {
            CurationLogger.error("Error reading file for image extraction: " + file.getOriginalFilename(), e);
            throw new PdfProcessingException("Failed to read PDF file for image extraction: " + e.getMessage());
        }
    }
    
    /**
     * Process extracted text for biological entities
     */
    public String processTextForEntities(String text) {
        // Basic entity processing - in production, this would use NLP libraries
        CurationLogger.entering(PdfProcessingService.class, "processTextForEntities");
        
        if (text == null || text.trim().isEmpty()) {
            return "No text provided for entity processing";
        }
        
        // Simple mock entity processing - in production use BioBERT, spaCy, etc.
        StringBuilder result = new StringBuilder();
        result.append("Entity Processing Results:\n\n");
        
        // Count potential gene mentions (simplified pattern matching)
        long geneCount = text.toLowerCase().split("\\b(?:gene|protein|mrna|expression)\\b").length - 1;
        result.append("Potential gene references: ").append(geneCount).append("\n");
        
        // Count potential disease mentions
        long diseaseCount = text.toLowerCase().split("\\b(?:disease|cancer|tumor|syndrome|disorder)\\b").length - 1;
        result.append("Potential disease references: ").append(diseaseCount).append("\n");
        
        // Text statistics
        result.append("Total characters: ").append(text.length()).append("\n");
        result.append("Total words: ").append(text.split("\\s+").length).append("\n");
        
        CurationLogger.exiting(PdfProcessingService.class, "processTextForEntities");
        return result.toString();
    }
    
    /**
     * Start asynchronous PDF processing with file bytes
     */
    public Long startPdfProcessing(String filename, String contentType, byte[] fileBytes, String sessionId) {
        CurationLogger.entering(PdfProcessingService.class, "startPdfProcessing");
        
        Long uploadId = System.currentTimeMillis();
        
        // Submit async processing task
        Future<?> future = executor.submit(() -> {
            try {
                processingStatusCache.put(uploadId, "IN_PROGRESS");
                CurationLogger.info("Starting PDF processing for uploadId: {}", uploadId);
                
                // Extract text
                String extractedText = extractText(filename, contentType, fileBytes);
                extractedTextCache.put(uploadId, extractedText);
                
                // Save extracted text to file for persistence
                saveExtractedTextToFile(uploadId, extractedText);
                
                // Extract images using Marker
                List<String> extractedImages = extractImages(filename, contentType, fileBytes, uploadId);
                extractedImagesCache.put(uploadId, extractedImages);
                
                // Process entities
                String entityResults = processTextForEntities(extractedText);
                
                processingStatusCache.put(uploadId, "COMPLETED");
                CurationLogger.info("Completed PDF processing for uploadId: {}", uploadId);
                
            } catch (Exception e) {
                CurationLogger.error("Error processing PDF for uploadId: " + uploadId, e);
                processingStatusCache.put(uploadId, "FAILED");
                String errorMessage = "Error processing PDF: " + e.getMessage();
                extractedTextCache.put(uploadId, errorMessage);
                saveExtractedTextToFile(uploadId, errorMessage);
                extractedImagesCache.put(uploadId, new ArrayList<>());
            }
        });
        
        processingTasks.put(uploadId, future);
        processingStatusCache.put(uploadId, "STARTED");
        
        CurationLogger.exiting(PdfProcessingService.class, "startPdfProcessing");
        return uploadId;
    }

    /**
     * Start asynchronous PDF processing (legacy method for backward compatibility)
     */
    public Long startPdfProcessing(MultipartFile file, String sessionId) {
        CurationLogger.entering(PdfProcessingService.class, "startPdfProcessing");
        
        Long uploadId = System.currentTimeMillis();
        
        // Submit async processing task
        Future<?> future = executor.submit(() -> {
            try {
                processingStatusCache.put(uploadId, "IN_PROGRESS");
                CurationLogger.info("Starting PDF processing for uploadId: {}", uploadId);
                
                // Extract text
                String extractedText = extractText(file);
                extractedTextCache.put(uploadId, extractedText);
                
                // Save extracted text to file for persistence
                saveExtractedTextToFile(uploadId, extractedText);
                
                // Extract images using Marker
                List<String> extractedImages;
                try {
                    byte[] fileBytes = file.getBytes();
                    extractedImages = extractImages(file.getOriginalFilename(), file.getContentType(), fileBytes, uploadId);
                } catch (IOException e) {
                    CurationLogger.warn("Failed to extract images: {}", e.getMessage());
                    extractedImages = new ArrayList<>();
                }
                extractedImagesCache.put(uploadId, extractedImages);
                
                // Process entities
                String entityResults = processTextForEntities(extractedText);
                
                processingStatusCache.put(uploadId, "COMPLETED");
                CurationLogger.info("Completed PDF processing for uploadId: {}", uploadId);
                
            } catch (Exception e) {
                CurationLogger.error("Error processing PDF for uploadId: " + uploadId, e);
                processingStatusCache.put(uploadId, "FAILED");
                String errorMessage = "Error processing PDF: " + e.getMessage();
                extractedTextCache.put(uploadId, errorMessage);
                saveExtractedTextToFile(uploadId, errorMessage);
                extractedImagesCache.put(uploadId, new ArrayList<>());
            }
        });
        
        processingTasks.put(uploadId, future);
        processingStatusCache.put(uploadId, "STARTED");
        
        CurationLogger.exiting(PdfProcessingService.class, "startPdfProcessing");
        return uploadId;
    }
    
    /**
     * Get processing status for an upload
     */
    public edu.mcw.rgd.entityTagger.dto.UploadStatus getProcessingStatus(Long uploadId) {
        edu.mcw.rgd.entityTagger.dto.UploadStatus status = new edu.mcw.rgd.entityTagger.dto.UploadStatus();
        status.setUploadId(uploadId);
        
        String statusText = processingStatusCache.getOrDefault(uploadId, "NOT_FOUND");
        status.setStatus(statusText);
        
        switch (statusText) {
            case "STARTED":
                status.setProgress(10);
                status.setMessage("Processing started");
                break;
            case "IN_PROGRESS":
                status.setProgress(50);
                status.setMessage("Extracting text from PDF");
                break;
            case "COMPLETED":
                status.setProgress(100);
                status.setMessage("Processing completed successfully");
                break;
            case "FAILED":
                status.setProgress(0);
                String errorDetails = extractedTextCache.get(uploadId);
                if (errorDetails != null && errorDetails.startsWith("Error processing PDF:")) {
                    // Check for timeout-related errors and provide user-friendly message
                    if (errorDetails.contains("timed out") || errorDetails.contains("too complex")) {
                        status.setMessage("Processing failed: PDF document is too complex for automated processing. Please try a simpler document or contact support.");
                    } else {
                        status.setMessage(errorDetails);
                    }
                } else {
                    status.setMessage("Processing failed");
                }
                break;
            default:
                status.setProgress(0);
                status.setMessage("Upload not found");
        }
        
        return status;
    }
    
    /**
     * Cancel processing for an upload
     */
    public boolean cancelProcessing(Long uploadId) {
        CurationLogger.info("Cancelling processing for uploadId: {}", uploadId);
        
        Future<?> task = processingTasks.get(uploadId);
        if (task != null && !task.isDone()) {
            boolean cancelled = task.cancel(true);
            if (cancelled) {
                processingStatusCache.put(uploadId, "CANCELLED");
                processingTasks.remove(uploadId);
                extractedTextCache.remove(uploadId);
            }
            return cancelled;
        }
        
        return false;
    }
    
    /**
     * Get extracted text for an upload, processed for display
     */
    public String getExtractedText(Long uploadId) {
        // First check cache
        String cachedText = extractedTextCache.get(uploadId);
        if (cachedText != null) {
            // Clean any cached text that might still have HTML tags
            String cleanedCachedText = cleanExtractedText(cachedText);
            // Return RAW markdown text - don't process to HTML here
            // The controller will handle markdown processing
            return cleanedCachedText;
        }
        
        // If not in cache, try to load from persistent storage
        try {
            String textFile = IMAGES_DIR + uploadId + "_extracted_text.txt";
            Path textPath = Paths.get(textFile);
            if (Files.exists(textPath)) {
                String extractedText = Files.readString(textPath, StandardCharsets.UTF_8);
                // Clean the extracted text before processing
                String cleanedText = cleanExtractedText(extractedText);
                // Cache the cleaned text for future use
                extractedTextCache.put(uploadId, cleanedText);
                
                // Return RAW markdown text - don't process to HTML here
                // The controller will handle markdown processing
                return cleanedText;
            }
        } catch (Exception e) {
            CurationLogger.warn("Failed to load extracted text from file for upload " + uploadId + ": " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Get raw extracted text for an upload (without markdown processing)
     */
    public String getRawExtractedText(Long uploadId) {
        // First check cache
        String cachedText = extractedTextCache.get(uploadId);
        if (cachedText != null) {
            return cleanExtractedText(cachedText);
        }
        
        // If not in cache, try to load from persistent storage
        try {
            String textFile = IMAGES_DIR + uploadId + "_extracted_text.txt";
            Path textPath = Paths.get(textFile);
            if (Files.exists(textPath)) {
                String extractedText = Files.readString(textPath, StandardCharsets.UTF_8);
                // Clean the extracted text
                String cleanedText = cleanExtractedText(extractedText);
                // Cache the cleaned text for future use
                extractedTextCache.put(uploadId, cleanedText);
                return cleanedText;
            }
        } catch (Exception e) {
            CurationLogger.warn("Failed to load extracted text from file for upload " + uploadId + ": " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Get extracted images for an upload
     */
    public List<String> getExtractedImages(Long uploadId) {
        return extractedImagesCache.getOrDefault(uploadId, new ArrayList<>());
    }
    
    /**
     * Check if file is a valid PDF
     */
    private boolean isPdfFile(String filename, String contentType) {
        return (filename != null && filename.toLowerCase().endsWith(".pdf")) ||
               "application/pdf".equals(contentType);
    }

    /**
     * Check if file is a valid PDF (legacy method)
     */
    private boolean isPdfFile(MultipartFile file) {
        String filename = file.getOriginalFilename();
        String contentType = file.getContentType();
        
        return isPdfFile(filename, contentType);
    }
    
    /**
     * Save extracted text to file for persistence across server restarts
     */
    private void saveExtractedTextToFile(Long uploadId, String extractedText) {
        try {
            // Ensure the images directory exists
            File imagesDir = new File(IMAGES_DIR);
            if (!imagesDir.exists()) {
                imagesDir.mkdirs();
            }
            
            String textFile = IMAGES_DIR + uploadId + "_extracted_text.txt";
            Path textPath = Paths.get(textFile);
            Files.writeString(textPath, extractedText, StandardCharsets.UTF_8);
            
            CurationLogger.info("Saved extracted text for upload {} to {}", uploadId, textFile);
        } catch (Exception e) {
            CurationLogger.warn("Failed to save extracted text to file for upload " + uploadId + ": " + e.getMessage());
        }
    }
    
    /**
     * Extract text from PDF using Marker library (Python-based)
     */
    private String extractTextWithMarker(String filename, byte[] fileBytes) {
        try {
            System.out.println("DEBUG: [1] Starting Marker extraction for file: " + filename + " with " + fileBytes.length + " bytes");
            System.out.println("DEBUG: [2] Current thread: " + Thread.currentThread().getName());
            CurationLogger.info("Starting Marker extraction for file: {} with {} bytes", filename, fileBytes.length);
            
            // Create temporary file for PDF
            File tempPdf = File.createTempFile("pdf_extract_", ".pdf");
            tempPdf.deleteOnExit();
            
            System.out.println("DEBUG: [3] Created temp PDF file: " + tempPdf.getAbsolutePath());
            CurationLogger.info("Created temp PDF file: {}", tempPdf.getAbsolutePath());
            
            try (FileOutputStream fos = new FileOutputStream(tempPdf)) {
                fos.write(fileBytes);
            }
            
            System.out.println("DEBUG: [4] Wrote " + fileBytes.length + " bytes to temp PDF file");
            CurationLogger.info("Wrote {} bytes to temp PDF file", fileBytes.length);
            
            // Get the Python script path from configuration
            
            // Check if Python script exists
            // Resolve the path with user.home
            String userHome = System.getProperty("user.home");
            System.out.println("DEBUG: [5] user.home system property is: " + userHome);
            System.out.println("DEBUG: [6] pythonScriptPath from config: " + pythonScriptPath);
            String resolvedScriptPath = pythonScriptPath.replace("${user.home}", userHome);
            System.out.println("DEBUG: [7] Checking Python script at: " + resolvedScriptPath);
            File scriptFile = new File(resolvedScriptPath);
            if (!scriptFile.exists()) {
                System.out.println("DEBUG: [8] Python script NOT found at: " + resolvedScriptPath);
                CurationLogger.error("Marker Python script not found at: {} (resolved from: {})", resolvedScriptPath, pythonScriptPath);
                return null;
            }
            
            System.out.println("DEBUG: [9] Found Python script at: " + resolvedScriptPath);
            CurationLogger.info("Found Python script at: {} (resolved from: {})", resolvedScriptPath, pythonScriptPath);
            
            // Execute Python script
            // Also resolve the Python executable path
            String resolvedPythonExecutable = pythonExecutable.replace("${user.home}", System.getProperty("user.home"));
            
            ProcessBuilder pb = new ProcessBuilder(
                resolvedPythonExecutable, resolvedScriptPath, tempPdf.getAbsolutePath()
            );
            // Don't redirect error stream - handle separately to capture clean JSON output
            pb.redirectErrorStream(false);
            
            // Set working directory to ensure consistent environment
            pb.directory(new File(System.getProperty("user.home")));
            
            System.out.println("DEBUG: [10] About to execute Python process in isolated thread...");
            System.out.println("DEBUG: [11] Command will be: " + resolvedPythonExecutable + " " + resolvedScriptPath + " " + tempPdf.getAbsolutePath());
            CurationLogger.info("Executing command: {} {} {}", resolvedPythonExecutable, resolvedScriptPath, tempPdf.getAbsolutePath());
            
            // Execute Python process in a separate, isolated thread to avoid database blocking
            Future<String> pythonResult = pythonExecutor.submit(() -> {
                try {
                    System.out.println("DEBUG: Python thread started - about to execute command: " + resolvedPythonExecutable + " " + resolvedScriptPath + " " + tempPdf.getAbsolutePath());
                    System.out.println("DEBUG: Working directory: " + pb.directory());
                    
                    // Fix PATH issue: prioritize virtual environment over anaconda
                    String currentPath = pb.environment().get("PATH");
                    String venvPath = "/Users/jdepons/rgd-python-venv/bin";
                    String fixedPath = venvPath + ":" + currentPath.replaceAll("/Users/jdepons/anaconda3/bin:?", "").replaceAll("/Users/jdepons/anaconda3/condabin:?", "");
                    pb.environment().put("PATH", fixedPath);
                    System.out.println("DEBUG: Fixed PATH: " + pb.environment().get("PATH"));
                    
                    System.out.println("DEBUG: Process builder command: " + pb.command());
                    System.out.println("DEBUG: About to call pb.start()...");
                    
                    Process process = pb.start();
                    System.out.println("DEBUG: Process started successfully in Python thread, waiting for completion...");
                    
                    return executePythonProcess(process, filename);
                } catch (Exception e) {
                    System.out.println("DEBUG: Exception in Python thread: " + e.getMessage());
                    e.printStackTrace();
                    return null;
                }
            });
            
            // Wait for the Python process with timeout
            String result;
            try {
                result = pythonResult.get(180, java.util.concurrent.TimeUnit.SECONDS);
            } catch (java.util.concurrent.TimeoutException e) {
                System.out.println("DEBUG: Python process execution timed out after 180 seconds");
                pythonResult.cancel(true);
                tempPdf.delete();
                return null;
            } catch (Exception e) {
                System.out.println("DEBUG: Error waiting for Python process: " + e.getMessage());
                tempPdf.delete();
                return null;
            }
            
            tempPdf.delete();
            return result;
            
        } catch (Exception e) {
            CurationLogger.warn("Error using Marker for PDF extraction: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * Execute the Python process and handle the result - runs in isolated thread
     */
    private String executePythonProcess(Process process, String filename) {
        try {
            // Read stdout (JSON output) and stderr (progress messages) WHILE process is running
            // This prevents buffer overflow blocking
            StringBuilder output = new StringBuilder();
            StringBuilder errorOutput = new StringBuilder();
            
            // Start threads to read output streams to prevent blocking
            Thread outputReader = new Thread(() -> {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        // Only capture lines that look like JSON (start with { or contain "success")
                        if (line.trim().startsWith("{") || line.contains("\"success\"")) {
                            output.append(line).append("\n");
                        }
                        System.out.println("DEBUG: Python stdout: " + line);
                    }
                } catch (IOException e) {
                    System.err.println("Error reading stdout: " + e.getMessage());
                }
            });
            
            Thread errorReader = new Thread(() -> {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        errorOutput.append(line).append("\n");
                        System.out.println("DEBUG: Python stderr: " + line);
                    }
                } catch (IOException e) {
                    System.err.println("Error reading stderr: " + e.getMessage());
                }
            });
            
            // Start reading threads
            outputReader.start();
            errorReader.start();
            
            // Wait for process with timeout (180 seconds max)
            boolean finished = process.waitFor(180, java.util.concurrent.TimeUnit.SECONDS);
            
            // Wait for readers to finish (max 5 seconds)
            try {
                outputReader.join(5000);
                errorReader.join(5000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            
            if (!finished) {
                System.out.println("DEBUG: Python process timed out after 180 seconds, killing it");
                System.out.println("DEBUG: Process isAlive: " + process.isAlive());
                process.destroyForcibly();
                return null;
            }
            
            int exitCode = process.exitValue();
            System.out.println("DEBUG: Process completed with exit code: " + exitCode);
            
            CurationLogger.info("Python process exited with code: {}", exitCode);
            CurationLogger.info("Python output: {}", output.toString());
            
            if (exitCode != 0) {
                CurationLogger.error("Marker extraction failed with exit code: {}. Stdout: {}. Stderr: {}", exitCode, output.toString(), errorOutput.toString());
                return null;
            }
            
            // Parse JSON response
            if (output.toString().trim().isEmpty()) {
                CurationLogger.error("Marker extraction returned empty output. Stderr: {}", errorOutput.toString());
                return null;
            }
            
            ObjectMapper mapper = new ObjectMapper();
            JsonNode result;
            try {
                result = mapper.readTree(output.toString());
            } catch (Exception e) {
                CurationLogger.error("Failed to parse JSON response: {}. Raw output: {}", e.getMessage(), output.toString());
                return null;
            }
            
            if (result == null || result.get("success") == null) {
                CurationLogger.error("Invalid JSON response format. Raw output: {}", output.toString());
                return null;
            }
            
            if (result.get("success").asBoolean()) {
                String extractedText = result.get("text").asText();
                
                // Clean extracted text by removing <br> tags that may interfere with entity highlighting
                extractedText = cleanExtractedText(extractedText);
                
                CurationLogger.info("Marker extracted {} characters from: {}", 
                    extractedText.length(), filename);
                return extractedText;
            } else {
                String error = result.get("error").asText();
                CurationLogger.warn("Marker extraction failed: {}", error);
                
                // Check if this is a timeout error - provide more helpful message
                if (error.contains("timed out") || error.contains("too complex")) {
                    System.out.println("DEBUG: PDF processing timed out - document may be too complex for Marker processing");
                    CurationLogger.warn("PDF appears to be too complex for current processing capabilities: {}", filename);
                }
                
                return null;
            }
            
        } catch (Exception e) {
            CurationLogger.warn("Error using Marker for PDF extraction: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * Clean extracted text by removing HTML tags and unwanted elements that interfere with entity highlighting
     */
    private String cleanExtractedText(String extractedText) {
        if (extractedText == null || extractedText.trim().isEmpty()) {
            return extractedText;
        }
        
        // Log original text sample for debugging
        String originalSample = extractedText.length() > 200 ? extractedText.substring(0, 200) : extractedText;
        CurationLogger.info("Original text sample before cleaning: {}", originalSample.replace("\n", "\\n"));
        
        // MINIMAL cleaning - preserve markdown formatting!
        // Only remove problematic HTML tags if they exist, but preserve markdown structure
        String cleanedText = extractedText;
        
        // Only remove HTML tags if they actually exist in the text
        if (cleanedText.contains("<") && cleanedText.contains(">")) {
            // Remove only specific problematic HTML tags
            cleanedText = cleanedText.replaceAll("(?i)<br\\s*/?\\s*>", "\n");
            cleanedText = cleanedText.replaceAll("(?i)</br\\s*>", "\n");
            cleanedText = cleanedText.replaceAll("(?i)</?p\\s*/?\\s*>", "\n");
            cleanedText = cleanedText.replaceAll("(?i)</?div[^>]*>", "\n");
            cleanedText = cleanedText.replaceAll("(?i)</?span[^>]*>", "");
        }
        
        // Log cleaned text sample for debugging
        String cleanedSample = cleanedText.length() > 200 ? cleanedText.substring(0, 200) : cleanedText;
        CurationLogger.info("Cleaned text sample after cleaning: {}", cleanedSample.replace("\n", "\\n"));
        
        // DO NOT collapse whitespace - preserve line breaks and formatting!
        // Just trim the overall text
        cleanedText = cleanedText.trim();
        
        CurationLogger.info("Cleaned extracted text: minimal cleaning, {} -> {} characters", 
            extractedText.length(), cleanedText.length());
        
        return cleanedText;
    }
}