package edu.mcw.rgd.report;



import edu.mcw.rgd.dao.impl.WebFeedbackDAO;

import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.util.List;


public class WebsiteFeedbackController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        WebFeedbackDAO dao = new WebFeedbackDAO();
        StringBuilder buffer = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            buffer.append(line);
            buffer.append(System.lineSeparator());
        }
        JSONObject obj = new JSONObject(buffer.toString());
        reader.close();

        try {
            boolean likedBool = (boolean) obj.get("liked");
            boolean dLikedBool = (boolean) obj.get("disliked");
            String page = (String) obj.get("webPage");

            if (likedBool)
                dao.insertLike(page);
            else if (dLikedBool)
                dao.insertDislike(page);
        }
        catch (Exception e){

        }

        return new ModelAndView("/WEB-INF/jsp/report/weblikes.jsp");
    }
}
