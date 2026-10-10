package edu.mcw.rgd.entityTagger.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * OpenAPI 3.0 configuration for the RGD Curation Tool API.
 * Provides comprehensive API documentation with Swagger UI.
 */
@Configuration
public class OpenApiConfig {

    @Value("${curation.api.version:1.0.0}")
    private String apiVersion;

    @Value("${curation.api.base.url:http://localhost:8080}")
    private String serverUrl;

    @Bean
    public OpenAPI curationToolOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Ontomation API")
                        .description("""
                                ## Ontomation - Entity Recognition API
                                
                                Ontomation provides AI-powered biological entity recognition 
                                and ontology matching capabilities for scientific literature curation.
                                
                                ### Key Features
                                - **Entity Recognition**: AI-powered extraction of biological entities from text
                                - **Ontology Matching**: Integration with RDO and GO ontologies for term matching
                                - **Batch Processing**: Efficient parallel processing for large datasets
                                - **Real-time Analysis**: Interactive text analysis with immediate results
                                - **PDF Processing**: Extract and analyze text from scientific publications
                                
                                ### Supported Entity Types
                                - Genes and proteins
                                - Diseases and phenotypes
                                - Biological pathways
                                - Chemical compounds
                                - Anatomical structures
                                - Cell types and tissues
                                - Strains and alleles
                                
                                ### Authentication
                                This API currently uses IP-based access control. Contact the RGD team for access.
                                
                                ### Rate Limits
                                - Single requests: 30 per minute per IP
                                - Batch requests: 5 per minute per IP
                                - Large batch requests (>50 items): 2 per hour per IP
                                
                                ### Support
                                For technical support, contact the RGD Bioinformatics team at rgd.informatics@mcw.edu
                                """)
                        .version(apiVersion)
                        .contact(new Contact()
                                .name("RGD Bioinformatics Team")
                                .email("rgd.informatics@mcw.edu")
                                .url("https://rgd.mcw.edu"))
                        .license(new License()
                                .name("RGD License")
                                .url("https://rgd.mcw.edu/wg/about-us/license/"))
                        .termsOfService("https://rgd.mcw.edu/wg/about-us/terms-of-use/"))
                .servers(List.of(
                        new Server()
                                .url(serverUrl)
                                .description("Ontomation API Server"),
                        new Server()
                                .url("https://rgd.mcw.edu/curation")
                                .description("Production Server"),
                        new Server()
                                .url("https://test.rgd.mcw.edu/curation")
                                .description("Test Server")))
                .tags(List.of(
                        new Tag()
                                .name("Entity Recognition")
                                .description("AI-powered biological entity recognition endpoints"),
                        new Tag()
                                .name("Batch Processing")
                                .description("Bulk text processing and status monitoring"),
                        new Tag()
                                .name("Ontology Matching")
                                .description("Ontology term matching and search capabilities"),
                        new Tag()
                                .name("System Administration")
                                .description("Service health monitoring and administrative functions"),
                        new Tag()
                                .name("Cache Management")
                                .description("Cache operations and performance monitoring")));
    }
}