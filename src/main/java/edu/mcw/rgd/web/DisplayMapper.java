package edu.mcw.rgd.web;

import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Apr 7, 2009
 * Time: 9:42:21 AM
 */
public class DisplayMapper {

    private HttpRequestFacade req;
    private ArrayList errors;    

    public DisplayMapper(HttpRequestFacade req, ArrayList errors) {
        this.req = req;
        this.errors = errors;
    }

    public String out(String name, String value, int count) {
        if (hasErrors() && req.request.getParameterValues(name) != null) {
            return req.request.getParameterValues(name)[count];
        }else {
            if (value == null) {
                return "";
            }else {
                return value;
            }
        }
    }

    public String out(String name, String value) {
        if (hasErrors()) {
            return req.getParameter(name);
        }else {
            if (value == null) {
                return "";
            }else {
                return value;
            }
        }
    }

    public String out(String name, int value) {
        return out(name, value + "");
    }

    public String out(String name, long value) {
        return out(name, value + "");
    }

    public String out(String name, Long value) {
        if (value == null) {
            return out(name, "");
        }else {
            return out(name, value.toString());
        }
    }

    public String out(String name, Integer value) {
        if (value == null) {
            return out(name, "");
        }else {
            return out(name, value.toString());
        }
    }

    public String out(String name, Float value) {
        if (value == null) {
            return out(name, "");
        }else {
            return out(name, value.toString());
        }
    }

    public String out(String name, Double value) {
        if (value == null) {
            return out(name, "");
        }else {
            return out(name, value.toString());
        }
    }

    public String out(String name, int value, int count) {
        return out(name, value + "", count);
    }

    public String out(String name, long value, int count) {
        return out(name, value + "", count);
    }

    public String out(String name, Long value, int count) {

        String strValue = null;
        if (value != null) {
            strValue=value + "";
        }

        return out(name, strValue, count);
    }

    public String out(String name, Integer value, int count) {
        if (value == null) {
            return out(name, "", count);
        }else {
            return out(name, value.toString(), count);
        }
    }

    public String out(String name, Float value, int count) {
        if (value == null) {
            return out(name, "", count);
        }else {
            return out(name, value.toString(), count);
        }
    }

    public String out(String name, Double value, int count) {
        if (value == null) {
            return out(name, "", count);
        }else {
            return out(name, value.toString(), count);
        }
    }

    public String outForce(String name, Integer value, String nullStr) {
        if (value == null) {
            return out(name, nullStr);
        }else {
            return out(name, value.toString());
        }
    }

    public String outForce(String name, Double value, String nullStr) {
        if (value == null) {
            return out(name, nullStr);
        }else {
            return out(name, value.toString());
        }
    }

    public boolean hasErrors() {
        return (errors!=null && errors.size() > 0);
    }

    /**
     * generate html code like this:
     *
     * <input type="checkbox" name="frameshift" style="border:0px solid black;" value="true"
     * <% if (req.getParameter("frameshift").equals("true")) out.print("checked"); %>> Frameshift

     * @param name checkbox control name
     * @param name checkbox text
     * @return html string for checkbox
     */
    public String makeCheckBox(String name, String text) {
        return "<label><input type=\"checkbox\" name=\""+name+"\" style=\"border:0px solid black;\" value=\"true\""
                + (req.getParameter(name).equals("true") ? "checked" : "")
                + ">" + text + "</label>";
    }
}
