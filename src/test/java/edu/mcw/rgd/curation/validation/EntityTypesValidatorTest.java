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
 * Unit tests for EntityTypesValidator.
 * Tests entity type validation logic including format, known types, and custom types.
 */
@ExtendWith(MockitoExtension.class)
class EntityTypesValidatorTest {

    @Mock
    private ValidEntityTypes validEntityTypesAnnotation;

    @Mock
    private ConstraintValidatorContext context;

    @Mock
    private ConstraintValidatorContext.ConstraintViolationBuilder violationBuilder;

    private EntityTypesValidator validator;

    @BeforeEach
    void setUp() {
        validator = new EntityTypesValidator();
        
        // Setup default annotation values
        when(validEntityTypesAnnotation.maxTypes()).thenReturn(10);
        when(validEntityTypesAnnotation.allowCustomTypes()).thenReturn(true);
        
        validator.initialize(validEntityTypesAnnotation);
        
        // Setup context mocking
        when(context.buildConstraintViolationWithTemplate(anyString())).thenReturn(violationBuilder);
    }

    // ================================
    // Valid Entity Types Tests
    // ================================

    @Test
    void testIsValid_SingleValidType() {
        // Act
        boolean result = validator.isValid("gene", context);

        // Assert
        assertTrue(result);
        verify(context, never()).disableDefaultConstraintViolation();
    }

