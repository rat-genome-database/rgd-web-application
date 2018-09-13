package edu.mcw.rgd.security;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 10/3/13
 * Time: 9:50 AM
 * <br>
 * Custom login control
 */
public class MyRgd extends SimpleTagSupport {

    public void doTag() throws JspException, IOException {
    JspWriter out = getJspContext().getOut();
    out.println("<div style=\"height:100px;width:200px;border:1px dotted red;background-color:yellow;color:red;\">");
    out.println("<span style=\"font-size:large;font-weight:bold;\">My Variant Visualizer</span>");
    out.println("<br>");
    out.println("<a href=''>Log In</a>");
    out.println("</div>");
  }
}
