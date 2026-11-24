package edu.mcw.rgd.feedback;

import edu.mcw.rgd.dao.impl.RgdFbDAO;
import edu.mcw.rgd.datamodel.FBAnswer;
import edu.mcw.rgd.datamodel.FBPerson;
import edu.mcw.rgd.datamodel.FBQuestion;
import edu.mcw.rgd.my.MyRGDLookupController;
import edu.mcw.rgd.process.Utils;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Reply page of the feedback curation tool: shows one message from FB_QUESTION (parameter messageId),
 * a dropdown of curators and a text area for the reply.
 * <p>
 * act=sendReply (POST with curatorId and reply) saves the reply in FB_ANSWER and emails it to the sender of the message.
 * <p>
 * act=addCurator (POST with firstName, lastName, email) adds a curator to FB_PERSON and answers with JSON:
 * {personId, label, message} when the curator is in the list now, or {error} when nothing was added.
 * <p>
 * Access is checked by AuthenticationInterceptor (curation/feedback/*).
 */
public class FeedbackMessageReplyController implements Controller {

    // sizes of columns FIRSTNAME, LASTNAME and EMAIL_ADDRESS in FB_PERSON
    public static final int MAX_FIRST_NAME = 15;
    public static final int MAX_LAST_NAME = 15;
    public static final int MAX_EMAIL = 40;
    // size of column ANSWER in FB_ANSWER
    public static final int MAX_ANSWER = 4000;

    private static final String EMAIL_PATTERN = "[^@\\s]+@[^@\\s]+\\.[^@\\s]+";
    private static final Pattern RECIPIENTS_EMAIL = Pattern.compile("Recipients email:\\s*(\\S+)", Pattern.CASE_INSENSITIVE);

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        RgdFbDAO dao = new RgdFbDAO();

        if( "addCurator".equals(request.getParameter("act")) ) {
            if( !"POST".equalsIgnoreCase(request.getMethod()) ) {
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                return null;
            }
            JSONObject result;
            try {
                result = addCurator(dao, request);
            } catch( Exception e ) {
                e.printStackTrace();
                result = new JSONObject().put("error", "The curator could not be added: " + e.getMessage());
            }
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(result.toString());
            return null;
        }

        ArrayList<String> error = new ArrayList<>();
        ArrayList<String> status = new ArrayList<>();

        FBQuestion question = null;
        String messageId = request.getParameter("messageId");
        try {
            question = dao.getQuestion(Integer.parseInt(messageId.trim()));
            if( question == null ) {
                error.add("There is no message with ID " + messageId + ".");
            }
        } catch( NullPointerException | NumberFormatException e ) {
            error.add("No message was selected to reply to.");
        }

        List<FBPerson> curators = dao.getCurators(); // people with IS_CURATOR='Y', for the curator dropdown

        if( question != null && "sendReply".equals(request.getParameter("act")) && "POST".equalsIgnoreCase(request.getMethod()) ) {
            if( sendReply(dao, question, curators, request, error) ) {
                // back to the list of messages, which confirms the reply;
                // being a redirect, a browser refresh cannot send the reply a second time
                StringBuilder url = new StringBuilder("home.html?replied=" + question.getMessageId());
                for( String param: new String[]{"token", "startDate", "endDate", "unanswered"} ) {
                    String value = request.getParameter(param);
                    if( value != null && !value.isEmpty() ) {
                        url.append("&").append(param).append("=").append(URLEncoder.encode(value, "UTF-8"));
                    }
                }
                response.sendRedirect(url.toString());
                return null;
            }
            // not sent: the curator and the reply text stay on the page
            request.setAttribute("selectedCuratorId", Utils.defaultString(request.getParameter("curatorId")));
            request.setAttribute("replyText", Utils.defaultString(request.getParameter("reply")));
        }

        request.setAttribute("question", question);
        // the answers already given to the message are shown under it
        request.setAttribute("answers", question == null ? new ArrayList<FBAnswer>() : dao.getAnswers(question.getMessageId()));
        request.setAttribute("curators", curators);
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        return new ModelAndView("/WEB-INF/jsp/curation/feedback/messageReply.jsp");
    }

    /**
     * Saves the reply in FB_ANSWER and emails it to the sender of the message.
     * The answer is not kept if the email cannot be sent.
     * @return true if the reply was saved and emailed; otherwise the reasons are added to errors
     */
    private boolean sendReply(RgdFbDAO dao, FBQuestion question, List<FBPerson> curators, HttpServletRequest request, List<String> errors) {

        String reply = Utils.defaultString(request.getParameter("reply")).trim();
        if( reply.isEmpty() ) {
            errors.add("Please enter a reply.");
        } else if( reply.length() > MAX_ANSWER ) {
            errors.add("The reply is " + reply.length() + " characters long; it can be at most " + MAX_ANSWER + " characters.");
        }

        FBPerson curator = null;
        String curatorId = Utils.defaultString(request.getParameter("curatorId")).trim();
        for( FBPerson c: curators ) {
            if( String.valueOf(c.getPersonId()).equals(curatorId) ) {
                curator = c;
            }
        }
        if( curator == null ) {
            errors.add("Please select the curator who is replying.");
        }

        String email = getReplyEmail(question);
        if( !email.matches(EMAIL_PATTERN) ) {
            errors.add(email.isEmpty() ? "This message has no email address to reply to."
                    : "The email address of this message, '" + email + "', is not valid.");
        }

        if( !errors.isEmpty() ) {
            return false;
        }
        return saveAnswer(dao, question, curator, reply, true, errors);
    }

    /** @return true if the text looks like an email address */
    public static boolean isValidEmail(String email) {
        return email != null && email.matches(EMAIL_PATTERN);
    }

    /**
     * Saves an answer to a message in FB_ANSWER and, if sendEmail is true, emails it to the sender of the message
     * (see getReplyEmail). With sendEmail, the answer is not kept if the email cannot be sent.
     * Used by the reply page and by the list of messages, which answers the selected messages together.
     * @return true if the answer was saved (and emailed); otherwise the reasons are added to errors
     */
    public static boolean saveAnswer(RgdFbDAO dao, FBQuestion question, FBPerson curator, String reply, boolean sendEmail, List<String> errors) {

        int answerId;
        try {
            answerId = dao.insertAnswer(question.getMessageId(), curator.getPersonId(), reply);
        } catch( Exception e ) {
            e.printStackTrace();
            errors.add("The reply could not be saved" + (sendEmail ? ", so it was not sent" : "") + ": " + e.getMessage());
            return false;
        }
        if( !sendEmail ) {
            return true;
        }

        String email = getReplyEmail(question);
        try {
            String subject = "Re: " + Utils.defaultString(question.getSubject()) + " (RGD message ID " + question.getMessageId() + ")";
            String body = reply + "\n" +
                    "\n" +
                    "-----------------------------------------------------------------\n" +
                    "Your message to the Rat Genome Database" +
                    (question.getMessageDate() == null ? "" : " of " + new SimpleDateFormat("MMMM d, yyyy").format(question.getMessageDate())) +
                    " (message ID " + question.getMessageId() + "):\n" +
                    "\n" +
                    Utils.defaultString(question.getMessage());
            MyRGDLookupController.send(email, subject, body);
        } catch( Exception e ) {
            e.printStackTrace();
            errors.add("The reply could not be emailed to " + email + ", so it was not saved: " + e.getMessage());
            try {
                dao.deleteAnswer(answerId);
            } catch( Exception e2 ) {
                e2.printStackTrace();
                errors.add("The unsent reply is still stored as answer " + answerId + " and could not be removed: " + e2.getMessage());
            }
            return false;
        }
        return true;
    }

    /**
     * @return email address a reply to the message goes to: the email of the sender on file;
     * if there is none, the address after "Recipients email:" in the message (added by the Send Message form);
     * empty string if the message has neither
     */
    public static String getReplyEmail(FBQuestion question) {
        String email = Utils.defaultString(question.getEmail()).trim();
        if( email.isEmpty() && question.getMessage() != null ) {
            Matcher m = RECIPIENTS_EMAIL.matcher(question.getMessage());
            if( m.find() ) {
                email = m.group(1);
            }
        }
        return email;
    }

    /**
     * Adds a curator (IS_CURATOR='Y') with the first name, last name and email given in the request.
     * A person who is already on file with that email is marked as a curator instead of being added again.
     */
    private JSONObject addCurator(RgdFbDAO dao, HttpServletRequest request) throws Exception {

        String firstName = Utils.defaultString(request.getParameter("firstName")).trim();
        String lastName = Utils.defaultString(request.getParameter("lastName")).trim();
        String email = Utils.defaultString(request.getParameter("email")).trim();

        if( firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() ) {
            return new JSONObject().put("error", "First name, last name and email are all required.");
        }
        if( firstName.length() > MAX_FIRST_NAME ) {
            return new JSONObject().put("error", "First name can be at most " + MAX_FIRST_NAME + " characters.");
        }
        if( lastName.length() > MAX_LAST_NAME ) {
            return new JSONObject().put("error", "Last name can be at most " + MAX_LAST_NAME + " characters.");
        }
        if( email.length() > MAX_EMAIL ) {
            return new JSONObject().put("error", "Email can be at most " + MAX_EMAIL + " characters.");
        }
        if( !email.matches(EMAIL_PATTERN) ) {
            return new JSONObject().put("error", "'" + email + "' is not a valid email address.");
        }

        FBPerson curator;
        String message;
        List<FBPerson> people = dao.getPeopleByEmailIgnoreCase(email);
        if( people.isEmpty() ) {
            curator = new FBPerson();
            curator.setFirstName(firstName);
            curator.setLastName(lastName);
            curator.setEmail(email);
            curator.setIsCurator("Y");
            dao.insertPerson(curator);
            message = curatorLabel(curator) + " was added as a curator.";
        } else {
            // somebody with this email is on file already (for example from the Contact Us form):
            // that person becomes a curator, with the name as it is on file
            curator = people.get(0);
            if( curator.isCurator() ) {
                message = curatorLabel(curator) + " is already a curator.";
            } else {
                curator.setIsCurator("Y");
                dao.updatePerson(curator);
                message = curatorLabel(curator) + " was already on file and is now a curator.";
            }
        }

        return new JSONObject()
                .put("personId", curator.getPersonId())
                .put("label", curatorLabel(curator))
                .put("message", message);
    }

    /** @return text shown for a curator in the dropdown: "First Last (email)" */
    public static String curatorLabel(FBPerson curator) {
        String name = (Utils.defaultString(curator.getFirstName()) + " " + Utils.defaultString(curator.getLastName())).trim();
        String email = Utils.defaultString(curator.getEmail());
        if( name.isEmpty() ) {
            return email;
        }
        return email.isEmpty() ? name : name + " (" + email + ")";
    }
}
