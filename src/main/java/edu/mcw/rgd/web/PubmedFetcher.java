package edu.mcw.rgd.web;
//api key 5982bf24afcfca4f73f9713454b4ec9d4c09


import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.http.*;
import java.net.URI;
import java.io.IOException;
import java.util.regex.*;
import java.net.http.HttpClient.Redirect;

public class PubmedFetcher {

    private static final String API_KEY = "5982bf24afcfca4f73f9713454b4ec9d4c09";  // NCBI E-utilities key
    private static final HttpClient client = HttpClient.newBuilder()
            .followRedirects(Redirect.ALWAYS)
            .build();

    public static String fetchPMCFullTextXML(String pubmedId) throws IOException, InterruptedException {
        // Step 1: Map PubMed ID to PMC ID using eLink with API key
        String elinkUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=" + pubmedId + "&retmode=xml";

       // String elinkUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?" +
      //          "dbfrom=pubmed&db=pmc&id=" + pubmedId + "&retmode=json&api_key=" + API_KEY;

        System.out.println(elinkUrl);
        HttpRequest elinkRequest = HttpRequest.newBuilder()
                .uri(URI.create(elinkUrl))
                .build();

        HttpResponse<String> elinkResponse = client.send(elinkRequest, HttpResponse.BodyHandlers.ofString());
        String json = elinkResponse.body();

        // Step 2: Extract PMC ID
        Pattern linkPattern = Pattern.compile("\"linkname\":\"pubmed_pmc\".*?\"links\":\\[\"(\\d+)\"\\]", Pattern.DOTALL);
        Matcher matcher = linkPattern.matcher(json);

        if (!matcher.find()) {
            return "Full text not available in PMC for PMID " + pubmedId;
        }

        String pmcNumericId = matcher.group(1);
        String pmcId = "PMC" + pmcNumericId;
        System.out.println("Found PMC ID: " + pmcId);

        // Step 3: Get full XML record using OAI-PMH
        String oaiUrl = "https://www.ncbi.nlm.nih.gov/pmc/oai/oai.cgi?" +
                "verb=GetRecord&identifier=oai:pubmedcentral.nih.gov:" + pmcNumericId + "&metadataPrefix=pmc";

        HttpRequest oaiRequest = HttpRequest.newBuilder()
                .uri(URI.create(oaiUrl))
                .build();

        HttpResponse<String> oaiResponse = client.send(oaiRequest, HttpResponse.BodyHandlers.ofString());
        return oaiResponse.body();
    }

    public static String fetchAbstract(String pubmedId) throws Exception {
        String urlStr = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
                + "?db=pubmed&id=" + pubmedId + "&retmode=xml";

        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.parse(conn.getInputStream());
        doc.getDocumentElement().normalize();

        NodeList abstractTextList = doc.getElementsByTagName("AbstractText");

        StringBuilder abstractText = new StringBuilder();
        for (int i = 0; i < abstractTextList.getLength(); i++) {
            Element elem = (Element) abstractTextList.item(i);
            String label = elem.getAttribute("Label");
            String text = elem.getTextContent().trim();

            if (!label.isEmpty()) {
                abstractText.append("[").append(label).append("] ");
            }
            abstractText.append(text).append("\n\n");
        }

        return abstractText.toString().trim();
    }

    public static void main(String[] args) {
        try {
            String pubmedId = "34523741"; // example
            String xml = fetchPMCFullTextXML(pubmedId);
            System.out.println(xml);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
