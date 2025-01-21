package edu.mcw.rgd.contact;

import edu.mcw.rgd.dao.impl.RgdFbDAO;
import edu.mcw.rgd.dao.impl.WebFeedbackDAO;

import edu.mcw.rgd.my.MyRGDLookupController;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.util.List;


public class WebsiteFeedbackController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        WebFeedbackDAO dao = new WebFeedbackDAO();
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

            boolean bypass = (boolean) obj.get("bypass");
            if (bypass){
                sendEmail(obj);
            }
            else {
                boolean likedBool = (boolean) obj.get("liked");
                boolean dLikedBool = (boolean) obj.get("disliked");
                String page = (String) obj.get("webPage");

                if (likedBool)
                    dao.insertLike(page);
                else if (dLikedBool)
                    dao.insertDislike(page);
            }
        }
        catch (Exception e){

        }

        return new ModelAndView("/WEB-INF/jsp/contact/weblikes.jsp");
    }
    public void sendEmail(JSONObject obj) throws Exception {
        RgdFbDAO fbdao = new RgdFbDAO();

        String message = (String) obj.get("message");
        String sender = (String) obj.get("email");
        String subject = (String) obj.get("subject");
        String page = (String) obj.get("webPage");

        String usrMsg = "Dear User,\n\nThank you for using RGD. Your comments/messages are very important to us.\n" +
                "We will reply or contact you as soon as possible.\n\n\n" +
                "Your comments/messages from the page \""+ page +"\" are as follows:\n" +
                "-----------------------------------------------------------------\n" +
                message+"\n" +
                "-----------------------------------------------------------------\n\n" +
                "If you have any further question, please feel free to contact us.\n\n" +
                "Rat Genome Database\n" +
                "Medical College of Wisconsin\n" +
                "414-456-8871";
        String rgdMessage = message+"\n\n" +
                "Reply to: "+sender+"\n"+
                "Webpage: " + page;

//        MyRGDLookupController.send("rgd.data@mcw.edu", "Send message form from " + page, rgdMessage);
        MyRGDLookupController.send("akundurthi@mcw.edu", "Send message form from " + page, rgdMessage);
        MyRGDLookupController.send(sender, "Thanks for your comment", usrMsg);

        String storedMessage = message + "\t Recipients email:"+sender;
        fbdao.insertMessageForm("Send Message Form",storedMessage,1);

        return;
    }
}
