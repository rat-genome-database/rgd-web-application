package edu.mcw.rgd.curation.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.springframework.validation.beanvalidation.MethodValidationPostProcessor;

import jakarta.validation.Validator;

/**
 * Test configuration for unit tests.
 * Provides test-specific beans and configurations.
 */
@Configuration
public class TestConfig {

    /**
     * ObjectMapper configured for testing with Java 8 time support
     */
    @Bean
    @Primary
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        return mapper;
    }

    /**
     * Validator for JSR-303 validation testing
     */
    @Bean
    public Validator validator() {
        return new LocalValidatorFactoryBean();
    }

    /**
     * Method validation post processor for testing
     */
    @Bean
    public MethodValidationPostProcessor methodValidationPostProcessor() {
        MethodValidationPostProcessor processor = new MethodValidationPostProcessor();
        processor.setValidator(validator());
        return processor;
    }
}