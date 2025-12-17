package edu.mcw.rgd.entityTagger.util;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.List;
import java.util.ArrayList;

/**
 * Utility class for processing Marker-generated markdown content
 */
public class MarkdownProcessor {
    
    // Pattern to match markdown image references: ![alt text](image_file)
    private static final Pattern IMAGE_PATTERN = Pattern.compile("!\\[([^\\]]*)\\]\\(([^)]+)\\)");
    
    /**
     * Convert Marker markdown text to HTML, replacing image references with proper HTML img tags
     */
    public static String processMarkdownToHtml(String markdownText, List<String> extractedImageUrls, Long uploadId) {
        if (markdownText == null || markdownText.trim().isEmpty()) {
            return markdownText;
        }
        
        CurationLogger.entering(MarkdownProcessor.class, "processMarkdownToHtml");
        CurationLogger.info("Processing markdown text with {} extracted images", 
                           extractedImageUrls != null ? extractedImageUrls.size() : 0);
        
        String processedText = markdownText;
        
        // Find all image references in the markdown
        Matcher matcher = IMAGE_PATTERN.matcher(markdownText);
        List<ImageReference> imageRefs = new ArrayList<>();
        
        while (matcher.find()) {
            String altText = matcher.group(1);
            String imageFile = matcher.group(2);
            
            ImageReference ref = new ImageReference();
            ref.fullMatch = matcher.group(0);
            ref.altText = altText.isEmpty() ? "Figure" : altText;
            ref.imageFile = imageFile;
            ref.start = matcher.start();
            ref.end = matcher.end();
            
            imageRefs.add(ref);
            CurationLogger.info("Found image reference: {} -> {}", altText, imageFile);
        }
        
        // Process image references in reverse order to maintain string positions
        for (int i = imageRefs.size() - 1; i >= 0; i--) {
            ImageReference ref = imageRefs.get(i);
            String htmlImg = createHtmlImageTag(ref, extractedImageUrls, uploadId, i + 1);
            
            processedText = processedText.substring(0, ref.start) + 
                           htmlImg + 
                           processedText.substring(ref.end);
        }
        
        // Convert basic markdown formatting to HTML (minimal conversion to avoid interfering with entity highlighting)
        processedText = convertMinimalMarkdownToHtml(processedText);
        
        // Final comprehensive cleanup to ensure absolutely no <br> tags remain
        processedText = removeBrTagsComprehensive(processedText);
        
        CurationLogger.info("Processed {} image references", imageRefs.size());
        CurationLogger.exiting(MarkdownProcessor.class, "processMarkdownToHtml");
        
        return processedText;
    }
    
    /**
     * Create HTML img tag for an image reference
     */
    private static String createHtmlImageTag(ImageReference ref, List<String> extractedImageUrls, Long uploadId, int figureNum) {
        // Try to find a matching extracted image URL
        String imageUrl = findMatchingImageUrl(ref.imageFile, extractedImageUrls);
        
        if (imageUrl != null) {
            // Found an actual extracted image
            return String.format(
                "<div class=\"figure-container mb-3\">" +
                "<img src=\"%s\" class=\"img-fluid figure-image\" alt=\"%s\" " +
                "style=\"max-width: 100%%; border: 1px solid #ddd; border-radius: 4px;\" " +
                "onclick=\"showImageModal(this)\" title=\"Click to view full size\">" +
                "<div class=\"figure-caption text-muted small mt-2\">" +
                "<strong>Figure %d:</strong> %s" +
                "</div>" +
                "</div>",
                imageUrl, ref.altText, figureNum, ref.altText
            );
        } else {
            // No actual image found, create a placeholder
            return String.format(
                "<div class=\"figure-placeholder mb-3 p-3 border rounded bg-light text-center\">" +
                "<div class=\"placeholder-icon mb-2\">" +
                "<i class=\"fas fa-image fa-3x text-muted\"></i>" +
                "</div>" +
                "<div class=\"placeholder-text\">" +
                "<strong>Figure %d</strong><br>" +
                "<span class=\"text-muted\">%s</span><br>" +
                "<small class=\"text-info\">Image detected in PDF but not extracted</small>" +
                "</div>" +
                "</div>",
                figureNum, ref.altText.isEmpty() ? ref.imageFile : ref.altText
            );
        }
    }
    
    /**
     * Find matching image URL from extracted images
     */
    private static String findMatchingImageUrl(String imageFile, List<String> extractedImageUrls) {
        if (extractedImageUrls == null || extractedImageUrls.isEmpty()) {
            return null;
        }
        
        // Clean the image file name for matching
        String cleanImageFile = imageFile.replaceAll("^_", "").toLowerCase();
        
        for (String url : extractedImageUrls) {
            if (url.toLowerCase().contains(cleanImageFile) || 
                cleanImageFile.contains(getFilenameFromUrl(url).toLowerCase())) {
                return url;
            }
        }
        
        return null;
    }
    
