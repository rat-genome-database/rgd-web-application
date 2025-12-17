package edu.mcw.rgd.entityTagger.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

/**
 * Custom validation annotation for text input validation.
 * Ensures text is suitable for entity recognition processing.
 */
@Documented
@Constraint(validatedBy = TextValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidText {
    
    String message() default "Invalid text for entity recognition";
    
    Class<?>[] groups() default {};
    
    Class<? extends Payload>[] payload() default {};
    
    /**
     * Minimum text length
     */
    int minLength() default 1;
    
    /**
     * Maximum text length
     */
    int maxLength() default 100000;
    
    /**
     * Whether to allow only printable characters
     */
    boolean printableOnly() default false;
    
    /**
     * Whether to require some alphabetic content
     */
    boolean requireAlphabetic() default true;
}