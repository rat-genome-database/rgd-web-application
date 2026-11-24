package edu.mcw.rgd.feedback;

import edu.mcw.rgd.dao.impl.RgdFbDAO;
import edu.mcw.rgd.datamodel.FBQuestion;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * Start page of the feedback curation tool: lists the messages in FB_QUESTION (RGD_FB) submitted in a date range.
 * Parameters startDate and endDate (yyyy-MM-dd) are both inclusive; without them
 * everything from the month of the oldest message through today is shown.
 * Parameter unanswered=1 leaves only the messages that have not been answered.
 * Access is checked by AuthenticationInterceptor (curation/feedback/*).
 */
public class FeedbackQuestionsController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> error = new ArrayList<>();

        LocalDate endDate = parseDate(request.getParameter("endDate"), "End date", error);
        if( endDate == null ) {
            endDate = LocalDate.now();
        }
        LocalDate startDate = parseDate(request.getParameter("startDate"), "Start date", error);
        RgdFbDAO dao = new RgdFbDAO();
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

        // unanswered=1: only the messages that have no answer yet
        boolean unansweredOnly = "1".equals(request.getParameter("unanswered"));
        if( unansweredOnly ) {
            questions.removeIf(q -> q.getAnswerCount() > 0);
        }

        request.setAttribute("unansweredOnly", unansweredOnly);
        request.setAttribute("questions", questions);
        request.setAttribute("startDate", startDate.toString());
        request.setAttribute("endDate", endDate.toString());
        request.setAttribute("error", error);

        // the reply page comes back here after a reply was sent
        ArrayList<String> status = new ArrayList<>();
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
