package edu.mcw.rgd.entityTagger.service;

import edu.mcw.rgd.entityTagger.util.CurationLogger;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.http.HttpHost;
import org.apache.http.util.EntityUtils;
import org.elasticsearch.client.Request;
import org.elasticsearch.client.Response;
import org.elasticsearch.client.RestClient;
import org.springframework.stereotype.Service;

import java.io.IOException;

/**
 * Service for looking up ontology accession IDs using the RGD Elasticsearch index
 */
@Service
public class OntologyAccessionService {
    
    private static final ObjectMapper MAPPER = new ObjectMapper();
    
    /**
     * Get accession ID for a term and ontology
     * @param term The term to search for
     * @param ont The ontology ID (e.g., "GO", "RDO", "MA", "DO")
     * @return The accession ID if found, or null if not found
     */
    public String getAcc(String term, String ont) {
        try {
            return getAccWithException(term, ont);
        } catch (Exception e) {
            CurationLogger.warn("Failed to get accession ID for term '{}' in ontology '{}': {}", 
                term, ont, e.getMessage());
            return null;
        }
    }
    
    /**
     * Get accession ID for a term and ontology (with exception handling)
     * @param term The term to search for
     * @param ont The ontology ID (e.g., "GO", "RDO", "MA", "DO")
     * @return The accession ID if found
     * @throws IOException if there's an error with the request
     */
    private String getAccWithException(String term, String ont) throws IOException {
        
        // Remap ontology strings
        if ("MA".equals(ont)) {
            ont = "UBERON";
        }
        if ("DO".equals(ont)) {
            ont = "RDO";
        }
        
        // Create the low-level REST client
        try (RestClient restClient = RestClient.builder(
                new HttpHost("travis.rgd.mcw.edu", 9200, "http")
        ).build()) {
            
            String searchTerm = term.trim().toLowerCase();
            String ontology = ont.toUpperCase();
            
            CurationLogger.info("=== ELASTICSEARCH QUERY: Searching for term '{}' in ontology '{}' ===", searchTerm, ontology);
            
            // Build the request body (query) as JSON
            String requestBody = """
                {
                  "size": 10000,
                  "query": {
                    "bool": {
                      "must": {
                        "dis_max": {
                          "queries": [
                            { "term": { "term.symbol": "%s" } }
                          ],
                          "tie_breaker": 0.7
                        }
                      },
                      "filter": {
                        "term": { "subcat.keyword": "%s" }
                      }
                    }
                  }
                }
                """.formatted(searchTerm, ontology);
                
            // Create a Request object
            Request request = new Request("POST", "/aimappings_index_dev/_search");
            request.setJsonEntity(requestBody);
            
            // Perform the request
            Response response = restClient.performRequest(request);
            
            // Parse the response JSON
            String responseBody = EntityUtils.toString(response.getEntity());
            CurationLogger.info("=== ELASTICSEARCH RESPONSE: {} ===", responseBody.length() > 500 ? responseBody.substring(0, 500) + "..." : responseBody);
            JsonNode rootNode = MAPPER.readTree(responseBody);
            
            // The 'hits' section is typically at: hits.hits[]
            JsonNode hitsNode = rootNode.path("hits");
            JsonNode hitsArray = hitsNode.path("hits");
            
            if (hitsArray.isArray()) {
                for (JsonNode hitNode : hitsArray) {
                    JsonNode sourceNode = hitNode.path("_source");
                    JsonNode termAcc = sourceNode.path("term_acc");
                    
                    if (!termAcc.isMissingNode() && !termAcc.asText().isEmpty()) {
                        String accessionId = termAcc.asText();
                        CurationLogger.debug("Found accession ID '{}' for term '{}' in ontology '{}'", 
                            accessionId, term, ont);
                        return accessionId;
                    }
                }
            }
            
            CurationLogger.debug("No accession ID found for term '{}' in ontology '{}'", term, ont);
            return null;
        }
    }
    
    /**
     * Get GO accession ID for cellular component terms
     * @param componentName The cellular component name
     * @return GO accession ID if found, null otherwise
     */
    public String getGoAccessionForCellularComponent(String componentName) {
        CurationLogger.info("=== LOOKING UP GO ACCESSION FOR CELLULAR COMPONENT: {} ===", componentName);
        String result = getAcc(componentName, "CC");
        CurationLogger.info("=== RESULT FOR {}: {} ===", componentName, result);
        return result;
    }
    
    /**
     * Get RDO accession ID for disease terms
     * @param diseaseName The disease name  
     * @return RDO accession ID if found, null otherwise
     */
    public String getRdoAccessionForDisease(String diseaseName) {
        return getAcc(diseaseName, "RDO");
    }
    
    /**
     * Get accession ID for any ontology term
     * @param termName The term name
     * @param ontologyCode The ontology code (GO, RDO, etc.)
     * @return Accession ID if found, null otherwise
     */
    public String getAccessionForTerm(String termName, String ontologyCode) {
        return getAcc(termName, ontologyCode);
    }
}