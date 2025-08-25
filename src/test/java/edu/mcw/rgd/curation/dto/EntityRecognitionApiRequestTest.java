package edu.mcw.rgd.curation.dto;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for EntityRecognitionApiRequest DTO.
 * Tests validation annotations and data integrity.
 */
class EntityRecognitionApiRequestTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    // ================================
    // Valid Request Tests
    // ================================

    @Test
    void testValidRequest_BasicScenario() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("The patient was diagnosed with diabetes mellitus.");
        request.setSessionId("test_session");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testValidRequest_CompleteScenario() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("The BRCA1 gene mutation increases breast cancer risk in patients.");
        request.setEntityTypes("gene,disease");
        request.setDomain("oncology");
        request.setConfidenceThreshold(0.8);
        request.setSessionId("oncology_test_001");
        request.setEnableOntologyMatching(true);
        request.setOntologyNamespace("disease_ontology");
        request.setFuzzyMatchThreshold(0.9);
        request.setMaxOntologyMatches(3);
        request.setIncludeObsoleteTerms(false);
        request.setEnableDeepAnalysis(true);

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testValidRequest_MinimalScenario() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("A"); // Minimal valid text

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    // ================================
    // Text Validation Tests
    // ================================

    @Test
    void testInvalidRequest_EmptyText() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("");
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot be empty")));
    }

    @Test
    void testInvalidRequest_NullText() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText(null);
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot be empty")));
    }

    @Test
    void testInvalidRequest_WhitespaceOnlyText() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("   \t\n  ");
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot be empty")));
    }

    @Test
    void testInvalidRequest_TextTooLong() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("x".repeat(100001)); // Exceeds 100,000 character limit
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 100,000")));
    }

    @Test
    void testValidRequest_TextAtMaxLength() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("x".repeat(100000)); // Exactly 100,000 characters
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    // ================================
    // Entity Types Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidEntityTypes() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setEntityTypes("gene,protein,disease");
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testInvalidRequest_EntityTypesTooLong() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setEntityTypes("x".repeat(201)); // Exceeds 200 character limit
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 200")));
    }

    @Test
    void testValidRequest_NullEntityTypes() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setEntityTypes(null);
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty()); // Entity types are optional
    }

    // ================================
    // Domain Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidDomain() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setDomain("cardiology");
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testInvalidRequest_DomainTooLong() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setDomain("x".repeat(101)); // Exceeds 100 character limit
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 100")));
    }

    // ================================
    // Confidence Threshold Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidConfidenceThresholds() {
        // Test various valid confidence thresholds
        double[] validThresholds = {0.0, 0.1, 0.5, 0.75, 1.0};
        
        for (double threshold : validThresholds) {
            EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
            request.setText("Sample text for testing.");
            request.setConfidenceThreshold(threshold);
            request.setSessionId("test");

            Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);
            assertTrue(violations.isEmpty(), "Threshold " + threshold + " should be valid");
        }
    }

    @Test
    void testInvalidRequest_ConfidenceThresholdTooLow() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setConfidenceThreshold(-0.1);
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    @Test
    void testInvalidRequest_ConfidenceThresholdTooHigh() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setConfidenceThreshold(1.1);
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

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
            "session_001",
            "test-session-123",
            "user.session.2024.01.15",
            "a",
            "x".repeat(100) // At max length
        };
        
        for (String sessionId : validSessionIds) {
            EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
            request.setText("Sample text for testing.");
            request.setSessionId(sessionId);

            Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);
            assertTrue(violations.isEmpty(), "Session ID '" + sessionId + "' should be valid");
        }
    }

    @Test
    void testInvalidRequest_SessionIdTooLong() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setSessionId("x".repeat(101)); // Exceeds 100 character limit

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("cannot exceed 100")));
    }

    @Test
    void testValidRequest_NullSessionId() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setSessionId(null);

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty()); // Session ID is optional
    }

    // ================================
    // Fuzzy Threshold Validation Tests
    // ================================

    @Test
    void testValidRequest_ValidFuzzyThresholds() {
        double[] validThresholds = {0.0, 0.5, 0.8, 1.0};
        
        for (double threshold : validThresholds) {
            EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
            request.setText("Sample text for testing.");
            request.setFuzzyMatchThreshold(threshold);
            request.setSessionId("test");

            Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);
            assertTrue(violations.isEmpty(), "Fuzzy threshold " + threshold + " should be valid");
        }
    }

    @Test
    void testInvalidRequest_FuzzyThresholdTooLow() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setFuzzyMatchThreshold(-0.1);
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    @Test
    void testInvalidRequest_FuzzyThresholdTooHigh() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setFuzzyMatchThreshold(1.1);
        request.setSessionId("test");

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("between 0.0 and 1.0")));
    }

    // ================================
    // Default Values Tests
    // ================================

    @Test
    void testDefaultValues() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();

        // Assert
        assertEquals(0.5, request.getConfidenceThreshold());
        assertEquals(0.8, request.getFuzzyMatchThreshold());
        assertEquals(5, request.getMaxOntologyMatches());
        assertTrue(request.isEnableOntologyMatching());
        assertFalse(request.isIncludeObsoleteTerms());
        assertFalse(request.isEnableDeepAnalysis());
    }

    // ================================
    // ToString Method Tests
    // ================================

    @Test
    void testToString() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Sample text for testing.");
        request.setEntityTypes("gene,protein");
        request.setDomain("genetics");
        request.setConfidenceThreshold(0.8);
        request.setSessionId("test_session");
        request.setEnableOntologyMatching(true);

        // Act
        String result = request.toString();

        // Assert
        assertNotNull(result);
        assertTrue(result.contains("textLength=25"));
        assertTrue(result.contains("entityTypes='gene,protein'"));
        assertTrue(result.contains("domain='genetics'"));
        assertTrue(result.contains("confidenceThreshold=0.80"));
        assertTrue(result.contains("enableOntologyMatching=true"));
        assertTrue(result.contains("sessionId='test_session'"));
    }

    @Test
    void testToString_NullText() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText(null);
        request.setSessionId("test");

        // Act
        String result = request.toString();

        // Assert
        assertNotNull(result);
        assertTrue(result.contains("textLength=0"));
    }

    // ================================
    // Multiple Validation Errors Tests
    // ================================

    @Test
    void testMultipleValidationErrors() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText(""); // Invalid - empty
        request.setEntityTypes("x".repeat(201)); // Invalid - too long
        request.setDomain("x".repeat(101)); // Invalid - too long
        request.setConfidenceThreshold(1.5); // Invalid - too high
        request.setSessionId("x".repeat(101)); // Invalid - too long
        request.setFuzzyMatchThreshold(-0.1); // Invalid - too low

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertEquals(6, violations.size()); // Should have 6 validation errors
    }

    // ================================
    // Boundary Value Tests
    // ================================

    @Test
    void testBoundaryValues_AtLimits() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("A"); // Minimum valid length
        request.setEntityTypes("x".repeat(200)); // At max length
        request.setDomain("x".repeat(100)); // At max length
        request.setConfidenceThreshold(0.0); // At minimum
        request.setSessionId("x".repeat(100)); // At max length
        request.setFuzzyMatchThreshold(1.0); // At maximum

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertTrue(violations.isEmpty());
    }

    @Test
    void testBoundaryValues_JustOverLimits() {
        // Arrange
        EntityRecognitionApiRequest request = new EntityRecognitionApiRequest();
        request.setText("Valid text");
        request.setEntityTypes("x".repeat(201)); // Just over max
        request.setDomain("x".repeat(101)); // Just over max
        request.setSessionId("x".repeat(101)); // Just over max

        // Act
        Set<ConstraintViolation<EntityRecognitionApiRequest>> violations = validator.validate(request);

        // Assert
        assertEquals(3, violations.size()); // Should have 3 violations for the over-limit fields
    }
}