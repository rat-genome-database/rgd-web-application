package edu.mcw.rgd.curation.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.mcw.rgd.curation.config.CurationConfig;
import edu.mcw.rgd.curation.config.TestConfig;
import edu.mcw.rgd.curation.dto.BatchEntityRecognitionRequest;
import edu.mcw.rgd.curation.dto.EntityRecognitionResponse;
import edu.mcw.rgd.curation.service.ResilientOllamaService;
import edu.mcw.rgd.curation.service.OntologyService;
import edu.mcw.rgd.curation.service.OntologyMatchingService;
import edu.mcw.rgd.curation.service.BatchProcessingService;
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
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests for batch processing functionality.
 * Tests the complete batch processing workflow including async operations and status tracking.
 */
@SpringJUnitConfig
@WebAppConfiguration
@Import({CurationConfig.class, TestConfig.class})
@ActiveProfiles("test")
class BatchProcessingIntegrationTest {

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
    // Batch Processing Workflow Tests
    // ================================

    @Test
    void testBatchProcessingWorkflow_Complete() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createLargeBatchRequest();
        String batchId = "workflow_test_batch_001";
        
        // Mock batch processing initiation
        BatchProcessingService.BatchProcessingResult initResult = createMockBatchResult(batchId, 10);
        when(batchProcessingService.processTextsAsync(any())).thenReturn(initResult);
        
        // Mock initial status (processing)
        BatchProcessingService.BatchProcessingStatus processingStatus = 
                createMockBatchStatus(batchId, "IN_PROGRESS", 10, 3);
        when(batchProcessingService.getBatchStatus(batchId))
                .thenReturn(processingStatus)
                .thenReturn(createMockBatchStatus(batchId, "COMPLETED", 10, 10));

        // Step 1: Start batch processing
        MvcResult startResult = mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.totalItems").value(10))
                .andReturn();

        // Step 2: Check processing status
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.totalItems").value(10))
                .andExpect(jsonPath("$.completedItems").value(3));

        // Step 3: Check completion status
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"))
                .andExpect(jsonPath("$.completedItems").value(10));

