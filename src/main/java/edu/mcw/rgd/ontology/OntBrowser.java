package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.pathway.PathwayDiagramController;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.RgdContext;

import jakarta.servlet.ServletRequest;
import jakarta.servlet.jsp.JspWriter;
import java.io.IOException;
import java.util.Collection;

/**
 * @author mtutaj
 * @since 10/17/13
 * ontology tree browser: a header pane + 3 term panes
 * <p>
 * param 'diagramMode': applies only for pathway terms;
 *   only terms with diagrams or having child terms with diagrams are shown;
 *   annotation icons are not shown any longer, only count of diagrams
 */
public class OntBrowser {

    OntViewBean bean = null;

    private String url; // url of the page the control is embedded with, for example: '/rgdweb/ontology/view.html?mode=popup';
    // acc_id parameters (and others, as needed, fe 'offset') will be added to the url on-the-fly
    private String offset = ""; // used to reduce window jitter when clicking sibling terms
    private String opener_sel_acc_id; // id of opener window's input control that should receive accession id of selected term
    private String opener_sel_term; // id of opener window's input control that should receive term name of selected term
    private String filter; // ontology term filter
    private boolean showSelectButton;
    private boolean alwaysShowSelectButton = false;
    private boolean iframe = false;
    private boolean diagramMode = false;

    //private boolean singlePageApplication=true;
    private boolean hideZeroAnnotations=false;
    //added for support by the disease portal.  Links work differently when true
    private boolean portalVersion = false;

    // true if we are on CURATOR server
    private boolean isCurator = false;
    //
    private String curationTool;
    public void setAcc_id(String accId, ServletRequest req) {

        bean = new OntViewBean();
        try {
            diagramMode = Utils.NVL(req.getParameter("dia"),"0").equals("1");
            curationTool = Utils.NVL(req.getParameter("curationTool"), "");
            bean.setDiagramMode(diagramMode);

            this.filter = req.getParameter("filter");

            OntViewController.populateBean(accId, null, bean, this.filter);
            OntologyXDAO oxdao = new OntologyXDAO();

            bean.getTerm().setTerm(oxdao.getTermByAccId(bean.getAccId()).getTerm());

            isCurator = RgdContext.isCurator();

        } catch (Exception e) {
            System.out.println("<h1>ERROR</h1><pre>" + e.toString() + "</pre>");
        }
    }

    public void setUrl(String url) {
        this.url = url.indexOf('?')>=0 ? url+"&" : url+"?";

        if( this.url.contains("always_select=1") || this.url.contains("select_always=1") )
            alwaysShowSelectButton = true;

        if( this.url.contains("mode=iframe") )
            iframe = true;
    }

    public void setOffset(String offset) {
        this.offset = offset;
    }

    public void setOpener_sel_acc_id(String opener_sel_acc_id) {
        this.opener_sel_acc_id = opener_sel_acc_id;
    }

    public void setOpener_sel_term(String opener_sel_term) {
        this.opener_sel_term = opener_sel_term;
    }

    public void setFilter(String filter) {
        this.filter= filter;
    }

    private boolean canShowSelectButton() {
        return !Utils.isStringEmpty(this.opener_sel_acc_id) ||
                !Utils.isStringEmpty(this.opener_sel_term);
    }


    public void doTag(ServletRequest req, JspWriter out) throws IOException {

        showSelectButton = canShowSelectButton();

        if (req.getParameter("pv") != null && req.getParameter("pv").equals("1")) {
            this.portalVersion=true;
            this.hideZeroAnnotations=true;
        }

        out.print(generateHeader());
        out.print(generateThreePanes());
        out.print(getScript());
    }

