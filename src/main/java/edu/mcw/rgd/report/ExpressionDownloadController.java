package edu.mcw.rgd.report;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.BufferedReader;

public class ExpressionDownloadController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        try {
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
                buffer.append(System.lineSeparator());
            }
            JSONObject obj = new JSONObject(buffer.toString());
            reader.close();
            // probably send rgdId
            int rgdId = obj.getInt("rgdId");
            request.setAttribute("rgdId",rgdId);
            request.setAttribute("termAcc", "UBERON:9999999");
//            String rsId = obj.get("rsId").toString();
//            request.setAttribute("rsId", rsId);
        }
        catch (Exception e){
            System.out.println(e);
            return null;
        }
        return new ModelAndView("/WEB-INF/jsp/report/gene/expressionDownload.jsp");
    }
}
