package edu.mcw.rgd.feedback;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Canned responses of the feedback curation tool: ready-made replies a curator can pick on the reply page
 * (messageReply.html). The chosen text is copied into the reply box, where it can be edited before it is sent.
 * <p>
 * To add a canned response, add one more add(...) line to the static block below:
 * the title is what the dropdown shows, the text is what goes into the reply box.
 */
public class FeedbackCannedResponses {

    public static class CannedResponse {
        private final String title;
        private final String text;

        public CannedResponse(String title, String text) {
            this.title = title;
            this.text = text;
        }

        /** @return short name shown in the dropdown */
        public String getTitle() {
            return fillIn(title);
        }

        /** @return the reply text */
        public String getText() {
            return fillIn(text);
        }
    }

    /** placeholder for the year after the current one: in 2027 it becomes 2028 */
    public static final String NEXT_YEAR = "{NEXT_YEAR}";

    // the placeholders are filled in when a response is shown, so the year follows the calendar without a code change
    private static String fillIn(String s) {
        return s.replace(NEXT_YEAR, String.valueOf(java.time.Year.now().getValue() + 1));
    }

    private static final List<CannedResponse> RESPONSES = new ArrayList<>();

    static {
        // canned responses, in the order they are listed in the dropdown, for example:
        // add("Title shown in the dropdown",
        //         "First line of the reply\n" +
        //         "\n" +
        //         "Second paragraph of the reply");
        // {NEXT_YEAR} in a title or a text becomes the year after the current one.

        add("RGD " + NEXT_YEAR + " Calendar Request",
                "Thank you for your interest in the Rat Genome Database " + NEXT_YEAR + " Calendar!\n" +
                "\n" +
                "We can only ship physical calendars to verified academic/research institutions, laboratory personnel, " +
                "and RGD photo contributors. (If you are a researcher who emailed from a personal account, " +
                "please reply from your institutional email address with your lab affiliation so we can fulfill your request.)\n" +
                "\n" +
                "However, you are welcome to download and print the full high-resolution PDF calendar from our website:\n" +
                "https://download.rgd.mcw.edu/data_release/Hi-res_Rat_Calendars/\n" +
                "\n" +
                "Thank you again for your interest in RGD!");
    }

    private static void add(String title, String text) {
        RESPONSES.add(new CannedResponse(title, text));
    }

    /** @return all canned responses, in the order they are listed in the dropdown */
    public static List<CannedResponse> getResponses() {
        return Collections.unmodifiableList(RESPONSES);
    }
}
