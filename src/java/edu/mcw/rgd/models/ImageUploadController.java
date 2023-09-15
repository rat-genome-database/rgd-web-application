package edu.mcw.rgd.models;



import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileUtils;

import org.apache.commons.io.IOUtils;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.*;
import java.security.MessageDigest;
import java.util.List;

/**
 * Created by jthota on 8/16/2016.
 */
public class ImageUploadController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        File file = null;
        int maxFileSize = 5000 * 1024;
        int maxMemSize = 5000 * 1024;
        MessageDigest md = MessageDigest.getInstance("MD5");
        DiskFileItemFactory factory = new DiskFileItemFactory();
        String contextRoot = request.getContextPath();
       // String filePath = "/data/data/strains/strain_images/";
	   String filePath = "/rgd/strains/strain_images/";
        File uploadedFile= new File(contextRoot +  "/WEB-INF/tmp");
        factory.setRepository(uploadedFile);
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(maxFileSize);
//        try {
//            FileItemIterator items = upload.getItemIterator(request);
//            while(items.hasNext()){
//                FileItemStream item=items.next();
//                InputStream is;
//                if (!item.isFormField()) {
//                    is=item.openStream();
//
//                    String fileName = item.getName();
//                    String fn= new String();
//                   if (fileName.lastIndexOf("\\") >= 0) {
//                       byte[] b=fileName.substring(fileName.lastIndexOf("\\")).getBytes();
//                       fn= md.digest(b).toString();
//                       file = new File(filePath + fn + ".png");
//                    } else {
//                       byte[] b=fileName.substring(fileName.lastIndexOf("\\")+1).getBytes();
//                       fn= md.digest(b).toString();
//                       file = new File(filePath +fn +".png");
//                    }
//                   if(item.getContentType().equalsIgnoreCase("image/jpeg")||item.getContentType().equalsIgnoreCase("image/PNG") || item.getContentType().equalsIgnoreCase("image/GIF")) {
//
//                       OutputStream out = new FileOutputStream(file);
//                        IOUtils.copy(is, out);
//                        is.close();
//                        out.close();
//                          String path= filePath+ file.getName();
//                          response.getWriter().write(path);
//                          return null;
//                }
//            }
//            }
//
//        } catch (Exception e) {
//        }
        response.getWriter().write("false");
        return null;
    }

    }