        // Verify service interactions
        verify(batchProcessingService).processTextsAsync(any());
        verify(batchProcessingService, times(2)).getBatchStatus(batchId);
    }

    @Test
    void testBatchProcessing_LargeDataset() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createExtraLargeBatchRequest();
        String batchId = "large_dataset_batch";
        
        BatchProcessingService.BatchProcessingResult result = createMockBatchResult(batchId, 50);
        when(batchProcessingService.processTextsAsync(any())).thenReturn(result);

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.totalItems").value(50));

        verify(batchProcessingService).processTextsAsync(any());
    }

    @Test
    void testBatchProcessing_WithOntologyMatching() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createBatchRequestWithOntology();
        String batchId = "ontology_batch";
        
        BatchProcessingService.BatchProcessingResult result = createMockBatchResult(batchId, 5);
        when(batchProcessingService.processTextsAsync(any())).thenReturn(result);
        when(ontologyService.isLoaded()).thenReturn(true);

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").value(batchId));

        verify(batchProcessingService).processTextsAsync(any());
    }

    // ================================
    // Batch Status Management Tests
    // ================================

    @Test
    void testBatchStatusProgression() throws Exception {
        // Arrange
        String batchId = "status_progression_test";
        
        // Mock status progression: PENDING -> IN_PROGRESS -> COMPLETED
        when(batchProcessingService.getBatchStatus(batchId))
                .thenReturn(createMockBatchStatus(batchId, "PENDING", 5, 0))
                .thenReturn(createMockBatchStatus(batchId, "IN_PROGRESS", 5, 2))
                .thenReturn(createMockBatchStatus(batchId, "IN_PROGRESS", 5, 4))
                .thenReturn(createMockBatchStatus(batchId, "COMPLETED", 5, 5));

        // Test each status stage
        String[] expectedStatuses = {"PENDING", "IN_PROGRESS", "IN_PROGRESS", "COMPLETED"};
        int[] expectedCompleted = {0, 2, 4, 5};

        for (int i = 0; i < expectedStatuses.length; i++) {
            mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.status").value(expectedStatuses[i]))
                    .andExpect(jsonPath("$.completedItems").value(expectedCompleted[i]));
        }

        verify(batchProcessingService, times(4)).getBatchStatus(batchId);
    }

    @Test
    void testBatchStatusWithErrors() throws Exception {
        // Arrange
        String batchId = "error_batch";
        BatchProcessingService.BatchProcessingStatus errorStatus = 
                createMockBatchStatus(batchId, "FAILED", 10, 3);
        errorStatus.setErrorMessage("Processing failed due to AI service timeout");
        errorStatus.setFailedItems(7);
        
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(errorStatus);

        // Act & Assert
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("FAILED"))
                .andExpect(jsonPath("$.completedItems").value(3))
                .andExpect(jsonPath("$.failedItems").value(7))
                .andExpect(jsonPath("$.errorMessage").value("Processing failed due to AI service timeout"));
    }

    @Test
    void testBatchCancellation() throws Exception {
        // Arrange
        String batchId = "cancellation_test";
        when(batchProcessingService.cancelBatch(batchId)).thenReturn(true);
        
        BatchProcessingService.BatchProcessingStatus cancelledStatus = 
                createMockBatchStatus(batchId, "CANCELLED", 10, 4);
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(cancelledStatus);

        // Act: Cancel batch
        mockMvc.perform(delete("/curation/batch/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Batch cancelled successfully"));

        // Act: Check cancelled status
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"))
                .andExpect(jsonPath("$.completedItems").value(4));

        verify(batchProcessingService).cancelBatch(batchId);
        verify(batchProcessingService).getBatchStatus(batchId);
    }

    // ================================
    // Synchronous Batch Processing Tests
    // ================================

    @Test
    void testSynchronousBatchProcessing() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createSmallBatchRequest();
        
        BatchProcessingService.SyncBatchResult syncResult = createMockSyncResult(3);
        when(batchProcessingService.processTextsSync(any())).thenReturn(syncResult);

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process-sync")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.results").isArray())
                .andExpect(jsonPath("$.results").value(org.hamcrest.Matchers.hasSize(3)))
                .andExpect(jsonPath("$.statistics.totalEntitiesFound").value(15))
                .andExpect(jsonPath("$.statistics.processingSuccessRate").value(1.0))
                .andExpect(jsonPath("$.processingTimeMs").value(5000));

        verify(batchProcessingService).processTextsSync(any());
    }

    @Test
    void testSynchronousBatchProcessing_PartialFailure() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createSmallBatchRequest();
        
        BatchProcessingService.SyncBatchResult syncResult = createMockSyncResultWithFailures(3, 1);
        when(batchProcessingService.processTextsSync(any())).thenReturn(syncResult);

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process-sync")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.results").value(org.hamcrest.Matchers.hasSize(3)))
                .andExpect(jsonPath("$.statistics.processingSuccessRate").value(0.67)) // 2/3 success
                .andExpect(jsonPath("$.results[2].success").value(false));

        verify(batchProcessingService).processTextsSync(any());
    }

    // ================================
    // Error Handling Tests
    // ================================

    @Test
    void testBatchProcessing_ServiceException() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = createSmallBatchRequest();
        when(batchProcessingService.processTextsAsync(any()))
                .thenThrow(new RuntimeException("Batch processing service unavailable"));

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("An unexpected error occurred. Please try again later."));
    }

    @Test
    void testBatchProcessing_InvalidBatchSize() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        
        // Create request with too many texts (exceeding limit)
        List<String> tooManyTexts = new ArrayList<>();
        for (int i = 0; i < 101; i++) { // Assuming 100 is the limit
            tooManyTexts.add("Sample text " + i);
        }
        request.setTexts(tooManyTexts);

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value(org.hamcrest.Matchers.containsString("Validation failed")));

        verify(batchProcessingService, never()).processTextsAsync(any());
    }

    // ================================
    // Performance and Load Tests
    // ================================

    @Test
    void testBatchProcessing_ConcurrentBatches() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request1 = createSmallBatchRequest();
        request1.setSessionId("concurrent_batch_1");
        
        BatchEntityRecognitionRequest request2 = createSmallBatchRequest();
        request2.setSessionId("concurrent_batch_2");
        
        when(batchProcessingService.processTextsAsync(any()))
                .thenReturn(createMockBatchResult("batch_1", 3))
                .thenReturn(createMockBatchResult("batch_2", 3));

        // Act: Submit concurrent batches
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request1)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request2)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Assert
        verify(batchProcessingService, times(2)).processTextsAsync(any());
    }

    // ================================
    // Data Validation Tests
    // ================================

    @Test
    void testBatchProcessing_MixedContentTypes() throws Exception {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
                "Medical text: Patient has diabetes mellitus.",
                "Scientific text: BRCA1 gene expression was measured.",
                "Clinical note: BP 140/90, prescribed lisinopril 10mg.",
                "Research text: P53 mutation frequency in colorectal cancer cohort."
        ));
        request.setEntityTypes("disease,drug,gene");
        request.setSessionId("mixed_content_test");
        
        BatchProcessingService.BatchProcessingResult result = createMockBatchResult("mixed_content_batch", 4);
        when(batchProcessingService.processTextsAsync(any())).thenReturn(result);

        // Act & Assert
        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalItems").value(4));

        verify(batchProcessingService).processTextsAsync(any());
    }

    // ================================
    // Helper Methods
    // ================================

    private BatchEntityRecognitionRequest createSmallBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
                "Patient diagnosed with hypertension.",
                "Treatment with ACE inhibitor lisinopril.",
                "BRCA1 mutation increases cancer risk."
        ));
        request.setEntityTypes("disease,drug,gene");
        request.setSessionId("small_batch_test");
        return request;
    }

    private BatchEntityRecognitionRequest createLargeBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        List<String> texts = new ArrayList<>();
        
        for (int i = 1; i <= 10; i++) {
            texts.add("Medical case " + i + ": Patient presents with symptoms and requires treatment.");
        }
        
        request.setTexts(texts);
        request.setEntityTypes("disease,drug,symptom");
        request.setSessionId("large_batch_test");
        return request;
    }

    private BatchEntityRecognitionRequest createExtraLargeBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        List<String> texts = new ArrayList<>();
        
        for (int i = 1; i <= 50; i++) {
            texts.add("Research abstract " + i + ": Study examines gene expression in disease context.");
        }
        
        request.setTexts(texts);
        request.setEntityTypes("gene,disease");
        request.setSessionId("extra_large_batch_test");
        return request;
    }

    private BatchEntityRecognitionRequest createBatchRequestWithOntology() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
                "Diabetes mellitus type 2 diagnosis confirmed.",
                "Metformin prescribed for glucose control.",
                "BRCA1 gene variant detected in patient.",
                "Hypertension managed with antihypertensive therapy.",
                "Insulin resistance observed in metabolic panel."
        ));
        request.setEntityTypes("disease,drug,gene");
        request.setEnableOntologyMatching(true);
        request.setOntologyNamespace("disease_ontology");
        request.setSessionId("ontology_batch_test");
        return request;
    }

    private BatchProcessingService.BatchProcessingResult createMockBatchResult(String batchId, int totalItems) {
        BatchProcessingService.BatchProcessingResult result = new BatchProcessingService.BatchProcessingResult();
        result.setBatchId(batchId);
        result.setTotalItems(totalItems);
        result.setStartTime(LocalDateTime.now());
        result.setProcessingFuture(CompletableFuture.completedFuture(null));
        return result;
    }

    private BatchProcessingService.BatchProcessingStatus createMockBatchStatus(String batchId, String status, 
                                                                               int totalItems, int completedItems) {
        BatchProcessingService.BatchProcessingStatus batchStatus = new BatchProcessingService.BatchProcessingStatus();
        batchStatus.setBatchId(batchId);
        batchStatus.setStatus(status);
        batchStatus.setTotalItems(totalItems);
        batchStatus.setCompletedItems(completedItems);
        batchStatus.setStartTime(LocalDateTime.now().minusMinutes(10));
        if ("COMPLETED".equals(status) || "FAILED".equals(status) || "CANCELLED".equals(status)) {
            batchStatus.setEndTime(LocalDateTime.now());
        }
        return batchStatus;
    }

    private BatchProcessingService.SyncBatchResult createMockSyncResult(int itemCount) {
        BatchProcessingService.SyncBatchResult result = new BatchProcessingService.SyncBatchResult();
        result.setSuccess(true);
        result.setProcessingTimeMs(5000L);
        
        // Create mock results
        List<edu.mcw.rgd.curation.dto.EntityRecognitionApiResponse> results = new ArrayList<>();
        for (int i = 0; i < itemCount; i++) {
            edu.mcw.rgd.curation.dto.EntityRecognitionApiResponse response = 
                    new edu.mcw.rgd.curation.dto.EntityRecognitionApiResponse();
            response.setSuccess(true);
            response.setSessionId("sync_test_" + i);
            results.add(response);
        }
        result.setResults(results);
        
        // Create mock statistics
        edu.mcw.rgd.curation.dto.BatchStatistics stats = new edu.mcw.rgd.curation.dto.BatchStatistics();
        stats.setTotalEntitiesFound(15);
        stats.setProcessingSuccessRate(1.0);
        result.setStatistics(stats);
        
        return result;
    }

    private BatchProcessingService.SyncBatchResult createMockSyncResultWithFailures(int itemCount, int failureCount) {
        BatchProcessingService.SyncBatchResult result = createMockSyncResult(itemCount);
        
        // Mark some results as failed
        List<edu.mcw.rgd.curation.dto.EntityRecognitionApiResponse> results = result.getResults();
        for (int i = itemCount - failureCount; i < itemCount; i++) {
            results.get(i).setSuccess(false);
            results.get(i).setError("Processing failed for item " + i);
        }
        
        // Update statistics
        double successRate = (double) (itemCount - failureCount) / itemCount;
        result.getStatistics().setProcessingSuccessRate(Math.round(successRate * 100.0) / 100.0);
        
        return result;
    }
}