    private String generateHeader() {

        int diagramCount = 0; // set only in diagram mode
        String termName = "";
        TermWithStats ts = (TermWithStats)bean.getTerm();
        String annotMsg = "";
        if( ts!=null) {
            diagramCount = ts.getDiagramCount(1);
            termName = ts.getTerm();

            if (!portalVersion) {
                annotMsg = " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Rat#annot'>Rat: (" + ts.getAnnotObjectCountForSpecies(3) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Mouse#annot'>Mouse: (" + ts.getAnnotObjectCountForSpecies(2) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Human#annot'>Human: (" + ts.getAnnotObjectCountForSpecies(1) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Chinchilla#annot'>Chinchilla: (" + ts.getAnnotObjectCountForSpecies(4) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Bonobo#annot'>Bonobo: (" + ts.getAnnotObjectCountForSpecies(5) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Dog#annot'>Dog: (" + ts.getAnnotObjectCountForSpecies(6) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Squirrel#annot'>Squirrel: (" + ts.getAnnotObjectCountForSpecies(7) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Pig#annot'>Pig: (" + ts.getAnnotObjectCountForSpecies(9) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Naked Mole-rat#annot'>Naked Mole-rat: (" + ts.getAnnotObjectCountForSpecies(14) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Green Monkey#annot'>Green Monkey: (" + ts.getAnnotObjectCountForSpecies(13) + ")</a>";
                annotMsg += " <a href='/rgdweb/ontology/annot.html?acc_id=" + bean.getAccId() + "&species=Black Rat#annot'>Black Rat: (" + ts.getAnnotObjectCountForSpecies(17) + ")</a>";
            }
        }

        String html;

        if (!portalVersion) {

            html =
                    "<div style=\"border: 1px solid black;  background-color:#F6F6F6; margin: 5px; padding:5px; \">\n" +
                            "<table border=0 align=\"center\" width=\"60%\" >\n" +
                            "  <tr>\n" +
                            "    <td valign=\"top\" align=\"center\"  colspan=2 style=\"font-size:18px; color:#2865A3; font-weight:700;\">" + termName
                            + " <span style=\"font-size:14px;\">(" + bean.getAccId() + ")</span></td>\n" +
                            "  </tr>\n" +
                            "  <tr>\n";
        }else {
            html =
                    "<div style=\"border: 1px solid black;  background-color:#F6F6F6; margin: 5px; padding:5px; \">\n" +
                            "<table border=0 align=\"center\" width=\"60%\" >\n" +
                            "  <tr>\n" +
                            "<td width=200><input type=\"button\" value=\"<< Back\" style=\"background-color:#FF7B23;\" class=\"btn btn-info btn-lg\" onClick=\"browserBack()\"/></td>" +
                            "    <td valign=\"top\" align=\"center\"  colspan=2 style=\"font-size:18px; color:#2865A3; font-weight:700;\">" + termName
                            + " <span style=\"font-size:14px;\">(" + bean.getAccId() + ")</span></td>\n" +
                            "<td width=200>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>" +
                            "  </tr>\n" +

                            "  <tr>\n";
        }

        if (!portalVersion) {
            if (diagramMode) {
                html += "   <td colspan=2 style=\"font-size:14px;\" align=\"center\">" + diagramCount + " pathway diagrams for this term and its child terms.";
                if (ts.getDiagramCount(0) > 0) { // if there is pathway diagram for this term
                    html += " <a href=\"" + Link.pathwayDiagram(bean.getAccId()) + "\">(View Interactive Pathway Diagram)</a>";
                }
                html += " &nbsp; &nbsp; <a href='" + Link.ontView(bean.getAccId()) + "' style='border:black 1px solid; background-color:white; font-weight:bold'>Standard Pathway Browser</a>";
            } else { // annot mode
                html += "   <td colspan=2 style=\"font-size:14px;\" align=\"center\"><b>Annotations:</b> " + annotMsg;
                if (diagramCount > 0) {
                    html += " &nbsp; &nbsp; <a href='" + Link.ontView(bean.getAccId()) + "&dia=1' style='border:black 1px solid; background-color:white; font-weight:bold'>Pathway Diagram Browser</a>";
                }
            }

        }

        html += """
                 </td>
              </tr>
            </table>
            </div>

            <table width="100%">
            <tr>
              <td width="30%" align="center" style="font-weight:700;color: white; background-image: url(/rgdweb/common/images/bg3.png);">Parent Terms</td>
              <td width="40%" align="center" style="font-weight:700;color: white; background-image: url(/rgdweb/common/images/bg3.png);">Term With Siblings</td>
              <td width="30%" align="center" style="font-weight:700;color: white; background-image: url(/rgdweb/common/images/bg3.png);">Child Terms</td>
            </tr>
            </table>
            """;
        return html;
    }

