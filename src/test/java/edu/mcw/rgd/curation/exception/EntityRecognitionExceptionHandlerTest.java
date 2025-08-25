package edu.mcw.rgd.curation.exception;

import edu.mcw.rgd.curation.dto.EntityRecognitionApiResponse;
import edu.mcw.rgd.curation.dto.BatchEntityRecognitionResponse;
import edu.mcw.rgd.curation.dto.OntologyMatchingResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Path;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.TimeoutException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Comprehensive unit tests for EntityRecognitionExceptionHandler.
 * Tests all exception handling scenarios and response formatting.
 */
@ExtendWith(MockitoExtension.class)
class EntityRecognitionExceptionHandlerTest {

    @InjectMocks
    private EntityRecognitionExceptionHandler exceptionHandler;

    @Mock
    private MethodArgumentNotValidException methodArgumentNotValidException;

    @Mock
    private BindingResult bindingResult;

    @Mock
    private FieldError fieldError1;

    @Mock
    private FieldError fieldError2;

    @Mock
    private ConstraintViolation<?> constraintViolation1;

    @Mock
    private ConstraintViolation<?> constraintViolation2;

    @Mock
    private Path propertyPath1;

    @Mock
    private Path propertyPath2;

    @BeforeEach
    void setUp() {
        // Setup common mocks
        when(methodArgumentNotValidException.getBindingResult()).thenReturn(bindingResult);
    }

    // ================================
    // Validation Error Tests
    // ================================

