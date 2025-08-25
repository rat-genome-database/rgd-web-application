package edu.mcw.rgd.curation.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.mcw.rgd.curation.config.CurationConfig;
import edu.mcw.rgd.curation.config.TestConfig;
import edu.mcw.rgd.curation.dto.EntityRecognitionApiRequest;
import edu.mcw.rgd.curation.dto.BatchEntityRecognitionRequest;
import edu.mcw.rgd.curation.service.ResilientOllamaService;
import edu.mcw.rgd.curation.service.OntologyService;
import edu.mcw.rgd.curation.service.OntologyMatchingService;
import edu.mcw.rgd.curation.service.BatchProcessingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.util.Arrays;
import java.util.concurrent.CompletableFuture;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests for EntityRecognitionController.
 * Tests the full request-response cycle with Spring context but mocked external services.
 */
@SpringJUnitConfig
@WebAppConfiguration
@AutoConfigureWebMvc
@Import({CurationConfig.class, TestConfig.class})
@ActiveProfiles("test")
class EntityRecognitionControllerIntegrationTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ResilientOllamaService resilientOllamaService;

    @MockBean
    private OntologyService ontologyService;

    @MockBean
    private OntologyMatchingService ontologyMatchingService;

    @MockBean
    private BatchProcessingService batchProcessingService;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
    }

    // ================================
    // Entity Recognition Integration Tests
    // ================================

    @Test
    void testRecognizeEntities_FullIntegration_Success() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        mockSuccessfulAiResponse();

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.sessionId").value("integration_test_001"))
                .andExpect(jsonPath("$.entities").isArray())
                .andExpect(jsonPath("$.entities[0].entityName").value("diabetes"))
                .andExpect(jsonPath("$.entities[0].entityType").value("disease"))
                .andExpect(jsonPath("$.entities[0].confidenceScore").value(0.95))
                .andExpect(jsonPath("$.processingTimeMs").isNumber())
                .andExpect(jsonPath("$.timestamp").exists());

        verify(resilientOllamaService).recognizeEntitiesComprehensive(any());
    }

    @Test
    void testRecognizeEntities_WithOntologyMatching() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        request.setEnableOntologyMatching(true);
        
        mockSuccessfulAiResponse();
        when(ontologyService.isLoaded()).thenReturn(true);
        when(ontologyMatchingService.matchEntity(anyString(), isNull(), any()))
                .thenReturn(createMockOntologyMatches());

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.entities[0].ontologyMatches").isArray())
                .andExpect(jsonPath("$.entities[0].ontologyMatches[0].termId").value("DOID:9351"))
                .andExpect(jsonPath("$.entities[0].ontologyMatches[0].name").value("diabetes mellitus"));

        verify(ontologyService).isLoaded();
        verify(ontologyMatchingService).matchEntity(anyString(), isNull(), any());
    }

    @Test
    void testRecognizeEntities_ValidationFailure() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText(""); // Invalid - empty text
        request.setConfidenceThreshold(1.5); // Invalid - out of range

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value(org.hamcrest.Matchers.containsString("Validation failed")))
                .andExpect(jsonPath("$.errorCode").value("VALIDATION_ERROR"));

        verify(resilientOllamaService, never()).recognizeEntitiesComprehensive(any());
    }

    @Test
    void testRecognizeEntities_MalformedJson() throws Exception {
        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{invalid json}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("Malformed JSON request body"))
                .andExpect(jsonPath("$.errorCode").value("MALFORMED_JSON"));
    }

    @Test
    void testRecognizeEntities_ServiceException() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenThrow(new RuntimeException("AI service unavailable"));

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("An unexpected error occurred. Please try again later."))
                .andExpect(jsonPath("$.errorCode").value("INTERNAL_ERROR"));
    }

    // ================================
    // Batch Processing Integration Tests
    // ================================

    @Test
    void testProcessBatch_FullIntegration_Success() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createValidBatchRequest();
        mockSuccessfulBatchResponse();

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").exists())
                .andExpect(jsonPath("$.totalItems").value(3))
                .andExpect(jsonPath("$.startTime").exists())
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("started successfully")));

        verify(batchProcessingService).processTextsAsync(any(BatchEntityRecognitionRequest.class));
    }

    @Test
    void testProcessBatch_ValidationFailure() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList()); // Invalid - empty list

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value(org.hamcrest.Matchers.containsString("Validation failed")));

        verify(batchProcessingService, never()).processTextsAsync(any());
    }

    @Test
    void testGetBatchStatus_Success() throws Exception {
        // Arrange
        String batchId = "batch_123";
        mockBatchStatusResponse(batchId);

        // Act & Assert
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.totalItems").value(5))
                .andExpect(jsonPath("$.completedItems").value(3));

        verify(batchProcessingService).getBatchStatus(batchId);
    }

    @Test
    void testGetBatchStatus_NotFound() throws Exception {
        // Arrange
        String batchId = "nonexistent_batch";
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(null);

        // Act & Assert
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("Batch not found: " + batchId));
    }

    @Test
    void testCancelBatch_Success() throws Exception {
        // Arrange
        String batchId = "batch_456";
        when(batchProcessingService.cancelBatch(batchId)).thenReturn(true);

        // Act & Assert
        mockMvc.perform(delete("/curation/batch/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Batch cancelled successfully"));

        verify(batchProcessingService).cancelBatch(batchId);
    }

    // ================================
    // Ontology Matching Integration Tests
    // ================================

    @Test
    void testMatchOntologyTerms_Success() throws Exception {
        // Arrange
        when(ontologyService.isLoaded()).thenReturn(true);
        when(ontologyMatchingService.matchEntity(anyString(), anyString(), any()))
                .thenReturn(createMockOntologyMatches());

        // Act & Assert
        mockMvc.perform(get("/curation/ontology/match")
                        .param("term", "diabetes")
                        .param("namespace", "disease_ontology")
                        .param("threshold", "0.8"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.matches").isArray())
                .andExpect(jsonPath("$.matches[0].termId").value("DOID:9351"))
                .andExpect(jsonPath("$.matches[0].name").value("diabetes mellitus"))
                .andExpect(jsonPath("$.matches[0].matchType").value("EXACT"));

        verify(ontologyService).isLoaded();
        verify(ontologyMatchingService).matchEntity("diabetes", "disease_ontology", 0.8);
    }

    @Test
    void testMatchOntologyTerms_OntologyNotLoaded() throws Exception {
        // Arrange
        when(ontologyService.isLoaded()).thenReturn(false);

        // Act & Assert
        mockMvc.perform(get("/curation/ontology/match")
                        .param("term", "diabetes"))
                .andExpect(status().isServiceUnavailable())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("Ontology service is not available"));

        verify(ontologyService).isLoaded();
        verify(ontologyMatchingService, never()).matchEntity(anyString(), anyString(), anyDouble());
    }

    // ================================
    // Health Check Integration Tests
    // ================================

    @Test
    void testHealthCheck_AllServicesHealthy() throws Exception {
        // Arrange
        when(resilientOllamaService.isHealthy()).thenReturn(true);
        when(ontologyService.isLoaded()).thenReturn(true);

        // Act & Assert
        mockMvc.perform(get("/curation/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.services.aiService").value("UP"))
                .andExpect(jsonPath("$.services.ontologyService").value("UP"))
                .andExpect(jsonPath("$.timestamp").exists());
    }

    @Test
    void testHealthCheck_SomeServicesDown() throws Exception {
        // Arrange
        when(resilientOllamaService.isHealthy()).thenReturn(false);
        when(ontologyService.isLoaded()).thenReturn(true);

        // Act & Assert
        mockMvc.perform(get("/curation/health"))
                .andExpect(status().isServiceUnavailable())
                .andExpect(jsonPath("$.status").value("DOWN"))
                .andExpect(jsonPath("$.services.aiService").value("DOWN"))
                .andExpect(jsonPath("$.services.ontologyService").value("UP"));
    }

    // ================================
    // Content Negotiation Tests
    // ================================

    @Test
    void testRecognizeEntities_AcceptXml_NotSupported() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .accept(MediaType.APPLICATION_XML)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotAcceptable());
    }

    @Test
    void testRecognizeEntities_UnsupportedContentType() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_XML)
                        .content("<xml>test</xml>"))
                .andExpect(status().isUnsupportedMediaType());
    }

    // ================================
    // Cross-cutting Concerns Tests
    // ================================

    @Test
    void testRecognizeEntities_LargeRequest() throws Exception {
        // Arrange
        EntityRecognitionApiRequest request = createValidRequest();
        request.setText("x".repeat(50000)); // Large but valid text
        mockSuccessfulAiResponse();

        // Act & Assert
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void testRecognizeEntities_ConcurrentRequests() throws Exception {
        // This test would be more complex in a real scenario
        // For now, just verify that the endpoint handles multiple requests
        EntityRecognitionApiRequest request = createValidRequest();
        mockSuccessfulAiResponse();

        // Simulate concurrent requests
        for (int i = 0; i < 3; i++) {
            request.setSessionId("concurrent_test_" + i);
            mockMvc.perform(post("/curation/recognize")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        verify(resilientOllamaService, times(3)).recognizeEntitiesComprehensive(any());
    }

    // ================================
    // Helper Methods
    // ================================

    private EntityRecognitionApiRequest createValidRequest() {
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Patient diagnosed with diabetes mellitus and prescribed metformin.");
        request.setEntityTypes("disease,drug");
        request.setConfidenceThreshold(0.7);
        request.setSessionId("integration_test_001");
        request.setEnableOntologyMatching(false); // Disabled by default to simplify tests
        return request;
    }

    private BatchEntityRecognitionRequest createValidBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
                "Patient has diabetes and hypertension.",
                "Treatment includes insulin and lisinopril.",
                "BRCA1 mutation increases cancer risk."
        ));
        request.setEntityTypes("disease,drug,gene");
        request.setSessionId("batch_integration_test");
        return request;
    }

    private void mockSuccessfulAiResponse() throws Exception {
        edu.mcw.rgd.curation.dto.EntityRecognitionResponse mockResponse = 
                new edu.mcw.rgd.curation.dto.EntityRecognitionResponse();
        mockResponse.setSuccess(true);
        mockResponse.setRequestId("test_request");
        mockResponse.setProcessingTimeMs(1500L);
        
        edu.mcw.rgd.curation.dto.EntityRecognitionResponse.RecognizedEntity entity = 
                new edu.mcw.rgd.curation.dto.EntityRecognitionResponse.RecognizedEntity();
        entity.setEntityName("diabetes");
        entity.setEntityType("disease");
        entity.setConfidenceScore(0.95);
        entity.setStartPosition(17);
        entity.setEndPosition(25);
        
        mockResponse.setEntities(Arrays.asList(entity));
        
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenReturn(CompletableFuture.completedFuture(mockResponse));
    }

    private void mockSuccessfulBatchResponse() throws Exception {
        BatchProcessingService.BatchProcessingResult mockResult = 
                new BatchProcessingService.BatchProcessingResult();
        mockResult.setBatchId("batch_integration_test_123");
        mockResult.setTotalItems(3);
        mockResult.setStartTime(java.time.LocalDateTime.now());
        mockResult.setProcessingFuture(CompletableFuture.completedFuture(null));
        
        when(batchProcessingService.processTextsAsync(any(BatchEntityRecognitionRequest.class)))
                .thenReturn(mockResult);
    }

    private void mockBatchStatusResponse(String batchId) {
        BatchProcessingService.BatchProcessingStatus mockStatus = 
                new BatchProcessingService.BatchProcessingStatus();
        mockStatus.setBatchId(batchId);
        mockStatus.setStatus("IN_PROGRESS");
        mockStatus.setTotalItems(5);
        mockStatus.setCompletedItems(3);
        mockStatus.setStartTime(java.time.LocalDateTime.now().minusMinutes(5));
        
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(mockStatus);
    }

    private java.util.List<OntologyMatchingService.MatchResult> createMockOntologyMatches() {
        java.util.List<OntologyMatchingService.MatchResult> matches = new java.util.ArrayList<>();
        
        edu.mcw.rgd.curation.dto.OntologyTerm term = new edu.mcw.rgd.curation.dto.OntologyTerm();
        term.setTermId("DOID:9351");
        term.setName("diabetes mellitus");
        term.setNamespace("disease_ontology");
        term.setDefinition("A glucose metabolism disorder characterized by high blood sugar.");
        
        OntologyMatchingService.MatchResult match = new OntologyMatchingService.MatchResult();
        match.setTerm(term);
        match.setMatchType(OntologyMatchingService.MatchType.EXACT);
        match.setConfidence(1.0);
        
        matches.add(match);
        return matches;
    }
}