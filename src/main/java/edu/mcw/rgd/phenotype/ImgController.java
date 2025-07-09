package edu.mcw.rgd.phenotype;

import edu.mcw.rgd.web.RgdContext;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import org.apache.commons.fileupload.*;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Nov 16, 2010
 * Time: 11:43:44 AM
 * To change this template use File | Settings | File Templates.
 */
public class ImgController implements Controller {

    private String imgDir;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // mime type for showed file
        String imgFile = request.getParameter("img");
        if( imgFile!=null ) {
            streamFile(imgDir+"/"+imgFile, request, response);
            return null;
        }

        ModelAndView mv =  new ModelAndView("/WEB-INF/jsp/phenotype/imgUploader.jsp");

//        if( ServletFileUpload.isMultipartContent(request) ) {
//            String uploadError = uploadFile(request);
//            if( uploadError!=null )
//                mv.addObject("uploadMsg", uploadError);
//        }

        // browse all files there
        File folder = new File(imgDir);
        mv.addObject("imgDirPath", imgDir);
        
        File[] listOfFiles = folder.listFiles();
        // sort the file by file name; ignore case of file names
        Arrays.sort(listOfFiles, new Comparator<File>() {
            public int compare(File o1, File o2) {
                return o1.getName().compareToIgnoreCase(o2.getName());
            }
        });
        
        mv.addObject("files", listOfFiles);

        // mime type for showed file
        String showFile = request.getParameter("show");
        if( showFile!=null ) {
            mv.addObject("img", showFile);

            // construct alternate uri
            String imgUrl = RgdContext.getHostname();
            if( request.getServerPort()!=80 )
                imgUrl += ":"+request.getServerPort();
            imgUrl += "/common/images/phenodb/"+showFile;
            mv.addObject("imgUrl", imgUrl);
        }
        return mv;
    }

    String getMimeType(String file) {
        String f = file.toLowerCase();
        if( f.endsWith(".jpeg") || f.endsWith(".jpg") || f.endsWith(".jpe"))
            return "image/jpeg";
        else if( f.endsWith(".png") )
            return "image/png";
        else if( f.endsWith(".bmp") || f.endsWith(".dib"))
            return "image/bmp";
        else if( f.endsWith(".gif") )
            return "image/gif";
        else
            return "application/octet-stream";
    }

    void streamFile(String fname, ServletRequest request, ServletResponse response) throws IOException {

        File file = new File(fname);
        InputStream in = new FileInputStream(file);
        response.setContentLength((int)file.length());

        String mimeType = getMimeType(fname);
        response.setContentType(mimeType);

        ServletOutputStream out = response.getOutputStream();
        byte[] bytes = new byte[8192];

        int bytesRead;
        while ((bytesRead = in.read(bytes)) != -1) {
            out.write(bytes, 0, bytesRead);
        }

        // do the following in a finally block:
        in.close();
        out.close();

    }

    // return status of the upload
    String uploadFile(HttpServletRequest request) throws Exception {

        //System.out.println("Content-Type: "+request.getContentType());

        DiskFileUpload fu = new DiskFileUpload();
        // If file size exceeds, a FileUploadException will be thrown
        fu.setSizeMax(9000000);
//
//        for( FileItem fi: (List<FileItem>) fu.parseRequest(request) ) {
//
//            //Check if not form field so as to only handle the file inputs
//            //else condition handles the submit button input
//            if(!fi.isFormField()) {
//                String fileName = fi.getName();
//
//                //System.out.println("NAME: "+fileName);
//                //System.out.println("SIZE: "+fi.getSize());
//                //System.out.println("TYPE: "+fi.getContentType());
//
//                // fi.getName() is browser dependent; if it contains the full path, we strip the directory part
//                int at1 = fileName.lastIndexOf('/');
//                int at2 = fileName.lastIndexOf('\\');
//                int at = at1>at2 ? at1 : at2;
//                if( at > 0 ) {
//                    fileName = fileName.substring(at+1);
//                }
//                // also we enforce that the file extension will always be lower case
//                // so image names will be more cross platform portable
//                at = fileName.lastIndexOf('.');
//                if( at > 0 ) {
//                    fileName = fileName.substring(0, at) + fileName.substring(at).toLowerCase();
//                }
//
//                // make sure the file has the unique name
//                File fNew = new File(imgDir+"/"+fileName);
//                if( fNew.exists() ) {
//                    return "UPLOAD ERROR: "+fileName+" already in the server area!";
//                }
//
//                // make sure the content type is image
//                if( !fi.getContentType().startsWith("image") ) {
//                    return "UPLOAD ERROR: "+fileName+" is not an image!";
//                }
//
//                // dump the file contents to disk
//                fi.write(fNew);
//            }
//            else {
//                //System.out.println("Field ="+fi.getFieldName());
//            }
//        }
        return "OK";
    }

    public String getImgDir() {
        return imgDir;
    }

    public void setImgDir(String imgDir) {
        this.imgDir = imgDir;
    }
}
