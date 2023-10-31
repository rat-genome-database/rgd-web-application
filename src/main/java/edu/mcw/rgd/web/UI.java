package edu.mcw.rgd.web;


import jakarta.mail.internet.AddressException;
import jakarta.mail.internet.InternetAddress;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: May 26, 2011
 * Time: 1:32:02 PM
 * To change this template use File | Settings | File Templates.
 */
public class UI {

    public String dynOpen(String id, String displayName) {
        String html = "";

        html += "<div id=\"" + id + "\" class=\"reportSection\"><img id=\"" + id + "_i\" src=\"/rgdweb/common/images/add.png\"  />";
        html += displayName + "</div><div style='display:none' id=\"" + id + "_content\">";

        return html;

    }

    public String dynClose(String id) {
        String html = "</div><script type=\"text/javascript\">regHeader(\"" + id + "\");</script>";
        return html;
    }

    public static String getRGBValue(int currentValue, int maxValue) {

        if (maxValue < 1) {
            maxValue=1;
        }

        double value = ((double) currentValue/ (double) maxValue );   // first you should normalize to a number between 0 and 1

        int aR = 232;
        int aG = 228;
        int aB=213;  // rgb for our 1st color (blue in this case)
        int bR = 119;
        int bG = 20;
        int bB=40;    // rbg for our 2nd color (red in this case)
        double red = (bR - aR) * value + aR;      // evaluated as -255*value + 255
        double green = (bG - aG) * value + aG;      // evaluates as 0
        double blue  = (bB - aB) * value + aB;      // evaluates as 255*value + 0

        return "rgb(" + (int) red + "," + (int) green + "," + (int) blue + ")";

    }

    public static boolean isValidEmailAddress(String email) {
        boolean result = true;
        try {
            InternetAddress emailAddr = new InternetAddress(email);
            emailAddr.validate();
        } catch (AddressException ex) {
            result = false;
        }
        return result;
    }

}