    @Test
    void testHandleValidationErrors_SingleError() {
        // Arrange
        when(fieldError1.getField()).thenReturn("text");
        when(fieldError1.getDefaultMessage()).thenReturn("cannot be empty");
        when(bindingResult.getFieldErrors()).thenReturn(Arrays.asList(fieldError1));

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleValidationErrors(methodArgumentNotValidException);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("text: cannot be empty"));
        assertEquals("VALIDATION_ERROR", response.getBody().getErrorCode());
    }

    @Test
    void testHandleValidationErrors_MultipleErrors() {
        // Arrange
        when(fieldError1.getField()).thenReturn("text");
        when(fieldError1.getDefaultMessage()).thenReturn("cannot be empty");
        when(fieldError2.getField()).thenReturn("confidenceThreshold");
        when(fieldError2.getDefaultMessage()).thenReturn("must be between 0.0 and 1.0");
        when(bindingResult.getFieldErrors()).thenReturn(Arrays.asList(fieldError1, fieldError2));

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleValidationErrors(methodArgumentNotValidException);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("text: cannot be empty"));
        assertTrue(response.getBody().getError().contains("confidenceThreshold: must be between 0.0 and 1.0"));
        assertEquals("VALIDATION_ERROR", response.getBody().getErrorCode());
    }

    @Test
    void testHandleValidationErrors_EmptyErrors() {
        // Arrange
        when(bindingResult.getFieldErrors()).thenReturn(Arrays.asList());

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleValidationErrors(methodArgumentNotValidException);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("VALIDATION_ERROR", response.getBody().getErrorCode());
    }

    // ================================
    // Bind Exception Tests
    // ================================

    @Test
    void testHandleBindException() {
        // Arrange
        BindException bindException = mock(BindException.class);
        when(bindException.getBindingResult()).thenReturn(bindingResult);
        when(fieldError1.getField()).thenReturn("entityTypes");
        when(fieldError1.getDefaultMessage()).thenReturn("invalid format");
        when(bindingResult.getFieldErrors()).thenReturn(Arrays.asList(fieldError1));

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleBindException(bindException);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("entityTypes: invalid format"));
        assertEquals("BIND_ERROR", response.getBody().getErrorCode());
    }

    // ================================
    // Constraint Violation Tests
    // ================================

    @Test
    void testHandleConstraintViolation_SingleViolation() {
        // Arrange
        Set<ConstraintViolation<?>> violations = new HashSet<>();
        violations.add(constraintViolation1);
        
        when(constraintViolation1.getPropertyPath()).thenReturn(propertyPath1);
        when(propertyPath1.toString()).thenReturn("text");
        when(constraintViolation1.getMessage()).thenReturn("must not be blank");
        
        ConstraintViolationException exception = new ConstraintViolationException(
                "Constraint violations", violations);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleConstraintViolation(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("text: must not be blank"));
        assertEquals("CONSTRAINT_ERROR", response.getBody().getErrorCode());
    }

    @Test
    void testHandleConstraintViolation_MultipleViolations() {
        // Arrange
        Set<ConstraintViolation<?>> violations = new HashSet<>();
        violations.add(constraintViolation1);
        violations.add(constraintViolation2);
        
        when(constraintViolation1.getPropertyPath()).thenReturn(propertyPath1);
        when(propertyPath1.toString()).thenReturn("text");
        when(constraintViolation1.getMessage()).thenReturn("must not be blank");
        
        when(constraintViolation2.getPropertyPath()).thenReturn(propertyPath2);
        when(propertyPath2.toString()).thenReturn("confidenceThreshold");
        when(constraintViolation2.getMessage()).thenReturn("must be between 0 and 1");
        
        ConstraintViolationException exception = new ConstraintViolationException(
                "Constraint violations", violations);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleConstraintViolation(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("Constraint violations:"));
        assertEquals("CONSTRAINT_ERROR", response.getBody().getErrorCode());
    }

    // ================================
    // Type Mismatch Tests
    // ================================

    @Test
    void testHandleTypeMismatch() {
        // Arrange
        MethodArgumentTypeMismatchException exception = mock(MethodArgumentTypeMismatchException.class);
        when(exception.getValue()).thenReturn("invalid_number");
        when(exception.getName()).thenReturn("confidenceThreshold");
        when(exception.getRequiredType()).thenReturn((Class) Double.class);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleTypeMismatch(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("Invalid value 'invalid_number'"));
        assertTrue(response.getBody().getError().contains("Expected type: Double"));
        assertEquals("TYPE_MISMATCH", response.getBody().getErrorCode());
    }

    @Test
    void testHandleTypeMismatch_NullRequiredType() {
        // Arrange
        MethodArgumentTypeMismatchException exception = mock(MethodArgumentTypeMismatchException.class);
        when(exception.getValue()).thenReturn("invalid_value");
        when(exception.getName()).thenReturn("parameter");
        when(exception.getRequiredType()).thenReturn(null);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleTypeMismatch(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().getError().contains("Expected type: unknown"));
        assertEquals("TYPE_MISMATCH", response.getBody().getErrorCode());
    }

    // ================================
    // Malformed JSON Tests
    // ================================

    @Test
    void testHandleMalformedJson() {
        // Arrange
        HttpMessageNotReadableException exception = mock(HttpMessageNotReadableException.class);
        when(exception.getMessage()).thenReturn("JSON parse error");

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleMalformedJson(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("Malformed JSON request body", response.getBody().getError());
        assertEquals("MALFORMED_JSON", response.getBody().getErrorCode());
    }

    // ================================
    // File Upload Size Tests
    // ================================

    @Test
    void testHandleMaxSizeException() {
        // Arrange
        MaxUploadSizeExceededException exception = new MaxUploadSizeExceededException(1000000L);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleMaxSizeException(exception);

        // Assert
        assertEquals(HttpStatus.PAYLOAD_TOO_LARGE, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("File size exceeds maximum allowed size", response.getBody().getError());
        assertEquals("FILE_SIZE_EXCEEDED", response.getBody().getErrorCode());
    }

    // ================================
    // PDF Processing Exception Tests
    // ================================

    @Test
    void testHandlePdfProcessingException_InvalidInput() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException(
                "Invalid input provided", PdfProcessingException.ErrorCode.INVALID_INPUT);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handlePdfProcessingException(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("Invalid input provided", response.getBody().getError());
        assertEquals("INVALID_INPUT", response.getBody().getErrorCode());
    }

    @Test
    void testHandlePdfProcessingException_FileNotFound() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException(
                "File not found", PdfProcessingException.ErrorCode.FILE_NOT_FOUND);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handlePdfProcessingException(exception);

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("File not found", response.getBody().getError());
        assertEquals("FILE_NOT_FOUND", response.getBody().getErrorCode());
    }

    @Test
    void testHandlePdfProcessingException_FileTooLarge() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException(
                "File too large", PdfProcessingException.ErrorCode.FILE_TOO_LARGE);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handlePdfProcessingException(exception);

        // Assert
        assertEquals(HttpStatus.PAYLOAD_TOO_LARGE, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("File too large", response.getBody().getError());
        assertEquals("FILE_TOO_LARGE", response.getBody().getErrorCode());
    }

    @Test
    void testHandlePdfProcessingException_ServiceUnavailable() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException(
                "External service error", PdfProcessingException.ErrorCode.EXTERNAL_SERVICE_ERROR);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handlePdfProcessingException(exception);

        // Assert
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("External service error", response.getBody().getError());
        assertEquals("EXTERNAL_SERVICE_ERROR", response.getBody().getErrorCode());
    }

    @Test
    void testHandlePdfProcessingException_NullErrorCode() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException("Error without code", null);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handlePdfProcessingException(exception);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("Error without code", response.getBody().getError());
    }

    // ================================
    // Timeout Exception Tests
    // ================================

    @Test
    void testHandleTimeoutException() {
        // Arrange
        TimeoutException exception = new TimeoutException("Operation timed out");

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleTimeoutException(exception);

        // Assert
        assertEquals(HttpStatus.REQUEST_TIMEOUT, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("Request timed out"));
        assertEquals("TIMEOUT", response.getBody().getErrorCode());
    }

    // ================================
    // Service Unavailable Tests
    // ================================

    @Test
    void testHandleServiceUnavailable() {
        // Arrange
        IllegalStateException exception = new IllegalStateException("Service is down");

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleServiceUnavailable(exception);

        // Assert
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("Service temporarily unavailable"));
        assertTrue(response.getBody().getError().contains("Service is down"));
        assertEquals("SERVICE_UNAVAILABLE", response.getBody().getErrorCode());
    }

    // ================================
    // Runtime Exception Tests
    // ================================

    @Test
    void testHandleRuntimeException() {
        // Arrange
        RuntimeException exception = new RuntimeException("Unexpected runtime error");

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleRuntimeException(exception);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertEquals("An unexpected error occurred. Please try again later.", 
                response.getBody().getError());
        assertEquals("INTERNAL_ERROR", response.getBody().getErrorCode());
    }

    // ================================
    // Generic Exception Tests
    // ================================

    @Test
    void testHandleGenericException() {
        // Arrange
        Exception exception = new Exception("Generic error");

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleGenericException(exception);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody().isSuccess());
        assertTrue(response.getBody().getError().contains("unexpected error occurred"));
        assertTrue(response.getBody().getError().contains("contact support"));
        assertEquals("UNKNOWN_ERROR", response.getBody().getErrorCode());
    }

    // ================================
    // Batch Processing Exception Tests
    // ================================

    @Test
    void testHandleBatchProcessingException_NotBatchRequest() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException(
                "Batch error", PdfProcessingException.ErrorCode.PROCESSING_ERROR);

        // Act
        ResponseEntity<BatchEntityRecognitionResponse> response = 
                exceptionHandler.handleBatchProcessingException(exception);

        // Assert
        assertNull(response); // Should return null for non-batch requests
    }

    // ================================
    // Ontology Matching Exception Tests
    // ================================

    @Test
    void testHandleOntologyMatchingException_NotOntologyRequest() {
        // Arrange
        PdfProcessingException exception = new PdfProcessingException(
                "Ontology error", PdfProcessingException.ErrorCode.PROCESSING_ERROR);

        // Act
        ResponseEntity<OntologyMatchingResponse> response = 
                exceptionHandler.handleOntologyMatchingException(exception);

        // Assert
        assertNull(response); // Should return null for non-ontology requests
    }

    // ================================
    // Validation Error Response Tests
    // ================================

    @Test
    void testValidationErrorResponse_Construction() {
        // Arrange & Act
        EntityRecognitionExceptionHandler.ValidationErrorResponse response = 
                new EntityRecognitionExceptionHandler.ValidationErrorResponse(
                        "Field is required", "fieldName", "invalidValue", "REQUIRED");

        // Assert
        assertEquals("Field is required", response.getMessage());
        assertEquals("fieldName", response.getField());
        assertEquals("invalidValue", response.getRejectedValue());
        assertEquals("REQUIRED", response.getCode());
    }

    @Test
    void testValidationErrorResponse_NullValues() {
        // Arrange & Act
        EntityRecognitionExceptionHandler.ValidationErrorResponse response = 
                new EntityRecognitionExceptionHandler.ValidationErrorResponse(
                        null, null, null, null);

        // Assert
        assertNull(response.getMessage());
        assertNull(response.getField());
        assertNull(response.getRejectedValue());
        assertNull(response.getCode());
    }

    // ================================
    // Error Code Mapping Tests
    // ================================

    @Test
    void testErrorCodeMapping_AllErrorCodes() {
        // Test each error code mapping by creating exceptions and checking status codes
        
        // BAD_REQUEST cases
        testErrorCodeMapping(PdfProcessingException.ErrorCode.INVALID_INPUT, HttpStatus.BAD_REQUEST);
        testErrorCodeMapping(PdfProcessingException.ErrorCode.FILE_FORMAT_ERROR, HttpStatus.BAD_REQUEST);
        
        // NOT_FOUND cases
        testErrorCodeMapping(PdfProcessingException.ErrorCode.FILE_NOT_FOUND, HttpStatus.NOT_FOUND);
        
        // PAYLOAD_TOO_LARGE cases
        testErrorCodeMapping(PdfProcessingException.ErrorCode.FILE_TOO_LARGE, HttpStatus.PAYLOAD_TOO_LARGE);
        
        // REQUEST_TIMEOUT cases
        testErrorCodeMapping(PdfProcessingException.ErrorCode.TIMEOUT, HttpStatus.REQUEST_TIMEOUT);
        testErrorCodeMapping(PdfProcessingException.ErrorCode.RATE_LIMIT_EXCEEDED, HttpStatus.REQUEST_TIMEOUT);
        
        // SERVICE_UNAVAILABLE cases
        testErrorCodeMapping(PdfProcessingException.ErrorCode.QUEUE_FULL, HttpStatus.SERVICE_UNAVAILABLE);
        testErrorCodeMapping(PdfProcessingException.ErrorCode.EXTERNAL_SERVICE_ERROR, HttpStatus.SERVICE_UNAVAILABLE);
        
        // INTERNAL_SERVER_ERROR cases
        testErrorCodeMapping(PdfProcessingException.ErrorCode.PROCESSING_ERROR, HttpStatus.INTERNAL_SERVER_ERROR);
        testErrorCodeMapping(PdfProcessingException.ErrorCode.PARSE_ERROR, HttpStatus.INTERNAL_SERVER_ERROR);
        testErrorCodeMapping(PdfProcessingException.ErrorCode.EXTRACTION_ERROR, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    private void testErrorCodeMapping(PdfProcessingException.ErrorCode errorCode, HttpStatus expectedStatus) {
        PdfProcessingException exception = new PdfProcessingException("Test error", errorCode);
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handlePdfProcessingException(exception);
        assertEquals(expectedStatus, response.getStatusCode(), 
                "Error code " + errorCode + " should map to " + expectedStatus);
    }

    // ================================
    // Edge Cases Tests
    // ================================

    @Test
    void testHandleValidationErrors_NullBindingResult() {
        // Arrange
        when(methodArgumentNotValidException.getBindingResult()).thenReturn(null);

        // Act & Assert
        assertThrows(NullPointerException.class, () -> {
            exceptionHandler.handleValidationErrors(methodArgumentNotValidException);
        });
    }

    @Test
    void testConstraintViolation_EmptyViolations() {
        // Arrange
        Set<ConstraintViolation<?>> emptyViolations = new HashSet<>();
        ConstraintViolationException exception = new ConstraintViolationException(
                "No violations", emptyViolations);

        // Act
        ResponseEntity<EntityRecognitionApiResponse> response = 
                exceptionHandler.handleConstraintViolation(exception);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().getError().contains("Constraint violations: "));
        assertEquals("CONSTRAINT_ERROR", response.getBody().getErrorCode());
    }
}