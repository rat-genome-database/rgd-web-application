package edu.mcw.rgd.entityTagger.controller;

import edu.mcw.rgd.entityTagger.dto.*;
import edu.mcw.rgd.entityTagger.service.*;
import edu.mcw.rgd.entityTagger.model.*;
import edu.mcw.rgd.entityTagger.exception.PdfProcessingException;
import edu.mcw.rgd.entityTagger.util.CurationLogger;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;

/**
 * REST Controller for entity recognition and ontology matching services.
 * Provides endpoints for text analysis, entity extraction, and ontology integration.
 */
@RestController
@RequestMapping("/api/curation/entity-recognition")
@CrossOrigin(origins = "*", maxAge = 3600)
@Tag(name = "Entity Recognition", description = "AI-powered biological entity recognition and ontology matching")
public class EntityRecognitionController {

    @Autowired
    private ResilientOllamaService resilientOllamaService;

    @Autowired
    private OntologyService ontologyService;

    @Autowired
    private OntologyMatchingService matchingService;

    @Autowired
    private OntologyUpdateService updateService;

    @Autowired
    private OntologyCacheService cacheService;

    @Autowired
    private BatchProcessingService batchProcessingService;
    
    @Autowired
    private EntityRecognitionService entityRecognitionService;
    
    @Autowired
    private SessionService sessionService;

