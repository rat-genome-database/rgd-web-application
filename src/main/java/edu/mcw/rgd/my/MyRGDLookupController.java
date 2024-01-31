package edu.mcw.rgd.my;

import com.sun.mail.smtp.SMTPTransport;
import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.myrgd.MyUser;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.VerifyRecaptcha;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.security.Security;
import java.util.*;

import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.AddressException;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class MyRGDLookupController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List errorList = new ArrayList();
        List statusList = new ArrayList();
        HttpRequestFacade req = new HttpRequestFacade(request);

        try {

            if (req.getParameter("submit").equals("Reset Password")) {

                String capcha = req.getParameter("g-recaptcha-response");
                if (!VerifyRecaptcha.verify(capcha)) {
                   throw new Exception("ReCaptcha Validation Failed.  Please Try Again.");
                }

                String emailAddress = req.getParameter("j_username");

                MyDAO mdao = new MyDAO();

                MyUser mu = mdao.getMyUser(emailAddress);

                String newPw = UUID.randomUUID().toString().replaceAll("-", "").substring(0,10);

                BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

                String encoded = passwordEncoder.encode(newPw);

                mdao.updatePassword(mu.getUsername(),encoded);

                String msg = "Your Password has been reset.\n\nNew Password: " + newPw + "\n\n";

                //this.send("jdepons", "wyominG1y", emailAddress, "", "test message", "this is a test");
                this.send(emailAddress, "Password Reset Request", msg );

                statusList.add("Password has been reset. A new password has been sent to " + mu.getUsername());

            }



        } catch(Exception e) {
            errorList.add(e.getMessage());

        }

        request.setAttribute("error",errorList);
        request.setAttribute("status",statusList);

        if (statusList.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/my/login.jsp");

        }else {
            return new ModelAndView("/WEB-INF/jsp/my/lookup.jsp");

        }


    }
    /**
     * Send email using GMail SMTP server.
     *
     * @param recipientEmail TO recipient
     * @param ccEmail CC recipient. Can be empty if there is no CC recipient
     * @param title title of the message
     * @param message message to be sent
     * @throws AddressException if the email address parse failed
     * @throws MessagingException if the connection is dead or not in the connected state or if the message is not a MimeMessage
     */
    public static void send(String recipientEmail, String title, String message) throws Exception {

        String smtpHost = "smtp.mcw.edu";

        // Get a Properties object
        Properties props = System.getProperties();

        props.setProperty("mail.smtp.host", "smtp.mcw.edu");
        props.setProperty("mail.smtp.port", "25");

        Session session = Session.getInstance(props, null);

        // -- Create a new message --
        final MimeMessage msg = new MimeMessage(session);

        // -- Set the FROM and TO fields --
        msg.setFrom(new InternetAddress("rgd@mcw.edu", "Rat Genome Database"));

        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail, false));

        //msg.setRecipients(Message.RecipientType.BCC, InternetAddress.parse("jdepons@mcw.edu", false));

        msg.setSubject(title);
        msg.setText(message, "utf-8");
        msg.setSentDate(new Date());

        SMTPTransport t = (SMTPTransport)session.getTransport("smtp");

        t.connect();
        t.sendMessage(msg, msg.getAllRecipients());
        t.close();
    }

}