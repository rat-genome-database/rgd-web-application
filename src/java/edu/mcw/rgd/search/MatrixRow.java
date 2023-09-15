package edu.mcw.rgd.search;

import jakarta.servlet.jsp.tagext.TagSupport;
import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.JspTagException;
import java.io.IOException;

/**
 * @author jdepons
 * @since Jul 9, 2008
 * tag lib class to display rows of the result matrix for the RGD search.
 */
public class MatrixRow extends TagSupport {

    //object title
    private String title;
    //object count
    private int[] counts;
    //view url to use for link
    private String view;
    // search term (used in url)
    private String term;

    public String getTerm() {
        return term;
    }

    public void setTerm(String term) {
        this.term = term;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int[] getCounts() {
        return counts;
    }

    public void setCounts(int[] counts) {
        this.counts = counts;
    }

    public String getView() {
        return view;
    }

    public void setView(String view) {
        this.view = view;
    }

    /**
     * Print out a table row for the object data passed in by the tag
     * @return
     * @throws JspTagException
     */
    public int doStartTag() throws JspTagException{
        try {
            JspWriter out = pageContext.getOut();                          
            out.println("  <tr>   ");
            out.println("      <td class=\"grayBg\">" + title + ":</td>");

            printValue(counts[3], 3, out);
            printValue(counts[2], 2, out);
            printValue(counts[1], 1, out);
            printValue(counts[4], 4, out);
            printValue(counts[5], 5, out);
            printValue(counts[6], 6, out);
            printValue(counts[7], 7, out);

            out.println("  </tr>  ");
        } catch (Exception ex) {
            throw new JspTagException("All is not well in the world." + ex );
        }
        // Evaluate the body if there is one
        return 1;
    }

    void printValue(int count, int speciesTypeKey, JspWriter out) throws IOException {
        if (count == 0 ) {
            out.println("<td>0</td>");
        }else {
            out.println("      <td><a href=\"" + view + "?term=" + term + "&speciesType=" + speciesTypeKey + "\">" + count + "</a></td>");
        }
    }
}
