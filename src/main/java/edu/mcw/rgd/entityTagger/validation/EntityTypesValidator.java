package edu.mcw.rgd.entityTagger.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Validator implementation for @ValidEntityTypes annotation.
 * Validates entity types for recognition processing.
 */
public class EntityTypesValidator implements ConstraintValidator<ValidEntityTypes, String> {

    // Known valid entity types for biological text
    private static final Set<String> VALID_ENTITY_TYPES = new HashSet<>(Arrays.asList(
        "gene", "protein", "disease", "phenotype", "pathway", "drug", "chemical",
        "organism", "tissue", "cell_type", "cell_line", "anatomy", "development",
        "biological_process", "molecular_function", "cellular_component",
        "strain", "allele", "variant", "qtl", "marker", "sequence"
    ));

    private static final Pattern VALID_TYPE_PATTERN = Pattern.compile("^[a-zA-Z][a-zA-Z0-9_-]*$");
    private static final Pattern SEPARATOR_PATTERN = Pattern.compile("[,;\\s]+");

    private int maxTypes;
    private boolean allowCustomTypes;

    @Override
    public void initialize(ValidEntityTypes constraintAnnotation) {
        this.maxTypes = constraintAnnotation.maxTypes();
        this.allowCustomTypes = constraintAnnotation.allowCustomTypes();
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.trim().isEmpty()) {
            return true; // Allow null/empty (entity types are optional)
        }

        String trimmed = value.trim();
        
        // Split by common separators
        String[] types = SEPARATOR_PATTERN.split(trimmed);
        
        // Remove empty strings
        types = Arrays.stream(types)
                .filter(type -> !type.trim().isEmpty())
                .map(String::trim)
                .toArray(String[]::new);

        // Check maximum number of types
        if (types.length > maxTypes) {
            setCustomMessage(context, String.format("Maximum %d entity types allowed, found %d", 
                    maxTypes, types.length));
            return false;
        }

        // Validate each entity type
        Set<String> uniqueTypes = new HashSet<>();
        for (String type : types) {
            String lowerType = type.toLowerCase();
            
            // Check for duplicates
            if (!uniqueTypes.add(lowerType)) {
                setCustomMessage(context, String.format("Duplicate entity type: %s", type));
                return false;
            }
            
            // Check format
            if (!VALID_TYPE_PATTERN.matcher(type).matches()) {
                setCustomMessage(context, String.format("Invalid entity type format: %s. " +
                        "Types must start with a letter and contain only letters, numbers, underscores, and hyphens", type));
                return false;
            }
            
            // Check if type is known or custom types are allowed
            if (!VALID_ENTITY_TYPES.contains(lowerType) && !allowCustomTypes) {
                setCustomMessage(context, String.format("Unknown entity type: %s. " +
                        "Valid types are: %s", type, String.join(", ", VALID_ENTITY_TYPES)));
                return false;
            }
            
            // Check length
            if (type.length() > 50) {
                setCustomMessage(context, String.format("Entity type too long: %s (maximum 50 characters)", type));
                return false;
            }
        }

        return true;
    }

    private void setCustomMessage(ConstraintValidatorContext context, String message) {
        context.disableDefaultConstraintViolation();
        context.buildConstraintViolationWithTemplate(message).addConstraintViolation();
    }

    /**
     * Get the set of valid entity types
     */
    public static Set<String> getValidEntityTypes() {
        return new HashSet<>(VALID_ENTITY_TYPES);
    }
}