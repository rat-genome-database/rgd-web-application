package edu.mcw.rgd.feedback;

import edu.mcw.rgd.dao.impl.RgdFbDAO;
import edu.mcw.rgd.datamodel.FBPerson;
import edu.mcw.rgd.datamodel.FBQuestion;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Start page of the feedback curation tool: lists the messages in FB_QUESTION (RGD_FB) submitted in a date range.
 * Parameters startDate and endDate (yyyy-MM-dd) are both inclusive; without them
 * everything from the month of the oldest message through today is shown.
 * Only the messages that have not been answered are shown, unless parameter unanswered=0 asks for all of them.
 * <p>
 * act=bulkAnswer (POST with messageIds, curatorId and response) answers all selected messages together:
 * response=number of a canned response saves its text in FB_ANSWER and emails it to the sender of every message;
 * response=hidden only saves the answer "hidden", so the messages count as answered without anybody being emailed.
 * <p>
 * Access is checked by AuthenticationInterceptor (curation/feedback/*).
 */
public class FeedbackQuestionsController implements Controller {

    // results of act=bulkAnswer are kept in the session over the redirect back to the list
    private static final String FLASH_STATUS = "feedbackFlashStatus";
    private static final String FLASH_ERROR = "feedbackFlashError";

    /** value of parameter response, and the answer saved, for messages that are hidden without sending an email */
    public static final String HIDDEN = "hidden";

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> error = new ArrayList<>();
        ArrayList<String> status = new ArrayList<>();
        RgdFbDAO dao = new RgdFbDAO();

        List<FBPerson> curators = dao.getCurators(); // people with IS_CURATOR='Y', for the curator dropdown

        if( "bulkAnswer".equals(request.getParameter("act")) && "POST".equalsIgnoreCase(request.getMethod()) ) {
            if( bulkAnswer(dao, curators, request, error, status) ) {
                // back to the list by a redirect, so a browser refresh cannot answer the messages a second time
                HttpSession session = request.getSession();
                session.setAttribute(FLASH_STATUS, status);
                session.setAttribute(FLASH_ERROR, error);

                StringBuilder url = new StringBuilder("home.html?");
                for( String param: new String[]{"token", "startDate", "endDate", "unanswered"} ) {
                    String value = request.getParameter(param);
                    if( value != null && !value.isEmpty() ) {
                        url.append(param).append("=").append(URLEncoder.encode(value, "UTF-8")).append("&");
                    }
                }
                url.setLength(url.length() - 1);
                response.sendRedirect(url.toString());
                return null;
            }
            // nothing was done: the curator, the answer and the selected messages stay on the page
            request.setAttribute("bulkCuratorId", Utils.defaultString(request.getParameter("curatorId")));
            request.setAttribute("bulkResponse", Utils.defaultString(request.getParameter("response")));
            request.setAttribute("bulkMessageIds", getSelectedMessageIds(request));
        } else {
            HttpSession session = request.getSession(false);
            if( session != null ) {
                addAll(status, session.getAttribute(FLASH_STATUS));
                addAll(error, session.getAttribute(FLASH_ERROR));
                session.removeAttribute(FLASH_STATUS);
                session.removeAttribute(FLASH_ERROR);
            }
        }

        LocalDate endDate = parseDate(request.getParameter("endDate"), "End date", error);
        if( endDate == null ) {
            endDate = LocalDate.now();
        }
        LocalDate startDate = parseDate(request.getParameter("startDate"), "Start date", error);
        if( startDate == null ) {
            // by default all messages are shown: start with the first day of the month of the oldest message
            String oldest = dao.getOldestQuestionDate();
            startDate = oldest == null ? endDate.minusYears(1) : LocalDate.parse(oldest).withDayOfMonth(1);
        }
        if( startDate.isAfter(endDate) ) {
            LocalDate tmp = startDate;
            startDate = endDate;
            endDate = tmp;
        }

        // the end date is inclusive: messages up to the end of that day are shown
        List<FBQuestion> questions = new ArrayList<>(dao.getQuestions(
                Timestamp.valueOf(startDate.atStartOfDay()),
                Timestamp.valueOf(endDate.plusDays(1).atStartOfDay())));

        // by default only the messages that have no answer yet are shown; unanswered=0 shows all
        boolean unansweredOnly = !"0".equals(request.getParameter("unanswered"));
        if( unansweredOnly ) {
            questions.removeIf(q -> q.getAnswerCount() > 0);
        }

        request.setAttribute("unansweredOnly", unansweredOnly);
        request.setAttribute("questions", questions);
        request.setAttribute("curators", curators);
        request.setAttribute("startDate", startDate.toString());
        request.setAttribute("endDate", endDate.toString());
        request.setAttribute("error", error);

        // the reply page comes back here after a reply was sent
        String replied = request.getParameter("replied");
        if( replied != null && replied.matches("\\d{1,9}") ) {
            FBQuestion question = dao.getQuestion(Integer.parseInt(replied));
            if( question != null && question.getAnswerCount() > 0 ) {
                status.add("The reply to message " + question.getMessageId() + " was saved and emailed to "
                        + FeedbackMessageReplyController.getReplyEmail(question) + ".");
            }
        }
        request.setAttribute("status", status);
        return new ModelAndView("/WEB-INF/jsp/curation/feedback/home.jsp");
    }

    /**
     * Answers all selected messages with the same text; with mode=email the answer is also emailed to every sender.
     * A message that cannot be answered (for example one without an email address, when emailing) is reported
     * in errors and skipped; the other messages are still answered.
     * @return false if the request was incomplete and no message was touched (the reasons are in errors);
     * true if the messages were processed: what was done is in status, what failed is in errors
     */
    private boolean bulkAnswer(RgdFbDAO dao, List<FBPerson> curators, HttpServletRequest request, List<String> errors, List<String> status) throws Exception {

        // parameter response: the number of a canned response, which is saved and emailed,
        // or "hidden": the answer "hidden" is saved and nobody is emailed
        String responseParam = Utils.defaultString(request.getParameter("response")).trim();
        boolean sendEmail = !responseParam.equals(HIDDEN);
        String answer = null;
        if( !sendEmail ) {
            answer = HIDDEN;
        } else if( responseParam.matches("\\d{1,4}") ) {
            List<FeedbackCannedResponses.CannedResponse> cannedResponses = FeedbackCannedResponses.getResponses();
            int index = Integer.parseInt(responseParam);
            if( index < cannedResponses.size() ) {
                answer = cannedResponses.get(index).getText().trim();
            }
        }
        if( answer == null ) {
            errors.add("Please select the response for the selected messages.");
        } else if( answer.length() > FeedbackMessageReplyController.MAX_ANSWER ) {
            errors.add("The response is " + answer.length() + " characters long; it can be at most "
                    + FeedbackMessageReplyController.MAX_ANSWER + " characters.");
        }

        Set<Integer> messageIds = getSelectedMessageIds(request);
        if( messageIds.isEmpty() ) {
            errors.add("Please select at least one message.");
        }

        FBPerson curator = null;
        String curatorId = Utils.defaultString(request.getParameter("curatorId")).trim();
        for( FBPerson c: curators ) {
            if( String.valueOf(c.getPersonId()).equals(curatorId) ) {
                curator = c;
            }
        }
        if( curator == null ) {
            errors.add("Please select the curator who is answering.");
        }

        if( !errors.isEmpty() ) {
            return false;
        }

        List<Integer> done = new ArrayList<>();
        for( int messageId: messageIds ) {
            FBQuestion question = dao.getQuestion(messageId);
            if( question == null ) {
                errors.add("Message " + messageId + ": there is no such message.");
                continue;
            }
            if( sendEmail && !FeedbackMessageReplyController.isValidEmail(FeedbackMessageReplyController.getReplyEmail(question)) ) {
                errors.add("Message " + messageId + ": it has no valid email address to reply to, so nothing was saved for it.");
                continue;
            }

            List<String> messageErrors = new ArrayList<>();
            if( FeedbackMessageReplyController.saveAnswer(dao, question, curator, answer, sendEmail, messageErrors) ) {
                done.add(messageId);
            }
            for( String messageError: messageErrors ) {
                errors.add("Message " + messageId + ": " + messageError);
            }
        }

        if( !done.isEmpty() ) {
            status.add((sendEmail ? "The canned response was saved and emailed to the sender" : "The answer \"hidden\" was saved without sending an email")
                    + " for " + done.size() + (done.size() == 1 ? " message" : " messages")
                    + " (ID " + Utils.concatenate(done, ", ") + ").");
        }
        return true;
    }

    /** @return IDs of the messages selected with the checkboxes of the list (parameter messageIds) */
    private Set<Integer> getSelectedMessageIds(HttpServletRequest request) {
        Set<Integer> messageIds = new LinkedHashSet<>();
        String[] values = request.getParameterValues("messageIds");
        if( values != null ) {
            for( String value: values ) {
                if( value.matches("\\d{1,9}") ) {
                    messageIds.add(Integer.parseInt(value));
                }
            }
        }
        return messageIds;
    }

    private void addAll(List<String> list, Object messages) {
        if( messages instanceof List ) {
            for( Object message: (List<?>) messages ) {
                list.add(String.valueOf(message));
            }
        }
    }

    /** @return the date, or null if the parameter is missing or not a yyyy-MM-dd date (the latter is reported in errors) */
    private LocalDate parseDate(String value, String label, List<String> errors) {
        if( value == null || value.trim().isEmpty() ) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch( DateTimeParseException e ) {
            errors.add(label + " is not a valid date (expected yyyy-mm-dd); the default was used instead.");
            return null;
        }
    }
}
