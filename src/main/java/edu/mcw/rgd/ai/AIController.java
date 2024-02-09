package edu.mcw.rgd.ai;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class AIController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {


        HttpURLConnection conn = null;
        DataOutputStream os = null;
        String pmidString=request.getParameter("pmid");
        if(pmidString==null || (pmidString!=null && pmidString.equals(""))){
            return new ModelAndView("/WEB-INF/jsp/ai/output.jsp");
        }
        try{
            int pmid=Integer.parseInt(pmidString);
            URL url = new URL("http://localhost:5000/process?pmid="+pmid); //important to add the trailing slash after add
//            String[] inputData = {"{ \"pmid\":16267253}"};
            conn = (HttpURLConnection) url.openConnection();

                if (conn.getResponseCode() != 200) {
                    throw new RuntimeException("Failed : HTTP error code : "
                            + conn.getResponseCode());
                }
            StringBuilder sb=new StringBuilder();

                try (BufferedReader br = new BufferedReader(new InputStreamReader(
                        (conn.getInputStream())));) {
                    String output;
                    while ((output = br.readLine()) != null) {
                        sb.append(output);
                    }
                if(sb.length()>0){
                    request.setAttribute("output", sb.toString());
                }
                }
                conn.disconnect();

        } catch (MalformedURLException e) {
            e.printStackTrace();
        }catch (IOException e){
            e.printStackTrace();
        }finally
        {
            if(conn != null)
            {
                conn.disconnect();
            }
        }


        return new ModelAndView("/WEB-INF/jsp/ai/output.jsp");

    }
}