    /**
     * Extract filename from URL
     */
    private static String getFilenameFromUrl(String url) {
        if (url == null || url.isEmpty()) {
            return "";
        }
        
        int lastSlash = url.lastIndexOf('/');
        if (lastSlash >= 0 && lastSlash < url.length() - 1) {
            return url.substring(lastSlash + 1);
        }
        
        return url;
    }
    
    /**
     * Convert minimal markdown formatting to HTML, avoiding interference with entity highlighting
     */
    private static String convertMinimalMarkdownToHtml(String text) {
        if (text == null) return null;
        
        CurationLogger.info("MarkdownProcessor - Text before HTML conversion: {}", 
            text.length() > 200 ? text.substring(0, 200).replace("\n", "\\n") : text.replace("\n", "\\n"));
        
        // Remove any existing <br> tags that might have been introduced elsewhere
        text = text.replaceAll("(?i)<br\\s*/?\\s*>", " ");
        text = text.replaceAll("(?i)</br\\s*>", " ");
        text = text.replaceAll("(?i)<br>", " ");
        text = text.replaceAll("(?i)<br/>", " ");
        text = text.replaceAll("(?i)<br />", " ");
        
        // Only convert headers - avoid line break conversions that interfere with entity highlighting
        text = text.replaceAll("(?m)^###### (.+)$", "<h6>$1</h6>");
        text = text.replaceAll("(?m)^##### (.+)$", "<h5>$1</h5>");
        text = text.replaceAll("(?m)^#### (.+)$", "<h4>$1</h4>");
        text = text.replaceAll("(?m)^### (.+)$", "<h3>$1</h3>");
        text = text.replaceAll("(?m)^## (.+)$", "<h2>$1</h2>");
        text = text.replaceAll("(?m)^# (.+)$", "<h1>$1</h1>");
        
        // Convert bold and italic - but be more careful to avoid conflicts
        text = text.replaceAll("\\*\\*([^*]+)\\*\\*", "<strong>$1</strong>");
        text = text.replaceAll("(?<!\\*)\\*([^*]+)\\*(?!\\*)", "<em>$1</em>");
        
        // Do NOT convert line breaks to avoid <br> tags appearing in entity highlights
        // Line breaks will be handled by CSS in the frontend
        
        // Final safety check - remove any remaining <br> patterns that might have been introduced
        text = text.replaceAll("(?i)\\s*<\\s*br\\s*[^>]*>\\s*", " ");
        text = text.replaceAll("(?i)\\s*<\\s*/\\s*br\\s*[^>]*>\\s*", " ");
        
        CurationLogger.info("MarkdownProcessor - Text after HTML conversion: {}", 
            text.length() > 200 ? text.substring(0, 200).replace("\n", "\\n") : text.replace("\n", "\\n"));
        
        return text;
    }
    
    /**
     * Comprehensive removal of all possible <br> tag patterns to prevent interference with entity highlighting
     */
    private static String removeBrTagsComprehensive(String text) {
        if (text == null) return null;
        
        String original = text;
        
        // Remove all variations of <br> tags
        text = text.replaceAll("(?i)<br\\s*/?\\s*>", " ");
        text = text.replaceAll("(?i)</br\\s*>", " ");
        text = text.replaceAll("(?i)<br\\s*/?>", " ");
        text = text.replaceAll("(?i)<br>", " ");
        text = text.replaceAll("(?i)<br/>", " ");
        text = text.replaceAll("(?i)<br />", " ");
        text = text.replaceAll("(?i)<BR>", " ");
        text = text.replaceAll("(?i)<BR/>", " ");
        text = text.replaceAll("(?i)<BR />", " ");
        
        // Aggressive pattern matching for malformed or spaced tags
        text = text.replaceAll("(?i)\\s*<\\s*br\\s*[^>]*>\\s*", " ");
        text = text.replaceAll("(?i)\\s*<\\s*/\\s*br\\s*[^>]*>\\s*", " ");
        text = text.replaceAll("(?i)\\s*<\\s*BR\\s*[^>]*>\\s*", " ");
        
        // Clean up multiple spaces left by tag removal
        text = text.replaceAll("\\s+", " ");
        
        if (!original.equals(text)) {
            CurationLogger.info("MarkdownProcessor - Removed {} <br> tags from text", 
                countBrTags(original) - countBrTags(text));
        }
        
        return text.trim();
    }
    
    /**
     * Count <br> tags in text for logging
     */
    private static int countBrTags(String text) {
        if (text == null) return 0;
        return text.split("(?i)<br[^>]*>").length - 1;
    }
    
    /**
     * Extract all image references from markdown text
     */
    public static List<String> extractImageReferences(String markdownText) {
        List<String> imageFiles = new ArrayList<>();
        
        if (markdownText == null || markdownText.trim().isEmpty()) {
            return imageFiles;
        }
        
        Matcher matcher = IMAGE_PATTERN.matcher(markdownText);
        while (matcher.find()) {
            String imageFile = matcher.group(2);
            imageFiles.add(imageFile);
        }
        
        return imageFiles;
    }
    
    /**
     * Inner class to hold image reference information
     */
    private static class ImageReference {
        String fullMatch;
        String altText;
        String imageFile;
        int start;
        int end;
    }
}