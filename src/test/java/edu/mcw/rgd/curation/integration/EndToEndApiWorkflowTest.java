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
import edu.mcw.rgd.curation.service.TempFileManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
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
import java.util.List;
import java.util.concurrent.CompletableFuture;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * End-to-end API workflow tests that simulate realistic user scenarios.
 * Tests complete workflows from initial health check through entity recognition to cleanup.
 */
@SpringJUnitConfig
@WebAppConfiguration
@Import({CurationConfig.class, TestConfig.class})
@ActiveProfiles("test")
@TestMethodOrder(OrderAnnotation.class)
class EndToEndApiWorkflowTest {

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

    @MockBean
    private TempFileManager tempFileManager;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        setupDefaultMocks();
    }

    // ================================
    // Complete Research Workflow
    // ================================

    @Test
    @Order(1)
    void testCompleteResearchWorkflow() throws Exception {
        /*
         * Scenario: A researcher wants to process medical literature for entity recognition
         * 1. Check system health
         * 2. Process single research abstract
         * 3. Process batch of abstracts
         * 4. Check ontology matches for discovered entities
         * 5. Monitor batch progress
         * 6. Cleanup temporary files
         */

        // Step 1: Health Check
        mockMvc.perform(get("/curation/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.services.aiService").value("UP"))
                .andExpect(jsonPath("$.services.ontologyService").value("UP"));

        // Step 2: Single Entity Recognition
        EntityRecognitionApiRequest singleRequest = createResearchRequest();
        
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(singleRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.entities").isArray())
                .andExpect(jsonPath("$.entities[0].entityName").value("BRCA1"))
                .andExpect(jsonPath("$.entities[0].entityType").value("gene"));

        // Step 3: Ontology Matching for discovered entity
        mockMvc.perform(get("/curation/ontology/match")
                        .param("term", "BRCA1")
                        .param("namespace", "gene_ontology")
                        .param("threshold", "0.9"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.matches").isArray())
                .andExpect(jsonPath("$.matches[0].termId").exists());

        // Step 4: Batch Processing
        BatchEntityRecognitionRequest batchRequest = createResearchBatchRequest();
        
        MvcResult batchResult = mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(batchRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.batchId").exists())
                .andReturn();

        // Extract batch ID for monitoring
        String responseBody = batchResult.getResponse().getContentAsString();
        com.fasterxml.jackson.databind.JsonNode jsonNode = objectMapper.readTree(responseBody);
        String batchId = jsonNode.get("batchId").asText();

        // Step 5: Monitor Batch Progress
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.batchId").value(batchId))
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"));

        // Simulate completion and check final status
        mockBatchCompletion(batchId);
        
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"));

        // Step 6: System Maintenance
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Verify all service interactions
        verify(resilientOllamaService, atLeastOnce()).isHealthy();
        verify(ontologyService, atLeastOnce()).isLoaded();
        verify(resilientOllamaService).recognizeEntitiesComprehensive(any());
        verify(ontologyMatchingService).matchEntity(anyString(), anyString(), any());
        verify(batchProcessingService).processTextsAsync(any());
        verify(batchProcessingService, atLeast(2)).getBatchStatus(batchId);
        verify(tempFileManager).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    // ================================
    // Clinical Documentation Workflow
    // ================================

    @Test
    @Order(2)
    void testClinicalDocumentationWorkflow() throws Exception {
        /*
         * Scenario: A clinician wants to process patient notes for entity recognition
         * 1. Process clinical note with disease and drug entities
         * 2. Enable ontology matching for standardization
         * 3. Validate results against medical ontologies
         */

        // Step 1: Clinical Note Processing
        EntityRecognitionApiRequest clinicalRequest = createClinicalRequest();
        
        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(clinicalRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.entities").isArray())
                .andExpect(jsonPath("$.entities[?(@.entityType == 'disease')]").exists())
                .andExpect(jsonPath("$.entities[?(@.entityType == 'drug')]").exists());

        // Step 2: Ontology Matching for Medical Terms
        mockMvc.perform(get("/curation/ontology/match")
                        .param("term", "diabetes mellitus")
                        .param("namespace", "disease_ontology")
                        .param("threshold", "0.8"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.matches[0].termId").value("DOID:9351"));

        mockMvc.perform(get("/curation/ontology/match")
                        .param("term", "metformin")
                        .param("namespace", "drug_ontology")
                        .param("threshold", "0.8"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(resilientOllamaService).recognizeEntitiesComprehensive(any());
        verify(ontologyMatchingService, times(2)).matchEntity(anyString(), anyString(), any());
    }

    // ================================
    // Large Scale Processing Workflow
    // ================================

    @Test
    @Order(3)
    void testLargeScaleProcessingWorkflow() throws Exception {
        /*
         * Scenario: Process large dataset of scientific literature
         * 1. Submit large batch for processing
         * 2. Monitor progress over time
         * 3. Handle partial failures gracefully
         * 4. Clean up resources after completion
         */

        // Step 1: Submit Large Batch
        BatchEntityRecognitionRequest largeBatchRequest = createLargeBatchRequest();
        
        MvcResult batchResult = mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(largeBatchRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.totalItems").value(25))
                .andReturn();

        String batchId = extractBatchId(batchResult);

        // Step 2: Monitor Progress with Multiple Checks
        // Simulate progress over time
        mockBatchProgressSequence(batchId);

        // Initial status - just started
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.completedItems").value(0));

        // Mid-progress status
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.completedItems").value(12));

        // Final status - some failures
        mockMvc.perform(get("/curation/batch/status/{batchId}", batchId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"))
                .andExpect(jsonPath("$.completedItems").value(22))
                .andExpect(jsonPath("$.failedItems").value(3));

        // Step 3: Check system resources after large batch
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalFiles").value(15)); // Some temp files created

        // Step 4: Cleanup
        mockMvc.perform(post("/curation/maintenance/temp-files/cleanup.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.filesRemoved").value(10));

        verify(batchProcessingService).processTextsAsync(any());
        verify(batchProcessingService, times(3)).getBatchStatus(batchId);
        verify(tempFileManager, times(2)).getFileStats();
        verify(tempFileManager).cleanupAllFiles();
    }

    // ================================
    // Error Recovery Workflow
    // ================================

    @Test
    @Order(4)
    void testErrorRecoveryWorkflow() throws Exception {
        /*
         * Scenario: Handle various error conditions gracefully
         * 1. Try processing when AI service is down
         * 2. Try batch processing with invalid data
         * 3. Recover when services come back online
         */

        // Step 1: AI Service Down
        when(resilientOllamaService.isHealthy()).thenReturn(false);
        
        mockMvc.perform(get("/curation/health"))
                .andExpect(status().isServiceUnavailable())
                .andExpect(jsonPath("$.status").value("DOWN"))
                .andExpect(jsonPath("$.services.aiService").value("DOWN"));

        // Try processing while service is down
        EntityRecognitionApiRequest request = createSimpleRequest();
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenThrow(new RuntimeException("AI service connection failed"));

        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false));

        // Step 2: Invalid Batch Data
        BatchEntityRecognitionRequest invalidBatch = new BatchEntityRecognitionRequest();
        invalidBatch.setTexts(Arrays.asList()); // Empty list

        mockMvc.perform(post("/curation/batch/process")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidBatch)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));

        // Step 3: Service Recovery
        when(resilientOllamaService.isHealthy()).thenReturn(true);
        mockSuccessfulAiResponse();

        mockMvc.perform(get("/curation/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));

        mockMvc.perform(post("/curation/recognize")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    // ================================
    // Performance Monitoring Workflow
    // ================================

    @Test
    @Order(5)
    void testPerformanceMonitoringWorkflow() throws Exception {
        /*
         * Scenario: Monitor system performance under load
         * 1. Submit multiple concurrent requests
         * 2. Monitor resource usage
         * 3. Ensure system remains responsive
         */

        // Submit multiple concurrent entity recognition requests
        for (int i = 0; i < 5; i++) {
            EntityRecognitionApiRequest request = createSimpleRequest();
            request.setSessionId("perf_test_" + i);
            
            mockMvc.perform(post("/curation/recognize")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        // Monitor system resources
        mockMvc.perform(get("/curation/maintenance/temp-files/stats.html"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Health check should still pass
        mockMvc.perform(get("/curation/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));

        verify(resilientOllamaService, times(5)).recognizeEntitiesComprehensive(any());
    }

    // ================================
    // Helper Methods
    // ================================

    private void setupDefaultMocks() {
        // Default health status
        when(resilientOllamaService.isHealthy()).thenReturn(true);
        when(ontologyService.isLoaded()).thenReturn(true);
        
        // Default successful responses
        try {
            mockSuccessfulAiResponse();
            mockSuccessfulOntologyMatches();
            mockSuccessfulBatchProcessing();
            mockSuccessfulTempFileOperations();
        } catch (Exception e) {
            throw new RuntimeException("Failed to setup mocks", e);
        }
    }

    private void mockSuccessfulAiResponse() throws Exception {
        edu.mcw.rgd.curation.dto.EntityRecognitionResponse mockResponse = 
                new edu.mcw.rgd.curation.dto.EntityRecognitionResponse();
        mockResponse.setSuccess(true);
        mockResponse.setRequestId("test_request");
        mockResponse.setProcessingTimeMs(1500L);
        
        // Create sample entities based on request type
        edu.mcw.rgd.curation.dto.EntityRecognitionResponse.RecognizedEntity entity1 = 
                new edu.mcw.rgd.curation.dto.EntityRecognitionResponse.RecognizedEntity();
        entity1.setEntityName("BRCA1");
        entity1.setEntityType("gene");
        entity1.setConfidenceScore(0.95);
        
        edu.mcw.rgd.curation.dto.EntityRecognitionResponse.RecognizedEntity entity2 = 
                new edu.mcw.rgd.curation.dto.EntityRecognitionResponse.RecognizedEntity();
        entity2.setEntityName("diabetes mellitus");
        entity2.setEntityType("disease");
        entity2.setConfidenceScore(0.88);
        
        mockResponse.setEntities(Arrays.asList(entity1, entity2));
        
        when(resilientOllamaService.recognizeEntitiesComprehensive(any()))
                .thenReturn(CompletableFuture.completedFuture(mockResponse));
    }

    private void mockSuccessfulOntologyMatches() {
        // BRCA1 gene match
        edu.mcw.rgd.curation.dto.OntologyTerm geneTerm = new edu.mcw.rgd.curation.dto.OntologyTerm();
        geneTerm.setTermId("HGNC:1100");
        geneTerm.setName("BRCA1");
        geneTerm.setNamespace("gene_ontology");
        
        OntologyMatchingService.MatchResult geneMatch = new OntologyMatchingService.MatchResult();
        geneMatch.setTerm(geneTerm);
        geneMatch.setMatchType(OntologyMatchingService.MatchType.EXACT);
        geneMatch.setConfidence(1.0);
        
        // Diabetes disease match
        edu.mcw.rgd.curation.dto.OntologyTerm diseaseTerm = new edu.mcw.rgd.curation.dto.OntologyTerm();
        diseaseTerm.setTermId("DOID:9351");
        diseaseTerm.setName("diabetes mellitus");
        diseaseTerm.setNamespace("disease_ontology");
        
        OntologyMatchingService.MatchResult diseaseMatch = new OntologyMatchingService.MatchResult();
        diseaseMatch.setTerm(diseaseTerm);
        diseaseMatch.setMatchType(OntologyMatchingService.MatchType.EXACT);
        diseaseMatch.setConfidence(0.95);
        
        when(ontologyMatchingService.matchEntity(eq("BRCA1"), anyString(), any()))
                .thenReturn(Arrays.asList(geneMatch));
        when(ontologyMatchingService.matchEntity(eq("diabetes mellitus"), anyString(), any()))
                .thenReturn(Arrays.asList(diseaseMatch));
        when(ontologyMatchingService.matchEntity(eq("metformin"), anyString(), any()))
                .thenReturn(Arrays.asList()); // Simple mock for drug
    }

    private void mockSuccessfulBatchProcessing() {
        BatchProcessingService.BatchProcessingResult result = new BatchProcessingService.BatchProcessingResult();
        result.setBatchId("workflow_batch_001");
        result.setTotalItems(5);
        result.setStartTime(LocalDateTime.now());
        result.setProcessingFuture(CompletableFuture.completedFuture(null));
        
        when(batchProcessingService.processTextsAsync(any())).thenReturn(result);
    }

    private void mockSuccessfulTempFileOperations() {
        TempFileManager.TempFileStats stats = mock(TempFileManager.TempFileStats.class);
        when(stats.getTotalFiles()).thenReturn(5);
        when(stats.getTotalSizeBytes()).thenReturn(10485760L); // 10MB
        when(stats.getOldestFileAge()).thenReturn(1800000L); // 30 minutes
        
        when(tempFileManager.getFileStats()).thenReturn(stats);
        when(tempFileManager.cleanupAllFiles()).thenReturn(3);
    }

    private void mockBatchCompletion(String batchId) {
        BatchProcessingService.BatchProcessingStatus completedStatus = 
                new BatchProcessingService.BatchProcessingStatus();
        completedStatus.setBatchId(batchId);
        completedStatus.setStatus("COMPLETED");
        completedStatus.setTotalItems(5);
        completedStatus.setCompletedItems(5);
        completedStatus.setStartTime(LocalDateTime.now().minusMinutes(2));
        completedStatus.setEndTime(LocalDateTime.now());
        
        when(batchProcessingService.getBatchStatus(batchId)).thenReturn(completedStatus);
    }

    private void mockBatchProgressSequence(String batchId) {
        // Sequence of status updates for large batch
        BatchProcessingService.BatchProcessingStatus status1 = createBatchStatus(batchId, "IN_PROGRESS", 25, 0);
        BatchProcessingService.BatchProcessingStatus status2 = createBatchStatus(batchId, "IN_PROGRESS", 25, 12);
        BatchProcessingService.BatchProcessingStatus status3 = createBatchStatus(batchId, "COMPLETED", 25, 22);
        status3.setFailedItems(3);
        
        when(batchProcessingService.getBatchStatus(batchId))
                .thenReturn(status1)
                .thenReturn(status2)
                .thenReturn(status3);
    }

    private BatchProcessingService.BatchProcessingStatus createBatchStatus(String batchId, String status, 
                                                                           int total, int completed) {
        BatchProcessingService.BatchProcessingStatus batchStatus = new BatchProcessingService.BatchProcessingStatus();
        batchStatus.setBatchId(batchId);
        batchStatus.setStatus(status);
        batchStatus.setTotalItems(total);
        batchStatus.setCompletedItems(completed);
        batchStatus.setStartTime(LocalDateTime.now().minusMinutes(5));
        return batchStatus;
    }

    private String extractBatchId(MvcResult result) throws Exception {
        String responseBody = result.getResponse().getContentAsString();
        com.fasterxml.jackson.databind.JsonNode jsonNode = objectMapper.readTree(responseBody);
        return jsonNode.get("batchId").asText();
    }

    private EntityRecognitionApiRequest createResearchRequest() {
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("The BRCA1 gene mutation is associated with increased risk of breast and ovarian cancer in patients.");
        request.setEntityTypes("gene,disease");
        request.setConfidenceThreshold(0.8);
        request.setSessionId("research_workflow_001");
        request.setEnableOntologyMatching(true);
        return request;
    }

    private EntityRecognitionApiRequest createClinicalRequest() {
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Patient presents with diabetes mellitus type 2. Prescribed metformin 500mg twice daily for glucose control.");
        request.setEntityTypes("disease,drug");
        request.setConfidenceThreshold(0.7);
        request.setSessionId("clinical_workflow_001");
        request.setEnableOntologyMatching(true);
        return request;
    }

    private EntityRecognitionApiRequest createSimpleRequest() {
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Simple test for entity recognition workflow.");
        request.setSessionId("simple_workflow_001");
        return request;
    }

    private BatchEntityRecognitionRequest createResearchBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
                "BRCA1 mutations are linked to hereditary breast cancer.",
                "P53 tumor suppressor gene plays crucial role in cancer prevention.",
                "Oncogenes like MYC are frequently altered in malignancies.",
                "EGFR targeting therapy shows promise in lung cancer treatment.",
                "PTEN loss is associated with multiple cancer types."
        ));
        request.setEntityTypes("gene,disease,drug");
        request.setSessionId("research_batch_workflow");
        request.setEnableOntologyMatching(true);
        return request;
    }

    private BatchEntityRecognitionRequest createLargeBatchRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        
        // Create 25 sample texts for large scale processing
        List<String> texts = Arrays.asList(
                "Abstract 1: Gene expression analysis in cancer cells.",
                "Abstract 2: Drug resistance mechanisms in tumor biology.",
                "Abstract 3: Biomarker discovery for precision medicine.",
                "Abstract 4: Metabolic pathways in disease progression.",
                "Abstract 5: Therapeutic targets in neurological disorders."
                // ... would continue with 20 more abstracts in real scenario
        );
        
        // For test purposes, simulate 25 items
        request.setTexts(texts);
        request.setEntityTypes("gene,disease,drug,protein");
        request.setSessionId("large_scale_workflow");
        
        // Mock the batch result to return 25 items
        BatchProcessingService.BatchProcessingResult largeResult = new BatchProcessingService.BatchProcessingResult();
        largeResult.setBatchId("large_batch_001");
        largeResult.setTotalItems(25); // Simulate 25 items
        largeResult.setStartTime(LocalDateTime.now());
        largeResult.setProcessingFuture(CompletableFuture.completedFuture(null));
        
        when(batchProcessingService.processTextsAsync(any())).thenReturn(largeResult);
        
        return request;
    }
}