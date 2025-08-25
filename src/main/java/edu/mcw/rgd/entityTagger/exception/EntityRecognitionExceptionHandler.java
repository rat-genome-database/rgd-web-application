package edu.mcw.rgd.entityTagger.exception;

import edu.mcw.rgd.entityTagger.dto.EntityRecognitionApiResponse;
import edu.mcw.rgd.entityTagger.dto.BatchEntityRecognitionResponse;
import edu.mcw.rgd.entityTagger.dto.OntologyMatchingResponse;
import edu.mcw.rgd.entityTagger.dto.ServiceStatusResponse;
import edu.mcw.rgd.entityTagger.util.CurationLogger;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeoutException;

/**
 * Global exception handler for entity recognition API endpoints.
 * Provides consistent error responses and proper HTTP status codes.
 */
@RestControllerAdvice(basePackages = "edu.mcw.rgd.entityTagger.controller")
public class EntityRecognitionExceptionHandler {

    /**
     * Handle validation errors from @Valid annotations
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleValidationErrors(
            MethodArgumentNotValidException ex) {
        
        CurationLogger.warn("Validation error: {}", ex.getMessage());
        
        List<String> errors = new ArrayList<>();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            errors.add(String.format("%s: %s", error.getField(), error.getDefaultMessage()));
        }
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "Validation failed: " + String.join(", ", errors), "VALIDATION_ERROR");
        
        return ResponseEntity.badRequest().body(response);
    }

    /**
     * Handle bind exceptions
     */
    @ExceptionHandler(BindException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleBindException(BindException ex) {
        CurationLogger.warn("Bind error: {}", ex.getMessage());
        
        List<String> errors = new ArrayList<>();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            errors.add(String.format("%s: %s", error.getField(), error.getDefaultMessage()));
        }
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "Invalid request parameters: " + String.join(", ", errors), "BIND_ERROR");
        
