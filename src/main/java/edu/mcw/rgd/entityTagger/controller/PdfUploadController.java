package edu.mcw.rgd.entityTagger.controller;

import edu.mcw.rgd.entityTagger.service.PdfProcessingService;
import edu.mcw.rgd.entityTagger.service.SessionService;
import edu.mcw.rgd.entityTagger.service.EntityRecognitionService;
import edu.mcw.rgd.entityTagger.service.EntityRecognitionResult;
import edu.mcw.rgd.entityTagger.service.BiologicalEntity;
import edu.mcw.rgd.entityTagger.dto.UploadResponse;
import edu.mcw.rgd.entityTagger.dto.UploadStatus;
import edu.mcw.rgd.entityTagger.exception.PdfProcessingException;
import edu.mcw.rgd.entityTagger.util.CurationLogger;
import edu.mcw.rgd.entityTagger.util.ServletPartMultipartFile;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.net.URI;
import java.util.Set;
import java.util.HashSet;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Controller for handling PDF file uploads and processing requests.
 * Provides web interface for drag-and-drop PDF uploads with progress tracking.
 */
public class PdfUploadController implements Controller {

    private static final long MAX_FILE_SIZE = 52428800L; // 50MB in bytes
    private static final String[] ALLOWED_CONTENT_TYPES = {"application/pdf"};
    
    private PdfProcessingService pdfProcessingService;
    private SessionService sessionService;
    private EntityRecognitionService entityRecognitionService;
    
    public void setPdfProcessingService(PdfProcessingService pdfProcessingService) {
        this.pdfProcessingService = pdfProcessingService;
    }
    
    public void setSessionService(SessionService sessionService) {
        this.sessionService = sessionService;
    }
    
    public void setEntityRecognitionService(EntityRecognitionService entityRecognitionService) {
        this.entityRecognitionService = entityRecognitionService;
    }

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String requestURI = request.getRequestURI();
        String method = request.getMethod();
        
        // Log for debugging
        CurationLogger.info("PdfUploadController handling request - URI: {}, Method: {}", requestURI, method);
        
        // Route based on URL and method
        if (requestURI.endsWith("curation/entityTagger/index.html") && "GET".equals(method)) {
            return showEntityTaggerIndex(request);
        } else if (requestURI.endsWith("curation/entityTagger/main.html") && "GET".equals(method)) {
            return showEntityTaggerMain(request);
        } else if (requestURI.endsWith("curation/pdf/upload.html")) {
            if ("GET".equals(method)) {
                return showUploadPage(request);
            } else if ("POST".equals(method)) {
                return handleFileUpload(request, response);
            }
        } else if (requestURI.endsWith("curation/pdf/status.html") && "GET".equals(method)) {
            return handleStatusRequest(request, response);
        } else if (requestURI.endsWith("curation/pdf/cancel.html") && "POST".equals(method)) {
            return handleCancelRequest(request, response);
        } else if (requestURI.endsWith("curation/pdf/session-info.html") && "GET".equals(method)) {
            return handleSessionInfoRequest(request, response);
        } else if (requestURI.endsWith("curation/entity/recognize.html") && "GET".equals(method)) {
            return handleEntityRecognitionRequest(request, response);
        } else if (requestURI.endsWith("curation/chat/ask") && "POST".equals(method)) {
            return handleChatRequest(request, response);
        }
        
