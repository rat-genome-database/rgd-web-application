package edu.mcw.rgd.web;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.io.IOException;

    public class PMCDownloader {
        public static void main(String[] args) {
            // Replace with your actual PMC ID (e.g., "PMC1234567")
            String pmcid = "PMC1234567";

            // Example: XML link
            String articleUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=PMC1950017&retmode=xml";

            try {
                String articleContent = downloadContentAsString(articleUrl);
                System.out.println(articleContent);
            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }
        }

        private static String downloadContentAsString(String url)
                throws IOException, InterruptedException {

            // IMPORTANT: Enable followRedirects
            HttpClient client = HttpClient.newBuilder()
                    .followRedirects(HttpClient.Redirect.ALWAYS)
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("User-Agent", "Mozilla/5.0 (compatible; your_email@example.com)")
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return response.body();
            } else {
                throw new IOException("Failed to download content. HTTP status: " + response.statusCode());
            }
        }
    }
