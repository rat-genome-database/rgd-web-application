package edu.mcw.rgd.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import org.apache.http.HttpHost;
import org.apache.http.util.EntityUtils;
import org.elasticsearch.client.Request;
import org.elasticsearch.client.Response;
import org.elasticsearch.client.RestClient;

import java.io.IOException;



public class OntologyTermMatcher {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    /**
     * Using the Low-Level REST Client to mimic your original Python logic.
     */
    public String getAcc(String term, String ont) throws IOException {

        // Remap ontology strings (like in your Python code)
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
            // Use the POST method on [index]/_search
            Request request = new Request("POST", "/aimappings_index_dev/_search");
            request.setJsonEntity(requestBody);

            // Perform the request
            Response response = restClient.performRequest(request);

            // Parse the response JSON
            String responseBody = EntityUtils.toString(response.getEntity());
            JsonNode rootNode = MAPPER.readTree(responseBody);

            // For debugging, you can print the entire JSON:
            // System.out.println("Raw Response:\n" + responseBody);

            // The 'hits' section is typically at: hits.hits[]
            // The total number of hits is at: hits.total.value

            JsonNode hitsNode = rootNode.path("hits");
            //long totalHits = hitsNode.path("total").path("value").asLong();
            //System.out.println("Got " + totalHits + " Hits:");

            JsonNode hitsArray = hitsNode.path("hits");
            if (hitsArray.isArray()) {
                for (JsonNode hitNode : hitsArray) {
                    JsonNode sourceNode = hitNode.path("_source");
                    // Adjust these field names to match your actual data structure
                    JsonNode termVal = sourceNode.path("term");
                    JsonNode termAcc = sourceNode.path("term_acc");
                    JsonNode typeVal = sourceNode.path("type");

                    return termAcc.asText();
                    // Print them out
                    //System.out.println("Term Found: " + termVal.asText() + " accID: " + termAcc.asText() + " typeVal: " + typeVal.asText() + "\n\n");
                }
            }
        }
        return "DOID:4";
    }

    public String formatAndMap(String input, String ontology) throws Exception{
        try {

            System.out.println("Processing " + ontology);
            String[] terms = input.split("\\|");

            StringBuilder html = new StringBuilder();
            //OntologyTermMatcher matcher= new OntologyTermMatcher();

            for (String term : terms) {
                String pTerm = term.trim().toLowerCase();
                String ontId = getAcc(pTerm, ontology);

                String url = "/rgdweb/ontology/annot.html?acc_id=" + ontId;

                html.append("<a href=\"").append(url).append("\">").append(pTerm).append("</a> , ");
            }
            return html.toString();
        }catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }
}
