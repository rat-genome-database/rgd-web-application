package edu.mcw.rgd.web;

import jakarta.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Feb 8, 2008
 * Time: 11:22:47 AM
 * <p>
 * This class is included for convenience when working with a UI.  It is initialized
 * by passing an HttpServletRequest Object.  Calls to get parameter will return a
 * string instead of null (the default behavior of HttpServletRequest).
 */
public class HttpRequestFacade {

    HttpServletRequest request;

    public HttpRequestFacade(HttpServletRequest request) {
        this.request = request;
    }

    public HttpServletRequest getRequest() {
        return this.request;
    }

    /**
     * Returns a parameter from the HttpServletRequest object passed to the
     * constructor.  This method will return an empty string instead of null
     * if the parameter does not exist.
     * @param name
     * @return
     */
    public String getParameter(String name) {
        return stringForNull(this.request.getParameter(name));
    }

    /**
     * Returns a parameter from the HttpServletRequest object passed to the
     * constructor.  This method will return an empty string instead of null
     * if the parameter does not exist.
     * @param name
     * @return
     */
    public String getParameterOriginal(String name) {
        return this.request.getParameter(name);
    }

    /**
     * Returns a parameter from the HttpServletRequest object passed to the
     * constructor.  This method will return an empty string instead of null
     * if the parameter does not exist.
     * @param name
     * @return
     */
    public List<String> getParameterValues(String name) {
        List l = new ArrayList();

        String[] s = this.request.getParameterValues(name);



        if (s != null) {
            for (int i=0; i< s.length; i++) {
                l.add(stringForNull(s[i]));
            }
        }        
        return l;
    }

    private String stringForNull(String str) {
        if (str == null) {
            return "";
        }

        //str.replaceAll("'", "''");
        //str.replaceAll(";", "");
        //str.replaceAll("--", "");

        return str.trim();
    }


    public boolean isSet(String name) {
        if (this.getParameter(name).equals("")) {
            return false;
        }else {
            return true;
        }
    }


    public boolean isInParameterValues(String name, String value) {
        String[] s = this.request.getParameterValues(name);

        if (s != null) {
            for (int i=0; i< s.length; i++) {
                if (stringForNull(s[i]).equals(value)) {
                    return true;
                }
            }
        }
        return false;

    }
}
