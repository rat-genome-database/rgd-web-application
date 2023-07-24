package edu.mcw.rgd.report;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.BufferedReader;

public class VariantDownloadController implements Controller {
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        try{
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
                buffer.append(System.lineSeparator());
            }
            JSONObject obj = new JSONObject(buffer.toString());
            reader.close();
            int start = Integer.parseInt(obj.get("start").toString());
            int stopPos = Integer.parseInt(obj.get("stopPos").toString());
            String chr = obj.get("chr").toString();
            int mapKey = Integer.parseInt(obj.get("mapKey").toString());
            String symbol = obj.get("symbol").toString();
            request.setAttribute("start",start);
            request.setAttribute("stopPos",stopPos);
            request.setAttribute("chr",chr);
            request.setAttribute("symbol",symbol);
            request.setAttribute("mapKey",mapKey);
        }
        catch (Exception e){
            System.out.println(e);
            return null;
        }
        return new ModelAndView("/WEB-INF/jsp/report/rsIds/downloadVariants.jsp");
    }
}