    @Test
    void testIsValid_MultipleValidTypes() {
        // Act
        boolean result = validator.isValid("gene,protein,disease", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_AllKnownTypes() {
        // Arrange
        String allTypes = "gene,protein,disease,phenotype,pathway,drug,chemical,organism,tissue,cell_type,cell_line,anatomy,development,biological_process,molecular_function,cellular_component,strain,allele,variant,qtl,marker,sequence";

        // Act
        boolean result = validator.isValid(allTypes, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_TypesWithSpaces() {
        // Act
        boolean result = validator.isValid("gene, protein, disease", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_TypesWithSemicolons() {
        // Act
        boolean result = validator.isValid("gene;protein;disease", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_TypesWithMixedSeparators() {
        // Act
        boolean result = validator.isValid("gene, protein; disease\tdrug", context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Null and Empty Tests
    // ================================

    @Test
    void testIsValid_NullValue() {
        // Act
        boolean result = validator.isValid(null, context);

        // Assert
        assertTrue(result); // Null is allowed (entity types are optional)
    }

    @Test
    void testIsValid_EmptyString() {
        // Act
        boolean result = validator.isValid("", context);

        // Assert
        assertTrue(result); // Empty string is allowed
    }

    @Test
    void testIsValid_WhitespaceOnly() {
        // Act
        boolean result = validator.isValid("   \t\n  ", context);

        // Assert
        assertTrue(result); // Whitespace-only is treated as empty
    }

    // ================================
    // Maximum Types Tests
    // ================================

    @Test
    void testIsValid_ExceedsMaxTypes() {
        // Arrange
        when(validEntityTypesAnnotation.maxTypes()).thenReturn(3);
        validator.initialize(validEntityTypesAnnotation);
        
        String tooManyTypes = "gene,protein,disease,phenotype";

        // Act
        boolean result = validator.isValid(tooManyTypes, context);

        // Assert
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate(contains("Maximum 3 entity types allowed"));
    }

    @Test
    void testIsValid_AtMaxTypes() {
        // Arrange
        when(validEntityTypesAnnotation.maxTypes()).thenReturn(3);
        validator.initialize(validEntityTypesAnnotation);
        
        String exactlyMaxTypes = "gene,protein,disease";

        // Act
        boolean result = validator.isValid(exactlyMaxTypes, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_UnderMaxTypes() {
        // Arrange
        when(validEntityTypesAnnotation.maxTypes()).thenReturn(5);
        validator.initialize(validEntityTypesAnnotation);
        
        String underMaxTypes = "gene,protein";

        // Act
        boolean result = validator.isValid(underMaxTypes, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Duplicate Types Tests
    // ================================

    @Test
    void testIsValid_DuplicateTypes() {
        // Act
        boolean result = validator.isValid("gene,protein,gene", context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("Duplicate entity type: gene"));
    }

    @Test
    void testIsValid_DuplicateTypesWithDifferentCase() {
        // Act
        boolean result = validator.isValid("gene,GENE", context);

        // Assert
        assertFalse(result); // Case-insensitive duplicate detection
        verify(context).buildConstraintViolationWithTemplate(contains("Duplicate entity type"));
    }

    @Test
    void testIsValid_DuplicateTypesWithSpaces() {
        // Act
        boolean result = validator.isValid("gene, gene ", context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("Duplicate entity type"));
    }

    // ================================
    // Format Validation Tests
    // ================================

    @Test
    void testIsValid_InvalidFormat_StartsWithNumber() {
        // Act
        boolean result = validator.isValid("1gene", context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("Invalid entity type format"));
    }

    @Test
    void testIsValid_InvalidFormat_SpecialCharacters() {
        // Act
        boolean result = validator.isValid("gene@protein", context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("Invalid entity type format"));
    }

    @Test
    void testIsValid_ValidFormat_WithHyphens() {
        // Act
        boolean result = validator.isValid("cell-type", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ValidFormat_WithUnderscores() {
        // Act
        boolean result = validator.isValid("cell_type", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ValidFormat_AlphaNumeric() {
        // Act
        boolean result = validator.isValid("gene123", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_ValidFormat_MixedCase() {
        // Act
        boolean result = validator.isValid("CellType", context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Length Validation Tests
    // ================================

    @Test
    void testIsValid_TypeTooLong() {
        // Arrange
        String longType = "a".repeat(51); // Exceeds 50 character limit

        // Act
        boolean result = validator.isValid(longType, context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("too long"));
    }

    @Test
    void testIsValid_TypeAtMaxLength() {
        // Arrange
        String maxLengthType = "a".repeat(50); // Exactly 50 characters

        // Act
        boolean result = validator.isValid(maxLengthType, context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_TypeUnderMaxLength() {
        // Arrange
        String normalLengthType = "biological_process"; // Well under 50 characters

        // Act
        boolean result = validator.isValid(normalLengthType, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Custom Types Tests
    // ================================

    @Test
    void testIsValid_CustomTypeAllowed() {
        // Arrange
        when(validEntityTypesAnnotation.allowCustomTypes()).thenReturn(true);
        validator.initialize(validEntityTypesAnnotation);

        // Act
        boolean result = validator.isValid("custom_type", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_CustomTypeNotAllowed() {
        // Arrange
        when(validEntityTypesAnnotation.allowCustomTypes()).thenReturn(false);
        validator.initialize(validEntityTypesAnnotation);

        // Act
        boolean result = validator.isValid("custom_type", context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("Unknown entity type"));
    }

    @Test
    void testIsValid_KnownTypeWhenCustomNotAllowed() {
        // Arrange
        when(validEntityTypesAnnotation.allowCustomTypes()).thenReturn(false);
        validator.initialize(validEntityTypesAnnotation);

        // Act
        boolean result = validator.isValid("gene", context);

        // Assert
        assertTrue(result); // Known types should still be allowed
    }

    @Test
    void testIsValid_MixedKnownAndCustomTypes() {
        // Arrange
        when(validEntityTypesAnnotation.allowCustomTypes()).thenReturn(true);
        validator.initialize(validEntityTypesAnnotation);

        // Act
        boolean result = validator.isValid("gene,custom_type,protein", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_MixedTypesCustomNotAllowed() {
        // Arrange
        when(validEntityTypesAnnotation.allowCustomTypes()).thenReturn(false);
        validator.initialize(validEntityTypesAnnotation);

        // Act
        boolean result = validator.isValid("gene,custom_type,protein", context);

        // Assert
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate(contains("Unknown entity type: custom_type"));
    }

    // ================================
    // Case Sensitivity Tests
    // ================================

    @Test
    void testIsValid_UpperCaseKnownType() {
        // Act
        boolean result = validator.isValid("GENE", context);

        // Assert
        assertTrue(result); // Should be case-insensitive
    }

    @Test
    void testIsValid_MixedCaseKnownType() {
        // Act
        boolean result = validator.isValid("Gene", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_CamelCaseKnownType() {
        // Act
        boolean result = validator.isValid("cellType", context);

        // Assert
        assertTrue(result); // cell_type exists, so cellType should match
    }

    // ================================
    // Edge Cases Tests
    // ================================

    @Test
    void testIsValid_EmptyTypeInList() {
        // Act
        boolean result = validator.isValid("gene,,protein", context);

        // Assert
        assertTrue(result); // Empty elements should be filtered out
    }

    @Test
    void testIsValid_WhitespaceTypeInList() {
        // Act
        boolean result = validator.isValid("gene,   ,protein", context);

        // Assert
        assertTrue(result); // Whitespace-only elements should be filtered out
    }

    @Test
    void testIsValid_TrailingSeparator() {
        // Act
        boolean result = validator.isValid("gene,protein,", context);

        // Assert
        assertTrue(result); // Trailing separator should be handled gracefully
    }

    @Test
    void testIsValid_LeadingSeparator() {
        // Act
        boolean result = validator.isValid(",gene,protein", context);

        // Assert
        assertTrue(result); // Leading separator should be handled gracefully
    }

    @Test
    void testIsValid_OnlySeparators() {
        // Act
        boolean result = validator.isValid(",,,", context);

        // Assert
        assertTrue(result); // Only separators should be treated as empty
    }

    // ================================
    // Known Types Coverage Tests
    // ================================

    @Test
    void testGetValidEntityTypes_ReturnsAllKnownTypes() {
        // Act
        var validTypes = EntityTypesValidator.getValidEntityTypes();

        // Assert
        assertNotNull(validTypes);
        assertTrue(validTypes.contains("gene"));
        assertTrue(validTypes.contains("protein"));
        assertTrue(validTypes.contains("disease"));
        assertTrue(validTypes.contains("phenotype"));
        assertTrue(validTypes.contains("pathway"));
        assertTrue(validTypes.contains("drug"));
        assertTrue(validTypes.contains("chemical"));
        assertTrue(validTypes.contains("organism"));
        assertTrue(validTypes.contains("tissue"));
        assertTrue(validTypes.contains("cell_type"));
        assertTrue(validTypes.contains("cell_line"));
        assertTrue(validTypes.contains("anatomy"));
        assertTrue(validTypes.contains("development"));
        assertTrue(validTypes.contains("biological_process"));
        assertTrue(validTypes.contains("molecular_function"));
        assertTrue(validTypes.contains("cellular_component"));
        assertTrue(validTypes.contains("strain"));
        assertTrue(validTypes.contains("allele"));
        assertTrue(validTypes.contains("variant"));
        assertTrue(validTypes.contains("qtl"));
        assertTrue(validTypes.contains("marker"));
        assertTrue(validTypes.contains("sequence"));
    }

    @Test
    void testIsValid_AllValidTypesFromStaticMethod() {
        // Arrange
        var validTypes = EntityTypesValidator.getValidEntityTypes();
        String allValidTypes = String.join(",", validTypes);

        // Act
        boolean result = validator.isValid(allValidTypes, context);

        // Assert
        assertTrue(result);
    }

    // ================================
    // Real-world Scenarios Tests
    // ================================

    @Test
    void testIsValid_CommonBiologicalTypes() {
        // Act
        boolean result = validator.isValid("gene,protein,disease,drug", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_OntologyTypes() {
        // Act
        boolean result = validator.isValid("biological_process,molecular_function,cellular_component", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_GeneticsTypes() {
        // Act
        boolean result = validator.isValid("gene,allele,variant,qtl,marker", context);

        // Assert
        assertTrue(result);
    }

    @Test
    void testIsValid_AnatomyTypes() {
        // Act
        boolean result = validator.isValid("anatomy,tissue,cell_type,organ", context);

        // Assert
        assertTrue(result); // organ is custom but custom types are allowed by default
    }

    @Test
    void testIsValid_PharmacologyTypes() {
        // Act
        boolean result = validator.isValid("drug,chemical,compound", context);

        // Assert
        assertTrue(result); // compound is custom but custom types are allowed
    }
}