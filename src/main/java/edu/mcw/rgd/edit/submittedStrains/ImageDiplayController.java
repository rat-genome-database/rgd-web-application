package edu.mcw.rgd.edit.submittedStrains;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Created by jthota on 11/15/2016.
 */
public class ImageDiplayController implements Controller {

    // strain images are uploaded here (see ImageUploadController); nothing outside it is served
    private static final Path IMAGE_DIR = Paths.get("/rgd/strains/strain_images");

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String fileLocation = request.getParameter("image");
        if( fileLocation == null || fileLocation.trim().isEmpty() ) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No image was given");
            return null;
        }

        Path file = Paths.get(fileLocation.trim()).toAbsolutePath().normalize();
        if( !file.startsWith(IMAGE_DIR) || !Files.isRegularFile(file) ) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return null;
        }

        String contentType = request.getServletContext().getMimeType(file.getFileName().toString());
        if( contentType == null || !contentType.startsWith("image/") ) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return null;
        }

        response.setContentType(contentType);
        response.setContentLengthLong(Files.size(file));
        try( OutputStream output = response.getOutputStream() ) {
            Files.copy(file, output);
        }
        return null;
    }
}
