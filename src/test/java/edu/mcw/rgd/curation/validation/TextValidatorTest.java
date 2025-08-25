package edu.mcw.rgd.curation.validation;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import jakarta.validation.ConstraintValidatorContext;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for TextValidator.
 * Tests text validation logic including length, content, and security checks.
 */
@ExtendWith(MockitoExtension.class)
class TextValidatorTest {

    @Mock
    private ValidText validTextAnnotation;

    @Mock
    private ConstraintValidatorContext context;

    @Mock
    private ConstraintValidatorContext.ConstraintViolationBuilder violationBuilder;

    private TextValidator validator;

    @BeforeEach
    void setUp() {
        validator = new TextValidator();
        
        // Setup default annotation values
        when(validTextAnnotation.minLength()).thenReturn(1);
        when(validTextAnnotation.maxLength()).thenReturn(100000);
        when(validTextAnnotation.printableOnly()).thenReturn(false);
        when(validTextAnnotation.requireAlphabetic()).thenReturn(true);
        
        validator.initialize(validTextAnnotation);
        
        // Setup context mocking
        when(context.buildConstraintViolationWithTemplate(anyString())).thenReturn(violationBuilder);
    }

    // ================================
    // Valid Text Tests
    // ================================

    @Test
    void testIsValid_ValidText() {
        // Arrange
        String validText = "This is a valid text for entity recognition analysis.";

        // Act
        boolean result = validator.isValid(validText, context);

        // Assert
        assertTrue(result);
        verify(context, never()).disableDefaultConstraintViolation();
    }