    private String generateThreePanes() {
        StringBuilder html = new StringBuilder(2000);
        html.append("<div id=\"browser\" style=\"padding-top:0px\">\n");
        html.append(" <table border=0 width=100%>\n");
        html.append("  <tr>\n");

        generateParentTermsPane(html);
        generateSiblingTermsPane(html, this.filter);
        generateChildTermsPane(html);

        html.append("  </tr>\n");
        html.append(" </table>\n");
        html.append("</div>\n");

        return html.toString();
    }

    private void generateParentTermsPane(StringBuilder out) {
        generateTermsPane(out, "30%", "parent_terms", bean.getAncestorTerms(), "right");
    }

    private void generateSiblingTermsPane(StringBuilder out, String filter) {

        out.append("<td valign=\"top\" style=\"max-width:40vw;overflow:auto;\">\n");
        out.append("  <div id=\"viewer\" class=\"tree_box\">\n");

        if( bean.getSiblingTerms()!=null ) {
            // compute row nr for selected term
            int row = 0; // current row nr
            int selRow = 0; // row nr for selected term


            for( OntDagNode node: bean.getSiblingTerms() ) {

                row++; // next row nr for sibling

                if( node.getTermAcc().equals(bean.getAccId())) {
                    selRow = row; // the sibling term is the selected term!!!
                    break;
                }
            }
            row = 0; // row nr for sibling term

            int skipCount = 0;
            for( OntDagNode node: bean.getSiblingTerms() ) {

                //if term has no annotations don't show
                if (hideZeroAnnotations && node.getAnnotCountForTermAndChilds()<1) {
                    skipCount++;
                    continue;
                }

                row++; // next row nr for sibling

                if( row == (selRow - skipCount)  ) {
                    out.append("<div id=\"sibling_terms\" >\n");
                }

                out.append("<div class='tp'>");

                if( showSelectButton ) {
                    out.append(generateSelectButton(node));
                }

                if ( portalVersion ) {

                    out.append("<span class='sibterm' id='" + node.getTermAcc() + "' onClick='browse(\"" + node.getTermAcc() + "\",\"" + node.getTerm().replaceAll("'s","") + "\")' >")
                            .append(node.getTerm().replace('_', ' '))
                            .append("</span>");
                }else {
                    out.append("<span class='sibterm' id='")
                            .append(node.getTermAcc())
                            .append("' onclick=keepY(this) >")
                            .append(node.getTerm().replace('_', ' '))
                            .append("</span>");
                }

                // write '+' if child terms are present
                // show link to annotations, if there are any
                // show link to pathway diagram, if any
                // show link to pathway diagram, if any
                generateIcons(out, node);

                if( row == (selRow - skipCount) ) {
                    // selected term: show link to strain report page, if applicable at the end of the line
                    if( bean.getStrainRgdId()!=0 ) {
                        out.append("&nbsp; &nbsp; <a href=\"").append(Link.strain(bean.getStrainRgdId())).append("\"> (View Strain Report)</a>\n");
                    }

                    // selected term: show term definition below term name, if available
                    String definition = Utils.defaultString(bean.getTerm().getDefinition());
                    // display pathway mini diagram if available
                    if( bean.getAccId().startsWith("PW") ) {
                        out.append(generatePathwayMiniDiagram(definition));
                    } else {
                        out.append("<br><div class=\"seltermdef\">").append(definition).append("</div>\n");
                    }


                    // selected term: show curation notes, if available, but only on CURATION servers
                    if( isCurator ) {
                        String comment = Utils.defaultString(bean.getTerm().getComment());
                        // display pathway mini diagram if available
                        if ( !comment.isEmpty() ) {
                            out.append("<br><div class=\"seltermcomment\">").append(comment).append("</div>\n");
                        }
                    }

                    out.append("</div>");
                } else {
                    out.append("</br>");
                }

                out.append("</div>\n");
            }
        }

        out.append("  </div>\n")
                .append("</td>\n");
    }


    private void generateChildTermsPane(StringBuilder out) {
        generateTermsPane(out, "30%", "child_terms", bean.getChildTerms(), "left");
    }

