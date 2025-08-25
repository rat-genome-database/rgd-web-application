package edu.mcw.rgd.curation.dto;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for BatchEntityRecognitionRequest DTO.
 * Tests validation annotations, utility methods, and data integrity.
 */
class BatchEntityRecognitionRequestTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    // ================================
    // Constructor and Default Values Tests
    // ================================

    @Test
    void testDefaultConstructor() {
        // Act
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();

        // Assert
        assertEquals(0.5, request.getConfidenceThreshold());
        assertEquals(0.8, request.getFuzzyMatchThreshold());
        assertEquals(5, request.getMaxOntologyMatches());
        assertEquals(5, request.getMaxConcurrentRequests());
        assertTrue(request.isEnableOntologyMatching());
        assertFalse(request.isIncludeObsoleteTerms());
        assertTrue(request.isParallelProcessing());
    }

    // ================================
    // Valid Request Tests
    // ================================

    @Test
    void testValidRequest_BasicScenario() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testValidRequest_MinimalScenario() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList("Sample text"));

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testValidRequest_MaximumTexts() {
        // Arrange
        List<String> texts = new ArrayList<>();
        for (int i = 0; i < 100; i++) { // At maximum allowed
            texts.add("Text " + i);
        }
        
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(texts);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testValidRequest_MaxLengthText() {
        // Arrange
        String maxLengthText = "x".repeat(100000); // Exactly at limit
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(maxLengthText));

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    // ================================
    // Text Validation Tests
    // ================================

    @Test
    void testInvalidRequest_EmptyTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(new ArrayList<>());

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot be empty")));
    }

    @Test
    void testInvalidRequest_NullTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(null);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot be empty")));
    }

    @Test
    void testInvalidRequest_TooManyTexts() {
        // Arrange
        List<String> texts = new ArrayList<>();
        for (int i = 0; i < 101; i++) { // Exceeds maximum of 100
            texts.add("Text " + i);
        }
        
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(texts);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("Cannot process more than 100")));
    }

    @Test
    void testInvalidRequest_TextTooLong() {
        // Arrange
        String tooLongText = "x".repeat(100001); // Exceeds 100,000 character limit
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(tooLongText));

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 100,000")));
    }

    // ================================
    // Entity Types Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidEntityTypes() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setEntityTypes("gene,protein,disease");

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testInvalidRequest_EntityTypesTooLong() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setEntityTypes("x".repeat(201)); // Exceeds 200 character limit

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 200")));
    }

    @Test
    void testValidRequest_NullEntityTypes() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setEntityTypes(null);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty()); // Entity types are optional
    }

    // ================================
    // Domain Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidDomain() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setDomain("medical");

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testInvalidRequest_DomainTooLong() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setDomain("x".repeat(101)); // Exceeds 100 character limit

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 100")));
    }

    // ================================
    // Confidence Threshold Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidConfidenceThresholds() {
        double[] validThresholds = {0.0, 0.1, 0.5, 0.75, 1.0};
        
        for (double threshold : validThresholds) {
            BatchEntityRecognitionRequest request = createValidRequest();
            request.setConfidenceThreshold(threshold);

            Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);
            assertTrue(violations.isEmpty(), "Threshold " + threshold + " should be valid");
        }
    }

    @Test
    void testInvalidRequest_ConfidenceThresholdTooLow() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setConfidenceThreshold(-0.1);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    @Test
    void testInvalidRequest_ConfidenceThresholdTooHigh() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setConfidenceThreshold(1.1);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    // ================================
    // Session ID Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidSessionIds() {
        String[] validSessionIds = {
            "batch_001",
            "test-batch-123",
            "user.batch.2024.01.15",
            "a",
            "x".repeat(100) // At max length
        };
        
        for (String sessionId : validSessionIds) {
            BatchEntityRecognitionRequest request = createValidRequest();
            request.setSessionId(sessionId);

            Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);
            assertTrue(violations.isEmpty(), "Session ID '" + sessionId + "' should be valid");
        }
    }

    @Test
    void testInvalidRequest_SessionIdTooLong() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setSessionId("x".repeat(101)); // Exceeds 100 character limit

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 100")));
    }

    // ================================
    // Ontology Namespace Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidOntologyNamespace() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setOntologyNamespace("disease_ontology");

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testInvalidRequest_OntologyNamespaceTooLong() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setOntologyNamespace("x".repeat(51)); // Exceeds 50 character limit

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 50")));
    }

    // ================================
    // Fuzzy Threshold Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidFuzzyThresholds() {
        double[] validThresholds = {0.0, 0.5, 0.8, 1.0};
        
        for (double threshold : validThresholds) {
            BatchEntityRecognitionRequest request = createValidRequest();
            request.setFuzzyMatchThreshold(threshold);

            Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);
            assertTrue(violations.isEmpty(), "Fuzzy threshold " + threshold + " should be valid");
        }
    }

    @Test
    void testInvalidRequest_FuzzyThresholdTooLow() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setFuzzyMatchThreshold(-0.1);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    @Test
    void testInvalidRequest_FuzzyThresholdTooHigh() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setFuzzyMatchThreshold(1.1);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    // ================================
    // Utility Methods Tests
    // ================================

    @Test
    void testGetTotalTextLength() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList("Hello", "World", "Test"));

        // Act
        int totalLength = request.getTotalTextLength();

        // Assert
        assertEquals(13, totalLength); // "Hello" (5) + "World" (5) + "Test" (4) = 14
    }

    @Test
    void testGetTotalTextLength_EmptyTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(new ArrayList<>());

        // Act
        int totalLength = request.getTotalTextLength();

        // Assert
        assertEquals(0, totalLength);
    }

    @Test
    void testGetTotalTextLength_NullTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(null);

        // Act
        int totalLength = request.getTotalTextLength();

        // Assert
        assertEquals(0, totalLength);
    }

    @Test
    void testIsValid_ValidRequest() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();

        // Act
        boolean isValid = request.isValid();

        // Assert
        assertTrue(isValid);
    }

    @Test
    void testIsValid_NullTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(null);

        // Act
        boolean isValid = request.isValid();

        // Assert
        assertFalse(isValid);
    }

    @Test
    void testIsValid_EmptyTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(new ArrayList<>());

        // Act
        boolean isValid = request.isValid();

        // Assert
        assertFalse(isValid);
    }

    @Test
    void testIsValid_TextsWithNullElement() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList("Valid text", null, "Another valid text"));

        // Act
        boolean isValid = request.isValid();

        // Assert
        assertFalse(isValid);
    }

    @Test
    void testIsValid_TextsWithEmptyElement() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList("Valid text", "", "Another valid text"));

        // Act
        boolean isValid = request.isValid();

        // Assert
        assertFalse(isValid);
    }

    @Test
    void testIsValid_TextsWithWhitespaceOnlyElement() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList("Valid text", "   \t\n   ", "Another valid text"));

        // Act
        boolean isValid = request.isValid();

        // Assert
        assertFalse(isValid);
    }

    // ================================
    // ToString Method Tests
    // ================================

    @Test
    void testToString() {
        // Arrange
        BatchEntityRecognitionRequest request = createValidRequest();
        request.setEntityTypes("gene,protein");
        request.setDomain("genetics");
        request.setSessionId("test_batch");

        // Act
        String result = request.toString();

        // Assert
        assertNotNull(result);
        assertTrue(result.contains("textCount=3"));
        assertTrue(result.contains("entityTypes='gene,protein'"));
        assertTrue(result.contains("domain='genetics'"));
        assertTrue(result.contains("enableOntologyMatching=true"));
        assertTrue(result.contains("sessionId='test_batch'"));
    }

    @Test
    void testToString_NullTexts() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(null);

        // Act
        String result = request.toString();

        // Assert
        assertNotNull(result);
        assertTrue(result.contains("textCount=0"));
        assertTrue(result.contains("totalLength=0"));
    }

    @Test
    void testToString_NullValues() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList("Sample text"));
        request.setEntityTypes(null);
        request.setDomain(null);
        request.setSessionId(null);

        // Act
        String result = request.toString();

        // Assert
        assertNotNull(result);
        assertTrue(result.contains("entityTypes='null'"));
        assertTrue(result.contains("domain='null'"));
        assertTrue(result.contains("sessionId='null'"));
    }

    // ================================
    // Boundary Value Tests
    // ================================

    @Test
    void testBoundaryValues_AtLimits() {
        // Arrange
        List<String> texts = new ArrayList<>();
        for (int i = 0; i < 100; i++) { // At maximum texts
            texts.add("a"); // Single character, minimum valid length
        }
        
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(texts);
        request.setEntityTypes("x".repeat(200)); // At max length
        request.setDomain("x".repeat(100)); // At max length
        request.setConfidenceThreshold(0.0); // At minimum
        request.setSessionId("x".repeat(100)); // At max length
        request.setOntologyNamespace("x".repeat(50)); // At max length
        request.setFuzzyMatchThreshold(1.0); // At maximum

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testBoundaryValues_JustOverLimits() {
        // Arrange
        List<String> texts = new ArrayList<>();
        for (int i = 0; i < 101; i++) { // Just over max texts
            texts.add("text");
        }
        
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(texts);

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("Cannot process more than 100")));
    }

    // ================================
    // Multiple Validation Errors Tests
    // ================================

    @Test
    void testMultipleValidationErrors() {
        // Arrange
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(new ArrayList<>()); // Invalid - empty
        request.setEntityTypes("x".repeat(201)); // Invalid - too long
        request.setDomain("x".repeat(101)); // Invalid - too long
        request.setConfidenceThreshold(1.5); // Invalid - too high
        request.setSessionId("x".repeat(101)); // Invalid - too long
        request.setOntologyNamespace("x".repeat(51)); // Invalid - too long
        request.setFuzzyMatchThreshold(-0.1); // Invalid - too low

        // Act
        Set<ConstraintViolation<BatchEntityRecognitionRequest>> violations = validator.validate(request);

        // Assert
        assertEquals(7, violations.size()); // Should have 7 validation errors
    }

    // ================================
    // Helper Methods
    // ================================

    private BatchEntityRecognitionRequest createValidRequest() {
        BatchEntityRecognitionRequest request = new BatchEntityRecognitionRequest();
        request.setTexts(Arrays.asList(
            "Patient has diabetes and takes insulin.",
            "Hypertension was treated with ACE inhibitors.",
            "The study examined BRCA1 mutations."
        ));
        return request;
    }
}