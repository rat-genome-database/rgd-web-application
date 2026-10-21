package edu.mcw.rgd.my;

import com.sun.mail.smtp.SMTPTransport;
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

    /**
     * Password recovery was for the retired email/password accounts; sign-in is the Google button in the
     * page header, so the old URL goes to the home page. send() is still used by the contact and submission forms.
     */
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.sendRedirect(request.getContextPath() + "/homepage/");
        return null;
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