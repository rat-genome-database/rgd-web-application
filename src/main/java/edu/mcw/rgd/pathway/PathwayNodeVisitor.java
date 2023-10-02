package edu.mcw.rgd.pathway;

import edu.mcw.rgd.reporting.Link;
import org.htmlparser.Parser;
import org.htmlparser.Tag;
import org.htmlparser.filters.StringFilter;
import org.htmlparser.util.NodeList;
import org.htmlparser.visitors.NodeVisitor;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Feb 18, 2008
 * Time: 10:53:59 AM
 */

/**
 * Visitor class used to operate on nodes of the html file built by pathway studio.  When
 * nodes that contain links to resources contained in RGD are found, the link is replaced with
 * a link to RGD
 */
public class PathwayNodeVisitor extends NodeVisitor{

    private static String uploadingDir;
    private static String dataDir;
    private String acc_id;


    public String getUploadingDir() {
        return uploadingDir;
    }

    public void setUploadingDir(String uploadingDir) {
        this.uploadingDir = uploadingDir;
    }


    public static String getDataDir() {
        return dataDir;
    }

    public void setDataDir(String dataDir) {
        this.dataDir = dataDir;
    }


    public String getAcc_id() {
        return acc_id;
    }

    public void setAcc_id(String acc_id) {
        this.acc_id = acc_id;
    }



    /**
     *When nodes that contain links to resources contained in RGD are found, the link is replaced with 
     * a link to RGD*
     * @param tag
     */

    public void visitTag(Tag tag){
        String mainTag = "";
        if (tag.getTagName().toLowerCase().equals("area")) {

            String href = tag.getAttribute("href");
            if(href.contains("%5C")){
                href = href.replaceAll("\\%5C","/");
            }

            tag.removeAttribute("target");

            if(href.contains("http://")){
                mainTag = href;
                tag.setAttribute("href", mainTag);
            }else{
                try {

                    //Parser parser = new Parser(wwwDir+ "/pathway/"+ href);
                    Parser parser = new Parser(uploadingDir+acc_id+"/"+href);

                    parser.reset();
                    NodeList nl = parser.extractAllNodesThatMatch(new StringFilter("RGD ID"));

                    if (nl.size() > 0) {
                        String rgdId = nl.elementAt(0).getParent().getNextSibling().getNextSibling().getChildren().elementAt(0).toHtml().trim();
                        tag.setAttribute("href", Link.gene(Integer.parseInt(rgdId)));
                        return;
                    }

                    parser.reset();

                    nl = parser.extractAllNodesThatMatch(new StringFilter("PW:ID"));
                    if (nl.size() > 0) {
                        String pwId = nl.elementAt(0).getParent().getNextSibling().getNextSibling().getChildren().elementAt(0).toHtml().trim();
                        tag.setAttribute("href","/rgdweb/ontology/annot.html?acc_id=" + pwId);
                        return;
                    }

                    parser.reset();

                    nl = parser.extractAllNodesThatMatch(new StringFilter("ListLink"));
                    if (nl.size() > 0) {
                        tag.setAttribute("href", findReplacementUrl(nl));
                        return;
                    }

                    parser.reset();

                    nl = parser.extractAllNodesThatMatch(new StringFilter("LinkURL"));
                    if (nl.size() > 0) {
                        tag.setAttribute("href", findReplacementUrl(nl));
                        return;
                    }

                    tag.removeAttribute("href");

                }catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        if (tag.getTagName().toLowerCase().equals("img")) {
            String ref = tag.getAttribute("src");

            tag.setAttribute("src", "/pathway/"+acc_id+"/"+ ref);
        }
    }

    String findReplacementUrl(NodeList nl) {
        String url = "";
        NodeList nodes = nl.elementAt(0).getParent().getNextSibling().getNextSibling().getChildren();
        //System.out.println("ZZLink Url here******: "+nodes);
        for (int i=0; i< nodes.size(); i++) {
            if (nodes.elementAt(i) instanceof org.htmlparser.tags.LinkTag) {
                url = nodes.elementAt(i).getChildren().elementAt(0).toHtml().trim();
            }
        }
        // remove 'http://rgd.mcw.edu' from URL
        if( url.startsWith("http://rgd.mcw.edu/") ) {
            url = url.substring(18);
        }
        return url;
    }
}
