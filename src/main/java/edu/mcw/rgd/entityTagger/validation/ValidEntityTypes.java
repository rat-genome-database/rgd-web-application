package edu.mcw.rgd.entityTagger.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

/**
 * Custom validation annotation for entity types validation.
 * Ensures entity types are valid for the recognition system.
 */
@Documented
@Constraint(validatedBy = EntityTypesValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidEntityTypes {
    
    String message() default "Invalid entity types specified";
    
    Class<?>[] groups() default {};
    
    Class<? extends Payload>[] payload() default {};
    
    /**
     * Maximum number of entity types allowed
     */
    int maxTypes() default 10;
    
    /**
     * Whether to allow custom entity types
     */
    boolean allowCustomTypes() default true;
}