        // Default case for unsupported methods
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return null;
    }

    /**
     * Display the Entity Tagger main page
     */
    private ModelAndView showEntityTaggerIndex(HttpServletRequest request) {
        CurationLogger.entering(PdfUploadController.class, "showEntityTaggerIndex");
        
        ModelAndView mav = new ModelAndView("/WEB-INF/jsp/curation/entityTagger/index.jsp");
        HttpSession session = request.getSession();
        
        // Get or create session for potential future use
        String sessionId = sessionService.getOrCreateSession(session, request);
        mav.addObject("sessionId", sessionId);
        
        CurationLogger.exiting(PdfUploadController.class, "showEntityTaggerIndex");
        return mav;
    }

    /**
     * Display the Entity Tagger main curation interface
     */
    private ModelAndView showEntityTaggerMain(HttpServletRequest request) {
        CurationLogger.entering(PdfUploadController.class, "showEntityTaggerMain");
        
        ModelAndView mav = new ModelAndView("/WEB-INF/jsp/curation/entityTagger/main.jsp");
        HttpSession session = request.getSession();
        
        // Get or create session for potential future use
        String sessionId = sessionService.getOrCreateSession(session, request);
        mav.addObject("sessionId", sessionId);
        
        CurationLogger.exiting(PdfUploadController.class, "showEntityTaggerMain");
        return mav;
    }

    /**
     * Display the PDF upload page
     */
    private ModelAndView showUploadPage(HttpServletRequest request) {
        CurationLogger.entering(PdfUploadController.class, "showUploadPage");
        
        ModelAndView mav = new ModelAndView("/WEB-INF/jsp/curation/entityTagger/pdf/upload.jsp");
        HttpSession session = request.getSession();
        
        // Get or create session
        String sessionId = sessionService.getOrCreateSession(session, request);
        mav.addObject("sessionId", sessionId);
        mav.addObject("maxFileSize", MAX_FILE_SIZE);
        mav.addObject("maxFileSizeMB", MAX_FILE_SIZE / (1024 * 1024));
        
        // Check for active uploads in session
        List<Long> activeUploads = sessionService.getActiveUploads(sessionId);
        mav.addObject("hasActiveUploads", !activeUploads.isEmpty());
        mav.addObject("activeUploadsCount", activeUploads.size());
        
        CurationLogger.exiting(PdfUploadController.class, "showUploadPage");
        return mav;
    }

    /**
     * Handle file upload POST requests with real PDF processing
     */
    private ModelAndView handleFileUpload(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CurationLogger.entering(PdfUploadController.class, "handleFileUpload");
        
        try {
            // Check if this is a chat request
            String action = request.getParameter("action");
            if ("chat".equals(action)) {
                return handleChatRequest(request, response);
            }
            
            // Set response content type to JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            HttpSession httpSession = request.getSession();
            String sessionId = sessionService.getOrCreateSession(httpSession, request);
            
            // Check if this is a multipart request
            if (!request.getContentType().startsWith("multipart/form-data")) {
                CurationLogger.warn("Received non-multipart request for file upload");
                throw new IllegalArgumentException("Request must be multipart/form-data");
            }
            
            // Get uploaded file from request using servlet API
            org.springframework.web.multipart.MultipartFile uploadedFile = null;
            try {
                jakarta.servlet.http.Part filePart = request.getPart("file");
                if (filePart != null) {
                    // Create a simple wrapper for the Part
                    uploadedFile = new ServletPartMultipartFile(filePart);
                }
            } catch (Exception e) {
                CurationLogger.warn("Could not get file part from request: {}", e.getMessage());
            }
            
            if (uploadedFile == null || uploadedFile.isEmpty()) {
                CurationLogger.warn("No file uploaded or file is empty");
                String errorResponse = "{"
                    + "\"success\": false,"
                    + "\"message\": \"No file was uploaded. Please select a PDF file.\","
                    + "\"errorCode\": \"NO_FILE\""
                    + "}";
                response.getWriter().write(errorResponse);
                response.getWriter().flush();
                return null;
            }
            
            // Validate file
            UploadResponse validationResult = validateFile(
                uploadedFile.getOriginalFilename(), 
                uploadedFile.getSize(), 
                uploadedFile.getContentType());
            
            if (!validationResult.isSuccess()) {
                CurationLogger.warn("File validation failed: {}", validationResult.getMessage());
                String errorResponse = "{"
                    + "\"success\": false,"
                    + "\"message\": \"" + validationResult.getMessage() + "\","
                    + "\"errorCode\": \"VALIDATION_FAILED\""
                    + "}";
                response.getWriter().write(errorResponse);
                response.getWriter().flush();
                return null;
            }
            
            // Read file bytes before async processing since Part will be unavailable after request closes
            byte[] fileBytes = uploadedFile.getBytes();
            CurationLogger.info("Read {} bytes from uploaded file: {}", fileBytes.length, uploadedFile.getOriginalFilename());
            
            // Start asynchronous PDF processing with file bytes
            Long uploadId = pdfProcessingService.startPdfProcessing(uploadedFile.getOriginalFilename(), 
                uploadedFile.getContentType(), fileBytes, sessionId);
            
            CurationLogger.info("Started PDF processing for file: {}, uploadId: {}", 
                uploadedFile.getOriginalFilename(), uploadId);
            
            // Return success response with upload ID
            String jsonResponse = "{"
                + "\"success\": true,"
                + "\"message\": \"File uploaded successfully. Processing started.\","
                + "\"uploadId\": " + uploadId + ","
                + "\"sessionId\": \"" + sessionId + "\","
                + "\"fileName\": \"" + uploadedFile.getOriginalFilename() + "\","
                + "\"fileSize\": " + uploadedFile.getSize() + ","
                + "\"timestamp\": " + System.currentTimeMillis()
                + "}";
            
            response.getWriter().write(jsonResponse);
            response.getWriter().flush();
            
            CurationLogger.exiting(PdfUploadController.class, "handleFileUpload");
            return null; // Return null since we've written the response directly
            
        } catch (Exception e) {
            CurationLogger.error("Error handling file upload", e);
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String errorResponse = "{"
                + "\"success\": false,"
                + "\"message\": \"An error occurred while processing the upload.\","
                + "\"errorCode\": \"INTERNAL_ERROR\","
                + "\"errorDetails\": \"" + e.getMessage().replace("\"", "\\\"") + "\""
                + "}";
            
            response.getWriter().write(errorResponse);
            response.getWriter().flush();
            return null;
        }
    }

    /**
     * Handle status check requests using real processing service
     */
    private ModelAndView handleStatusRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CurationLogger.entering(PdfUploadController.class, "handleStatusRequest");
        
        try {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            String uploadIdParam = request.getParameter("uploadId");
            if (uploadIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                String errorResponse = "{\"error\": \"uploadId parameter is required\"}";
                response.getWriter().write(errorResponse);
                response.getWriter().flush();
                return null;
            }
            
            Long uploadId;
            try {
                uploadId = Long.valueOf(uploadIdParam);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                String errorResponse = "{\"error\": \"Invalid uploadId format\"}";
                response.getWriter().write(errorResponse);
                response.getWriter().flush();
                return null;
            }
            
            // Get real processing status
            UploadStatus status = pdfProcessingService.getProcessingStatus(uploadId);
            
            String jsonResponse = "{"
                + "\"status\": \"" + status.getStatus() + "\","
                + "\"progress\": " + status.getProgress() + ","
                + "\"message\": \"" + status.getMessage() + "\","
                + "\"uploadId\": " + uploadId
                + "}";
            
            response.getWriter().write(jsonResponse);
            response.getWriter().flush();
            
            CurationLogger.exiting(PdfUploadController.class, "handleStatusRequest");
            return null;
            
        } catch (Exception e) {
            CurationLogger.error("Error handling status request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String errorResponse = "{\"error\": \"Internal server error\"}";
            response.getWriter().write(errorResponse);
            response.getWriter().flush();
            return null;
        }
    }

    /**
     * Handle cancel requests
     */
    private ModelAndView handleCancelRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String jsonResponse = "{"
            + "\"success\": true,"
            + "\"message\": \"Upload cancelled successfully\""
            + "}";
        
        response.getWriter().write(jsonResponse);
        response.getWriter().flush();
        return null;
    }

    /**
     * Handle session info requests
     */
    private ModelAndView handleSessionInfoRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String jsonResponse = "{"
            + "\"success\": true,"
            + "\"sessionId\": \"test-session\","
            + "\"activeUploadsCount\": 0,"
            + "\"totalUploads\": 0,"
            + "\"successfulUploads\": 0,"
            + "\"failedUploads\": 0"
            + "}";
        
        response.getWriter().write(jsonResponse);
        response.getWriter().flush();
        return null;
    }


    /**
     * Handle entity recognition requests
     */
    private ModelAndView handleEntityRecognitionRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CurationLogger.entering(PdfUploadController.class, "handleEntityRecognitionRequest");
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        
        String uploadId = request.getParameter("uploadId");
        String selectedModel = request.getParameter("model");
        
        // Default to 70B model if not specified
        if (selectedModel == null || selectedModel.trim().isEmpty()) {
            selectedModel = "llama3.3:70b";
        }
        
        if (uploadId == null || uploadId.trim().isEmpty()) {
            response.getWriter().write(generateErrorHtml("No upload ID provided", uploadId));
            response.getWriter().flush();
            return null;
        }
        
        try {
            // Get the extracted text for this upload
            Long uploadIdLong = Long.parseLong(uploadId);
            String extractedText = pdfProcessingService.getExtractedText(uploadIdLong);
            
            if (extractedText == null || extractedText.trim().isEmpty()) {
                response.getWriter().write(generateErrorHtml("No text found for upload ID: " + uploadId, uploadId));
                response.getWriter().flush();
                return null;
            }
            
            CurationLogger.info("Performing entity recognition on " + extractedText.length() + " characters of text");
            
            long startTime = System.currentTimeMillis();
            
            // Perform entity recognition using Ollama
            CurationLogger.info("=== STARTING ENTITY RECOGNITION with model {} ===", selectedModel);
            System.out.println("=== STARTING ENTITY RECOGNITION for upload " + uploadId + " with model " + selectedModel + " ===");
            System.out.println("Text length: " + extractedText.length() + " characters");
            EntityRecognitionResult result = entityRecognitionService.recognizeEntities(extractedText, selectedModel);
            System.out.println("=== ENTITY RECOGNITION RETURNED ===");
            
            long processingTime = System.currentTimeMillis() - startTime;
            result.setProcessingTimeMs(processingTime);
            
            // Log detailed results
            CurationLogger.info("=== ENTITY RECOGNITION COMPLETED in {} ms ===", processingTime);
            CurationLogger.info("Result successful: {}", result.isSuccessful());
            System.out.println("=== ENTITY RECOGNITION COMPLETED in " + processingTime + " ms ===");
            System.out.println("Result successful: " + result.isSuccessful());
            
            if (!result.isSuccessful()) {
                CurationLogger.error("Entity recognition failed with error: {}", result.getErrorMessage());
                System.out.println("ERROR: " + result.getErrorMessage());
                // Add error message to the HTML response
                response.setContentType("text/html");
                response.getWriter().write("<html><body><h1>Entity Recognition Failed</h1><p style='color:red;'>" + 
                    result.getErrorMessage() + "</p><p>Processing time: " + processingTime + "ms</p></body></html>");
                response.getWriter().flush();
                return null;
            }
            
            System.out.println("Genes found: " + (result.getGenes() != null ? result.getGenes().size() : 0));
            System.out.println("Species found: " + (result.getSpecies() != null ? result.getSpecies().size() : 0));
            CurationLogger.info("Genes found: {}", result.getGenes() != null ? result.getGenes().size() : 0);
            CurationLogger.info("Diseases found: {}", result.getDiseases() != null ? result.getDiseases().size() : 0);
            CurationLogger.info("Chemicals found: {}", result.getChemicals() != null ? result.getChemicals().size() : 0);
            CurationLogger.info("Species found: {}", result.getSpecies() != null ? result.getSpecies().size() : 0);
            CurationLogger.info("Phenotypes found: {}", result.getPhenotypes() != null ? result.getPhenotypes().size() : 0);
            CurationLogger.info("Cellular components found: {}", result.getCellularComponents() != null ? result.getCellularComponents().size() : 0);
            CurationLogger.info("Rat strains found: {}", result.getRatStrains() != null ? result.getRatStrains().size() : 0);
            
            // Generate HTML response with highlighted text
            String htmlContent = generateEntityRecognitionHtmlWithHighlighting(uploadId, result, extractedText);
            
            response.getWriter().write(htmlContent);
            response.getWriter().flush();
            
            CurationLogger.exiting(PdfUploadController.class, "handleEntityRecognitionRequest");
            
        } catch (Exception e) {
            CurationLogger.error("Entity recognition failed for upload " + uploadId, e);
            response.getWriter().write(generateErrorHtml("Entity recognition failed: " + e.getMessage(), uploadId));
            response.getWriter().flush();
        }
        
        return null;
    }
    
    /**
     * Handle chat requests for paper Q&A
     */
    private ModelAndView handleChatRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CurationLogger.entering(PdfUploadController.class, "handleChatRequest");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Read JSON request body
            StringBuilder jsonBody = new StringBuilder();
            String line;
            try (BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    jsonBody.append(line);
                }
            }
            
            // Parse JSON
            ObjectMapper mapper = new ObjectMapper();
            JsonNode requestJson = mapper.readTree(jsonBody.toString());
            
            String question = requestJson.get("question").asText();
            String uploadIdStr = request.getParameter("uploadId");
            
            CurationLogger.info("Chat request - Upload ID: {}, Question: {}", uploadIdStr, question);
            
            // Get extracted text using uploadId
            String paperContext = "";
            if (uploadIdStr != null) {
                try {
                    Long uploadId = Long.parseLong(uploadIdStr);
                    paperContext = pdfProcessingService.getExtractedText(uploadId);
                    CurationLogger.info("Retrieved paper context with length: {}", paperContext != null ? paperContext.length() : 0);
                } catch (NumberFormatException e) {
                    CurationLogger.error("Invalid uploadId format: {}", uploadIdStr);
                }
            }
            
            // Call Ollama to get answer
            String answer = getChatResponseFromOllama(question, paperContext);
            
            // Create response JSON
            Map<String, Object> responseMap = new HashMap<>();
            responseMap.put("success", true);
            responseMap.put("answer", answer);
            responseMap.put("timestamp", System.currentTimeMillis());
            
            String jsonResponse = mapper.writeValueAsString(responseMap);
            response.getWriter().write(jsonResponse);
            response.getWriter().flush();
            
        } catch (Exception e) {
            CurationLogger.error("Error handling chat request", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to process chat request: " + e.getMessage());
            
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(errorResponse));
            response.getWriter().flush();
        }
        
        return null;
    }
    
    /**
     * Get chat response from Ollama
     */
    private String getChatResponseFromOllama(String question, String paperContext) {
        try {
            // Prepare the prompt
            String prompt = "You are a helpful AI assistant analyzing a scientific paper. " +
                           "Based on the following paper content, please answer the user's question.\n\n" +
                           "Paper Content:\n" + paperContext + "\n\n" +
                           "User Question: " + question + "\n\n" +
                           "Please provide a clear and concise answer based on the paper content. " +
                           "If the answer is not found in the paper, say so.";
            
            // Call Ollama API - use configurable host
            String ollamaHost = System.getProperty("ollama.host", System.getProperty("curation.ollama.host", "grudge.rgd.mcw.edu"));
            String ollamaPort = System.getProperty("ollama.port", System.getProperty("curation.ollama.port", "11434"));
            String ollamaUrl = "http://" + ollamaHost + ":" + ollamaPort + "/api/generate";
            
            HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(30))
                .build();
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "llama3.1:8b");  // Faster model for chat interactions
            requestBody.put("prompt", prompt);
            requestBody.put("stream", false);
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 500);
            
            ObjectMapper mapper = new ObjectMapper();
            String requestJson = mapper.writeValueAsString(requestBody);
            
            HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(ollamaUrl))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(120))
                .POST(HttpRequest.BodyPublishers.ofString(requestJson))
                .build();
            
            HttpResponse<String> httpResponse = client.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            
            if (httpResponse.statusCode() == 200) {
                JsonNode responseJson = mapper.readTree(httpResponse.body());
                if (responseJson.has("response")) {
                    return responseJson.get("response").asText();
                }
            }
            
            return "I apologize, but I couldn't generate a response at this time. Please try again.";
            
        } catch (Exception e) {
            CurationLogger.error("Error calling Ollama for chat", e);
            return "I encountered an error while processing your question. Please try again later.";
        }
    }
    
    /**
     * Generate HTML for entity recognition results with text highlighting
     */
    private String generateEntityRecognitionHtmlWithHighlighting(String uploadId, EntityRecognitionResult result, String extractedText) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>")
            .append("<html><head>")
            .append("<title>Entity Recognition - Upload ").append(uploadId).append("</title>")
            .append("<style>")
            .append("body{font-family:Arial,sans-serif;margin:20px;line-height:1.6;}")
            .append(".header{background:#f8f9fa;padding:15px;border-radius:5px;margin-bottom:20px;}")
            .append(".tabs{display:flex;border-bottom:2px solid #dee2e6;margin-bottom:20px;}")
            .append(".tab{padding:10px 20px;cursor:pointer;background:#f8f9fa;margin-right:5px;border-radius:5px 5px 0 0;}")
            .append(".tab.active{background:#fff;border:1px solid #dee2e6;border-bottom:none;}")
            .append(".tab-content{display:none;}")
            .append(".tab-content.active{display:block;}")
            .append(".text-display{background:#fff;padding:40px;border:1px solid #ddd;white-space:normal;line-height:1.9;max-height:80vh;overflow-y:auto;text-align:left;font-size:15px;font-family:'Georgia','Times New Roman',serif;max-width:none;}")
            .append(".text-display p{margin:16px 0;text-indent:0;line-height:1.8;text-align:justify;font-weight:normal;font-size:15px;}")
            .append(".text-display .journal-header{font-size:12px;color:#666;text-align:right;margin-bottom:20px;font-style:italic;border-bottom:1px solid #eee;padding-bottom:10px;}")
            .append(".text-display .article-title{font-size:24px;font-weight:bold;margin:30px 0 20px 0;text-align:center;line-height:1.3;color:#2c3e50;border-bottom:2px solid #3498db;padding-bottom:15px;}")
            .append(".text-display .authors{font-size:14px;color:#555;margin:20px 0;line-height:1.6;text-align:center;font-style:italic;}")
            .append(".text-display .section-header{font-size:18px;font-weight:bold;margin:35px 0 18px 0;text-align:left;color:#2c3e50;border-bottom:1px solid #bdc3c7;padding-bottom:8px;}")
            .append(".text-display .subsection-title{font-size:16px;font-weight:600;margin:25px 0 15px 0;color:#34495e;}")
            .append(".text-display h1{font-size:24px;font-weight:bold;margin:30px 0 20px 0;color:#2c3e50;}")
            .append(".text-display h2{font-size:20px;font-weight:bold;margin:25px 0 15px 0;color:#2c3e50;}")
            .append(".text-display h3{font-size:18px;font-weight:bold;margin:20px 0 12px 0;color:#34495e;}")
            .append(".text-display .figure-caption{font-size:13px;color:#666;margin:15px 0;font-style:italic;text-align:center;background:#f8f9fa;padding:10px;border-left:4px solid #3498db;}")
            .append(".text-display .figure-container{text-align:center;margin:25px 0;}")
            .append(".text-display .pdf-image{max-width:100%;height:auto;border:1px solid #ddd;box-shadow:0 4px 8px rgba(0,0,0,0.1);border-radius:4px;}")
            .append(".highlight-gene{background:#e8f5e9;border:1px solid #4caf50;padding:2px 6px;border-radius:4px;font-weight:500;color:#2e7d32;}")
            .append(".highlight-disease{background:#ffebee;border:1px solid #f44336;padding:2px 6px;border-radius:4px;font-weight:500;color:#c62828;}")
            .append(".highlight-chemical{background:#fff8e1;border:1px solid #ffc107;padding:2px 6px;border-radius:4px;font-weight:500;color:#f57c00;}")
            .append(".highlight-species{background:#e3f2fd;border:1px solid #2196f3;padding:2px 6px;border-radius:4px;font-weight:500;color:#1565c0;}")
            .append(".highlight-phenotype{background:#f3e5f5;border:1px solid #9c27b0;padding:2px 6px;border-radius:4px;font-weight:500;color:#7b1fa2;}")
            .append(".highlight-cellular-component{background:#e0f2f1;border:1px solid #009688;padding:2px 6px;border-radius:4px;font-weight:500;color:#00695c;}")
            .append(".highlight-rat-strain{background:#fff3e0;border:1px solid #ff9800;padding:2px 6px;border-radius:4px;font-weight:500;color:#ef6c00;}")
            .append(".entity{display:inline-block;margin:2px;padding:4px 8px;border-radius:4px;font-weight:bold;}")
            .append(".gene{background:#d4edda;color:#155724;}")
            .append(".disease{background:#f8d7da;color:#721c24;}")
            .append(".chemical{background:#fff3cd;color:#856404;}")
            .append(".species{background:#cce5ff;color:#004085;}")
            .append(".phenotype{background:#e2e3e5;color:#383d41;}")
            .append(".cellular-component{background:#e1d5e7;color:#6f42c1;}")
            .append(".rat-strain{background:#ffebe6;color:#cc5500;}")
            .append(".confidence{font-size:0.8em;opacity:0.8;}")
            .append(".accession-id{font-size:0.9em;color:#666;font-weight:normal;margin:0 5px;padding:2px 6px;background:#f0f0f0;border-radius:3px;}")
            .append(".stats{background:#e9ecef;padding:10px;border-radius:5px;margin-bottom:15px;}")
            .append(".section{margin-bottom:20px;}")
            .append(".entity-list{margin-left:20px;}")
            .append(".no-entities{color:#6c757d;font-style:italic;}")
            .append(".tooltip{position:relative;display:inline-block;cursor:help;}")
            .append(".tooltip .tooltiptext{visibility:hidden;width:220px;background-color:#2c3e50;color:#fff;text-align:center;padding:8px 12px;border-radius:6px;position:absolute;z-index:1000;bottom:130%;left:50%;margin-left:-110px;opacity:0;transition:opacity 0.3s ease;font-size:12px;font-weight:normal;box-shadow:0 4px 8px rgba(0,0,0,0.2);}")
            .append(".tooltip:hover .tooltiptext{visibility:visible;opacity:0.95;}")
            .append(".tooltip .tooltiptext::after{content:'';position:absolute;top:100%;left:50%;margin-left:-5px;border-width:5px;border-style:solid;border-color:#2c3e50 transparent transparent transparent;}")
            .append(".column-header{font-weight:bold;color:#666;border-bottom:1px solid #ddd;padding-bottom:5px;margin-bottom:10px;}")
            .append(".chat-container{display:flex;flex-direction:column;height:600px;border:1px solid #ddd;border-radius:8px;}")
            .append(".chat-messages{flex:1;overflow-y:auto;padding:20px;background:#f8f9fa;}")
            .append(".chat-message{margin-bottom:15px;padding:10px 15px;border-radius:8px;max-width:70%;}")
            .append(".chat-message.user{background:#007bff;color:white;margin-left:auto;text-align:right;}")
            .append(".chat-message.assistant{background:#ffffff;border:1px solid #dee2e6;}")
            .append(".chat-input-container{display:flex;padding:15px;background:#fff;border-top:1px solid #dee2e6;}")
            .append(".chat-input{flex:1;padding:10px;border:1px solid #ced4da;border-radius:4px;margin-right:10px;font-size:14px;}")
            .append(".chat-send-btn{padding:10px 20px;background:#007bff;color:white;border:none;border-radius:4px;cursor:pointer;font-weight:500;}")
            .append(".chat-send-btn:hover{background:#0056b3;}")
            .append(".chat-send-btn:disabled{background:#6c757d;cursor:not-allowed;}")
            .append(".chat-typing{font-style:italic;color:#6c757d;padding:5px 15px;}")
            .append(".chat-timestamp{font-size:11px;color:#6c757d;margin-top:5px;}")
            .append("</style>")
            .append("</head><body>");
        
        // Header
        html.append("<div class='header'>")
            .append("<h1>Entity Recognition Results</h1>")
            .append("<p><strong>Upload ID:</strong> ").append(uploadId).append("</p>");
            
        if (result.isSuccessful()) {
            html.append("<p><strong>Processing Time:</strong> ").append(result.getProcessingTimeMs()).append("ms</p>")
                .append("<p><strong>Text Length:</strong> ").append(extractedText.length()).append(" characters</p>");
        }
        
        html.append("</div>");
        
        if (!result.isSuccessful()) {
            html.append("<div class='alert alert-danger'>")
                .append("<h3>Error</h3>")
                .append("<p>").append(result.getErrorMessage()).append("</p>")
                .append("</div>");
        } else {
            // Statistics
            html.append("<div class='stats'>")
                .append("<strong>Summary:</strong> ")
                .append("Found ").append(result.getTotalEntities()).append(" entities total - ")
                .append("Genes: ").append(result.getGenes().size()).append(", ")
                .append("Diseases: ").append(result.getDiseases().size()).append(", ")
                .append("Chemicals: ").append(result.getChemicals().size()).append(", ")
                .append("Species: ").append(result.getSpecies().size()).append(", ")
                .append("Phenotypes: ").append(result.getPhenotypes().size()).append(", ")
                .append("Cellular Components: ").append(result.getCellularComponents().size()).append(", ")
                .append("Rat Strains: ").append(result.getRatStrains().size())
                .append("</div>");
            
            // Tabs
            html.append("<div class='tabs'>")
                .append("<div id='highlighted-tab' class='tab active' onclick='showTab(\"highlighted\")'>Highlighted Text</div>")
                .append("<div id='entities-tab' class='tab' onclick='showTab(\"entities\")'>Entity List</div>")
                .append("<div id='summary-tab' class='tab' onclick='showTab(\"summary\")'>Summary</div>")
                .append("<div id='significant-tab' class='tab' onclick='showTab(\"significant\")'>Significant Results</div>")
                .append("<div id='chat-tab' class='tab' onclick='showTab(\"chat\")'>Chat</div>")
                .append("</div>");
            
            // Highlighted text tab
            html.append("<div id='highlighted-content' class='tab-content active'>");
            html.append("<h3>Text with Highlighted Entities</h3>");
            html.append("<div class='text-display'>");
            
            // Highlight entities in text
            String highlightedText = highlightEntitiesInText(extractedText, result, uploadId);
            html.append(highlightedText);
            
            html.append("</div>");
            html.append("</div>");
            
            // Entity list tab
            html.append("<div id='entities-content' class='tab-content'>");
            html.append("<h3>Identified Entities</h3>");
            
            // Entity sections
            CurationLogger.info("DEBUG: About to append entity sections for entity list tab");
            CurationLogger.info("DEBUG: Genes count: " + (result.getGenes() != null ? result.getGenes().size() : "null"));
            CurationLogger.info("DEBUG: Diseases count: " + (result.getDiseases() != null ? result.getDiseases().size() : "null"));
            CurationLogger.info("DEBUG: Chemicals count: " + (result.getChemicals() != null ? result.getChemicals().size() : "null"));
            CurationLogger.info("DEBUG: Species count: " + (result.getSpecies() != null ? result.getSpecies().size() : "null"));
            CurationLogger.info("DEBUG: Phenotypes count: " + (result.getPhenotypes() != null ? result.getPhenotypes().size() : "null"));
            CurationLogger.info("DEBUG: Cellular Components count: " + (result.getCellularComponents() != null ? result.getCellularComponents().size() : "null"));
            CurationLogger.info("DEBUG: Rat Strains count: " + (result.getRatStrains() != null ? result.getRatStrains().size() : "null"));
            
            appendEntitySection(html, "Genes", result.getGenes(), "gene");
            appendEntitySection(html, "Diseases", result.getDiseases(), "disease");
            appendEntitySection(html, "Chemicals", result.getChemicals(), "chemical");
            appendEntitySection(html, "Species", result.getSpecies(), "species");
            appendEntitySection(html, "Phenotypes", result.getPhenotypes(), "phenotype");
            appendEntitySection(html, "Cellular Components", result.getCellularComponents(), "cellular-component");
            appendEntitySection(html, "Rat Strains", result.getRatStrains(), "rat-strain");
            
            html.append("</div>");
            
            // Summary tab
            html.append("<div id='summary-content' class='tab-content'>");
            html.append("<h3>Paper Summary</h3>");
            
            // Generate and append summary
            String summary = generatePaperSummary(extractedText, result);
            html.append(summary);
            
            html.append("</div>");
            
            // Significant Results tab
            html.append("<div id='significant-content' class='tab-content'>");
            html.append("<h3>Significant Results</h3>");
            
            // Generate and append significant results
            String significantResults = generateSignificantResults(extractedText, result);
            html.append(significantResults);
            
            html.append("</div>");
            
            // Chat tab
            html.append("<div id='chat-content' class='tab-content'>");
            html.append("<h3>Chat with Paper</h3>");
            html.append("<p style='color:#6c757d;margin-bottom:15px;'>Ask questions about this paper and get AI-powered insights.</p>");
            html.append("<div class='chat-container'>");
            html.append("<div id='chat-messages' class='chat-messages'>");
            html.append("<div class='chat-message assistant'>Hello! I can help you understand this paper better. Feel free to ask me questions about the content, findings, methodologies, or any specific aspects you'd like to explore.</div>");
            html.append("</div>");
            html.append("<div class='chat-input-container'>");
            html.append("<input type='text' id='chat-input' class='chat-input' placeholder='Type your question here...' onkeypress='if(event.key===\"Enter\") sendChatMessage()'>");
            html.append("<button id='chat-send-btn' class='chat-send-btn' onclick='sendChatMessage()'>Send</button>");
            html.append("</div>");
            html.append("</div>");
            html.append("</div>");
        }
        
        html.append("<script type='text/javascript'>")
            .append("function showTab(tabName) {")
            .append("  var tabs = document.querySelectorAll('.tab');")
            .append("  var contents = document.querySelectorAll('.tab-content');")
            .append("  for (var i = 0; i < tabs.length; i++) {")
            .append("    tabs[i].classList.remove('active');")
            .append("  }")
            .append("  for (var i = 0; i < contents.length; i++) {")
            .append("    contents[i].classList.remove('active');")
            .append("  }")
            .append("  document.getElementById(tabName + '-tab').classList.add('active');")
            .append("  document.getElementById(tabName + '-content').classList.add('active');")
            .append("}")
            .append("function sendChatMessage() {")
            .append("  var input = document.getElementById('chat-input');")
            .append("  var question = input.value.trim();")
            .append("  if (!question) return;")
            .append("  var messagesDiv = document.getElementById('chat-messages');")
            .append("  messagesDiv.innerHTML += '<div class=\"chat-message user\">' + question + '</div>';")
            .append("  input.value = '';")
            .append("  messagesDiv.innerHTML += '<div class=\"chat-message assistant typing\">Thinking...</div>';")
            .append("  messagesDiv.scrollTop = messagesDiv.scrollHeight;")
            .append("  var xhr = new XMLHttpRequest();")
            .append("  xhr.open('POST', '/rgdweb/curation/pdf/upload.html?action=chat&uploadId=" + uploadId + "', true);")
            .append("  xhr.setRequestHeader('Content-Type', 'application/json');")
            .append("  xhr.onreadystatechange = function() {")
            .append("    if (xhr.readyState === 4) {")
            .append("      var typingDiv = messagesDiv.querySelector('.typing');")
            .append("      if (typingDiv) typingDiv.remove();")
            .append("      if (xhr.status === 200) {")
            .append("        var response = JSON.parse(xhr.responseText);")
            .append("        messagesDiv.innerHTML += '<div class=\"chat-message assistant\">' + response.answer + '</div>';")
            .append("      } else {")
            .append("        messagesDiv.innerHTML += '<div class=\"chat-message assistant error\">Sorry, I encountered an error. Please try again.</div>';")
            .append("      }")
            .append("      messagesDiv.scrollTop = messagesDiv.scrollHeight;")
            .append("    }")
            .append("  };")
            .append("  xhr.send(JSON.stringify({question: question}));")
            .append("}")
            .append("</script>")
            .append("<p><a href='javascript:history.back()'>← Back to Upload</a></p>")
            .append("</body></html>");
        
        return html.toString();
    }
    
    /**
     * Highlight entities in the extracted text
     */
    private String highlightEntitiesInText(String text, EntityRecognitionResult result, String uploadId) {
        // Remove Marker page span tags first
        String cleanedText = text.replaceAll("<span id=\"page-\\d+-\\d+\"></span>", "");
        
        // Process markdown headers FIRST before HTML escaping
        String processedText = processMarkdownHeaders(cleanedText);
        
        // Escape HTML characters (but preserve our newly created HTML tags)
        String escapedText = escapeHtmlButPreserveTags(processedText);
        
        // Create a list of all entities with their type for highlighting
        Map<String, String> entityMap = new HashMap<>();
        
        // Add all entities to the map
        for (BiologicalEntity entity : result.getGenes()) {
            entityMap.put(entity.getName(), "gene");
        }
        for (BiologicalEntity entity : result.getDiseases()) {
            entityMap.put(entity.getName(), "disease");
        }
        for (BiologicalEntity entity : result.getChemicals()) {
            entityMap.put(entity.getName(), "chemical");
        }
        for (BiologicalEntity entity : result.getSpecies()) {
            entityMap.put(entity.getName(), "species");
        }
        for (BiologicalEntity entity : result.getPhenotypes()) {
            entityMap.put(entity.getName(), "phenotype");
        }
        for (BiologicalEntity entity : result.getCellularComponents()) {
            entityMap.put(entity.getName(), "cellular-component");
        }
        for (BiologicalEntity entity : result.getRatStrains()) {
            entityMap.put(entity.getName(), "rat-strain");
        }
        
        // Sort entities by length (longer first) to avoid partial matches
        List<Map.Entry<String, String>> sortedEntities = new ArrayList<>(entityMap.entrySet());
        sortedEntities.sort((a, b) -> Integer.compare(b.getKey().length(), a.getKey().length()));
        
        // Highlight each entity in the text
        String highlightedText = escapedText;
        for (Map.Entry<String, String> entry : sortedEntities) {
            String entityName = entry.getKey();
            String entityType = entry.getValue();
            
            // Create case-insensitive pattern
            String pattern = "(?i)\\b" + java.util.regex.Pattern.quote(entityName) + "\\b";
            String replacement = "<span class='highlight-" + entityType + " tooltip'>" +
                "$0<span class='tooltiptext'>" + entityType + ": " + entityName + "</span></span>";
            
            highlightedText = highlightedText.replaceAll(pattern, replacement);
        }
        
        // Get extracted images for this upload
        List<String> imageUrls;
        try {
            Long uploadIdLong = Long.valueOf(uploadId);
            imageUrls = pdfProcessingService.getExtractedImages(uploadIdLong);
            System.out.println("DEBUG: Retrieved " + imageUrls.size() + " images for upload " + uploadId);
            CurationLogger.info("Retrieved {} images for upload {}", imageUrls.size(), uploadId);
        } catch (Exception e) {
            System.out.println("DEBUG: Failed to get extracted images: " + e.getMessage());
            CurationLogger.warn("Failed to get extracted images for upload {}: {}", uploadId, e.getMessage());
            imageUrls = new ArrayList<>();
        }
        
        // Format with proper document structure (same as view text)
        highlightedText = formatDocumentStructure(highlightedText, imageUrls);
        
        // Final cleanup pass: specifically target any remaining **CAPS** patterns that weren't caught
        highlightedText = cleanupRemainingAsterisks(highlightedText);
        
        return highlightedText;
    }
    
    /**
     * Format extracted text to match the original PDF layout structure
     */
    private String formatDocumentStructure(String text, List<String> imageUrls) {
        System.out.println("DEBUG: formatDocumentStructure called with imageUrls.size(): " + imageUrls.size());
        
        // Split into lines for processing
        String[] lines = text.split("\n");
        StringBuilder formatted = new StringBuilder();
        
        boolean inParagraph = false;
        String currentParagraph = "";
        int imageIndex = 0;
        int totalLines = lines.length;
        
        // Track which figures have been inserted to avoid duplicates
        Set<Integer> insertedFigures = new HashSet<>();
        
        for (int i = 0; i < lines.length; i++) {
            String line = lines[i].trim();
            
            // Skip completely empty lines
            if (line.isEmpty()) {
                // End current paragraph if we have one
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                continue;
            }
            
            // Skip column markers - remove two-column layout functionality
            if (line.equals("=== LEFT COLUMN ===") || line.equals("=== RIGHT COLUMN ===")) {
                // Simply skip these markers instead of creating column layout
                continue;
            }
            
            // Detect journal/publication info
            if (isJournalHeader(line)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                formatted.append("<div class='journal-header'>").append(line).append("</div>");
                continue;
            }
            
            // Detect main article title
            if (isMainTitle(line, i, lines)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                formatted.append("<h1 class='article-title'>").append(line).append("</h1>");
                continue;
            }
            
            // Detect author information
            if (isAuthorLine(line)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                formatted.append("<div class='authors'>").append(line).append("</div>");
                continue;
            }
            
            
            // Detect subsection titles
            if (isSubsectionTitle(line, i, lines)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                formatted.append("<h3 class='subsection-title'>").append(line).append("</h3>");
                continue;
            }
            
            // Detect figure/table captions
            if (isFigureCaption(line)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                
                // Insert image before figure caption if available
                if (imageIndex < imageUrls.size()) {
                    String imageUrl = imageUrls.get(imageIndex);
                    formatted.append("<div class='figure-container'>")
                             .append("<img src='").append(imageUrl).append("' alt='Figure' class='pdf-image'/>")
                             .append("</div>");
                    imageIndex++;
                }
                
                formatted.append("<div class='figure-caption'>").append(line).append("</div>");
                continue;
            }
            
            // Handle section headers
            if (isSectionHeader(line)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    formatted.append("<p>").append(currentParagraph.trim()).append("</p>");
                    currentParagraph = "";
                    inParagraph = false;
                }
                // Remove markdown bold markers from section headers
                String cleanHeader = line.replaceAll("\\*\\*", "").replaceAll("__", "").trim();
                formatted.append("<h2 class='section-header'>").append(cleanHeader).append("</h2>");
                
                // Insert an image after major sections if we have remaining images
                if (imageIndex < imageUrls.size()) {
                    String imageUrl = imageUrls.get(imageIndex);
                    formatted.append("<div class='figure-container'>")
                             .append("<img src='").append(imageUrl).append("' alt='Figure " + (imageIndex + 1) + "' class='pdf-image'/>")
                             .append("</div>");
                    imageIndex++;
                }
                continue;
            }
            
            // Check if this line should start a new paragraph
            if (isNewParagraphStart(line, i, lines)) {
                if (inParagraph && !currentParagraph.trim().isEmpty()) {
                    // Before closing paragraph, check for figures and insert them
                    String processedParagraph = insertFiguresInText(currentParagraph.trim(), imageUrls, insertedFigures);
                    formatted.append("<p>").append(processedParagraph).append("</p>");
                    currentParagraph = "";
                }
                currentParagraph = line;
                inParagraph = true;
            } else {
                // Continue current paragraph
                if (!inParagraph) {
                    currentParagraph = line;
                    inParagraph = true;
                } else {
                    currentParagraph += " " + line;
                }
            }
        }
        
        // Close final paragraph if needed
        if (inParagraph && !currentParagraph.trim().isEmpty()) {
            // Process figures in final paragraph
            String processedParagraph = insertFiguresInText(currentParagraph.trim(), imageUrls, insertedFigures);
            formatted.append("<p>").append(processedParagraph).append("</p>");
        }
        
        // Insert any remaining images at the end
        while (imageIndex < imageUrls.size()) {
            String imageUrl = imageUrls.get(imageIndex);
            formatted.append("<div class='figure-container'>")
                     .append("<img src='").append(imageUrl).append("' alt='Figure " + (imageIndex + 1) + "' class='pdf-image'/>")
                     .append("</div>");
            imageIndex++;
        }
        
        
        return formatted.toString();
    }
    
    /**
     * Detect journal header lines (e.g., "nature structural & molecular biology")
     */
    private boolean isJournalHeader(String line) {
        return line.toLowerCase().matches(".*(nature|cell|science|journal|proceedings|molecular biology|volume|number).*") &&
               line.length() < 100;
    }
    
    /**
     * Generate a summary of the paper based on extracted text
     */
    private String generatePaperSummary(String extractedText, EntityRecognitionResult result) {
        StringBuilder summary = new StringBuilder();
        
        // Split text into lines for analysis
        String[] lines = extractedText.split("\n");
        
        // Try to identify title (usually first substantial line)
        String title = "";
        for (String line : lines) {
            line = line.trim();
            if (line.length() > 20 && !line.matches("^\\d+→.*")) {
                title = line;
                break;
            }
        }
        
        if (!title.isEmpty()) {
            summary.append("<h4>Title</h4>");
            summary.append("<p>").append(title).append("</p>");
        }
        
        // Key findings based on entities
        summary.append("<h4>Key Entities Identified</h4>");
        summary.append("<ul>");
        
        if (result.getGenes() != null && !result.getGenes().isEmpty()) {
            summary.append("<li><strong>Genes/Proteins:</strong> ");
            summary.append(result.getGenes().size()).append(" identified, including ");
            summary.append(result.getGenes().stream()
                .limit(3)
                .map(BiologicalEntity::getName)
                .collect(Collectors.joining(", ")));
            if (result.getGenes().size() > 3) {
                summary.append(" and others");
            }
            summary.append("</li>");
        }
        
        if (result.getDiseases() != null && !result.getDiseases().isEmpty()) {
            summary.append("<li><strong>Diseases:</strong> ");
            summary.append(result.getDiseases().stream()
                .limit(3)
                .map(BiologicalEntity::getName)
                .collect(Collectors.joining(", ")));
            summary.append("</li>");
        }
        
        if (result.getChemicals() != null && !result.getChemicals().isEmpty()) {
            summary.append("<li><strong>Chemicals/Drugs:</strong> ");
            summary.append(result.getChemicals().stream()
                .limit(3)
                .map(BiologicalEntity::getName)
                .collect(Collectors.joining(", ")));
            summary.append("</li>");
        }
        
        if (result.getSpecies() != null && !result.getSpecies().isEmpty()) {
            summary.append("<li><strong>Species:</strong> ");
            summary.append(result.getSpecies().stream()
                .map(BiologicalEntity::getName)
                .distinct()
                .collect(Collectors.joining(", ")));
            summary.append("</li>");
        }
        
        summary.append("</ul>");
        
        // Extract key sentences containing important entities
        summary.append("<h4>Key Findings</h4>");
        summary.append("<ul>");
        
        // Find sentences with multiple entities
        String[] sentences = extractedText.split("\\. ");
        int keyFindings = 0;
        for (String sentence : sentences) {
            if (keyFindings >= 5) break; // Limit to 5 key findings
            
            int entityCount = 0;
            // Count entities in this sentence
            if (result.getGenes() != null) {
                for (BiologicalEntity gene : result.getGenes()) {
                    if (sentence.toLowerCase().contains(gene.getName().toLowerCase())) {
                        entityCount++;
                    }
                }
            }
            
            // If sentence contains 2+ entities, consider it important
            if (entityCount >= 2 && sentence.length() > 50 && sentence.length() < 300) {
                summary.append("<li>").append(sentence.trim()).append(".</li>");
                keyFindings++;
            }
        }
        
        if (keyFindings == 0) {
            summary.append("<li>No key findings with multiple entity relationships were automatically identified.</li>");
        }
        
        summary.append("</ul>");
        
        // Statistics
        summary.append("<h4>Document Statistics</h4>");
        summary.append("<ul>");
        summary.append("<li>Total words: ").append(extractedText.split("\\s+").length).append("</li>");
        summary.append("<li>Total entities identified: ").append(result.getTotalEntities()).append("</li>");
        summary.append("<li>Processing time: ").append(result.getProcessingTimeMs()).append(" ms</li>");
        summary.append("</ul>");
        
        return summary.toString();
    }
    
    /**
     * Generate significant results analysis focusing on statistical significance
     */
    private String generateSignificantResults(String extractedText, EntityRecognitionResult result) {
        StringBuilder results = new StringBuilder();
        
        // Find p-values and statistical significance
        results.append("<h4>Statistical Significance Analysis</h4>");
        
        List<String> significantFindings = findStatisticalSignificance(extractedText);
        
        if (!significantFindings.isEmpty()) {
            results.append("<div class='alert alert-success'>");
            results.append("<strong>Significant Results Found:</strong> ").append(significantFindings.size()).append(" statistically significant findings detected");
            results.append("</div>");
            
            results.append("<h5>P-values &lt; 0.05:</h5>");
            results.append("<ul>");
            
            for (String finding : significantFindings) {
                results.append("<li>").append(finding).append("</li>");
            }
            
            results.append("</ul>");
        } else {
            results.append("<div class='alert alert-warning'>");
            results.append("<strong>No Clear Statistical Significance Found:</strong> No p-values < 0.05 were automatically detected in the text.");
            results.append("</div>");
        }
        
        // Look for other significance indicators
        results.append("<h4>Other Significance Indicators</h4>");
        List<String> otherSignificance = findOtherSignificanceIndicators(extractedText);
        
        if (!otherSignificance.isEmpty()) {
            results.append("<ul>");
            for (String indicator : otherSignificance) {
                results.append("<li>").append(indicator).append("</li>");
            }
            results.append("</ul>");
        } else {
            results.append("<p><em>No additional significance indicators found.</em></p>");
        }
        
        // Statistical method analysis
        results.append("<h4>Statistical Methods Detected</h4>");
        List<String> methods = findStatisticalMethods(extractedText);
        
        if (!methods.isEmpty()) {
            results.append("<ul>");
            for (String method : methods) {
                results.append("<li>").append(method).append("</li>");
            }
            results.append("</ul>");
        } else {
            results.append("<p><em>No specific statistical methods automatically identified.</em></p>");
        }
        
        // Entity-related significant findings
        results.append("<h4>Entity-Related Significant Findings</h4>");
        List<String> entityFindings = findEntityRelatedSignificance(extractedText, result);
        
        if (!entityFindings.isEmpty()) {
            results.append("<ul>");
            for (String finding : entityFindings) {
                results.append("<li>").append(finding).append("</li>");
            }
            results.append("</ul>");
        } else {
            results.append("<p><em>No entity-specific significant findings detected.</em></p>");
        }
        
        return results.toString();
    }
    
    /**
     * Find p-values and statistical significance in text
     */
    private List<String> findStatisticalSignificance(String text) {
        List<String> findings = new ArrayList<>();
        String[] sentences = text.split("\\.");
        
        // Patterns for p-values
        String[] pValuePatterns = {
            "p\\s*[<>=]\\s*0\\.0[0-4]\\d*",
            "p\\s*[<>=]\\s*\\.0[0-4]\\d*",
            "P\\s*[<>=]\\s*0\\.0[0-4]\\d*",
            "P\\s*[<>=]\\s*\\.0[0-4]\\d*",
            "p-value\\s*[<>=]\\s*0\\.0[0-4]\\d*",
            "P-value\\s*[<>=]\\s*0\\.0[0-4]\\d*"
        };
        
        for (String sentence : sentences) {
            sentence = sentence.trim();
            for (String pattern : pValuePatterns) {
                if (sentence.matches(".*" + pattern + ".*")) {
                    // Extract context around the p-value
                    String context = extractPValueContext(sentence);
                    if (!context.isEmpty() && sentence.length() > 20 && sentence.length() < 400) {
                        findings.add(context);
                    }
                    break;
                }
            }
        }
        
        return findings;
    }
    
    /**
     * Find other indicators of significance
     */
    private List<String> findOtherSignificanceIndicators(String text) {
        List<String> indicators = new ArrayList<>();
        String[] sentences = text.split("\\.");
        
        String[] significanceKeywords = {
            "significantly",
            "significant difference",
            "statistically significant",
            "highly significant",
            "significantly higher",
            "significantly lower",
            "significantly increased",
            "significantly decreased",
            "significant correlation",
            "significant association",
            "significant reduction",
            "significant improvement",
            "significant effect"
        };
        
        for (String sentence : sentences) {
            sentence = sentence.trim().toLowerCase();
            for (String keyword : significanceKeywords) {
                if (sentence.contains(keyword) && sentence.length() > 30 && sentence.length() < 300) {
                    // Capitalize first letter for display
                    String displaySentence = sentence.substring(0, 1).toUpperCase() + sentence.substring(1);
                    indicators.add(displaySentence);
                    break;
                }
            }
        }
        
        // Remove duplicates and limit to top 10
        return indicators.stream().distinct().limit(10).collect(Collectors.toList());
    }
    
    /**
     * Find statistical methods mentioned in the text
     */
    private List<String> findStatisticalMethods(String text) {
        List<String> methods = new ArrayList<>();
        String lowerText = text.toLowerCase();
        
        String[] statisticalMethods = {
            "t-test", "t test", "student's t-test",
            "anova", "analysis of variance",
            "chi-square", "chi square test",
            "mann-whitney", "wilcoxon",
            "fisher's exact test",
            "regression analysis", "linear regression", "logistic regression",
            "correlation analysis", "pearson correlation", "spearman correlation",
            "bootstrap", "monte carlo",
            "confidence interval", "95% confidence interval"
        };
        
        for (String method : statisticalMethods) {
            if (lowerText.contains(method)) {
                methods.add(method.substring(0, 1).toUpperCase() + method.substring(1));
            }
        }
        
        return methods.stream().distinct().collect(Collectors.toList());
    }
    
    /**
     * Find significant findings related to identified entities
     */
    private List<String> findEntityRelatedSignificance(String text, EntityRecognitionResult result) {
        List<String> findings = new ArrayList<>();
        String[] sentences = text.split("\\.");
        
        // Collect all entity names
        List<String> entityNames = new ArrayList<>();
        if (result.getGenes() != null) {
            entityNames.addAll(result.getGenes().stream().map(BiologicalEntity::getName).collect(Collectors.toList()));
        }
        if (result.getDiseases() != null) {
            entityNames.addAll(result.getDiseases().stream().map(BiologicalEntity::getName).collect(Collectors.toList()));
        }
        if (result.getChemicals() != null) {
            entityNames.addAll(result.getChemicals().stream().map(BiologicalEntity::getName).collect(Collectors.toList()));
        }
        
        for (String sentence : sentences) {
            sentence = sentence.trim();
            String lowerSentence = sentence.toLowerCase();
            
            // Check if sentence contains both an entity and significance indicators
            boolean hasEntity = false;
            boolean hasSignificance = false;
            
            for (String entityName : entityNames) {
                if (lowerSentence.contains(entityName.toLowerCase())) {
                    hasEntity = true;
                    break;
                }
            }
            
            if (hasEntity) {
                String[] sigIndicators = {"p <", "p=", "p>", "significantly", "significant"};
                for (String indicator : sigIndicators) {
                    if (lowerSentence.contains(indicator)) {
                        hasSignificance = true;
                        break;
                    }
                }
                
                if (hasSignificance && sentence.length() > 40 && sentence.length() < 350) {
                    findings.add(sentence);
                }
            }
        }
        
        return findings.stream().distinct().limit(8).collect(Collectors.toList());
    }
    
    /**
     * Extract context around p-value mentions
     */
    private String extractPValueContext(String sentence) {
        // Clean up the sentence and return meaningful context
        sentence = sentence.trim();
        if (sentence.length() > 300) {
            // Try to find the p-value and extract reasonable context around it
            String[] parts = sentence.split("(?i)p\\s*[<>=]");
            if (parts.length > 1) {
                String before = parts[0];
                String after = parts[1];
                
                // Take last part of before (up to 150 chars) and first part of after (up to 150 chars)
                if (before.length() > 150) {
                    before = "..." + before.substring(before.length() - 150);
                }
                if (after.length() > 150) {
                    after = after.substring(0, 150) + "...";
                }
                
                return before + " p" + after;
            }
        }
        return sentence;
    }
    
    /**
     * Detect main article title
     */
    private boolean isMainTitle(String line, int index, String[] lines) {
        // Only consider lines very early in the document as potential titles
        if (line.length() < 10 || index > 5) return false;
        
        // Should start with capital and not be a sentence with periods
        if (!Character.isUpperCase(line.charAt(0)) || line.contains(".")) return false;
        
        // Should be relatively short for a title (not a full sentence/paragraph)
        if (line.split("\\s+").length > 15) return false;
        
        // Avoid lines that look like paragraphs or have complex punctuation
        if (line.contains(";") || line.contains("(") || line.contains(")")) return false;
        
        // Look for common title patterns but be more restrictive
        return line.matches(".*\\b(Analysis|Study|Investigation|Research|Report)\\b.*") ||
               line.matches("^[A-Z][a-z]+\\s+of\\s+.*") ||
               (line.split("\\s+").length >= 3 && line.split("\\s+").length <= 8 && 
                !line.toLowerCase().contains("the") && !line.toLowerCase().contains("and"));
    }
    
    /**
     * Detect author information lines
     */
    private boolean isAuthorLine(String line) {
        // Look for patterns typical of author lines
        return line.matches(".*[A-Z][a-z]+\\s+[A-Z][a-z]+.*") && // First Last names
               (line.contains(",") || line.matches(".*\\d+.*")) && // Contains commas or numbers (affiliations)
               line.length() < 200;
    }
    
    /**
     * Detect section headers (RESULTS, DISCUSSION, etc.)
     */
    private boolean isSectionHeader(String line) {
        // Remove markdown bold markers if present
        String cleanLine = line.replaceAll("\\*\\*", "").replaceAll("__", "").trim();
        
        CurationLogger.info("DEBUG: isSectionHeader checking: '" + line + "' -> cleaned: '" + cleanLine + "'");
        
        if (cleanLine.length() < 3 || cleanLine.length() > 50) {
            CurationLogger.info("DEBUG: isSectionHeader rejected due to length: " + cleanLine.length());
            return false;
        }
        
        // Check for typical section headers
        boolean isHeader = cleanLine.equals("RESULTS") || 
               cleanLine.equals("DISCUSSION") || 
               cleanLine.equals("METHODS") ||
               cleanLine.equals("INTRODUCTION") ||
               cleanLine.equals("CONCLUSION") ||
               cleanLine.equals("ABSTRACT") ||
               cleanLine.equals("REFERENCES") ||
               cleanLine.equals("ACKNOWLEDGMENTS") ||
               cleanLine.equals("MATERIALS AND METHODS") ||
               cleanLine.equals("EXPERIMENTAL PROCEDURES") ||
               (cleanLine.matches("^[A-Z\\s]+$") && cleanLine.split("\\s+").length <= 3);
        
        CurationLogger.info("DEBUG: isSectionHeader result for '" + cleanLine + "': " + isHeader);
        return isHeader;
    }
    
    /**
     * Detect subsection titles
     */
    private boolean isSubsectionTitle(String line, int index, String[] lines) {
        if (line.length() < 15 || line.length() > 150) return false;
        
        // Should start with capital letter
        if (!Character.isUpperCase(line.charAt(0))) return false;
        
        // Should not end with sentence punctuation (except period at end)
        if (line.endsWith(",") || line.endsWith(";")) return false;
        
        // Look for scientific subsection patterns
        return line.matches(".*\\b(Crystal structure|structure|domain|function|analysis|assay|experiment|activity|binding|complex|formation)\\b.*") ||
               line.matches(".*\\b(MUN|SNARE|Munc13|syntaxin|NF|sequence|pocket)\\b.*") ||
               (Character.isUpperCase(line.charAt(0)) && !line.endsWith(".") && line.split("\\s+").length > 3);
    }
    
    /**
     * Detect figure/table captions
     */
    private boolean isFigureCaption(String line) {
        return line.matches("^(Figure|Fig\\.|Table|Supplementary)\\s+\\d+.*") ||
               line.matches("^[A-Z]\\s+.*") && line.length() < 200; // Single letter labels
    }
    
    /**
     * Insert figures inline when their references are encountered in text
     */
    private String insertFiguresInText(String text, List<String> imageUrls, Set<Integer> insertedFigures) {
        // Debug logging
        System.out.println("DEBUG: insertFiguresInText called - imageUrls.size(): " + imageUrls.size() + ", text length: " + text.length());
        
        // Pattern to match figure references like [Fig. 1](#page-3-0)A, [Figure 2](#page-4-0)B, etc.
        Pattern figureRefPattern = Pattern.compile("(\\[(Fig\\.|Figure)\\s+(\\d+)\\]\\(#[^)]*\\)[A-Z]?)");
        Matcher matcher = figureRefPattern.matcher(text);
        
        StringBuffer result = new StringBuffer();
        
        while (matcher.find()) {
            String fullMatch = matcher.group(0);
            int figureNum = Integer.parseInt(matcher.group(3));
            
            System.out.println("DEBUG: Found figure reference: " + fullMatch + " (figureNum: " + figureNum + ")");
            
            // Check if we have this figure available and haven't inserted it yet
            if (figureNum <= imageUrls.size() && !insertedFigures.contains(figureNum)) {
                System.out.println("DEBUG: Inserting figure " + figureNum + " at position");
                String imageUrl = imageUrls.get(figureNum - 1); // Convert to 0-based index
                insertedFigures.add(figureNum);
                
                // Insert the figure right after the reference
                String figureHtml = "</p><div class='figure-container'>" +
                                  "<img src='" + imageUrl + "' alt='Figure " + figureNum + "' class='pdf-image'/>" +
                                  "</div><p>";
                                  
                matcher.appendReplacement(result, fullMatch + figureHtml);
            } else {
                // Keep original reference
                matcher.appendReplacement(result, fullMatch);
            }
        }
        matcher.appendTail(result);
        
        return result.toString();
    }
    
    /**
     * Determine if a line should start a new paragraph
     */
    private boolean isNewParagraphStart(String line, int index, String[] lines) {
        // Start new paragraph if:
        // 1. Line starts with capital and previous was empty
        // 2. Line starts certain patterns suggesting new thought
        // 3. Line follows a sentence-ending pattern
        
        if (index == 0) return true;
        
        String prevLine = index > 0 ? lines[index - 1].trim() : "";
        
        // New paragraph if previous line ended a sentence and this starts with capital
        if (prevLine.endsWith(".") && Character.isUpperCase(line.charAt(0))) {
            return true;
        }
        
        // New paragraph for certain starting patterns
        if (line.matches("^(The|This|These|However|Moreover|Furthermore|Additionally|In|For|To|We|Our|Previous|Recent)\\b.*")) {
            return true;
        }
        
        return false;
    }
    
    /**
     * Generate HTML for entity recognition results
     */
    private String generateEntityRecognitionHtml(String uploadId, EntityRecognitionResult result, int textLength) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>")
            .append("<html><head>")
            .append("<title>Entity Recognition - Upload ").append(uploadId).append("</title>")
            .append("<style>")
            .append("body{font-family:Arial,sans-serif;margin:20px;line-height:1.6;}")
            .append(".header{background:#f8f9fa;padding:15px;border-radius:5px;margin-bottom:20px;}")
            .append(".entity{display:inline-block;margin:2px;padding:4px 8px;border-radius:4px;font-weight:bold;}")
            .append(".gene{background:#d4edda;color:#155724;}")
            .append(".disease{background:#f8d7da;color:#721c24;}")
            .append(".chemical{background:#fff3cd;color:#856404;}")
            .append(".species{background:#cce5ff;color:#004085;}")
            .append(".phenotype{background:#e2e3e5;color:#383d41;}")
            .append(".confidence{font-size:0.8em;opacity:0.8;}")
            .append(".stats{background:#e9ecef;padding:10px;border-radius:5px;margin-bottom:15px;}")
            .append(".section{margin-bottom:20px;}")
            .append(".entity-list{margin-left:20px;}")
            .append(".no-entities{color:#6c757d;font-style:italic;}")
            .append("</style>")
            .append("</head><body>");
        
        // Header
        html.append("<div class='header'>")
            .append("<h1>Entity Recognition Results</h1>")
            .append("<p><strong>Upload ID:</strong> ").append(uploadId).append("</p>");
            
        if (result.isSuccessful()) {
            html.append("<p><strong>Processing Time:</strong> ").append(result.getProcessingTimeMs()).append("ms</p>")
                .append("<p><strong>Text Length:</strong> ").append(textLength).append(" characters</p>");
        }
        
        html.append("</div>");
        
        if (!result.isSuccessful()) {
            html.append("<div class='alert alert-danger'>")
                .append("<h3>Error</h3>")
                .append("<p>").append(result.getErrorMessage()).append("</p>")
                .append("</div>");
        } else {
            // Statistics
            html.append("<div class='stats'>")
                .append("<strong>Summary:</strong> ")
                .append("Found ").append(result.getTotalEntities()).append(" entities total - ")
                .append("Genes: ").append(result.getGenes().size()).append(", ")
                .append("Diseases: ").append(result.getDiseases().size()).append(", ")
                .append("Chemicals: ").append(result.getChemicals().size()).append(", ")
                .append("Species: ").append(result.getSpecies().size()).append(", ")
                .append("Phenotypes: ").append(result.getPhenotypes().size()).append(", ")
                .append("Cellular Components: ").append(result.getCellularComponents().size()).append(", ")
                .append("Rat Strains: ").append(result.getRatStrains().size())
                .append("</div>");
            
            // Entity sections
            appendEntitySection(html, "Genes", result.getGenes(), "gene");
            appendEntitySection(html, "Diseases", result.getDiseases(), "disease");
            appendEntitySection(html, "Chemicals", result.getChemicals(), "chemical");
            appendEntitySection(html, "Species", result.getSpecies(), "species");
            appendEntitySection(html, "Phenotypes", result.getPhenotypes(), "phenotype");
            appendEntitySection(html, "Cellular Components", result.getCellularComponents(), "cellular-component");
            appendEntitySection(html, "Rat Strains", result.getRatStrains(), "rat-strain");
        }
        
        html.append("<p><a href='javascript:history.back()'>← Back to Upload</a></p>")
            .append("</body></html>");
        
        return html.toString();
    }
    
    /**
     * Append an entity section to the HTML
     */
    private void appendEntitySection(StringBuilder html, String title, List<BiologicalEntity> entities, String cssClass) {
        CurationLogger.info("DEBUG: appendEntitySection called for " + title + " with " + (entities != null ? entities.size() : "null") + " entities");
        
        if (entities == null) {
            CurationLogger.warn("DEBUG: entities list is null for " + title);
            entities = new ArrayList<>();
        }
        
        html.append("<div class='section'>")
            .append("<h3>").append(title).append(" (").append(entities.size()).append(" found)</h3>");
        
        if (entities.isEmpty()) {
            html.append("<p class='no-entities'>No ").append(title.toLowerCase()).append(" identified</p>");
        } else {
            CurationLogger.info("DEBUG: Generating entity list HTML for " + entities.size() + " " + title);
            html.append("<div class='entity-list'>");
            for (BiologicalEntity entity : entities) {
                CurationLogger.info("DEBUG: Adding entity: " + entity.getName() + " (" + entity.getDescription() + ")");
                html.append("<div class='entity ").append(cssClass).append("'>")
                    .append("<strong>").append(entity.getName()).append("</strong>");
                
                // Add accession ID if available
                if (entity.getAccessionId() != null && !entity.getAccessionId().isEmpty()) {
                    html.append(" <span class='accession-id'>[").append(entity.getAccessionId()).append("]</span>");
                }
                
                if (entity.getDescription() != null && !entity.getDescription().isEmpty()) {
                    html.append(" - ").append(entity.getDescription());
                }
                
                html.append(" <span class='confidence'>(").append(entity.getConfidencePercentage()).append(")</span>")
                    .append("</div>");
            }
            html.append("</div>");
        }
        
        html.append("</div>");
        CurationLogger.info("DEBUG: Finished appendEntitySection for " + title);
    }
    
    /**
     * Generate error HTML page
     */
    private String generateErrorHtml(String errorMessage, String uploadId) {
        return "<!DOCTYPE html>"
            + "<html><head><title>Entity Recognition Error</title>"
            + "<style>body{font-family:Arial,sans-serif;margin:20px;} .error{background:#f8d7da;color:#721c24;padding:15px;border-radius:5px;}</style>"
            + "</head><body>"
            + "<h1>Entity Recognition Error</h1>"
            + "<p><strong>Upload ID:</strong> " + (uploadId != null ? uploadId : "Unknown") + "</p>"
            + "<div class='error'>" + errorMessage + "</div>"
            + "<p><a href='javascript:history.back()'>← Back to Upload</a></p>"
            + "</body></html>";
    }

    /**
     * Validate uploaded file
     */
    private UploadResponse validateFile(String originalFilename, long fileSize, String contentType) {
        UploadResponse response = new UploadResponse();
        
        // Check if file is empty
        if (fileSize == 0) {
            response.setSuccess(false);
            response.setMessage("Please select a file to upload");
            return response;
        }

        // Check file size
        if (fileSize > MAX_FILE_SIZE) {
            response.setSuccess(false);
            response.setMessage("File size exceeds maximum limit of " + (MAX_FILE_SIZE / (1024 * 1024)) + "MB");
            return response;
        }

        // Check content type
        boolean validContentType = false;
        for (String allowedType : ALLOWED_CONTENT_TYPES) {
            if (allowedType.equals(contentType)) {
                validContentType = true;
                break;
            }
        }

        if (!validContentType) {
            response.setSuccess(false);
            response.setMessage("Only PDF files are allowed");
            return response;
        }

        // Check file extension
        if (originalFilename == null || !originalFilename.toLowerCase().endsWith(".pdf")) {
            response.setSuccess(false);
            response.setMessage("File must have .pdf extension");
            return response;
        }

        response.setSuccess(true);
        return response;
    }

    /**
     * Process markdown headers in text and convert to HTML
     */
    private String processMarkdownHeaders(String text) {
        // Split into lines for processing
        String[] lines = text.split("\n");
        StringBuilder result = new StringBuilder();
        
        for (String line : lines) {
            String trimmedLine = line.trim();
            
            // Handle different markdown header levels
            if (trimmedLine.startsWith("###### ")) {
                // Level 6 header
                String headerText = trimmedLine.substring(7);
                result.append("<h6>").append(headerText).append("</h6>");
            } else if (trimmedLine.startsWith("##### ")) {
                // Level 5 header
                String headerText = trimmedLine.substring(6);
                result.append("<h5>").append(headerText).append("</h5>");
            } else if (trimmedLine.startsWith("#### ")) {
                // Level 4 header
                String headerText = trimmedLine.substring(5);
                result.append("<h4>").append(headerText).append("</h4>");
            } else if (trimmedLine.startsWith("### ")) {
                // Level 3 header
                String headerText = trimmedLine.substring(4);
                result.append("<h3>").append(headerText).append("</h3>");
            } else if (trimmedLine.startsWith("## ")) {
                // Level 2 header
                String headerText = trimmedLine.substring(3);
                result.append("<h2>").append(headerText).append("</h2>");
            } else if (trimmedLine.startsWith("# ")) {
                // Level 1 header
                String headerText = trimmedLine.substring(2);
                result.append("<h1>").append(headerText).append("</h1>");
            } else {
                // Check if this line is a standalone section header with bold markdown
                // Enhanced pattern to catch more variations
                if (trimmedLine.matches("^\\*\\*[A-Z][A-Z\\s]+\\*\\*$")) {
                    // This is a section header like "**RESULTS**" or "**EXPERIMENTAL PROCEDURES**"
                    String headerText = trimmedLine.replaceAll("\\*\\*", "").trim();
                    CurationLogger.info("DEBUG: Found section header in processMarkdownHeaders: '" + trimmedLine + "' -> '" + headerText + "'");
                    result.append("<h2 class='section-header'>").append(headerText).append("</h2>");
                } else {
                    // Process markdown formatting (bold and italics) but avoid double-processing section headers
                    String processedLine = processMarkdownFormatting(line);
                    result.append(processedLine);
                }
            }
            result.append("\n");
        }
        
        return result.toString();
    }
    
    /**
     * Process markdown formatting for bold and italics
     */
    private String processMarkdownFormatting(String text) {
        // Skip processing if this line is a section header (all caps with asterisks)
        String trimmed = text.trim();
        if (trimmed.matches("^\\*\\*[A-Z][A-Z\\s]+\\*\\*$")) {
            CurationLogger.info("DEBUG: Skipping markdown formatting for section header: " + trimmed);
            return text; // Return as-is, will be handled by formatDocumentStructure
        }
        
        // Process bold (**text** or __text__)
        text = text.replaceAll("\\*\\*([^\\*]+)\\*\\*", "<strong>$1</strong>");
        text = text.replaceAll("__([^_]+)__", "<strong>$1</strong>");
        
        // Process italics (*text* or _text_)
        // Need to be careful not to match single asterisks that are part of bold
        text = text.replaceAll("(?<!\\*)\\*([^\\*]+)\\*(?!\\*)", "<em>$1</em>");
        text = text.replaceAll("(?<!_)_([^_]+)_(?!_)", "<em>$1</em>");
        
        return text;
    }
    
    /**
     * Escape HTML characters but preserve existing HTML tags
     */
    private String escapeHtmlButPreserveTags(String text) {
        // First escape all HTML characters
        String escaped = text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;");
        
        // Then un-escape our generated HTML tags
        escaped = escaped
            .replace("&lt;h1&gt;", "<h1>")
            .replace("&lt;/h1&gt;", "</h1>")
            .replace("&lt;h2&gt;", "<h2>")
            .replace("&lt;/h2&gt;", "</h2>")
            .replace("&lt;h3&gt;", "<h3>")
            .replace("&lt;/h3&gt;", "</h3>");
        
        // Un-escape section headers with class attributes
        escaped = escaped.replaceAll("&lt;h2 class=&quot;section-header&quot;&gt;", "<h2 class='section-header'>");
        
        // Un-escape superscript and subscript tags for scientific notation
        escaped = escaped
            .replace("&lt;sup&gt;", "<sup>")
            .replace("&lt;/sup&gt;", "</sup>")
            .replace("&lt;sub&gt;", "<sub>")
            .replace("&lt;/sub&gt;", "</sub>");
        
        // Un-escape emphasis and strong tags for markdown formatting
        escaped = escaped
            .replace("&lt;em&gt;", "<em>")
            .replace("&lt;/em&gt;", "</em>")
            .replace("&lt;strong&gt;", "<strong>")
            .replace("&lt;/strong&gt;", "</strong>");
        
        // Un-escape Marker page span tags (but we'll actually remove them instead)
        // Remove page span markers entirely as they're not needed for display
        escaped = escaped.replaceAll("&lt;span id=&quot;page-\\d+-\\d+&quot;&gt;&lt;/span&gt;", "");
        
        return escaped;
    }
    
    /**
     * Final cleanup pass to remove any remaining **CAPS** patterns that represent section headers
     */
    private String cleanupRemainingAsterisks(String text) {
        // Target patterns like **RESULTS**, **EXPERIMENTAL PROCEDURES**, etc. that may have been missed
        // This is a final safety net to ensure these patterns are cleaned up
        CurationLogger.info("DEBUG: cleanupRemainingAsterisks - before cleanup length: " + text.length());
        
        // Replace standalone lines with **CAPS** patterns
        String result = text.replaceAll("(?m)^\\s*\\*\\*([A-Z][A-Z\\s]+)\\*\\*\\s*$", "<h2 class='section-header'>$1</h2>");
        
        // Also handle cases where they might be in the middle of other text
        result = result.replaceAll("\\*\\*([A-Z]{2,}(?:\\s+[A-Z]+)*)\\*\\*", "<strong>$1</strong>");
        
        CurationLogger.info("DEBUG: cleanupRemainingAsterisks - after cleanup length: " + result.length());
        return result;
    }

}