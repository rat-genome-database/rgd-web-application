package edu.mcw.rgd.entityTagger.controller;

import edu.mcw.rgd.entityTagger.util.CurationLogger;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Controller for serving extracted PDF images from temporary directory
 */
public class ImageController implements Controller {

    private static final String IMAGES_DIR = "/Users/jdepons/apache-tomcat-10.1.13/webapps/rgdweb/curation/images/";

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not specified");
            return null;
        }
        
        // Remove leading slash
        String imageName = pathInfo.substring(1);
        
        // Validate filename for security (no path traversal)
        if (imageName.contains("..") || imageName.contains("/") || imageName.contains("\\")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image name");
            return null;
        }
        
        Path imagePath = Paths.get(IMAGES_DIR, imageName);
        File imageFile = imagePath.toFile();
        
        if (!imageFile.exists() || !imageFile.isFile()) {
            CurationLogger.warn("Image not found: {}", imagePath);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return null;
        }
        
        // Set content type based on file extension
        String contentType = getContentType(imageName);
        response.setContentType(contentType);
        response.setContentLength((int) imageFile.length());
        
        // Set cache headers
        response.setHeader("Cache-Control", "public, max-age=3600");
        response.setDateHeader("Expires", System.currentTimeMillis() + 3600000);
        
        // Stream the image
        try (FileInputStream fis = new FileInputStream(imageFile);
             OutputStream os = response.getOutputStream()) {
            
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        } catch (IOException e) {
            CurationLogger.error("Error serving image: " + imageName, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error serving image");
        }
        
        return null;
    }
    
    private String getContentType(String filename) {
        String extension = filename.toLowerCase();
        if (extension.endsWith(".png")) {
            return "image/png";
        } else if (extension.endsWith(".jpg") || extension.endsWith(".jpeg")) {
            return "image/jpeg";
        } else if (extension.endsWith(".gif")) {
            return "image/gif";
        } else {
            return "application/octet-stream";
        }
    }
}