    private void generateTermsPane(StringBuilder out, String width, String id,
                                   Collection<OntDagNode> nodes, String showRelImages) {
        String curTool = "";
        if (!Utils.isStringEmpty(curationTool))
            curTool = "&curationTool=1";
//        System.out.print(id+"\n"+nodes.size());
        if(id.equals("child_terms")&&nodes.size()>0){
            out.append("<td valign=\"top\" style=\"max-width:30vw;overflow:auto;\">\n");
        }
        else {
            out.append("<td valign=\"top\" width=").append(width).append(">\n");
        }
        out.append("  <div id=\"").append(id).append("\" class=\"tree_box\">\n");

        if( nodes!=null ) {
            for( OntDagNode node: nodes ) {


                //if term has no annotations don't show
                if (hideZeroAnnotations && node.getAnnotCountForTermAndChilds()<1) {
                    //skipCount++;
                    continue;
                }

                out.append("<div class='tp'>");

                if( showSelectButton )
                    out.append(generateSelectButton(node));

                // term relation image -- could be null
                if( showRelImages.equals("left") ) {
                    String image = OntViewBean.getRelationImage(node.getOntRel());
                    if( image!=null ) {
                        out.append("<img class='rel' src='/common/images/").append(image).append("' title='").append(node.getOntRel()).append("'>&nbsp;");
                    }
                }

                if ( portalVersion ) {

                    out.append("<span class='sibterm' id='" + node.getTermAcc() + "' onClick='browse(\"" + node.getTermAcc() + "\",\"" + node.getTerm().replaceAll("'s","") + "\")' >")
                            .append(node.getTerm().replace('_', ' '))
                            .append("</span>");


                }else {
                    out.append("<a id=\"").append(node.getTermAcc()).append("\" href=\"").append(this.url).append("acc_id=").append(node.getTermAcc()).append(curTool).append("\">").append(node.getTerm().replace('_', ' ')).append("</a>");
                }

                // write '+' if child terms are present
                // show link to annotations, if there are any
                // show link to pathway diagram, if any
                // show link to pathway diagram, if any
                generateIcons(out, node);

                // term relation image -- could be null
                if( showRelImages.equals("right") ) {
                    String image = OntViewBean.getRelationImage(node.getOntRel());
                    if( image!=null ) {
                        //out += "<div class='prel'>";
                        //out += "<img class='rel' src='/common/images/"+image+"'>";
                        //out += "</div>";
                        out.append("&nbsp;&nbsp;<img class='rel' src='/common/images/").append(image).append("' title='").append(node.getOntRel()).append("'>");
                    }
                }

                out.append("</div>\n");
            }
        }

        out.append("  </div>\n");
        out.append("</td>\n");
    }

    // child count icon '+'
    // annotation icon [A]
    // pathway diagram icon [D]
    private void generateIcons(StringBuilder out, OntDagNode node) {


        // write '+' if child terms with diagrams are present -- in diagram mode
        if( diagramMode ) {
            if (node.getCountOfPathwayDiagramsForTermChilds() > 0) {
                out.append("<span title=\"").append(node.getCountOfPathwayDiagramsForTermChilds()).append(" child term(s) have interactive pathway diagrams\" class='cc'>&nbsp;+</span> ");
            }
        } else {
            // write '+' if child terms are present -- in normal mode
            if (node.getChildCount() > 0) {
                out.append("<span title=\"").append(node.getChildCount()).append(" child terms\" class='cc'>&nbsp;+</span> ");
            }
        }

        //if (this.portalVersion) {
        //    return;
        // }

        // show link to annotations, if there are any
        if( !diagramMode && node.getAnnotCountForTermAndChilds()>0 ) {
            if (portalVersion) {
                out.append("&nbsp;<a class='annotlnk' target='_blank' title=\"show term annotations\" href=\"").append(Link.ontAnnot(node.getTermAcc())).append("\"></a>");
            }else {
                out.append("&nbsp;<a class='annotlnk' title=\"show term annotations\" href=\"").append(Link.ontAnnot(node.getTermAcc())).append("\"></a>");

            }

        }

        // show link to pathway diagram, if any
        if( node.isHasPathwayDiagram() ) {
            out.append("&nbsp;<a class='diaglnk' title=\"view interactive pathway diagram\" href=\"").append(Link.pathwayDiagram(node.getTermAcc())).append("\"></a>");
        }

        // show link to pathway diagram, if any
        if( !diagramMode && node.getCountOfPathwayDiagramsForTermChilds()>0 ) {
            out.append("&nbsp;<span class='diaglnkdot' title=\"").append(node.getCountOfPathwayDiagramsForTermChilds()).append(" child term(s) have interactive pathway diagrams\"></span>");
        }

        if (!hideZeroAnnotations) {
            out.append("&nbsp;<a class='binoculars' ng-click=\"rgd.addWatch('" + node.getTermAcc() + "')\" title='launch term watcher'></a>");
        }
    }

