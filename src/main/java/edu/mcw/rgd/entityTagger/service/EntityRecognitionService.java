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
    
    private static final String OLLAMA_HOST = System.getProperty("ollama.host", System.getProperty("curation.ollama.host", "grudge.rgd.mcw.edu"));
    private static final String OLLAMA_PORT = System.getProperty("ollama.port", System.getProperty("curation.ollama.port", "11434"));
    private static final String OLLAMA_BASE_URL = System.getProperty("ollama.base.url", "http://" + OLLAMA_HOST + ":" + OLLAMA_PORT);
    private static final String DEFAULT_MODEL = "llama3.3:70b";
    private static final int REQUEST_TIMEOUT_SECONDS = 300;
    
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    
    private OntologyService ontologyService;
    private OntologyAccessionService ontologyAccessionService;
    private int chunkSize = 8000;
    private int chunkOverlap = 100;
    
    public OntologyService getOntologyService() {
        return ontologyService;
    }
    
    public void setOntologyService(OntologyService ontologyService) {
        this.ontologyService = ontologyService;
    }
    
    public OntologyAccessionService getOntologyAccessionService() {
        return ontologyAccessionService;
    }
    
    public void setOntologyAccessionService(OntologyAccessionService ontologyAccessionService) {
        this.ontologyAccessionService = ontologyAccessionService;
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
     * Recognize biological entities in the given text using default model
     */
    public EntityRecognitionResult recognizeEntities(String text) {
        return recognizeEntities(text, DEFAULT_MODEL);
    }
    
    /**
     * Recognize biological entities in the given text using specified model
     */
    public EntityRecognitionResult recognizeEntities(String text, String model) {
        CurationLogger.entering(EntityRecognitionService.class, "recognizeEntities", text.length() + " characters");
        CurationLogger.info("Processing FULL TEXT: {} characters ({} KB)", text.length(), text.length() / 1024);
        System.out.println("EntityRecognitionService.recognizeEntities called with " + text.length() + " characters");

        try {
            // Filter out Discussion and References sections before processing
            String filteredText = excludeDiscussionAndReferences(text);
            System.out.println("After filtering Discussion/References: " + filteredText.length() + " characters (original: " + text.length() + ")");
            CurationLogger.info("Filtered text from {} to {} characters", text.length(), filteredText.length());

            // Adjust chunk size based on model - smaller models need smaller chunks
            int effectiveChunkSize = getEffectiveChunkSize(model);
            System.out.println("Using chunk size: " + effectiveChunkSize + " for model: " + model);

            EntityRecognitionResult result;
            // If text is large, chunk it for better processing
            if (filteredText.length() > effectiveChunkSize) {
                System.out.println("Text is large (" + filteredText.length() + " chars), chunking into smaller pieces...");
                result = processTextInChunks(filteredText, model, effectiveChunkSize);
            } else {
                System.out.println("Text is small enough, processing as single chunk...");
                result = processSingleChunk(filteredText, model);
            }

            // Set the model used for this recognition
            result.setModelUsed(model);
            return result;
            
        } catch (Exception e) {
            CurationLogger.error("Entity recognition failed - Ollama service unavailable", e);
            // Return error result when Ollama service is unavailable
            return createErrorResult("Ollama service is unavailable. Please ensure Ollama is running on " + OLLAMA_BASE_URL + 
                                   ". Error: " + e.getMessage());
        }
    }
    
    /**
     * Get effective chunk size based on model capabilities
     */
    private int getEffectiveChunkSize(String model) {
        if (model.contains("1b")) {
            return 2000;  // Very small chunks for 1B model
        } else if (model.contains("3b")) {
            return 4000;  // Small chunks for 3B model
        } else if (model.contains("8b")) {
            return 6000;  // Medium chunks for 8B model
        } else if (model.contains("14b")) {
            return 6500;  // Medium chunks for 14B model
        } else if (model.contains("20b")) {
            return 7000;  // Medium-large chunks for 20B model
        } else if (model.contains("32b")) {
            return 7500;  // Large chunks for 32B model
        } else {
            return chunkSize;  // Default (8000) for 70B model
        }
    }
    
    /**
     * Process text in chunks to handle large documents
     */
    private EntityRecognitionResult processTextInChunks(String text, String model, int effectiveChunkSize) {
        System.out.println("=== CHUNKING TEXT: " + text.length() + " characters with chunk size " + effectiveChunkSize + " ===");
        
        List<String> chunks = createTextChunks(text, effectiveChunkSize);
        System.out.println("Created " + chunks.size() + " chunks");
        
        EntityRecognitionResult combinedResult = new EntityRecognitionResult();
        combinedResult.setSuccessful(true);
        combinedResult.setGenes(new ArrayList<>());
        combinedResult.setDiseases(new ArrayList<>());
        combinedResult.setChemicals(new ArrayList<>());
        combinedResult.setSpecies(new ArrayList<>());
        combinedResult.setPhenotypes(new ArrayList<>());
        combinedResult.setCellularComponents(new ArrayList<>());
        combinedResult.setRatStrains(new ArrayList<>());
        combinedResult.setRawModelResponses(new ArrayList<>());

        long totalTime = 0;
        
        for (int i = 0; i < chunks.size(); i++) {
            String chunk = chunks.get(i);
            System.out.println("Processing chunk " + (i + 1) + "/" + chunks.size() + " (" + chunk.length() + " chars)");
            
            long chunkStartTime = System.currentTimeMillis();
            EntityRecognitionResult chunkResult = processSingleChunk(chunk, model);
            long chunkTime = System.currentTimeMillis() - chunkStartTime;
            totalTime += chunkTime;
            
            if (chunkResult.isSuccessful()) {
                // Merge results from this chunk
                mergeResults(combinedResult, chunkResult);
                System.out.println("Chunk " + (i + 1) + " completed in " + chunkTime + "ms - found entities: " +
                    "genes=" + chunkResult.getGenes().size() + 
                    ", species=" + chunkResult.getSpecies().size() +
                    ", chemicals=" + chunkResult.getChemicals().size());
            } else {
                System.out.println("Chunk " + (i + 1) + " failed: " + chunkResult.getErrorMessage());
            }
        }
        
        // Remove duplicates and set final counts
        removeDuplicateEntities(combinedResult);
        combinedResult.setProcessingTimeMs(totalTime);
        
        System.out.println("=== CHUNKING COMPLETE ===");
        System.out.println("Total processing time: " + totalTime + "ms");
        System.out.println("Final counts: genes=" + combinedResult.getGenes().size() + 
            ", species=" + combinedResult.getSpecies().size() + 
            ", chemicals=" + combinedResult.getChemicals().size() +
            ", diseases=" + combinedResult.getDiseases().size());
        
        return combinedResult;
    }
    
    /**
     * Process a single chunk of text
     */
    private EntityRecognitionResult processSingleChunk(String text, String model) {
        try {
            String prompt = buildEntityRecognitionPrompt(text, model);
            String response = callOllamaAPI(prompt, model);
            EntityRecognitionResult result = parseEntityResponse(response, text);

            // Store the raw response for reasoning display
            if (result.getRawModelResponses() == null) {
                result.setRawModelResponses(new ArrayList<>());
            }
            result.getRawModelResponses().add(response);

            return result;
        } catch (Exception e) {
            return createErrorResult("Failed to process chunk: " + e.getMessage());
        }
    }
    
    /**
     * Create text chunks with overlap to avoid splitting entities (using default chunk size)
     */
    private List<String> createTextChunks(String text) {
        return createTextChunks(text, chunkSize);
    }
    
    /**
     * Create text chunks with overlap to avoid splitting entities (using specified chunk size)
     */
    private List<String> createTextChunks(String text, int targetChunkSize) {
        List<String> chunks = new ArrayList<>();
        
        int start = 0;
        while (start < text.length()) {
            int end = Math.min(start + targetChunkSize, text.length());
            
            // If not the last chunk, try to break at a sentence boundary
            if (end < text.length()) {
                // Look for sentence endings within the last 200 characters
                int lastPeriod = text.lastIndexOf('.', end);
                int lastExclamation = text.lastIndexOf('!', end);
                int lastQuestion = text.lastIndexOf('?', end);
                
                int sentenceEnd = Math.max(lastPeriod, Math.max(lastExclamation, lastQuestion));
                
                // If we found a sentence ending within reasonable range, use it
                if (sentenceEnd > end - 200 && sentenceEnd > start) {
                    end = sentenceEnd + 1;
                }
            }
            
            String chunk = text.substring(start, end).trim();
            if (!chunk.isEmpty()) {
                chunks.add(chunk);
            }
            
            // Move start position with overlap to avoid splitting entities
            start = Math.max(end - chunkOverlap, start + targetChunkSize - chunkOverlap);
        }
        
        return chunks;
    }
    
    /**
     * Merge results from one chunk into the combined results
     */
    private void mergeResults(EntityRecognitionResult combined, EntityRecognitionResult chunk) {
        if (chunk.getGenes() != null) combined.getGenes().addAll(chunk.getGenes());
        if (chunk.getDiseases() != null) combined.getDiseases().addAll(chunk.getDiseases());
        if (chunk.getChemicals() != null) combined.getChemicals().addAll(chunk.getChemicals());
        if (chunk.getSpecies() != null) combined.getSpecies().addAll(chunk.getSpecies());
        if (chunk.getPhenotypes() != null) combined.getPhenotypes().addAll(chunk.getPhenotypes());
        if (chunk.getCellularComponents() != null) combined.getCellularComponents().addAll(chunk.getCellularComponents());
        if (chunk.getRatStrains() != null) combined.getRatStrains().addAll(chunk.getRatStrains());
        if (chunk.getRawModelResponses() != null) combined.getRawModelResponses().addAll(chunk.getRawModelResponses());
    }
    
    /**
     * Remove duplicate entities based on name (case-insensitive)
     */
    private void removeDuplicateEntities(EntityRecognitionResult result) {
        result.setGenes(removeDuplicates(result.getGenes()));
        result.setDiseases(removeDuplicates(result.getDiseases()));
        result.setChemicals(removeDuplicates(result.getChemicals()));
        result.setSpecies(removeDuplicates(result.getSpecies()));
        result.setPhenotypes(removeDuplicates(result.getPhenotypes()));
        result.setCellularComponents(removeDuplicates(result.getCellularComponents()));
        result.setRatStrains(removeDuplicates(result.getRatStrains()));
    }
    
    /**
     * Remove duplicates from a list of entities
     */
    private List<BiologicalEntity> removeDuplicates(List<BiologicalEntity> entities) {
        Map<String, BiologicalEntity> uniqueEntities = new LinkedHashMap<>();
        
        for (BiologicalEntity entity : entities) {
            String key = entity.getName().toLowerCase().trim();
            if (!uniqueEntities.containsKey(key) || 
                entity.getConfidence() > uniqueEntities.get(key).getConfidence()) {
                uniqueEntities.put(key, entity);
            }
        }
        
        return new ArrayList<>(uniqueEntities.values());
    }

    /**
     * Exclude Discussion and References sections from text to focus on core scientific content
     */
    private String excludeDiscussionAndReferences(String text) {
        String upperText = text.toUpperCase();

        // Find the start of DISCUSSION section
        int discussionIndex = findSectionStart(text, upperText, new String[]{"DISCUSSION", "**DISCUSSION**", "# DISCUSSION"});

        // Find the start of REFERENCES section
        int referencesIndex = findSectionStart(text, upperText, new String[]{"REFERENCES", "**REFERENCES**", "# REFERENCES", "BIBLIOGRAPHY", "LITERATURE CITED"});

        // Find the start of ACKNOWLEDGMENTS section (often comes before References)
        int acknowledgementsIndex = findSectionStart(text, upperText, new String[]{"ACKNOWLEDGMENTS", "ACKNOWLEDGEMENTS", "**ACKNOWLEDGMENTS**", "**ACKNOWLEDGEMENTS**"});

        // Determine the cutoff point (earliest of Discussion, Acknowledgements, or References)
        int cutoffIndex = text.length();

        if (discussionIndex > 0 && discussionIndex < cutoffIndex) {
            cutoffIndex = discussionIndex;
            CurationLogger.info("Found DISCUSSION section at character {}", discussionIndex);
        }

        if (acknowledgementsIndex > 0 && acknowledgementsIndex < cutoffIndex) {
            cutoffIndex = acknowledgementsIndex;
            CurationLogger.info("Found ACKNOWLEDGEMENTS section at character {}", acknowledgementsIndex);
        }

        if (referencesIndex > 0 && referencesIndex < cutoffIndex) {
            cutoffIndex = referencesIndex;
            CurationLogger.info("Found REFERENCES section at character {}", referencesIndex);
        }

        // If we found any of these sections, truncate the text
        if (cutoffIndex < text.length()) {
            String filteredText = text.substring(0, cutoffIndex).trim();
            CurationLogger.info("Excluded {} characters from Discussion/References sections", text.length() - filteredText.length());
            return filteredText;
        }

        // No sections found, return original text
        return text;
    }

    /**
     * Find the start index of a section in the text
     */
    private int findSectionStart(String text, String upperText, String[] sectionHeaders) {
        int earliestIndex = -1;

        for (String header : sectionHeaders) {
            // Look for the header at the beginning of a line
            int index = upperText.indexOf("\n" + header);
            if (index > 0) {
                // Found it at the beginning of a line
                if (earliestIndex < 0 || index < earliestIndex) {
                    earliestIndex = index;
                }
            }

            // Also check if it's at the very beginning of the text
            if (upperText.startsWith(header)) {
                return 0;
            }
        }

        return earliestIndex;
    }

    /**
     * Build a specialized prompt for biological entity recognition
     */
    private String buildEntityRecognitionPrompt(String text) {
        return buildEntityRecognitionPrompt(text, null);
    }

    /**
     * Build a specialized prompt for biological entity recognition with model-specific variations
     */
    private String buildEntityRecognitionPrompt(String text, String model) {
        CurationLogger.info("Building prompt with FULL TEXT: {} characters ({} KB)", text.length(), text.length() / 1024);
        CurationLogger.info("Text sample (first 300 chars): {}", text.length() > 300 ? text.substring(0, 300) : text);
        CurationLogger.info("Text sample (last 300 chars): {}", text.length() > 300 ? text.substring(text.length() - 300) : text);

        // Use reasoning-enabled prompt for gpt-oss and deepseek-r1 models
        if (model != null && (model.contains("gpt-oss") || model.contains("deepseek-r1"))) {
            return String.format("""
                Analyze the following scientific text and extract biological entities.

                First, provide your reasoning for entity identification, explaining:
                1. Why you identified specific entities
                2. Context clues that helped you recognize them
                3. Any ambiguities or challenges in identification

                Then provide the extracted entities in JSON format.

                Entity types to find:
                - genes/proteins (gene symbols or protein names)
                - species (ONLY taxonomic species like Homo sapiens, Mus musculus - NOT cell types)
                - chemicals/drugs
                - diseases/disorders
                - phenotypes (observable characteristics)
                - subcellular_localizations (nucleus, mitochondria, ER, Golgi, cytoplasm, etc.)
                - rat_strains (specific rat strain names)

                Required JSON structure:
                {"genes":[],"diseases":[],"chemicals":[],"species":[],"phenotypes":[],"cellular_components":[],"rat_strains":[]}

                Each array contains objects: {"name":"entityname","description":"brief context","confidence":0.0-1.0}

                Text to analyze:
                %s

                Your reasoning and analysis:
                """, text);
        }

        // Default prompt for other models (no reasoning requested)
        return String.format("""
            Extract entities from this text and return ONLY JSON. No explanations.

            Find: genes, species, chemicals, diseases, phenotypes, subcellular_localizations (organelles/cellular locations), rat_strains

            Return ONLY this exact JSON structure:
            {"genes":[],"diseases":[],"chemicals":[],"species":[],"phenotypes":[],"cellular_components":[],"rat_strains":[]}

            For species: ONLY extract taxonomic species (e.g., Homo sapiens, Mus musculus, Rattus norvegicus, E. coli). Do NOT include cell types (e.g., neurons, T cells, fibroblasts).

            For cellular_components, specifically extract subcellular localizations like: nucleus, mitochondria, endoplasmic reticulum, Golgi apparatus, cytoplasm, plasma membrane, etc.

            Each array contains objects like: {"name":"entityname","description":"brief","confidence":0.9}

            Text: %s

            JSON:
            """, text);
    }
    
    /**
     * Call the Ollama API with the given prompt using default model
     */
    private String callOllamaAPI(String prompt) throws IOException, InterruptedException {
        return callOllamaAPI(prompt, DEFAULT_MODEL);
    }
    
    /**
     * Call the Ollama API with the given prompt using specified model
     */
    private String callOllamaAPI(String prompt, String model) throws IOException, InterruptedException {
        CurationLogger.info("=== CALLING OLLAMA AI MODEL: {} ===", model);
        CurationLogger.info("Prompt length: {} characters", prompt.length());
        System.out.println("=== CALLING OLLAMA at " + OLLAMA_BASE_URL + " with model " + model + " ===");
        System.out.println("Prompt length: " + prompt.length() + " characters");
        
        Map<String, Object> requestBody = Map.of(
            "model", model,
            "prompt", prompt,
            "stream", false,
            "options", Map.of(
                "temperature", 0.1,
                "top_p", 0.9,
                "num_predict", 4096
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
        CurationLogger.info("First 500 chars of AI response: {}", 
            generatedText.length() > 500 ? generatedText.substring(0, 500) + "..." : generatedText);
        CurationLogger.info("FULL OLLAMA RESPONSE: {}", generatedText);
        System.out.println("=== OLLAMA RESPONSE RECEIVED: " + generatedText.length() + " characters ===");
        System.out.println("First 500 chars: " + (generatedText.length() > 500 ? generatedText.substring(0, 500) + "..." : generatedText));
        return generatedText;
    }
    
    /**
     * Parse the entity recognition response from the LLM
     */
    private EntityRecognitionResult parseEntityResponse(String response, String originalText) {
        CurationLogger.info("=== PARSING ENTITY RESPONSE ===");
        CurationLogger.info("Response length: {} characters", response.length());
        
        try {
            // Try to extract JSON from the response
            String jsonString = extractJsonFromResponse(response);
            
            // Validate that we have a JSON string
            if (jsonString == null || jsonString.trim().isEmpty() || !jsonString.trim().startsWith("{")) {
                CurationLogger.error("Invalid JSON string extracted: {}", jsonString);
                return createErrorResult("Invalid JSON response from Ollama");
            }
            
            JsonNode jsonResponse;
            try {
                jsonResponse = objectMapper.readTree(jsonString);
            } catch (Exception jsonEx) {
                CurationLogger.error("Failed to parse JSON: {}", jsonString);
                CurationLogger.error("JSON Parse Error: ", jsonEx);
                
                // Try to clean up common JSON issues
                jsonString = jsonString.replaceAll(",\\s*}", "}"); // Remove trailing commas
                jsonString = jsonString.replaceAll(",\\s*]", "]"); // Remove trailing commas in arrays
                jsonString = jsonString.replaceAll("'", "\""); // Replace single quotes with double quotes
                
                // Fix common small model issues - convert string arrays to object arrays
                jsonString = jsonString.replaceAll("\"species\":\\s*\\[\"([^\"]+)\"\\]", "\"species\":[{\"name\":\"$1\",\"description\":\"\",\"confidence\":0.8}]");
                jsonString = jsonString.replaceAll("\"diseases\":\\s*\\[\"([^\"]+)\"\\]", "\"diseases\":[{\"name\":\"$1\",\"description\":\"\",\"confidence\":0.8}]");
                jsonString = jsonString.replaceAll("\"chemicals\":\\s*\\[\"([^\"]+)\"\\]", "\"chemicals\":[{\"name\":\"$1\",\"description\":\"\",\"confidence\":0.8}]");
                jsonString = jsonString.replaceAll("\"genes\":\\s*\\[\"([^\"]+)\"\\]", "\"genes\":[{\"name\":\"$1\",\"description\":\"\",\"confidence\":0.8}]");
                
                try {
                    jsonResponse = objectMapper.readTree(jsonString);
                    CurationLogger.info("Successfully parsed JSON after cleanup");
                } catch (Exception retryEx) {
                    return createErrorResult("Failed to parse JSON response: " + jsonEx.getMessage());
                }
            }
            
            EntityRecognitionResult result = new EntityRecognitionResult();
            result.setSuccessful(true);
            
            // Parse each entity type from AI response
            CurationLogger.info("=== PARSING INDIVIDUAL ENTITY TYPES ===");
            
            List<BiologicalEntity> genes = parseEntityList(jsonResponse.get("genes"));
            CurationLogger.info("Parsed {} genes", genes.size());
            result.setGenes(genes);
            
            List<BiologicalEntity> chemicals = parseEntityList(jsonResponse.get("chemicals"));
            CurationLogger.info("Parsed {} chemicals", chemicals.size());
            result.setChemicals(chemicals);
            
            List<BiologicalEntity> species = parseEntityList(jsonResponse.get("species"));
            CurationLogger.info("Parsed {} species: {}", species.size(), 
                species.stream().map(BiologicalEntity::getName).collect(java.util.stream.Collectors.toList()));
            result.setSpecies(species);
            
            List<BiologicalEntity> phenotypes = parseEntityList(jsonResponse.get("phenotypes"));
            CurationLogger.info("Parsed {} phenotypes", phenotypes.size());
            result.setPhenotypes(phenotypes);
            
            // Process cellular components and add GO accession IDs
            List<BiologicalEntity> cellularComponents = parseEntityList(jsonResponse.get("cellular_components"));
            enrichCellularComponentsWithAccessionIds(cellularComponents);
            result.setCellularComponents(cellularComponents);
            
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
        CurationLogger.info("=== RAW OLLAMA RESPONSE (first 1000 chars) ===");
        CurationLogger.info(response.length() > 1000 ? response.substring(0, 1000) + "..." : response);
        
        // Clean up the response
        String cleaned = response.trim();
        
        // Remove markdown code blocks if present
        if (cleaned.contains("```json")) {
            int startMarker = cleaned.indexOf("```json");
            int endMarker = cleaned.indexOf("```", startMarker + 7);
            if (startMarker != -1 && endMarker != -1) {
                cleaned = cleaned.substring(startMarker + 7, endMarker).trim();
            }
        } else if (cleaned.contains("```")) {
            // Remove generic code blocks
            cleaned = cleaned.replaceAll("```[^`]*```", "");
            cleaned = cleaned.replaceAll("```", "").trim();
        }
        
        // Find the main JSON object
        int braceCount = 0;
        int start = -1;
        int end = -1;
        
        for (int i = 0; i < cleaned.length(); i++) {
            char c = cleaned.charAt(i);
            if (c == '{') {
                if (start == -1) {
                    start = i;
                }
                braceCount++;
            } else if (c == '}') {
                braceCount--;
                if (braceCount == 0 && start != -1) {
                    end = i;
                    break;
                }
            }
        }
        
        if (start != -1 && end != -1 && end > start) {
            String jsonString = cleaned.substring(start, end + 1);
            CurationLogger.info("=== EXTRACTED JSON ===");
            CurationLogger.info(jsonString.length() > 1000 ? jsonString.substring(0, 1000) + "..." : jsonString);
            return jsonString;
        }
        
        // If no valid JSON found, log error and return cleaned response
        CurationLogger.error("Could not extract valid JSON from response. Cleaned response: {}", cleaned);
        return cleaned;
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
     * Enrich cellular components with GO accession IDs using the ontology accession service
     */
    private void enrichCellularComponentsWithAccessionIds(List<BiologicalEntity> cellularComponents) {
        CurationLogger.info("=== ENRICHING {} CELLULAR COMPONENTS ===", cellularComponents.size());
        if (ontologyAccessionService == null) {
            CurationLogger.warn("OntologyAccessionService not available - cellular components will not have GO accession IDs");
            return;
        }
        
        for (BiologicalEntity component : cellularComponents) {
            CurationLogger.info("=== PROCESSING CELLULAR COMPONENT: {} ===", component.getName());
            try {
                String goAccession = ontologyAccessionService.getGoAccessionForCellularComponent(component.getName());
                if (goAccession != null && !goAccession.isEmpty()) {
                    component.setAccessionId(goAccession);
                    component.setType("cellular-component");
                    CurationLogger.info("=== ADDED GO ACCESSION {} TO CELLULAR COMPONENT: {} ===", goAccession, component.getName());
                } else {
                    CurationLogger.info("=== NO GO ACCESSION FOUND FOR CELLULAR COMPONENT: {} ===", component.getName());
                }
            } catch (Exception e) {
                CurationLogger.warn("=== ERROR LOOKING UP GO ACCESSION FOR CELLULAR COMPONENT '{}': {} ===", 
                    component.getName(), e.getMessage());
            }
        }
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
        
        CurationLogger.info("parseEntityList called with node: {}", entitiesNode);
        
        if (entitiesNode == null) {
            CurationLogger.info("entitiesNode is null");
            return entities;
        }
        
        if (!entitiesNode.isArray()) {
            CurationLogger.info("entitiesNode is not an array, type: {}", entitiesNode.getNodeType());
            return entities;
        }
        
        CurationLogger.info("entitiesNode is array with {} elements", entitiesNode.size());
        
        for (int i = 0; i < entitiesNode.size(); i++) {
            JsonNode entityNode = entitiesNode.get(i);
            CurationLogger.info("Processing entity node {}: {}", i, entityNode);
            
            BiologicalEntity entity = new BiologicalEntity();
            String name = entityNode.get("name") != null ? entityNode.get("name").asText() : "";
            String description = entityNode.get("description") != null ? entityNode.get("description").asText() : "";
            double confidence = entityNode.get("confidence") != null ? entityNode.get("confidence").asDouble() : 0.8;
            
            entity.setName(name);
            entity.setDescription(description);
            entity.setConfidence(confidence);
            
            CurationLogger.info("Created entity: name='{}', description='{}', confidence={}", name, description, confidence);
            
            if (!entity.getName().isEmpty()) {
                entities.add(entity);
                CurationLogger.info("Added entity to list");
            } else {
                CurationLogger.info("Skipped entity with empty name");
            }
        }
        
        CurationLogger.info("parseEntityList returning {} entities", entities.size());
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