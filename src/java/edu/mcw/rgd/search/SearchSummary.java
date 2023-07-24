package edu.mcw.rgd.search;

import edu.mcw.rgd.datamodel.SpeciesType;
import jakarta.servlet.jsp.JspTagException;
import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.tagext.TagSupport;

import java.io.IOException;

/**
 * @author jdepons
 * @since Jul 9, 2008
 */
public class SearchSummary extends TagSupport {

    private String title;
    private int[] counts;
    private String view;
    private String term;
    private String showDetails = "true";


    public String setShowDetails() {
        return showDetails;
    }

    public void setShowDetails(String showDetails) {
        this.showDetails = showDetails;
    }

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


    public int doStartTag() throws JspTagException {
        try {
            JspWriter out = pageContext.getOut();
            doStartTag(out);
        } catch (Exception ex) {
            throw new JspTagException("All is not well in the world." + ex );
        }
        // Evaluate the body if there is one
        return 1;
    }

    // show data for rat, mouse and human
    public void doStartTag(JspWriter out) throws IOException {
        int totalCount = counts[0] + counts[1] + counts[2] + counts[3] + counts[4] + counts[5] + counts[6] + counts[7];

        if (totalCount > 0) {
            out.println("<div style=\"background-color: #cccccc; color: #0c1d2e;\"><b>" + title.toUpperCase() + "</b></a></div>");
            out.println("<b>" + totalCount + " Found</b>&nbsp;&nbsp;&nbsp;");

            if(!(counts[1] == totalCount || counts[2] == totalCount || counts[3] == totalCount || counts[4] == totalCount || counts[5] == totalCount || counts[6] == totalCount || counts[7] == totalCount) || !Boolean.parseBoolean(showDetails)) {
                out.print("<a href=\"" + view + "?term=" + term + "&speciesType=0\">View " + title + " for All Species</a><br>");
            }

            if (Boolean.parseBoolean(showDetails)) {
                out.println("<table>");

                //for (int i=7; i>=0; i--) {
                    //printRow(out, i);
                    printRow(out, 3);
                    printRow(out, 2);
                    printRow(out, 1);
                    printRow(out, 4);
                    printRow(out, 5);
                    printRow(out, 6);
                    printRow(out, 7);
                //}
                out.println("</table><br>");
            } else {
                out.println("<p>");
            }
        }
    }

    void printRow(JspWriter out, int i) throws IOException {
        if (counts[i] > 0 ) {
            out.println("<tr> ");
            out.println("    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>");
            out.println("    <td>" + SpeciesType.getTaxonomicName(i) + "</td>");
            out.println("    <td>&nbsp;</td>");
            out.println("    <td align=\"center\" width='40'>" + counts[i] + "</td>");
            out.println("    <td>&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"" + view + "?term=" + term + "&speciesType=" + i + "\">View " + SpeciesType.getCommonName(i) + " " + title + " Report</a>");
            out.println("</tr>");
        }
    }
}