    private String generatePathwayMiniDiagram(String definition) {

        String diagramImageUrl;
        try {
            diagramImageUrl = new PathwayDiagramController().generateContent("small", bean.getAccId());
        }
        catch( Exception e ) {
            diagramImageUrl = "";
        }

        //String diagramImageUrl = "/pathway/PW0000363/leptin%20system%20pathway/pwmap.png";
        if( !diagramImageUrl.isEmpty() ) {
            return
                "<table>"
                + "  <tr>"
                + "    <td><div class=\"seltermdef\">"+definition+"</div></td>"
                + "    <td valign=\"top\" style=\"\">"
                + "     <a href=\""+Link.pathwayDiagram(bean.getAccId())+"\" title=\"view interactive pathway diagram\">"
                + "     <img src=\""+diagramImageUrl+"\" alt=\"\" style=\"width:150px;\" border=\"1\"/><br/>"
                + "     View Interactive Diagram</a>"
                + "    </td>"
                + " </tr>"
                + "</table>";
        } else {
            return "<br><div class=\"seltermdef\">"+definition+"</div>\n";
        }
    }

    private String generateSelectButton(OntDagNode node) {
        if( alwaysShowSelectButton || node.getAnnotCountForTermAndChilds()>0 || !Utils.isStringEmpty(this.curationTool)) {
            return "<span class='term_select' onclick=\"selectTerm('"+node.getTermAcc()+"','"+ node.getTerm().replaceAll("\'","\\\\'")+"')\">select</span>&nbsp;";
        } else {
            return "<span class='term_select_disabled'>select</span>&nbsp;";
        }
    }

    private String getScript() {
        String curTool = "";
        if (!Utils.isStringEmpty(curationTool)) {
            curTool = "&curationTool=1";
        }
        String selectTermFunction = "function selectTerm(accId,termName) {\n";
        //String opener = iframe ? "  window.parent" : "  window.opener";
        String opener = "window.parent";

        if( !Utils.isStringEmpty(this.opener_sel_acc_id) ) {
            //selectTermFunction += opener + (iframe ? ".postMessage(accId+'|'+termName, '*');\n" :
            //       ".document.getElementById('"+this.opener_sel_acc_id+"').value=accId;\n");
            selectTermFunction += opener + (true ? ".postMessage(accId+'|'+termName, '*');\n" :
                    ".document.getElementById('"+this.opener_sel_acc_id+"').value=accId;\n");
        }
        if( !Utils.isStringEmpty(this.opener_sel_acc_id) ) {
            selectTermFunction +=
                    opener + ".document.getElementById('"+this.opener_sel_acc_id+"').value=accId;\n";
        }
        if( !Utils.isStringEmpty(this.opener_sel_term) ) {
            selectTermFunction +=
                    opener + ".document.getElementById('"+this.opener_sel_term+"').value=termName;\n";
        }
        selectTermFunction += "  window.close();\n";
        selectTermFunction += "}\n";

        return "<script>\n" +
                selectTermFunction +
                "\n" +
                "    function keepY(obj) {\n" +
                "        var v = document.getElementById(\"viewer\");\n" +
                "        var offset = obj.offsetTop - v.scrollTop;\n" +
                "        window.self.location.href=\""+this.url+"acc_id=\" + obj.id + \"&offset=\" + offset +\""+curTool+"\";\n" +
                "    }\n" +
                "\n" +
                "    function loadIt() {\n" +
                "        var obj = document.getElementById(\""+bean.getAccId()+"\");\n" +
                "        objTop = obj.offsetTop;\n" +
                "        var offset = "+this.offset+";\n" +
                "\n" +
                "        if (offset) {\n" +
                "            document.getElementById(\"viewer\").scrollTop=objTop - offset;\n" +
                "        }else {\n" +
                "            document.getElementById(\"viewer\").scrollTop=objTop - 11;\n" +
                "        }\n" +
                "    }\n" +
                "    onload=loadIt;\n" +
                "\n" +
                "</script>";
    }

    public void setCurationTool(String curationTool) {
        this.curationTool = curationTool;
    }
}