package edu.mcw.rgd.curation.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.mcw.rgd.curation.dto.*;
import edu.mcw.rgd.curation.service.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Comprehensive unit tests for EntityRecognitionController.
 * Tests all endpoints with various scenarios including success, validation errors, and service failures.
 */
@ExtendWith(MockitoExtension.class)
class EntityRecognitionControllerTest {

    @Mock
    private ResilientOllamaService resilientOllamaService;

    @Mock
    private OntologyService ontologyService;

    @Mock
    private OntologyMatchingService matchingService;

    @Mock
    private OntologyUpdateService updateService;

    @Mock
    private OntologyCacheService cacheService;

    @Mock
    private BatchProcessingService batchProcessingService;

    @InjectMocks
    private EntityRecognitionController controller;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneController(controller).build();
        objectMapper = new ObjectMapper();
    }

    // ================================
    // Entity Recognition Tests
    // ================================

    @Test
    void testRecognizeEntities_Success() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        EntityRecognitionResponse mockAiResponse = createMockAiResponse();
        
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenReturn(CompletableFuture.completedFuture(mockAiResponse));
        when(ontologyService.isLoaded()).thenReturn(true);
        when(matchingService.matchEntity(anyString(), isNull(), any()))
                .thenReturn(createMockOntologyMatches());

        // Act & Assert
        mockMvc.perform(post("/recognize")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.entityCount").value(2))
                .andExpect(jsonPath("$.entities[0].entityName").value("diabetes mellitus"))
                .andExpect(jsonPath("$.entities[0].entityType").value("disease"))
                .andExpect(jsonPath("$.entities[0].confidenceScore").value(0.95))
                .andExpect(jsonPath("$.entities[1].entityName").value("metformin"))
                .andExpect(jsonPath("$.entities[1].entityType").value("drug"));

        verify(resilientOllamaService).recognizeEntitiesComprehensive(any());
        verify(ontologyService).isLoaded();
    }

    @Test
    void testRecognizeEntities_ValidationError_EmptyText() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("");
        request.setSessionId("test");

        // Act & Assert
        mockMvc.perform(post("/recognize")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        verify(resilientOllamaService, never()).recognizeEntitiesComprehensive(any());
    }

    @Test
    void testRecognizeEntities_ValidationError_InvalidConfidenceThreshold() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        request.setConfidenceThreshold(1.5); // Invalid - should be <= 1.0

        // Act & Assert
        mockMvc.perform(post("/recognize")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        verify(resilientOllamaService, never()).recognizeEntitiesComprehensive(any());
    }

    @Test
    void testRecognizeEntities_ServiceFailure() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenThrow(new RuntimeException("AI service unavailable"));

        // Act & Assert
        mockMvc.perform(post("/recognize")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorMessage").value(containsString("AI service unavailable")));

        verify(resilientOllamaService).recognizeEntitiesComprehensive(any());
    }

    @Test
    void testRecognizeEntities_WithoutOntologyMatching() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        request.setEnableOntologyMatching(false);
        EntityRecognitionResponse mockAiResponse = createMockAiResponse();
        
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenReturn(CompletableFuture.completedFuture(mockAiResponse));

        // Act & Assert
        mockMvc.perform(post("/recognize")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.entities[0].ontologyMatches").doesNotExist());

        verify(ontologyService, never()).isLoaded();
        verify(matchingService, never()).matchEntity(anyString(), anyString(), any());
    }

    // ================================
    // Batch Processing Tests
    // ================================

    @Test
    void testBatchRecognizeEntities_Success() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createValidBatchRequest();
        BatchProcessingService.SyncBatchResult mockResult = createMockSyncBatchResult();
        
        when(batchProcessingService.processTextsSync(any())).thenReturn(mockResult);

        // Act & Assert
        mockMvc.perform(post("/batch")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.processedCount").value(2))
                .andExpect(jsonPath("$.successfulCount").value(2));

        verify(batchProcessingService).processTextsSync(any());
    }

    @Test
    void testBatchRecognizeEntities_EmptyTexts() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(new ArrayList<>());
        request.setSessionId("test");

        // Act & Assert
        mockMvc.perform(post("/batch")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        verify(batchProcessingService, never()).processTextsSync(any());
    }

    @Test
    void testBatchRecognizeEntities_ServiceFailure() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createValidBatchRequest();
        BatchProcessingService.SyncBatchResult failedResult = new BatchProcessingService.SyncBatchResult();
        failedResult.setSuccess(false);
        failedResult.setErrorMessage("Batch processing failed");
        
        when(batchProcessingService.processTextsSync(any())).thenReturn(failedResult);

        // Act & Assert
        mockMvc.perform(post("/batch")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false));

        verify(batchProcessingService).processTextsSync(any());
    }

    // ================================
    // Async Batch Processing Tests
    // ================================

    @Test
    void testBatchRecognizeEntitiesAsync_Success() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createValidBatchRequest();
        BatchProcessingService.BatchProcessingResult mockResult = createMockBatchProcessingResult();
        
        when(batchProcessingService.processTextsAsync(any())).thenReturn(mockResult);

        // Act & Assert
        mockMvc.perform(post("/batch/async")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").value("batch_123"))
                .andExpect(jsonPath("$.totalItems").value(10))
                .andExpect(jsonPath("$.statusUrl").value(containsString("/batch/status/batch_123")));

        verify(batchProcessingService).processTextsAsync(any());
    }

    @Test
    void testGetBatchStatus_Success() throws Exception {
        // Arrange
        String batchId = "batch_123";
        BatchProcessingService.BatchProcessingStatus status = createMockBatchStatus();
        
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(status);

        // Act & Assert
        mockMvc.perform(get("/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.status").value("PROCESSING"))
                .andExpect(jsonPath("$.progressPercentage").value(50.0));

        verify(batchProcessingService).getBatchStatus(batchId);
    }

    @Test
    void testGetBatchStatus_NotFound() throws Exception {
        // Arrange
        String batchId = "nonexistent_batch";
        
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(null);

        // Act & Assert
        mockMvc.perform(get("/batch/status/{batchId}", batchId))
                .andExpect(status().isNotFound());

        verify(batchProcessingService).getBatchStatus(batchId);
    }

    @Test
    void testCancelBatchProcessing_Success() throws Exception {
        // Arrange
        String batchId = "batch_123";
        
        when(batchProcessingService.cancelBatch(batchId)).thenReturn(true);

        // Act & Assert
        mockMvc.perform(post("/batch/cancel/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.message").value(containsString("cancelled")));

        verify(batchProcessingService).cancelBatch(batchId);
    }

    @Test
    void testCancelBatchProcessing_NotFound() throws Exception {
        // Arrange
        String batchId = "nonexistent_batch";
        
        when(batchProcessingService.cancelBatch(batchId)).thenReturn(false);

        // Act & Assert
        mockMvc.perform(post("/batch/cancel/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value(containsString("not found")));

        verify(batchProcessingService).cancelBatch(batchId);
    }

    // ================================
    // Ontology Matching Tests
    // ================================

    @Test
    void testMatchOntology_Success() throws Exception {
        // Arrange
        OntologyMatchingRequest request = createValidOntologyMatchingRequest();
        Map<String, List<OntologyMatchingService.MatchResult>> mockMatches = createMockMatchResults();
        
        when(ontologyService.isLoaded()).thenReturn(true);
        when(matchingService.batchMatchEntities(any(), any(), any())).thenReturn(mockMatches);

        // Act & Assert
        mockMvc.perform(post("/match-ontology")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalMatches").value(2))
                .andExpect(jsonPath("$.matches.diabetes").isArray());

        verify(ontologyService).isLoaded();
        verify(matchingService).batchMatchEntities(any(), any(), any());
    }

    @Test
    void testMatchOntology_OntologyNotLoaded() throws Exception {
        // Arrange
        OntologyMatchingRequest request = createValidOntologyMatchingRequest();
        
        when(ontologyService.isLoaded()).thenReturn(false);

        // Act & Assert
        mockMvc.perform(post("/match-ontology")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isServiceUnavailable())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorMessage").value(containsString("not loaded")));

        verify(ontologyService).isLoaded();
        verify(matchingService, never()).batchMatchEntities(any(), any(), any());
    }

    // ================================
    // Service Status Tests
    // ================================

    @Test
    void testGetStatus_Success() throws Exception {
        // Arrange
        ResilientOllamaService.ServiceInfo aiServiceInfo = new ResilientOllamaService.ServiceInfo();
        aiServiceInfo.healthy = true;
        
        OntologyService.OntologyStatistics stats = new OntologyService.OntologyStatistics();
        stats.totalTerms = 45000;
        stats.namespaceStats = Map.of("disease_ontology", 15000, "gene_ontology", 30000);
        
        OntologyUpdateService.UpdateServiceStatus updateStatus = new OntologyUpdateService.UpdateServiceStatus();
        updateStatus.updateInProgress = false;
        updateStatus.lastUpdateCheck = LocalDateTime.now().minusHours(2);
        
        when(resilientOllamaService.getServiceInfo()).thenReturn(aiServiceInfo);
        when(ontologyService.isLoaded()).thenReturn(true);
        when(ontologyService.getStatistics()).thenReturn(stats);
        when(updateService.getStatus()).thenReturn(updateStatus);
        when(cacheService.isCacheEnabled()).thenReturn(true);
        when(cacheService.getCacheHitRate()).thenReturn(0.87);

        // Act & Assert
        mockMvc.perform(get("/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.overallHealthy").value(true))
                .andExpect(jsonPath("$.aiServiceHealthy").value(true))
                .andExpect(jsonPath("$.ontologyLoaded").value(true))
                .andExpect(jsonPath("$.ontologyTermCount").value(45000))
                .andExpect(jsonPath("$.cacheEnabled").value(true))
                .andExpect(jsonPath("$.cacheHitRate").value(0.87));

        verify(resilientOllamaService).getServiceInfo();
        verify(ontologyService).isLoaded();
        verify(ontologyService).getStatistics();
    }

    @Test
    void testGetStatus_ServiceUnhealthy() throws Exception {
        // Arrange
        ResilientOllamaService.ServiceInfo aiServiceInfo = new ResilientOllamaService.ServiceInfo();
        aiServiceInfo.healthy = false;
        
        when(resilientOllamaService.getServiceInfo()).thenReturn(aiServiceInfo);
        when(ontologyService.isLoaded()).thenReturn(false);

        // Act & Assert
        mockMvc.perform(get("/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.overallHealthy").value(false))
                .andExpect(jsonPath("$.aiServiceHealthy").value(false))
                .andExpect(jsonPath("$.ontologyLoaded").value(false));

        verify(resilientOllamaService).getServiceInfo();
        verify(ontologyService).isLoaded();
    }

    // ================================
    // Admin Endpoints Tests
    // ================================

    @Test
    void testUpdateOntology_Success() throws Exception {
        // Arrange
        OntologyUpdateService.UpdateResult updateResult = new OntologyUpdateService.UpdateResult();
        updateResult.setSuccess(true);
        updateResult.setTotalTermsLoaded(50000);
        updateResult.setLoadResults(Map.of("RDO", true, "GO", true));
        
        when(updateService.updateFromRemote())
                .thenReturn(CompletableFuture.completedFuture(updateResult));

        // Act & Assert
        mockMvc.perform(post("/admin/update-ontology"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalTermsLoaded").value(50000));

        verify(updateService).updateFromRemote();
    }

    @Test
    void testClearCache_Success() throws Exception {
        // Arrange
        when(cacheService.isCacheEnabled()).thenReturn(true);

        // Act & Assert
        mockMvc.perform(post("/admin/clear-cache"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.operation").value("clear_all"));

        verify(cacheService).isCacheEnabled();
        verify(cacheService).clearAllCaches();
    }

    @Test
    void testClearCache_CacheDisabled() throws Exception {
        // Arrange
        when(cacheService.isCacheEnabled()).thenReturn(false);

        // Act & Assert
        mockMvc.perform(post("/admin/clear-cache"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorMessage").value(containsString("not enabled")));

        verify(cacheService).isCacheEnabled();
        verify(cacheService, never()).clearAllCaches();
    }

    // ================================
    // Helper Methods
    // ================================

    private EntityRecognitionApiRequest createValidRequest() {
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("The patient was diagnosed with diabetes mellitus and prescribed metformin.");
        request.setEntityTypes("disease,drug");
        request.setConfidenceThreshold(0.7);
        request.setEnableOntologyMatching(true);
        request.setSessionId("test_session_001");
        return request;
    }

    private EntityRecognitionResponse createMockAiResponse() {
        EntityRecognitionResponse response = new EntityRecognitionResponse();
        response.setSuccess(true);
        response.setRequestId("test_session_001");
        response.setProcessingTimeMs(1500L);
        
        List<EntityRecognitionResponse.RecognizedEntity> entities = new ArrayList<>();
        
        EntityRecognitionResponse.RecognizedEntity entity1 = new EntityRecognitionResponse.RecognizedEntity();
        entity1.setEntityName("diabetes mellitus");
        entity1.setEntityType("disease");
        entity1.setConfidenceScore(0.95);
        entity1.setStartPosition(28);
        entity1.setEndPosition(44);
        entity1.setContext("...diagnosed with diabetes mellitus and prescribed...");
        entities.add(entity1);
        
        EntityRecognitionResponse.RecognizedEntity entity2 = new EntityRecognitionResponse.RecognizedEntity();
        entity2.setEntityName("metformin");
        entity2.setEntityType("drug");
        entity2.setConfidenceScore(0.92);
        entity2.setStartPosition(59);
        entity2.setEndPosition(68);
        entity2.setContext("...and prescribed metformin.");
        entities.add(entity2);
        
        response.setEntities(entities);
        return response;
    }

    private List<OntologyMatchingService.MatchResult> createMockOntologyMatches() {
        List<OntologyMatchingService.MatchResult> matches = new ArrayList<>();
        
        OntologyTerm term = new OntologyTerm();
        term.setTermId("DOID:9351");
        term.setName("diabetes mellitus");
        term.setNamespace("disease_ontology");
        term.setDefinition("A glucose metabolism disorder...");
        
        OntologyMatchingService.MatchResult match = new OntologyMatchingService.MatchResult();
        match.setTerm(term);
        match.setMatchType(OntologyMatchingService.MatchType.EXACT);
        match.setConfidence(1.0);
        match.setExplanation("Exact term match");
        
        matches.add(match);
        return matches;
    }

    private BatchEntityRecognitionRequest createValidBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
            "Patient has diabetes and takes insulin.",
            "Hypertension was treated with ACE inhibitors."
        ));
        request.setEntityTypes("disease,drug");
        request.setConfidenceThreshold(0.7);
        request.setEnableOntologyMatching(true);
        request.setSessionId("batch_test_001");
        return request;
    }

    private BatchProcessingService.SyncBatchResult createMockSyncBatchResult() {
        BatchProcessingService.SyncBatchResult result = new BatchProcessingService.SyncBatchResult();
        result.setSuccess(true);
        result.setProcessingTimeMs(3000L);
        
        List<EntityRecognitionApiResponse> results = new ArrayList<>();
        for (int i = 0; i < 2; i++) {
            EntityRecognitionApiResponse response = new EntityRecognitionApiResponse();
            response.setSuccess(true);
            response.setEntityCount(1);
            results.add(response);
        }
        result.setResults(results);
        
        BatchStatistics stats = new BatchStatistics();
        stats.setTotalEntitiesFound(2);
        stats.setProcessingSuccessRate(1.0);
        result.setStatistics(stats);
        
        return result;
    }

    private BatchProcessingService.BatchProcessingResult createMockBatchProcessingResult() {
        BatchProcessingService.BatchProcessingResult result = new BatchProcessingService.BatchProcessingResult();
        result.setBatchId("batch_123");
        result.setTotalItems(10);
        result.setStartTime(LocalDateTime.now());
        return result;
    }

    private BatchProcessingService.BatchProcessingStatus createMockBatchStatus() {
        BatchProcessingService.BatchProcessingStatus status = new BatchProcessingService.BatchProcessingStatus();
        status.setBatchId("batch_123");
        status.setStatus("PROCESSING");
        status.setTotalItems(100);
        status.setProcessedItems(50);
        status.setSuccessfulItems(48);
        status.setStartTime(LocalDateTime.now().minusMinutes(5));
        return status;
    }

    private OntologyMatchingRequest createValidOntologyMatchingRequest() {
        OntologyMatchingRequest request = new OntologyMatchingRequest();
        request.setEntityNames(Arrays.asList("diabetes", "hypertension"));
        request.setNamespace("disease_ontology");
        request.setEnableExactMatch(true);
        request.setEnableFuzzyMatch(true);
        request.setFuzzyThreshold(0.8);
        request.setMaxResults(5);
        request.setSessionId("ontology_test_001");
        return request;
    }

    private Map<String, List<OntologyMatchingService.MatchResult>> createMockMatchResults() {
        Map<String, List<OntologyMatchingService.MatchResult>> matches = new HashMap<>();
        
        OntologyTerm diabetesTerm = new OntologyTerm();
        diabetesTerm.setTermId("DOID:9351");
        diabetesTerm.setName("diabetes mellitus");
        diabetesTerm.setNamespace("disease_ontology");
        
        OntologyMatchingService.MatchResult diabetesMatch = new OntologyMatchingService.MatchResult();
        diabetesMatch.setTerm(diabetesTerm);
        diabetesMatch.setMatchType(OntologyMatchingService.MatchType.FUZZY);
        diabetesMatch.setConfidence(0.95);
        
        matches.put("diabetes", Arrays.asList(diabetesMatch));
        
        OntologyTerm hypertensionTerm = new OntologyTerm();
        hypertensionTerm.setTermId("DOID:10763");
        hypertensionTerm.setName("hypertension");
        hypertensionTerm.setNamespace("disease_ontology");
        
        OntologyMatchingService.MatchResult hypertensionMatch = new OntologyMatchingService.MatchResult();
        hypertensionMatch.setTerm(hypertensionTerm);
        hypertensionMatch.setMatchType(OntologyMatchingService.MatchType.EXACT);
        hypertensionMatch.setConfidence(1.0);
        
        matches.put("hypertension", Arrays.asList(hypertensionMatch));
        
        return matches;
    }
}