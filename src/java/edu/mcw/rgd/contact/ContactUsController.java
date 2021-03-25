package edu.mcw.rgd.contact;

import edu.mcw.rgd.datamodel.FBPerson;
import edu.mcw.rgd.my.MyRGDLookupController;
import edu.mcw.rgd.dao.impl.RgdFbDAO;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.util.List;

public class ContactUsController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // search for user, if exist get person id. Else create/insert and get id. Type ID is used for comment about dropdown
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
            updateDatabase(obj);
        }
        catch (Exception e){
            System.out.println(e);
        }

        return new ModelAndView("/WEB-INF/jsp/contact/contactUs.jsp");
    }
    public void updateDatabase(JSONObject obj) throws Exception{
        RgdFbDAO dao = new RgdFbDAO();
        FBPerson fb = new FBPerson();
        fb.setFirstName((String)obj.get("firstName"));
        fb.setLastName((String)obj.get("lastName"));
        fb.setEmail((String)obj.get("email"));
        fb.setInstitute((String)obj.get("institute"));
        String phone = (String)obj.get("phone");
        int num = 0;
        if (!phone.isEmpty())
            num = Integer.parseInt(phone);
        fb.setPhoneNumber(num);
        fb.setAddress((String)obj.get("address"));
        fb.setInstitute((String)obj.get("institute"));
        fb.setCity((String)obj.get("city"));
        String zip = (String)obj.get("zipCode");
        int code = 0;
        if (!zip.isEmpty())
            code = Integer.parseInt(zip);
        fb.setZipCode(code);
        fb.setCountry((String)obj.get("country"));
        fb.setState((String)obj.get("state"));

        String message = (String)obj.get("message");
        String subject = (String)obj.get("subject");

        String typeButString = (String)obj.get("type");
        int type = Integer.parseInt(typeButString);


        List<FBPerson> senders = dao.getPersonByEmail(fb.getEmail());
        if (!senders.isEmpty()) {
            if (!fb.equals(senders.get(0))) {
                dao.updatePerson(fb);
            }
        }
        else{
            dao.insertPerson(fb);
            senders = dao.getPersonByEmail(fb.getEmail());
        }

        int messageId = dao.insertMessage(subject, message, type, senders.get(0).getPersonId());

        sendMessage(fb, messageId, message, subject, type);

        return;
    }
    public void sendMessage(FBPerson fb, int messageId, String message, String subject, int type) throws Exception {
        String senderEmail = "Dear " + fb.getFirstName() + "\n" +
                "\n" +
                "Thank you for using RGD. Your comments/messages are very important to us." +
                "We will reply or contact you as soon as possible.\n" +
                "\n" +
                "Your message ID is "+messageId+". Please refer to this number in any"+
                "subsequent correspondence.\n" +
                "\n" +
                "\n" +
                "Your comments/messages are as follows:\n" +
                "-----------------------------------------------------------------\n" +
                message + "\n" +
                "-----------------------------------------------------------------\n" +
                "\n" +
                "If you have any further question, please feel free to contact us.\n" +
                "\n" +
                "Rat Genome Database\n" +
                "Bioinformatics Research Center\n" +
                "Medical College of Wisconsin\n" +
                "414-456-8871\");";

        String rgdMessage = message + "\n\n" +
                "This message came from "+fb.getFirstName() + " "+fb.getLastName()+".\n" +
                "Email: " + fb.getEmail() +"\n"+
                "Phone Number: "+fb.getPhoneNumber()+"\n"+
                "Institute: "+fb.getInstitute()+"\n"+
                "City: "+ fb.getCity()+"\n"+
                "State: "+ fb.getState()+"\n" +
                "Country: "+fb.getCountry();

        MyRGDLookupController.send("llamers@mcw.edu", subject, rgdMessage); // to RGD
        MyRGDLookupController.send(fb.getEmail(), "Thank you for your comment submission", senderEmail); // to sender
        return;
    }
}
