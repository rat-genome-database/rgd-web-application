package edu.mcw.rgd.entityTagger.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.regex.Pattern;

/**
 * Validator implementation for @ValidText annotation.
 * Validates text input for entity recognition processing.
 */
public class TextValidator implements ConstraintValidator<ValidText, String> {

    private static final Pattern PRINTABLE_PATTERN = Pattern.compile("^[\\p{Print}\\s]*$");
    private static final Pattern ALPHABETIC_PATTERN = Pattern.compile(".*[\\p{L}]+.*");
    private static final Pattern EXCESSIVE_WHITESPACE_PATTERN = Pattern.compile("\\s{10,}");
    private static final Pattern SUSPICIOUS_PATTERNS = Pattern.compile(
        "(?i)(script|javascript|<|>|&lt;|&gt;|eval\\(|alert\\()"
    );

    private int minLength;
    private int maxLength;
    private boolean printableOnly;
    private boolean requireAlphabetic;

    @Override
    public void initialize(ValidText constraintAnnotation) {
        this.minLength = constraintAnnotation.minLength();
        this.maxLength = constraintAnnotation.maxLength();
        this.printableOnly = constraintAnnotation.printableOnly();
        this.requireAlphabetic = constraintAnnotation.requireAlphabetic();
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return false;
        }

        // Check length constraints
        if (value.length() < minLength || value.length() > maxLength) {
            setCustomMessage(context, String.format("Text length must be between %d and %d characters", 
                    minLength, maxLength));
            return false;
        }

        // Check for empty or whitespace-only content
        String trimmed = value.trim();
        if (trimmed.isEmpty()) {
            setCustomMessage(context, "Text cannot be empty or contain only whitespace");
            return false;
        }

        // Check for printable characters only
        if (printableOnly && !PRINTABLE_PATTERN.matcher(value).matches()) {
            setCustomMessage(context, "Text contains non-printable characters");
            return false;
        }

        // Check for alphabetic content requirement
        if (requireAlphabetic && !ALPHABETIC_PATTERN.matcher(value).matches()) {
            setCustomMessage(context, "Text must contain some alphabetic characters");
            return false;
        }

        // Check for excessive whitespace
        if (EXCESSIVE_WHITESPACE_PATTERN.matcher(value).find()) {
            setCustomMessage(context, "Text contains excessive whitespace");
            return false;
        }

        // Check for suspicious patterns that might indicate security issues
        if (SUSPICIOUS_PATTERNS.matcher(value).find()) {
            setCustomMessage(context, "Text contains potentially unsafe content");
            return false;
        }

        // Check for reasonable word count (prevent extremely dense text)
        String[] words = trimmed.split("\\s+");
        if (words.length > 50000) {
            setCustomMessage(context, "Text contains too many words (maximum 50,000)");
            return false;
        }

        // Check for reasonable line count
        String[] lines = value.split("\\r?\\n");
        if (lines.length > 10000) {
            setCustomMessage(context, "Text contains too many lines (maximum 10,000)");
            return false;
        }

        return true;
    }

    private void setCustomMessage(ConstraintValidatorContext context, String message) {
        context.disableDefaultConstraintViolation();
        context.buildConstraintViolationWithTemplate(message).addConstraintViolation();
    }
}