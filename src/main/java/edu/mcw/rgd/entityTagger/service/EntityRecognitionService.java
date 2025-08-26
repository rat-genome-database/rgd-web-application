package edu.mcw.rgd.entityTagger.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.mcw.rgd.entityTagger.util.CurationLogger;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * Service for recognizing biological entities in text using Ollama LLM
 */
public class EntityRecognitionService {
    
    private static final String OLLAMA_BASE_URL = System.getProperty("ollama.base.url", "http://grudge.rgd.mcw.edu:11434");
    private static final String DEFAULT_MODEL = "llama3.3:70b";
    private static final int REQUEST_TIMEOUT_SECONDS = 120;
    
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    
    private OntologyService ontologyService;
    private int chunkSize = 4000;
    private int chunkOverlap = 200;
    
    public OntologyService getOntologyService() {
        return ontologyService;
    }
    
    public void setOntologyService(OntologyService ontologyService) {
        this.ontologyService = ontologyService;
    }
    
    public int getChunkSize() {
        return chunkSize;
    }
    
    public void setChunkSize(int chunkSize) {
        this.chunkSize = chunkSize;
    }
    
    public int getChunkOverlap() {
        return chunkOverlap;
    }
    
    public void setChunkOverlap(int chunkOverlap) {
        this.chunkOverlap = chunkOverlap;
    }
    
