package edu.mcw.rgd.entityTagger.exception;

/**
 * Exception thrown when PDF processing operations fail
 */
public class PdfProcessingException extends Exception {
    
    private ErrorCode errorCode;
    
    public PdfProcessingException(String message) {
        super(message);
    }
    
    public PdfProcessingException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public PdfProcessingException(String message, ErrorCode errorCode) {
        super(message);
        this.errorCode = errorCode;
    }
    
    public ErrorCode getErrorCode() {
        return errorCode;
    }
    
    public String getUserMessage() {
        return getMessage();
    }
    
    /**
     * Enum defining specific PDF processing error codes
     */
    public enum ErrorCode {
        FILE_NOT_FOUND("FILE_NOT_FOUND"),
        INVALID_FORMAT("INVALID_FORMAT"),
        CORRUPTED_FILE("CORRUPTED_FILE"),
        PERMISSION_DENIED("PERMISSION_DENIED"),
        PROCESSING_TIMEOUT("PROCESSING_TIMEOUT"),
        EXTRACTION_FAILED("EXTRACTION_FAILED"),
        UNKNOWN_ERROR("UNKNOWN_ERROR"),
        INVALID_INPUT("INVALID_INPUT"),
        FILE_FORMAT_ERROR("FILE_FORMAT_ERROR"),
        FILE_TOO_LARGE("FILE_TOO_LARGE"),
        TIMEOUT("TIMEOUT"),
        RATE_LIMIT_EXCEEDED("RATE_LIMIT_EXCEEDED"),
        QUEUE_FULL("QUEUE_FULL"),
        EXTERNAL_SERVICE_ERROR("EXTERNAL_SERVICE_ERROR"),
        PROCESSING_ERROR("PROCESSING_ERROR"),
        PARSE_ERROR("PARSE_ERROR"),
        EXTRACTION_ERROR("EXTRACTION_ERROR");
        
        private final String code;
        
        ErrorCode(String code) {
            this.code = code;
        }
        
        public String getCode() {
            return code;
        }
    }
}