    /**
     * Recognize entities in text using AI and match to ontologies
     * 
     * @param request Entity recognition request
     * @return Entity recognition response with matched ontology terms
     */
    @Operation(
        summary = "Recognize biological entities in text",
        description = """
                Analyzes the provided text using AI to identify and extract biological entities such as genes, 
                diseases, proteins, and other biomedical terms. Optionally matches identified entities to 
                standardized ontology terms from RDO and GO.
                
                **Features:**
                - AI-powered entity recognition using advanced language models
                - Confidence scoring for each identified entity
                - Position tracking for extracted entities
                - Optional ontology matching with RDO and GO
                - Context preservation around identified entities
                
                **Supported Entity Types:**
                - gene, protein, disease, phenotype, pathway, drug, chemical
                - organism, tissue, cell_type, anatomy, strain, allele
                - biological_process, molecular_function, cellular_component
                """,
        tags = {"Entity Recognition"}
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200", 
            description = "Entities successfully recognized",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = EntityRecognitionApiResponse.class),
                examples = @ExampleObject(
                    name = "Successful Recognition",
                    value = """
                        {
                          "success": true,
                          "sessionId": "session_123",
                          "timestamp": "2024-01-15T10:30:00",
                          "processingTimeMs": 1500,
                          "entityCount": 3,
                          "entities": [
                            {
                              "entityName": "diabetes mellitus",
                              "entityType": "disease",
                              "confidenceScore": 0.95,
                              "startPosition": 45,
                              "endPosition": 60,
                              "context": "...patients with diabetes mellitus showed...",
                              "ontologyMatches": [
                                {
                                  "termId": "DOID:9351",
                                  "termName": "diabetes mellitus",
                                  "namespace": "disease_ontology",
                                  "matchType": "EXACT",
                                  "confidence": 1.0
                                }
                              ]
                            }
                          ],
                          "summary": {
                            "totalEntities": 3,
                            "averageConfidence": 0.87,
                            "ontologyMatchCount": 2
                          }
                        }
                        """
                )
            )
        ),
        @ApiResponse(
            responseCode = "400", 
            description = "Invalid request parameters",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(
                    name = "Validation Error",
                    value = """
                        {
                          "success": false,
                          "errorMessage": "Text cannot be empty or contain only whitespace",
                          "timestamp": "2024-01-15T10:30:00"
                        }
                        """
                )
            )
        ),
        @ApiResponse(
            responseCode = "500", 
            description = "Internal server error",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(
                    name = "Server Error",
                    value = """
                        {
                          "success": false,
                          "errorMessage": "Entity recognition failed: AI service unavailable",
                          "timestamp": "2024-01-15T10:30:00"
                        }
                        """
                )
            )
        )
    })
    @PostMapping("/recognize")
    public ResponseEntity<EntityRecognitionApiResponse> recognizeEntities(
            @Parameter(description = "Entity recognition request with text and processing options", required = true)
            @Valid @RequestBody EntityRecognitionApiRequest request) {
        
        CurationLogger.entering(EntityRecognitionController.class, "recognizeEntities", 
                "sessionId=" + request.getSessionId());

        try {
            // Validate request
            if (request.getText() == null || request.getText().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(EntityRecognitionApiResponse.error("Text cannot be empty"));
            }

            // Create internal request
            EntityRecognitionRequest internalRequest = new EntityRecognitionRequest();
            internalRequest.setText(request.getText());
            internalRequest.setEntityTypes(request.getEntityTypes());
            internalRequest.setDomain(request.getDomain());
            internalRequest.setConfidenceThreshold(request.getConfidenceThreshold());
            internalRequest.setSessionId(request.getSessionId());

            // Perform entity recognition with AI
            CompletableFuture<EntityRecognitionResponse> aiResponseFuture = 
                    resilientOllamaService.recognizeEntitiesComprehensive(internalRequest);
            
            EntityRecognitionResponse aiResponse = aiResponseFuture.get();

            // Match entities to ontology terms if requested
            EntityRecognitionApiResponse apiResponse = new EntityRecognitionApiResponse();
            apiResponse.setSuccess(aiResponse.isSuccess());
            apiResponse.setSessionId(aiResponse.getRequestId());
            apiResponse.setProcessingTimeMs(aiResponse.getProcessingTimeMs());
            apiResponse.setTimestamp(LocalDateTime.now());

            if (aiResponse.isSuccess() && aiResponse.getEntities() != null) {
                List<RecognizedEntityDto> enrichedEntities = new ArrayList<>();

                for (EntityRecognitionResponse.RecognizedEntity entity : aiResponse.getEntities()) {
                    RecognizedEntityDto dto = convertToDto(entity);
                    
                    // Add ontology matching if enabled
                    if (request.isEnableOntologyMatching() && ontologyService.isLoaded()) {
                        try {
                            addOntologyMatches(dto, entity, request);
                        } catch (Exception e) {
                            CurationLogger.warn("Failed to add ontology matches for entity '{}': {}", 
                                    entity.getEntityName(), e.getMessage());
                        }
                    }
                    
                    enrichedEntities.add(dto);
                }

                apiResponse.setEntities(enrichedEntities);
                apiResponse.setEntityCount(enrichedEntities.size());
            } else {
                apiResponse.setEntities(new ArrayList<>());
                apiResponse.setEntityCount(0);
            }

            // Add summary statistics
            if (aiResponse.getStatistics() != null) {
                EntitySummaryDto summary = new EntitySummaryDto();
                summary.setTotalEntities(apiResponse.getEntityCount());
                summary.setProcessedTextLength(request.getText().length());
                summary.setAverageConfidence(calculateAverageConfidence(apiResponse.getEntities()));
                summary.setEntityTypeCounts(calculateEntityTypeCounts(apiResponse.getEntities()));
                summary.setOntologyMatchCount(calculateOntologyMatchCount(apiResponse.getEntities()));
                apiResponse.setSummary(summary);
            }

            // Add any warnings or messages
            if (aiResponse.getWarnings() != null && !aiResponse.getWarnings().isEmpty()) {
                apiResponse.setWarnings(aiResponse.getWarnings());
            }

            CurationLogger.info("Entity recognition completed: {} entities found for session {}", 
                    apiResponse.getEntityCount(), request.getSessionId());

            return ResponseEntity.ok(apiResponse);

        } catch (Exception e) {
            CurationLogger.error("Entity recognition failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(EntityRecognitionApiResponse.error("Entity recognition failed: " + e.getMessage()));
        }
    }

    /**
     * Process multiple texts in batch (synchronous with parallel processing)
     * 
     * @param request Batch processing request
     * @return Batch processing response
     */
    @Operation(
        summary = "Process multiple texts in batch (synchronous)",
        description = """
                Processes multiple texts simultaneously using parallel processing for improved performance. 
                This endpoint blocks until all texts are processed and returns complete results.
                
                **Features:**
                - Parallel processing with configurable thread pools
                - Maintains original text order in results
                - Comprehensive batch statistics
                - Timeout protection with configurable limits
                - Memory-efficient chunked processing
                
                **Use Cases:**
                - Processing 2-100 texts simultaneously
                - When immediate results are needed
                - Real-time batch analysis workflows
                
                **Limits:**
                - Maximum 100 texts per batch
                - 30-minute timeout per batch
                - Maximum 100KB per individual text
                """,
        tags = {"Batch Processing"}
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Batch processing completed successfully",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = BatchEntityRecognitionResponse.class),
                examples = @ExampleObject(
                    name = "Successful Batch",
                    value = """
                        {
                          "success": true,
                          "sessionId": "batch_123",
                          "timestamp": "2024-01-15T10:30:00",
                          "processingTimeMs": 15000,
                          "processedCount": 10,
                          "successfulCount": 9,
                          "failedCount": 1,
                          "results": [
                            {
                              "success": true,
                              "entities": [
                                {
                                  "entityName": "hypertension",
                                  "entityType": "disease",
                                  "confidenceScore": 0.92
                                }
                              ]
                            }
                          ],
                          "batchSummary": {
                            "totalEntitiesFound": 47,
                            "totalOntologyMatches": 31,
                            "averageConfidenceAcrossBatch": 0.84,
                            "mostCommonEntityType": "disease"
                          }
                        }
                        """
                )
            )
        ),
        @ApiResponse(responseCode = "400", description = "Invalid batch request"),
        @ApiResponse(responseCode = "500", description = "Batch processing failed")
    })
    @PostMapping("/batch")
    public ResponseEntity<BatchEntityRecognitionResponse> batchRecognizeEntities(
            @Parameter(description = "Batch processing request with multiple texts", required = true)
            @Valid @RequestBody BatchEntityRecognitionRequest request) {
        
        CurationLogger.entering(EntityRecognitionController.class, "batchRecognizeEntities", 
                "texts=" + (request.getTexts() != null ? request.getTexts().size() : 0));

        try {
            // Use enhanced batch processing service
            BatchProcessingService.SyncBatchResult syncResult = batchProcessingService.processTextsSync(request);
            
            if (!syncResult.isSuccess()) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(BatchEntityRecognitionResponse.error(syncResult.getErrorMessage()));
            }

            // Convert to API response
            BatchEntityRecognitionResponse response = new BatchEntityRecognitionResponse();
            response.setSuccess(true);
            response.setSessionId(request.getSessionId());
            response.setTimestamp(LocalDateTime.now());
            response.setResults(syncResult.getResults());
            response.setProcessingTimeMs(syncResult.getProcessingTimeMs());

            // Create batch summary from statistics
            if (syncResult.getStatistics() != null) {
                BatchEntityRecognitionResponse.BatchSummaryDto summary = createBatchSummary(syncResult.getStatistics());
                response.setBatchSummary(summary);
            }

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            CurationLogger.error("Batch entity recognition failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(BatchEntityRecognitionResponse.error("Batch processing failed: " + e.getMessage()));
        }
    }

    /**
     * Start asynchronous batch processing for large datasets
     * 
     * @param request Batch processing request
     * @return Batch processing result with batch ID for tracking
     */
    @Operation(
        summary = "Start asynchronous batch processing",
        description = """
                Initiates asynchronous processing of large text datasets. Returns immediately with a batch ID 
                that can be used to monitor progress and retrieve results when processing is complete.
                
                **Features:**
                - Non-blocking operation for large datasets
                - Progress tracking with detailed status updates
                - Cancellation support for running batches
                - Automatic cleanup of completed batches
                - Error recovery and partial result handling
                
                **Use Cases:**
                - Processing 100+ texts
                - Long-running analysis workflows
                - Background processing jobs
                - Large document collections
                
                **Workflow:**
                1. Submit batch → Get batch ID
                2. Poll `/batch/status/{batchId}` for progress
                3. Retrieve results when status = "COMPLETED"
                4. Optional: Cancel with `/batch/cancel/{batchId}`
                """,
        tags = {"Batch Processing"}
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "202",
            description = "Batch processing started successfully",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(
                    name = "Batch Started",
                    value = """
                        {
                          "success": true,
                          "batchId": "batch_456789",
                          "totalItems": 150,
                          "startTime": "2024-01-15T10:30:00",
                          "message": "Batch processing started successfully",
                          "statusUrl": "/api/curation/entity-recognition/batch/status/batch_456789"
                        }
                        """
                )
            )
        ),
        @ApiResponse(responseCode = "400", description = "Invalid batch request"),
        @ApiResponse(responseCode = "500", description = "Failed to start batch processing")
    })
    @PostMapping("/batch/async")
    public ResponseEntity<Map<String, Object>> batchRecognizeEntitiesAsync(
            @Parameter(description = "Batch processing request for asynchronous processing", required = true)
            @Valid @RequestBody BatchEntityRecognitionRequest request) {
        
        CurationLogger.entering(EntityRecognitionController.class, "batchRecognizeEntitiesAsync", 
                "texts=" + (request.getTexts() != null ? request.getTexts().size() : 0));

        try {
            BatchProcessingService.BatchProcessingResult result = 
                    batchProcessingService.processTextsAsync(request);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("batchId", result.getBatchId());
            response.put("totalItems", result.getTotalItems());
            response.put("startTime", result.getStartTime());
            response.put("message", "Batch processing started successfully");
            response.put("statusUrl", "/api/curation/entity-recognition/batch/status/" + result.getBatchId());

            CurationLogger.info("Async batch processing started with ID: {}", result.getBatchId());
            return ResponseEntity.accepted().body(response);

        } catch (Exception e) {
            CurationLogger.error("Failed to start async batch processing", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to start batch processing: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Get status of an asynchronous batch processing operation
     * 
     * @param batchId Batch processing ID
     * @return Batch processing status
     */
    @Operation(
        summary = "Get batch processing status",
        description = """
                Retrieves the current status and progress of an asynchronous batch processing operation.
                
                **Status Values:**
                - `PROCESSING`: Batch is currently being processed
                - `COMPLETED`: All items processed successfully
                - `FAILED`: Batch processing failed
                - `CANCELLED`: Batch was cancelled by user
                
                **Progress Information:**
                - Total items in batch
                - Items processed so far
                - Successful vs failed items
                - Estimated completion time
                - Detailed error information
                
                **Polling Guidelines:**
                - Poll every 5-30 seconds depending on batch size
                - Exponential backoff recommended for large batches
                - Stop polling when status is COMPLETED, FAILED, or CANCELLED
                """,
        tags = {"Batch Processing"}
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Status retrieved successfully",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = BatchProcessingService.BatchProcessingStatus.class),
                examples = @ExampleObject(
                    name = "Processing Status",
                    value = """
                        {
                          "batchId": "batch_456789",
                          "status": "PROCESSING",
                          "totalItems": 150,
                          "processedItems": 75,
                          "successfulItems": 73,
                          "startTime": "2024-01-15T10:30:00",
                          "progressPercentage": 50.0
                        }
                        """
                )
            )
        ),
        @ApiResponse(responseCode = "404", description = "Batch ID not found"),
        @ApiResponse(responseCode = "500", description = "Error retrieving batch status")
    })
    @GetMapping("/batch/status/{batchId}")
    public ResponseEntity<BatchProcessingService.BatchProcessingStatus> getBatchStatus(
            @Parameter(description = "Unique batch processing identifier", required = true, example = "batch_456789")
            @PathVariable String batchId) {
        
        CurationLogger.entering(EntityRecognitionController.class, "getBatchStatus", 
                "batchId=" + batchId);

        try {
            BatchProcessingService.BatchProcessingStatus status = 
                    batchProcessingService.getBatchStatus(batchId);

            if (status == null) {
                return ResponseEntity.notFound().build();
            }

            return ResponseEntity.ok(status);

        } catch (Exception e) {
            CurationLogger.error("Failed to get batch status for ID: " + batchId, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Cancel a running batch processing operation
     * 
     * @param batchId Batch processing ID
     * @return Cancellation result
     */
    @PostMapping("/batch/cancel/{batchId}")
    public ResponseEntity<Map<String, Object>> cancelBatchProcessing(
            @PathVariable String batchId) {
        
        CurationLogger.entering(EntityRecognitionController.class, "cancelBatchProcessing", 
                "batchId=" + batchId);

        try {
            boolean cancelled = batchProcessingService.cancelBatch(batchId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", cancelled);
            response.put("batchId", batchId);
            response.put("message", cancelled ? "Batch processing cancelled" : "Batch not found or already completed");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            CurationLogger.error("Failed to cancel batch processing for ID: " + batchId, e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to cancel batch: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Get ontology matching results for specific entities
     * 
     * @param request Ontology matching request
     * @return Ontology matching response
     */
    @PostMapping("/match-ontology")
    public ResponseEntity<OntologyMatchingResponse> matchOntology(
            @Valid @RequestBody OntologyMatchingRequest request) {
        
        CurationLogger.entering(EntityRecognitionController.class, "matchOntology", 
                "entities=" + (request.getEntityNames() != null ? request.getEntityNames().size() : 0));

        try {
            if (!ontologyService.isLoaded()) {
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body(OntologyMatchingResponse.error("Ontology data is not loaded"));
            }

            if (request.getEntityNames() == null || request.getEntityNames().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(OntologyMatchingResponse.error("No entity names provided"));
            }

            OntologyMatchingResponse response = new OntologyMatchingResponse();
            response.setSessionId(request.getSessionId());
            response.setTimestamp(LocalDateTime.now());

            long startTime = System.currentTimeMillis();

            // Configure matching options
            OntologyMatchingService.MatchingOptions options = new OntologyMatchingService.MatchingOptions();
            if (request.getFuzzyThreshold() != null) {
                options.fuzzyThreshold = request.getFuzzyThreshold();
            }
            if (request.getMaxResults() != null) {
                options.maxResults = request.getMaxResults();
            }
            if (request.getMinimumConfidence() != null) {
                options.minimumConfidence = request.getMinimumConfidence();
            }

            // Enable/disable matching types based on request
            options.enableExactMatch = request.isEnableExactMatch();
            options.enableFuzzyMatch = request.isEnableFuzzyMatch();
            options.enableSynonymMatch = request.isEnableSynonymMatch();
            options.enablePartialMatch = request.isEnablePartialMatch();

            // Perform batch matching
            Map<String, List<OntologyMatchingService.MatchResult>> matchResults = 
                    matchingService.batchMatchEntities(request.getEntityNames(), 
                            request.getNamespace(), options);

            // Convert to DTOs
            Map<String, List<OntologyMatchDto>> dtoResults = new HashMap<>();
            int totalMatches = 0;

            for (Map.Entry<String, List<OntologyMatchingService.MatchResult>> entry : matchResults.entrySet()) {
                String entityName = entry.getKey();
                List<OntologyMatchDto> matches = new ArrayList<>();

                for (OntologyMatchingService.MatchResult matchResult : entry.getValue()) {
                    OntologyMatchDto dto = new OntologyMatchDto();
                    dto.setTermId(matchResult.getTerm().getTermId());
                    dto.setTermName(matchResult.getTerm().getName());
                    dto.setNamespace(matchResult.getTerm().getNamespace());
                    dto.setDefinition(matchResult.getTerm().getDefinition());
                    dto.setMatchType(matchResult.getMatchType());
                    dto.setConfidence(matchResult.getConfidence());
                    dto.setExplanation(matchResult.getExplanation());
                    dto.setSynonyms(matchResult.getTerm().getSynonyms() != null ? 
                            new ArrayList<>(matchResult.getTerm().getSynonyms()) : null);
                    dto.setObsolete(matchResult.getTerm().isObsolete());

                    matches.add(dto);
                    totalMatches++;
                }

                dtoResults.put(entityName, matches);
            }

            response.setMatches(dtoResults);
            response.setTotalMatches(totalMatches);
            response.setProcessingTimeMs(System.currentTimeMillis() - startTime);
            response.setSuccess(true);

            CurationLogger.info("Ontology matching completed: {} total matches for {} entities", 
                    totalMatches, request.getEntityNames().size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            CurationLogger.error("Ontology matching failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(OntologyMatchingResponse.error("Ontology matching failed: " + e.getMessage()));
        }
    }

    /**
     * Get service status and health information
     * 
     * @return Service status response
     */
    @Operation(
        summary = "Get service health status",
        description = """
                Provides comprehensive health and status information for all service components.
                
                **Health Checks:**
                - AI Service (Ollama) connectivity and model availability
                - Ontology data loading status and term counts
                - Cache performance metrics and hit rates
                - Update service status and last check times
                - Overall system health assessment
                
                **Use Cases:**
                - Service monitoring and alerting
                - Debugging connectivity issues
                - Performance monitoring
                - System health dashboards
                
                **Response Codes:**
                - 200: All services healthy
                - 206: Partial functionality (some services degraded)
                - 503: Critical services unavailable
                """,
        tags = {"System Administration"}
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Service status retrieved successfully",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = ServiceStatusResponse.class),
                examples = @ExampleObject(
                    name = "Healthy Status",
                    value = """
                        {
                          "success": true,
                          "timestamp": "2024-01-15T10:30:00",
                          "overallHealthy": true,
                          "aiServiceHealthy": true,
                          "aiServiceStatus": "Connected to Ollama at grudge.rgd.mcw.edu:11434",
                          "ontologyLoaded": true,
                          "ontologyTermCount": 45362,
                          "ontologyNamespaces": ["disease_ontology", "gene_ontology"],
                          "cacheEnabled": true,
                          "cacheHitRate": 0.87,
                          "updateInProgress": false,
                          "lastUpdateCheck": "2024-01-15T08:00:00"
                        }
                        """
                )
            )
        ),
        @ApiResponse(responseCode = "503", description = "Service unavailable")
    })
    @GetMapping("/status")
    public ResponseEntity<ServiceStatusResponse> getStatus() {
        CurationLogger.entering(EntityRecognitionController.class, "getStatus");

        try {
            ServiceStatusResponse response = new ServiceStatusResponse();
            response.setTimestamp(LocalDateTime.now());

            // AI Service Status
            ResilientOllamaService.ServiceInfo aiServiceInfo = resilientOllamaService.getServiceInfo();
            response.setAiServiceHealthy(aiServiceInfo.isHealthy());
            response.setAiServiceStatus(aiServiceInfo.toString());

            // Ontology Service Status
            response.setOntologyLoaded(ontologyService.isLoaded());
            if (ontologyService.isLoaded()) {
                OntologyService.OntologyStatistics stats = ontologyService.getStatistics();
                response.setOntologyTermCount(stats.getTotalTerms());
                response.setOntologyNamespaces(new ArrayList<>(stats.getNamespaceStats().keySet()));
            }

            // Update Service Status
            OntologyUpdateService.UpdateServiceStatus updateStatus = updateService.getStatus();
            response.setUpdateInProgress(updateStatus.isUpdateInProgress());
            response.setLastUpdateCheck(updateStatus.getLastUpdateCheck());

            // Cache Status
            response.setCacheEnabled(cacheService.isCacheEnabled());
            if (cacheService.isCacheEnabled()) {
                response.setCacheHitRate(cacheService.getCacheHitRate());
            }

            response.setOverallHealthy(aiServiceInfo.isHealthy() && ontologyService.isLoaded());
            response.setSuccess(true);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            CurationLogger.error("Failed to get service status", e);
            ServiceStatusResponse response = ServiceStatusResponse.error("Failed to get status: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * Trigger ontology update from remote sources
     * 
     * @return Update response
     */
    @PostMapping("/admin/update-ontology")
    public ResponseEntity<OntologyUpdateResponse> updateOntology() {
        CurationLogger.entering(EntityRecognitionController.class, "updateOntology");

        try {
            CompletableFuture<OntologyUpdateService.UpdateResult> updateFuture = updateService.updateFromRemote();
            OntologyUpdateService.UpdateResult result = updateFuture.get();

            OntologyUpdateResponse response = new OntologyUpdateResponse();
            response.setSuccess(result.isSuccess());
            response.setTimestamp(LocalDateTime.now());
            response.setTotalTermsLoaded(result.getTotalTermsLoaded());
            response.setOntologiesUpdated(result.getLoadResults().keySet());
            response.setErrors(result.getErrors());

            if (result.isSuccess()) {
                CurationLogger.info("Ontology update completed successfully: {} terms loaded", 
                        result.getTotalTermsLoaded());
                return ResponseEntity.ok(response);
            } else {
                CurationLogger.warn("Ontology update completed with errors: {}", result.getErrors());
                return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT).body(response);
            }

        } catch (Exception e) {
            CurationLogger.error("Ontology update failed", e);
            OntologyUpdateResponse response = OntologyUpdateResponse.error("Update failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * Clear all caches
     * 
     * @return Cache operation response
     */
    @PostMapping("/admin/clear-cache")
    public ResponseEntity<CacheOperationResponse> clearCache() {
        CurationLogger.entering(EntityRecognitionController.class, "clearCache");

        try {
            if (!cacheService.isCacheEnabled()) {
                return ResponseEntity.badRequest()
                        .body(CacheOperationResponse.error("Cache is not enabled"));
            }

            cacheService.clearAllCaches();

            CacheOperationResponse response = new CacheOperationResponse();
            response.setSuccess(true);
            response.setTimestamp(LocalDateTime.now());
            response.setOperation("clear_all");
            response.setMessage("All caches cleared successfully");

            CurationLogger.info("All caches cleared via admin endpoint");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            CurationLogger.error("Failed to clear cache", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(CacheOperationResponse.error("Failed to clear cache: " + e.getMessage()));
        }
    }

    // Private helper methods

    private RecognizedEntityDto convertToDto(EntityRecognitionResponse.RecognizedEntity entity) {
        RecognizedEntityDto dto = new RecognizedEntityDto();
        dto.setEntityName(entity.getEntityName());
        dto.setEntityType(entity.getEntityType());
        dto.setConfidenceScore(entity.getConfidenceScore());
        dto.setStartPosition(entity.getStartPosition());
        dto.setEndPosition(entity.getEndPosition());
        dto.setContext(entity.getContext());
        dto.setNormalizedName(entity.getNormalizedName());
        dto.setSynonyms(entity.getSynonyms());
        return dto;
    }

    private void addOntologyMatches(RecognizedEntityDto dto, 
                                  EntityRecognitionResponse.RecognizedEntity entity,
                                  EntityRecognitionApiRequest request) throws PdfProcessingException {
        
        OntologyMatchingService.MatchingOptions options = new OntologyMatchingService.MatchingOptions();
        options.maxResults = 3; // Limit to top 3 matches for each entity
        options.minimumConfidence = request.getConfidenceThreshold() != null ? 
                request.getConfidenceThreshold() : 0.5;

        List<OntologyMatchingService.MatchResult> matches = matchingService.matchEntity(
                entity.getEntityName(), null, options);

        if (!matches.isEmpty()) {
            List<OntologyMatchDto> matchDtos = new ArrayList<>();
            for (OntologyMatchingService.MatchResult match : matches) {
                OntologyMatchDto matchDto = new OntologyMatchDto();
                matchDto.setTermId(match.getTerm().getTermId());
                matchDto.setTermName(match.getTerm().getName());
                matchDto.setNamespace(match.getTerm().getNamespace());
                matchDto.setDefinition(match.getTerm().getDefinition());
                matchDto.setMatchType(match.getMatchType());
                matchDto.setConfidence(match.getConfidence());
                matchDto.setExplanation(match.getExplanation());
                matchDto.setObsolete(match.getTerm().isObsolete());
                matchDtos.add(matchDto);
            }
            dto.setOntologyMatches(matchDtos);
        }
    }

    private double calculateAverageConfidence(List<RecognizedEntityDto> entities) {
        if (entities == null || entities.isEmpty()) {
            return 0.0;
        }
        return entities.stream()
                .mapToDouble(RecognizedEntityDto::getConfidenceScore)
                .average()
                .orElse(0.0);
    }

    private Map<String, Integer> calculateEntityTypeCounts(List<RecognizedEntityDto> entities) {
        Map<String, Integer> counts = new HashMap<>();
        if (entities != null) {
            for (RecognizedEntityDto entity : entities) {
                counts.merge(entity.getEntityType(), 1, Integer::sum);
            }
        }
        return counts;
    }

    private int calculateOntologyMatchCount(List<RecognizedEntityDto> entities) {
        if (entities == null) {
            return 0;
        }
        return entities.stream()
                .mapToInt(entity -> entity.getOntologyMatches() != null ? entity.getOntologyMatches().size() : 0)
                .sum();
    }

    private BatchEntityRecognitionResponse.BatchSummaryDto createBatchSummary(BatchStatistics stats) {
        BatchEntityRecognitionResponse.BatchSummaryDto summary = new BatchEntityRecognitionResponse.BatchSummaryDto();
        
        summary.setTotalEntitiesFound(stats.getTotalEntitiesFound());
        summary.setTotalOntologyMatches(stats.getTotalOntologyMatches());
        summary.setAverageConfidenceAcrossBatch(stats.getAverageConfidence());
        
        // Find most common entity type
        if (stats.getEntityTypeCounts() != null && !stats.getEntityTypeCounts().isEmpty()) {
            String mostCommonType = stats.getEntityTypeCounts().entrySet().stream()
                    .max(Map.Entry.comparingByValue())
                    .map(Map.Entry::getKey)
                    .orElse(null);
            summary.setMostCommonEntityType(mostCommonType);
        }
        
        // Calculate unique terms (approximation - count of distinct entity type keys)
        if (stats.getEntityTypeCounts() != null) {
            summary.setUniqueTermsFound(stats.getEntityTypeCounts().size());
        }
        
        return summary;
    }
}