        return ResponseEntity.badRequest().body(response);
    }

    /**
     * Handle constraint violations
     */
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleConstraintViolation(
            ConstraintViolationException ex) {
        
        CurationLogger.warn("Constraint violation: {}", ex.getMessage());
        
        List<String> errors = new ArrayList<>();
        Set<ConstraintViolation<?>> violations = ex.getConstraintViolations();
        for (ConstraintViolation<?> violation : violations) {
            errors.add(violation.getPropertyPath() + ": " + violation.getMessage());
        }
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "Constraint violations: " + String.join(", ", errors), "CONSTRAINT_ERROR");
        
        return ResponseEntity.badRequest().body(response);
    }

    /**
     * Handle method argument type mismatch
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleTypeMismatch(
            MethodArgumentTypeMismatchException ex) {
        
        CurationLogger.warn("Type mismatch error: {}", ex.getMessage());
        
        String error = String.format("Invalid value '%s' for parameter '%s'. Expected type: %s",
                ex.getValue(), ex.getName(), 
                ex.getRequiredType() != null ? ex.getRequiredType().getSimpleName() : "unknown");
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(error, "TYPE_MISMATCH");
        
        return ResponseEntity.badRequest().body(response);
    }

    /**
     * Handle malformed JSON requests
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleMalformedJson(
            HttpMessageNotReadableException ex) {
        
        CurationLogger.warn("Malformed JSON request: {}", ex.getMessage());
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "Malformed JSON request body", "MALFORMED_JSON");
        
        return ResponseEntity.badRequest().body(response);
    }

    /**
     * Handle file upload size exceeded
     */
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleMaxSizeException(
            MaxUploadSizeExceededException ex) {
        
        CurationLogger.warn("File size exceeded: {}", ex.getMessage());
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "File size exceeds maximum allowed size", "FILE_SIZE_EXCEEDED");
        
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE).body(response);
    }

    /**
     * Handle PDF processing exceptions
     */
    @ExceptionHandler(PdfProcessingException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handlePdfProcessingException(
            PdfProcessingException ex) {
        
        CurationLogger.error("PDF processing error: {}", ex.getMessage(), ex);
        
        HttpStatus status = mapErrorCodeToHttpStatus(ex.getErrorCode());
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                ex.getMessage(), ex.getErrorCode().getCode());
        
        return ResponseEntity.status(status).body(response);
    }

    /**
     * Handle timeout exceptions
     */
    @ExceptionHandler(TimeoutException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleTimeoutException(
            TimeoutException ex) {
        
        CurationLogger.error("Request timeout: {}", ex.getMessage(), ex);
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "Request timed out. Please try again with a smaller text or check service status.", 
                "TIMEOUT");
        
        return ResponseEntity.status(HttpStatus.REQUEST_TIMEOUT).body(response);
    }

    /**
     * Handle service unavailable scenarios
     */
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleServiceUnavailable(
            IllegalStateException ex) {
        
        CurationLogger.error("Service unavailable: {}", ex.getMessage(), ex);
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "Service temporarily unavailable: " + ex.getMessage(), 
                "SERVICE_UNAVAILABLE");
        
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    /**
     * Handle general runtime exceptions
     */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleRuntimeException(
            RuntimeException ex) {
        
        CurationLogger.error("Runtime exception: {}", ex.getMessage(), ex);
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "An unexpected error occurred. Please try again later.", 
                "INTERNAL_ERROR");
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    /**
     * Handle all other exceptions
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<EntityRecognitionApiResponse> handleGenericException(Exception ex) {
        CurationLogger.error("Unexpected exception: {}", ex.getMessage(), ex);
        
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(
                "An unexpected error occurred. Please contact support if the problem persists.", 
                "UNKNOWN_ERROR");
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }


    /**
     * Create error response with additional debugging information
     */
    private EntityRecognitionApiResponse createDetailedErrorResponse(String message, 
                                                                   String errorCode, 
                                                                   Exception ex) {
        EntityRecognitionApiResponse response = EntityRecognitionApiResponse.error(message, errorCode);
        response.setTimestamp(LocalDateTime.now());
        
        // Add debugging information in development mode
        if (isDevelopmentMode()) {
            List<String> warnings = new ArrayList<>();
            warnings.add("Exception type: " + ex.getClass().getSimpleName());
            if (ex.getCause() != null) {
                warnings.add("Caused by: " + ex.getCause().getClass().getSimpleName());
            }
            response.setWarnings(warnings);
        }
        
        return response;
    }

    /**
     * Map error codes to appropriate HTTP status codes
     */
    private HttpStatus mapErrorCodeToHttpStatus(PdfProcessingException.ErrorCode errorCode) {
        if (errorCode == null) {
            return HttpStatus.INTERNAL_SERVER_ERROR;
        }
        
        switch (errorCode) {
            case INVALID_INPUT:
            case FILE_FORMAT_ERROR:
                return HttpStatus.BAD_REQUEST;
            
            case FILE_NOT_FOUND:
                return HttpStatus.NOT_FOUND;
            
            case FILE_TOO_LARGE:
                return HttpStatus.PAYLOAD_TOO_LARGE;
            
            case TIMEOUT:
            case RATE_LIMIT_EXCEEDED:
                return HttpStatus.REQUEST_TIMEOUT;
            
            case QUEUE_FULL:
            case EXTERNAL_SERVICE_ERROR:
                return HttpStatus.SERVICE_UNAVAILABLE;
            
            case PROCESSING_ERROR:
            case PARSE_ERROR:
            case EXTRACTION_ERROR:
            default:
                return HttpStatus.INTERNAL_SERVER_ERROR;
        }
    }

    /**
     * Check if current request is a batch processing request
     */
    private boolean isBatchRequest() {
        // This would need to be implemented based on request context
        // For now, return false
        return false;
    }

    /**
     * Check if current request is an ontology matching request
     */
    private boolean isOntologyMatchingRequest() {
        // This would need to be implemented based on request context
        // For now, return false
        return false;
    }

    /**
     * Check if application is running in development mode
     */
    private boolean isDevelopmentMode() {
        // This could be configured via application properties
        return false;
    }

    /**
     * Create a validation error response
     */
    public static class ValidationErrorResponse {
        private final String message;
        private final String field;
        private final Object rejectedValue;
        private final String code;

        public ValidationErrorResponse(String message, String field, Object rejectedValue, String code) {
            this.message = message;
            this.field = field;
            this.rejectedValue = rejectedValue;
            this.code = code;
        }

        // Getters
        public String getMessage() { return message; }
        public String getField() { return field; }
        public Object getRejectedValue() { return rejectedValue; }
        public String getCode() { return code; }
    }
}