    @Test
    void testIsValid_ValidMedicalText() {
        // Arrange
        String medicalText = "The patient was diagnosed with diabetes mellitus type 2 and prescribed metformin 500mg twice daily.";

        // Act
        boolean result = validator.isValid(medicalText, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ValidTextWithNumbers() {
        // Arrange
        String textWithNumbers = "Study involved 150 patients aged 45-65 years with BMI > 30 kg/m2.";

        // Act
        boolean result = validator.isValid(textWithNumbers, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ValidTextWithSpecialCharacters() {
        // Arrange
        String textWithSpecial = "Gene expression (p < 0.05) was measured using RT-PCR & Western blot.";

        // Act
        boolean result = validator.isValid(textWithSpecial, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Null and Empty Text Tests
    // ================================

    @Test
    void testIsValid_NullText() {
        // Act
        boolean result = validator.isValid(null, context);

        // Assert
        assertFalse(result);
    }

    @Test
    void testIsValid_EmptyText() {
        // Act
        boolean result = validator.isValid("", context);

        // Assert
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate(contains("length must be"));
    }

    @Test
    void testIsValid_WhitespaceOnlyText() {
        // Act
        boolean result = validator.isValid("   \t\n  ", context);

        // Assert
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate(contains("empty or contain only whitespace"));
    }

    // ================================
    // Length Validation Tests
    // ================================

    @Test
    void testIsValid_TextTooShort() {
        // Arrange
        when(validTextAnnotation.minLength()).thenReturn(10);
        validator.initialize(validTextAnnotation);
        
        String shortText = "Short";

        // Act
        boolean result = validator.isValid(shortText, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("length must be between"));
    }

    @Test
    void testIsValid_TextTooLong() {
        // Arrange
        when(validTextAnnotation.maxLength()).thenReturn(50);
        validator.initialize(validTextAnnotation);
        
        String longText = "This is a very long text that exceeds the maximum allowed length of fifty characters.";

        // Act
        boolean result = validator.isValid(longText, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("length must be between"));
    }

    @Test
    void testIsValid_TextAtMinLength() {
        // Arrange
        when(validTextAnnotation.minLength()).thenReturn(5);
        validator.initialize(validTextAnnotation);
        
        String text = "Hello";

        // Act
        boolean result = validator.isValid(text, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_TextAtMaxLength() {
        // Arrange
        when(validTextAnnotation.maxLength()).thenReturn(10);
        validator.initialize(validTextAnnotation);
        
        String text = "1234567890"; // Exactly 10 characters

        // Act
        boolean result = validator.isValid(text, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Alphabetic Content Tests
    // ================================

    @Test
    void testIsValid_NoAlphabeticContent() {
        // Arrange
        String numbersOnly = "12345 67890";

        // Act
        boolean result = validator.isValid(numbersOnly, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("alphabetic characters"));
    }

    @Test
    void testIsValid_NoAlphabeticRequired() {
        // Arrange
        when(validTextAnnotation.requireAlphabetic()).thenReturn(false);
        validator.initialize(validTextAnnotation);
        
        String numbersOnly = "12345 67890";

        // Act
        boolean result = validator.isValid(numbersOnly, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_MixedAlphaNumeric() {
        // Arrange
        String mixedText = "Patient123 has condition456";

        // Act
        boolean result = validator.isValid(mixedText, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Printable Characters Tests
    // ================================

    @Test
    void testIsValid_NonPrintableCharacters() {
        // Arrange
        when(validTextAnnotation.printableOnly()).thenReturn(true);
        validator.initialize(validTextAnnotation);
        
        String textWithNonPrintable = "Text with \u0001 control character";

        // Act
        boolean result = validator.isValid(textWithNonPrintable, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("non-printable characters"));
    }

    @Test
    void testIsValid_PrintableCharactersOnly() {
        // Arrange
        when(validTextAnnotation.printableOnly()).thenReturn(true);
        validator.initialize(validTextAnnotation);
        
        String printableText = "Text with normal characters and symbols !@#$%";

        // Act
        boolean result = validator.isValid(printableText, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_NonPrintableAllowed() {
        // Arrange
        when(validTextAnnotation.printableOnly()).thenReturn(false);
        validator.initialize(validTextAnnotation);
        
        String textWithNonPrintable = "Text with \u0001 control character";

        // Act
        boolean result = validator.isValid(textWithNonPrintable, context);

        // Assert
        assertTrue(result); // Non-printable allowed when printableOnly = false
    }

    // ================================
    // Excessive Whitespace Tests
    // ================================

    @Test
    void testIsValid_ExcessiveWhitespace() {
        // Arrange
        String textWithExcessiveSpaces = "Text with          many spaces";

        // Act
        boolean result = validator.isValid(textWithExcessiveSpaces, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("excessive whitespace"));
    }

    @Test
    void testIsValid_NormalWhitespace() {
        // Arrange
        String textWithNormalSpaces = "Text with normal spaces between words";

        // Act
        boolean result = validator.isValid(textWithNormalSpaces, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Security Pattern Tests
    // ================================

    @Test
    void testIsValid_SuspiciousScriptTag() {
        // Arrange
        String suspiciousText = "Text with <script>alert('xss')</script> content";

        // Act
        boolean result = validator.isValid(suspiciousText, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("unsafe content"));
    }

    @Test
    void testIsValid_SuspiciousJavaScript() {
        // Arrange
        String suspiciousText = "Text with javascript:alert(1) content";

        // Act
        boolean result = validator.isValid(suspiciousText, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("unsafe content"));
    }

    @Test
    void testIsValid_SuspiciousEval() {
        // Arrange
        String suspiciousText = "Code contains eval(userInput) function";

        // Act
        boolean result = validator.isValid(suspiciousText, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("unsafe content"));
    }

    @Test
    void testIsValid_HTMLEntities() {
        // Arrange
        String textWithEntities = "Text with &lt;gene&gt; and &amp; symbols";

        // Act
        boolean result = validator.isValid(textWithEntities, context);

        // Assert
        assertFalse(result); // HTML entities are considered suspicious
        verify(context).buildConstraintViolationWithTemplate(contains("unsafe content"));
    }

    @Test
    void testIsValid_MedicalTermsWithBrackets() {
        // Arrange
        String medicalText = "Gene expression was measured [95% CI: 1.2-3.4]";

        // Act
        boolean result = validator.isValid(medicalText, context);

        // Assert
        assertTrue(result); // Square brackets should be allowed for scientific notation
    }

    // ================================
    // Word and Line Count Tests
    // ================================

    @Test
    void testIsValid_TooManyWords() {
        // Arrange
        StringBuilder longText = new StringBuilder();
        for (int i = 0; i < 60000; i++) {
            longText.append("word ");
        }

        // Act
        boolean result = validator.isValid(longText.toString(), context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("too many words"));
    }

    @Test
    void testIsValid_TooManyLines() {
        // Arrange
        StringBuilder longText = new StringBuilder();
        for (int i = 0; i < 15000; i++) {
            longText.append("line ").append(i).append("\n");
        }

        // Act
        boolean result = validator.isValid(longText.toString(), context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("too many lines"));
    }

    @Test
    void testIsValid_ReasonableWordCount() {
        // Arrange
        StringBuilder text = new StringBuilder();
        for (int i = 0; i < 1000; i++) {
            text.append("word ");
        }

        // Act
        boolean result = validator.isValid(text.toString(), context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ReasonableLineCount() {
        // Arrange
        StringBuilder text = new StringBuilder();
        for (int i = 0; i < 100; i++) {
            text.append("Line ").append(i).append("\n");
        }

        // Act
        boolean result = validator.isValid(text.toString(), context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Edge Cases Tests
    // ================================

    @Test
    void testIsValid_SingleCharacter() {
        // Arrange
        String singleChar = "A";

        // Act
        boolean result = validator.isValid(singleChar, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_UnicodeCharacters() {
        // Arrange
        String unicodeText = "Text with unicode: α, β, γ, δ, ε";

        // Act
        boolean result = validator.isValid(unicodeText, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_MedicalAbbreviations() {
        // Arrange
        String medicalText = "Pt. had MI, dx w/ ECG & echo. Rx: ASA 81mg qd, ACE-I, β-blocker.";

        // Act
        boolean result = validator.isValid(medicalText, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ScientificNotation() {
        // Arrange
        String scientificText = "Concentration was 1.5×10^-6 M with p-value < 0.001";

        // Act
        boolean result = validator.isValid(scientificText, context);

        // Assert
        assertTrue(result);
    }
}