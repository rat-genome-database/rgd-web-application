package edu.mcw.rgd.edit.submittedStrains;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;

/**
 * Created by jthota on 11/15/2016.
 */
public class ImageDiplayController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        try{
            String fileLocation= request.getParameter("image");
            String fileName= fileLocation.replace("/", File.separator);
            System.out.println(fileName);
            FileInputStream fis= new FileInputStream(new File(fileName));
            BufferedInputStream bis= new BufferedInputStream(fis);
            response.setContentType("image/jpeg");
            BufferedOutputStream output= new BufferedOutputStream(response.getOutputStream());
            for(int data; (data=bis.read())>-1;){
                output.write(data);
            }
            fis.close();
            bis.close();
            output.close();
        }catch (IOException e){

        }
        return null;
    }
}