    public EntityRecognitionService() {
        this.httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(30))
            .build();
        this.objectMapper = new ObjectMapper();
    }
    
    /**
     * Recognize biological entities in the given text
     */
    public EntityRecognitionResult recognizeEntities(String text) {
        CurationLogger.entering(EntityRecognitionService.class, "recognizeEntities", text.length() + " characters");
        
        try {
            String prompt = buildEntityRecognitionPrompt(text);
            String response = callOllamaAPI(prompt);
            return parseEntityResponse(response, text);
            
        } catch (Exception e) {
            CurationLogger.error("Entity recognition failed - Ollama service unavailable", e);
            // Return error result when Ollama service is unavailable
            return createErrorResult("Ollama service is unavailable. Please ensure Ollama is running on " + OLLAMA_BASE_URL + 
                                   ". Error: " + e.getMessage());
        }
    }
    
    /**
     * Build a specialized prompt for biological entity recognition
     */
    private String buildEntityRecognitionPrompt(String text) {
        return String.format("""
            You are a biological entity recognition system specialized in identifying genes, proteins, diseases, chemicals, cellular components, rat strains, and other biological entities from scientific text.
            
            Please analyze the following text and identify biological entities. Return your response in the following JSON format:
            
            {
              "genes": [
                {"name": "GENE_NAME", "description": "Brief description", "confidence": 0.95}
              ],
              "diseases": [
                {"name": "DISEASE_NAME", "description": "Brief description", "confidence": 0.90}
              ],
              "chemicals": [
                {"name": "CHEMICAL_NAME", "description": "Brief description", "confidence": 0.85}
              ],
              "species": [
                {"name": "SPECIES_NAME", "description": "Brief description", "confidence": 0.90}
              ],
              "phenotypes": [
                {"name": "PHENOTYPE_NAME", "description": "Brief description", "confidence": 0.85}
              ],
              "cellular_components": [
                {"name": "CELLULAR_COMPONENT_NAME", "description": "Brief description", "confidence": 0.80}
              ],
              "rat_strains": [
                {"name": "RAT_STRAIN_NAME", "description": "Brief description", "confidence": 0.90}
              ]
            }
            
            Guidelines:
            - Only include entities you are confident about (confidence > 0.7)
            - FOR GENES: Identify ALL of the following:
              * Gene symbols (e.g., ELOVL4, BRCA1, TP53, APOE)
              * Gene full names (e.g., elongation of very long chain fatty acids protein 4)
              * Protein names (e.g., p53, amyloid precursor protein, tau)
              * Protein abbreviations and common names
              * Mutant forms (e.g., W246G mutant, p.W246G)
              * Include both human and model organism (rat, mouse) genes
            - Provide standard gene/protein names when possible, but also capture variants and mutants
            - Include common disease names and phenotypes
            - Include drug names and chemical compounds
            - For cellular_components, identify GO Cellular Component terms like: nucleus, mitochondria, endoplasmic reticulum, ribosome, cytoplasm, cell membrane, golgi apparatus, lysosome, peroxisome, cytoskeleton, nuclear envelope, plasma membrane, synaptic vesicle, dendritic spine, axon terminal, etc.
            - For rat_strains, identify laboratory rat strain names used in biological/medical research. Common strains include: SHR (Spontaneously Hypertensive Rat), WKY (Wistar Kyoto), Sprague Dawley, F344 (Fischer 344), LEW (Lewis), BN, ACI, DA (Dark Agouti), Zucker, Wistar, BBDP, GH (Genetically Hypertensive), and strain/substrain notations like SHR/N, WKY/NCrl, F344/N.
            - Confidence should be between 0.0 and 1.0
            - If no entities are found in a category, return an empty array
            
            Text to analyze:
            "%s"
            
            Return only the JSON response, no additional text.
            """, text.length() > 2000 ? text.substring(0, 2000) + "..." : text);
    }
    
    /**
     * Call the Ollama API with the given prompt
     */
    private String callOllamaAPI(String prompt) throws IOException, InterruptedException {
        CurationLogger.info("=== CALLING OLLAMA AI MODEL: {} ===", DEFAULT_MODEL);
        CurationLogger.info("Prompt length: {} characters", prompt.length());
        
        Map<String, Object> requestBody = Map.of(
            "model", DEFAULT_MODEL,
            "prompt", prompt,
            "stream", false,
            "options", Map.of(
                "temperature", 0.1,
                "top_p", 0.9,
                "num_predict", 2048
            )
        );
        
        String jsonBody = objectMapper.writeValueAsString(requestBody);
        
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(OLLAMA_BASE_URL + "/api/generate"))
            .timeout(Duration.ofSeconds(REQUEST_TIMEOUT_SECONDS))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
            .build();
            
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        
        if (response.statusCode() != 200) {
            throw new IOException("Ollama API returned status: " + response.statusCode() + " - " + response.body());
        }
        
        // Parse the Ollama response to extract the generated text
        JsonNode responseJson = objectMapper.readTree(response.body());
        String generatedText = responseJson.get("response").asText();
        
        CurationLogger.info("=== OLLAMA AI RESPONSE RECEIVED: {} characters ===", generatedText.length());
        CurationLogger.info("First 200 chars of AI response: {}", 
            generatedText.length() > 200 ? generatedText.substring(0, 200) + "..." : generatedText);
        return generatedText;
    }
    
    /**
     * Parse the entity recognition response from the LLM
     */
    private EntityRecognitionResult parseEntityResponse(String response, String originalText) {
        try {
            // Try to extract JSON from the response
            String jsonString = extractJsonFromResponse(response);
            JsonNode jsonResponse = objectMapper.readTree(jsonString);
            
            EntityRecognitionResult result = new EntityRecognitionResult();
            result.setSuccessful(true);
            
            // Parse each entity type from AI response
            result.setGenes(parseEntityList(jsonResponse.get("genes")));
            result.setChemicals(parseEntityList(jsonResponse.get("chemicals")));
            result.setSpecies(parseEntityList(jsonResponse.get("species")));
            result.setPhenotypes(parseEntityList(jsonResponse.get("phenotypes")));
            result.setCellularComponents(parseEntityList(jsonResponse.get("cellular_components")));
            
            // Use AI-detected rat strains without ontology validation
            List<BiologicalEntity> aiRatStrains = parseEntityList(jsonResponse.get("rat_strains"));
            // Set type for AI-detected rat strains
            for (BiologicalEntity strain : aiRatStrains) {
                strain.setType("rat-strain");
            }
            result.setRatStrains(aiRatStrains);
            
            // Use AI-detected diseases and validate with RDO ontology
            List<BiologicalEntity> aiDiseases = parseEntityList(jsonResponse.get("diseases"));
            result.setDiseases(validateDiseasesWithOntology(aiDiseases));
            
            result.setProcessingTimeMs(System.currentTimeMillis() - System.currentTimeMillis()); // Will be set by caller
            
            CurationLogger.info("Parsed entities - Genes: " + result.getGenes().size() + 
                              ", Diseases: " + result.getDiseases().size() +
                              ", Chemicals: " + result.getChemicals().size() +
                              ", Species: " + result.getSpecies().size() +
                              ", Phenotypes: " + result.getPhenotypes().size() +
                              ", Cellular Components: " + result.getCellularComponents().size() +
                              ", Rat Strains: " + result.getRatStrains().size());
            
            return result;
            
        } catch (Exception e) {
            CurationLogger.error("Failed to parse entity response", e);
            return createErrorResult("Failed to parse entity recognition response: " + e.getMessage());
        }
    }
    
    /**
     * Extract JSON content from LLM response (which may contain extra text)
     */
    private String extractJsonFromResponse(String response) {
        // Look for JSON content between braces
        int start = response.indexOf('{');
        int end = response.lastIndexOf('}');
        
        if (start != -1 && end != -1 && end > start) {
            return response.substring(start, end + 1);
        }
        
        // If no JSON found, assume the entire response is JSON
        return response.trim();
    }
    
    
    
    /**
     * Validate AI-detected diseases against the RGD Disease Ontology (RDO)
     */
    private List<BiologicalEntity> validateDiseasesWithOntology(List<BiologicalEntity> aiDiseases) {
        List<BiologicalEntity> validatedDiseases = new ArrayList<>();
        
        // Load RDO ontology to ensure it's available
        RdoOntologyService.loadOntology();
        
        for (BiologicalEntity aiDisease : aiDiseases) {
            String diseaseName = aiDisease.getName();
            
            // Try to find the disease in the RDO ontology
            RdoOntologyService.DiseaseEntity ontologyDisease = findDiseaseInOntology(diseaseName);
            
            if (ontologyDisease != null) {
                // Create validated entity with ontology information
                BiologicalEntity validatedDisease = new BiologicalEntity();
                validatedDisease.setName(ontologyDisease.getName());
                validatedDisease.setType("disease");
                validatedDisease.setAccessionId(ontologyDisease.getId()); // Set accession ID
                validatedDisease.setDescription("Disease " + ontologyDisease.getId() + 
                    (ontologyDisease.getDefinition() != null ? ": " + ontologyDisease.getDefinition() : ""));
                validatedDisease.setConfidence(Math.min(aiDisease.getConfidence() + 0.1, 1.0)); // Boost confidence for validated diseases
                
                validatedDiseases.add(validatedDisease);
                
                CurationLogger.info("Validated disease: {} -> {} ({})", 
                    diseaseName, ontologyDisease.getName(), ontologyDisease.getId());
            } else {
                // Keep AI-detected disease but with lower confidence if not found in ontology
                aiDisease.setConfidence(Math.max(aiDisease.getConfidence() - 0.2, 0.5));
                aiDisease.setDescription("AI-detected disease (not validated in RDO ontology)");
                validatedDiseases.add(aiDisease);
                
                CurationLogger.info("AI-detected disease not found in ontology: {}", diseaseName);
            }
        }
        
        return validatedDiseases;
    }
    
    /**
     * Find a disease in the RDO ontology by name or synonym
     */
    private RdoOntologyService.DiseaseEntity findDiseaseInOntology(String diseaseName) {
        // Try exact name match first
        for (RdoOntologyService.DiseaseEntity disease : RdoOntologyService.getAllDiseases()) {
            if (disease.getName().equalsIgnoreCase(diseaseName)) {
                return disease;
            }
        }
        
        // Try synonym match
        for (RdoOntologyService.DiseaseEntity disease : RdoOntologyService.getAllDiseases()) {
            for (String synonym : disease.getSynonyms()) {
                if (synonym.equalsIgnoreCase(diseaseName)) {
                    return disease;
                }
            }
        }
        
        // Try partial match for common variations
        String normalizedInput = diseaseName.toLowerCase().trim();
        for (RdoOntologyService.DiseaseEntity disease : RdoOntologyService.getAllDiseases()) {
            String normalizedName = disease.getName().toLowerCase().trim();
            
            // Check if input contains the disease name or vice versa
            if (normalizedInput.contains(normalizedName) || normalizedName.contains(normalizedInput)) {
                return disease;
            }
            
            // Check synonyms for partial matches
            for (String synonym : disease.getSynonyms()) {
                String normalizedSynonym = synonym.toLowerCase().trim();
                if (normalizedInput.contains(normalizedSynonym) || normalizedSynonym.contains(normalizedInput)) {
                    return disease;
                }
            }
        }
        
        return null;
    }
    

    /**
     * Combine two lists of entities, removing duplicates based on entity name
     */
    private List<BiologicalEntity> combineEntityLists(List<BiologicalEntity> aiEntities, List<BiologicalEntity> ontologyEntities) {
        List<BiologicalEntity> combined = new ArrayList<>(aiEntities);
        Set<String> existingNames = aiEntities.stream()
            .map(entity -> entity.getName().toLowerCase())
            .collect(Collectors.toSet());
        
        for (BiologicalEntity ontologyEntity : ontologyEntities) {
            if (!existingNames.contains(ontologyEntity.getName().toLowerCase())) {
                combined.add(ontologyEntity);
                existingNames.add(ontologyEntity.getName().toLowerCase());
            }
        }
        
        return combined;
    }
    
    /**
     * Parse a list of entities from JSON
     */
    private List<BiologicalEntity> parseEntityList(JsonNode entitiesNode) {
        List<BiologicalEntity> entities = new ArrayList<>();
        
        if (entitiesNode != null && entitiesNode.isArray()) {
            for (JsonNode entityNode : entitiesNode) {
                BiologicalEntity entity = new BiologicalEntity();
                entity.setName(entityNode.get("name") != null ? entityNode.get("name").asText() : "");
                entity.setDescription(entityNode.get("description") != null ? entityNode.get("description").asText() : "");
                entity.setConfidence(entityNode.get("confidence") != null ? entityNode.get("confidence").asDouble() : 0.8);
                
                if (!entity.getName().isEmpty()) {
                    entities.add(entity);
                }
            }
        }
        
        return entities;
    }
    
    /**
     * Create an error result
     */
    private EntityRecognitionResult createErrorResult(String errorMessage) {
        EntityRecognitionResult result = new EntityRecognitionResult();
        result.setSuccessful(false);
        result.setErrorMessage(errorMessage);
        result.setGenes(Collections.emptyList());
        result.setDiseases(Collections.emptyList());
        result.setChemicals(Collections.emptyList());
        result.setSpecies(Collections.emptyList());
        result.setPhenotypes(Collections.emptyList());
        result.setCellularComponents(Collections.emptyList());
        result.setRatStrains(Collections.emptyList());
        
        CurationLogger.error("Entity recognition error result created: " + errorMessage);
        
        return result;
    }
    
    /**
     * Test the Ollama service connectivity
     */
    public boolean testConnection() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(OLLAMA_BASE_URL + "/api/tags"))
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();
                
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200;
            
        } catch (Exception e) {
            CurationLogger.error("Ollama connection test failed", e);
            return false;
        }
    }
    
    /**
     * Get available models from Ollama
     */
    public List<String> getAvailableModels() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(OLLAMA_BASE_URL + "/api/tags"))
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();
                
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() == 200) {
                JsonNode json = objectMapper.readTree(response.body());
                List<String> models = new ArrayList<>();
                
                if (json.has("models")) {
                    for (JsonNode model : json.get("models")) {
                        if (model.has("name")) {
                            models.add(model.get("name").asText());
                        }
                    }
                }
                
                return models;
            }
            
        } catch (Exception e) {
            CurationLogger.error("Failed to get available models", e);
        }
        
        return Collections.singletonList(DEFAULT_MODEL);
    }
    
}