package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermDagEdge;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;
import java.io.*;

/**
 * Created by IntelliJ IDEA. <br>
 * User: mtutaj <br>
 * Date: 6/27/11 <br>
 * Time: 10:22 AM <br>
 * <p>
 * given accession id, generates dot file to be consumed by graphviz tool
 */
public class OntDotController implements Controller {

    // directory where gprahviz images and image map files are created
    private String tmpFileDir = "/rgd/www/ols-web/graphviz";
    // path to dot executable
    public String DOT_EXE_PATH = "/usr/bin/dot";
    // default node url
    static private final String DEFAULT_NODE_URL = "/rgdweb/ontology/annot.html?acc_id=";

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String imgFormat = "png";
        // if page is standalone
        boolean isStandAlone = request.getParameter("standalone") != null;

        // if img_id parameter is given, it will stream the image
        String imgId = request.getParameter("img_id");
        if( imgId!=null ) {
            serveImage(imgId, response);
            return null;
        }

        // generate dot document only
        boolean dotDocOnly = request.getParameter("dot") != null;

        // there must be accession id parameter
        String[] accIds = new String[1];
        if(request.getParameter("acc_id") ==null ) {
            accIds[0] = "RDO:0007215"; // diabetess insipius, nephrogenic
        } else {
            accIds = request.getParameter("acc_id").split(" ");
        }

        if(request.getParameter("of") !=null ) {
            imgFormat = request.getParameter("of").toLowerCase();
        }

        // optional max line length parameter
        int maxLineLen = 0;
        if( request.getParameter("max_line_len")!= null ) {
            // always convert the param to number
            try { maxLineLen = Integer.parseInt(request.getParameter("max_line_len")); } catch(NumberFormatException e){}
        }

        // optional url
        String nodeUrl = request.getParameter("node_url");
        if( nodeUrl==null )
            nodeUrl = DEFAULT_NODE_URL;

        String htmlContent = generateResponse(accIds, nodeUrl, maxLineLen, dotDocOnly, imgFormat);
        response.getWriter().write(htmlContent);

       //added close() - Pushkala
        response.getWriter().close();
        return null;
    }

    public static String generateResponse(String accId, String nodeUrl) throws Exception {
        final int maxLineLen = -1; // one word per line in node box
        final boolean generateDotDocOnly = false;
        String[] accIds = new String[1];
        accIds[0] = accId;
        return generateResponse(accIds, nodeUrl, maxLineLen, generateDotDocOnly);
    }

    public static String generateResponse(String accId, String nodeUrl, int maxLineLen) throws Exception {
        String[] accIds = new String[1];
        accIds[0] = accId;
        return generateResponse(accIds, nodeUrl, maxLineLen, false);
    }

    public static String generateResponse(String accId, String nodeUrl, int maxLineLen, boolean generateDotDocOnly) throws Exception {
        String[] accIds = new String[1];
        accIds[0] = accId;
        OntDotController dot = new OntDotController();
        return dot.generateResponse(accIds, false, maxLineLen, generateDotDocOnly, nodeUrl);
    }

    public static String generateResponse(String[] accIds, String nodeUrl, int maxLineLen, boolean generateDotDocOnly) throws Exception {
        return generateResponse(accIds, nodeUrl, maxLineLen, generateDotDocOnly, "png");
    }

    public static String generateResponse(String[] accIds, String nodeUrl, int maxLineLen, boolean generateDotDocOnly, String imgFormat) throws Exception {
        OntDotController dot = new OntDotController();
        return dot.generateResponse(accIds, false, maxLineLen, generateDotDocOnly, nodeUrl, imgFormat);
    }

    /**
     * given term accession id, it will generate html code with graph showing a term and all paths to root term
     * @param accId term accession id
     * @param isStandAlone if true, standalone html page will be returned
     * @return String containing valid html code, ready to be embedded within an existing page
     * @throws Exception
     */
    public String generateResponse(String accId, boolean isStandAlone) throws Exception {

        String[] accIds = new String[1];
        accIds[0] = accId;
        return generateResponse(accIds, isStandAlone, -1, false, DEFAULT_NODE_URL);
    }

    /**
     * given term accession id, it will generate html code with graph showing a term and all paths to root term
     * @param accId term accession id
     * @param isStandAlone if true, standalone html page will be returned
     * @param maxLineLen if negative or 0, every word of node text is shown in separate line;
     *   if positive, it denotes the maximum line length in characters
     * @param dotDocOnly if true DOT document is returned instead of image map + image
     * @return String containing valid html code, ready to be embedded within an existing page
     * @throws Exception
     */
    public String generateResponse(String accId, boolean isStandAlone, int maxLineLen, boolean dotDocOnly, String nodeUrl) throws Exception {

        String[] accIds = new String[1];
        accIds[0] = accId;
        return generateResponse(accIds, isStandAlone, maxLineLen, dotDocOnly, nodeUrl);
    }

    /**
     * given term accession id, it will generate html code with graph showing a term and all paths to root term
     * @param accIds term accession ids
     * @param isStandAlone if true, standalone html page will be returned
     * @param maxLineLen if negative or 0, every word of node text is shown in separate line;
     *   if positive, it denotes the maximum line length in characters
     * @param dotDocOnly if true DOT document is returned instead of image map + image
     * @return String containing valid html code, ready to be embedded within an existing page
     * @throws Exception
     */
    public String generateResponse(String[] accIds, boolean isStandAlone, int maxLineLen, boolean dotDocOnly, String nodeUrl) throws Exception {
        return generateResponse(accIds, isStandAlone, maxLineLen, dotDocOnly, nodeUrl, "png");
    }

    public String generateResponse(String[] accIds, boolean isStandAlone, int maxLineLen, boolean dotDocOnly, String nodeUrl, String imgFormat) throws Exception {

        OntologyXDAO dao = new OntologyXDAO();

        List<Term> terms = dao.getTermByAccId(accIds);
        // generate DOT source
        String dot = toDot(terms, dao.getAllParentEdges(accIds), maxLineLen, nodeUrl, imgFormat);

        // return dot document if required
        if( dotDocOnly )
            return dot;

        // generate server side files: the image itself and the image map
        String[] ssFiles = generateServerSideFiles(dot, imgFormat);
        // serve the contents of the files
        return serveServerSideFiles(ssFiles, isStandAlone, imgFormat.equalsIgnoreCase("svg"));
    }

    public void serveImage(String imgId, HttpServletResponse response) throws Exception {

        // security: imgId is a local resource and cannot have any security breaking parts, like '/etc/hosts'
        if( imgId!=null ) {
            if( imgId.contains("..") || imgId.contains("/") || imgId.contains("\\") ) {
                // this part of file name is suspicious: return rgd logo :-)
                response.sendRedirect("/common/images/rgd_logo.gif");
                return;
            }
        }

        File file = new File(getTmpFileDir()+"/"+imgId);
        if( file.exists() ) {
            // Set content type
            if (imgId.toLowerCase().endsWith(".svg")) {
                response.setContentType("image/svg+xml");
            } else {
                response.setContentType("image/png");
            }

            // Set content size
            response.setContentLength((int)file.length());

            // Open the file and output streams
            FileInputStream in = new FileInputStream(file);
            OutputStream out = response.getOutputStream();

            // Copy the contents of the file to the output stream
            byte[] buf = new byte[1024];
            int count = 0;
            while ((count = in.read(buf)) >= 0) {
                out.write(buf, 0, count);
            }
            in.close();
            out.close();
        }
        else {
            // file does not exist -- most likely because a web spider sent request for a image
            // that is no longer available (images longer than 1 day are deleted)
            response.sendRedirect("/common/images/rgd_logo.gif");
        }
    }

    private String serveServerSideFiles(String[] files, boolean isStandAlone, boolean isSvg) throws Exception {

        StringBuilder buf = new StringBuilder();
        if( isStandAlone ) {
            buf.append("<html><head><META HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\">\t<META HTTP-EQUIV=\"CONTENT-TYPE\"\n" +
                    "CONTENT=\"text/html; charset=UTF-8\"><META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\"></head><body><h2>TERM HIERARCHY</h2>\n");
        }

        if( files[0]!=null ) {
            // there are image file and image map available

            if (isSvg) {
                buf.append("<object id=\"termHierarchy\" type=\"image/svg+xml\" data=\"/rgdweb/ontology/dot.html?img_id=")
                    .append(files[0])
                    .append("\"/>\n");
            } else {
                buf.append("<img id=\"termHierarchy\" border=\"0\" usemap=\"#go_graph\" alt=\"paths to the root\" src=\"/rgdweb/ontology/dot.html?img_id=")
                    .append(files[0])
                    .append("\"/>\n");
                // read the contents of map file and show it
                StringBuilder dotMap = new StringBuilder();

                BufferedReader reader = new BufferedReader(new FileReader(files[1]));
                String line;
                while( (line=reader.readLine())!=null ) {
                    dotMap.append(line);
                }
                reader.close();
                buf.append(dotMap.toString());
            }


        }
        else {
            // error -- no image and no image map -- graphviz tool not configured on this machine?
            buf.append("<div style='border:1px solid #C6C6C6;background-color:#F6F6F6;height:padding:5px;color:red;font-weight:bold;font-size:12px;margin-top:20px;margin-bottom:20px;'>GRAPH IMAGE ERROR</div>")
               .append("\n");
        }

        if( isStandAlone ) {
            buf.append("\n</body>\n</html>\n");
        }
        return buf.toString();
    }


    // generate png file with the image of paths to root
    // and generate image map file so you can click every node
    private String[] generateServerSideFiles(String dotSource) throws Exception {
       return generateServerSideFiles(dotSource, "png");
    }

    private String[] generateServerSideFiles(String dotSource, String imgFormat) throws Exception {

        File img, dot, map;

        String format = " -T" + imgFormat + " ";
        String mapFormat = " -Tcmapx_np";

        File tmpFileDir = new File(getTmpFileDir());
        if (!tmpFileDir.exists()){
            //if not properly configured, use java.io.tempdir
            tmpFileDir = null;
        }

        dot = File.createTempFile("graph_", ".dot.tmp", tmpFileDir);
        FileWriter fout = new FileWriter(dot);
        fout.write(dotSource);
        fout.close();

        map = File.createTempFile("graph_", ".map.tmp", tmpFileDir);

        img = File.createTempFile("graph_", "." + imgFormat, tmpFileDir);

        //dot graph_59807.dot.tmp -Tcmapx_np -ograph_59807.map.tmp -Tpng -ograph_59807.png
        String cmd = new StringBuilder()
                .append(DOT_EXE_PATH)
                .append(" ")
                .append(dot.getAbsolutePath())
                .append(mapFormat).append(" -o").append(map.getAbsolutePath())
                .append(format).append(" -o").append(img.getAbsolutePath())
                .toString();

        try {
            Process p = Runtime.getRuntime().exec(cmd);
            //start process to clean out error stream to prevent blocking
            StreamReader sr = new StreamReader(p.getErrorStream());
            sr.run();
            //wait for process to end
            p.waitFor();

            //return relative path of img file so that full path doesn't get transferred back to front-end user code
            return new String[]{img.getName(), map.getAbsolutePath()};
        }
        catch(IOException io) {
            //io.printStackTrace();

            return new String[]{null, null}; // no image, no image map available
        }
    }


    private class StreamReader extends Thread {

        BufferedReader br;
        ByteArrayOutputStream output;

        public String toString() {
            return output.toString();
        }

        public StreamReader(InputStream is) {
            br = new BufferedReader(new InputStreamReader(is));
            output = new ByteArrayOutputStream();
        }

        public void run() {
            try {
                String line;
                while ((line = br.readLine()) != null) {
                    output.write(line.getBytes());
                }
                br.close();
                //System.out.println("OntDotController error: "+output.toString());
            }
            catch (IOException ioe) {
                ioe.printStackTrace();
            }
        }
        
    }

    /**
     * generate DOT document for a given term and a list of edges
     * @param term term
     * @param edges list of term edges
     * @param maxLineLen if positive, denotes maximum line length in characters; if 0 or negative,
     *  every word of term name will be shown in separate line
     * @param nodeUrl url of page shown when given node is clicked
     * @return DOT document
     */
    String toDot(Term term, List<TermDagEdge> edges, int maxLineLen, String nodeUrl) {
        return toDot(term, edges, maxLineLen, nodeUrl, "png");
    }

    String toDot(Term term, List<TermDagEdge> edges, int maxLineLen, String nodeUrl, String imgFormat) {
        List<Term> terms = new ArrayList<Term>();
        terms.add(term);
        return toDot(terms, edges, maxLineLen, nodeUrl, imgFormat);
    }

    /**
     * generate DOT document for a given term and a list of edges
     * @param terms terms
     * @param edges list of term edges
     * @param maxLineLen if positive, denotes maximum line length in characters; if 0 or negative,
     *  every word of term name will be shown in separate line
     * @param nodeUrl url of page shown when given node is clicked
     * @return DOT document
     */
    String toDot(List<Term> terms, List<TermDagEdge> edges, int maxLineLen, String nodeUrl) {
        return toDot(terms, edges, maxLineLen, nodeUrl, "png");
    }

    String toDot(List<Term> terms, List<TermDagEdge> edges, int maxLineLen, String nodeUrl, String imgFormat) {
        //dot graph_59807.dot.tmp -Tcmapx_np -ox.map -Tpng -ox.png
        //<IMG SRC="x.png" USEMAP="#go_graph" />

        StringBuffer dot = new StringBuffer();
        dot.append("digraph go_graph {     \n");
        dot.append(" graph [               \n");
        dot.append("  style=\"\",          \n");
        dot.append("  center=\"true\",     \n");
        dot.append("  ratio=\"compress\",  \n");
        dot.append("  concentrate=\"true\",\n");
        dot.append("  nodesep=.1,          \n");
        dot.append("  ranksep=.25,         \n");
        dot.append("  rankdir=\"BT\"       \n");
        dot.append(" ];                    \n");
        // Overall node style
        dot.append(" node [                              \n");
        dot.append("  shape=\"plaintext\",               \n");
        dot.append("  height=\"0\",                      \n");
        dot.append("  width=\"0\",                       \n");
        dot.append("  fontname=\"Courier\",              \n");
        dot.append("  fontsize=\"8\",                    \n");
        dot.append("  fontcolor=\"black\",               \n");
        dot.append("  color=\"black\",                   \n");
        dot.append("  fillcolor=\"lightgoldenrodyellow\",\n");
        dot.append("  style=\"filled\"                   \n");
        dot.append(" ];\n\n");
        // Overall edge style
        dot.append(" edge [                          \n");
        dot.append("  fontname=\"Courier\",          \n");
        dot.append("  fontsize=\"8\",                \n");
        dot.append("  fontcolor=\"black\",           \n");
        dot.append("  color=\"black\",               \n");
        dot.append("  arrowsize=\"0.5\"              \n");
        dot.append(" ];\n\n");

        dot.append(dumpPathsToRoot(terms, edges, maxLineLen, nodeUrl, imgFormat));

        dot.append("}");
        return dot.toString();
    }

    StringBuffer dumpPathsToRoot(Term term, List<TermDagEdge> edges, int maxLineLen, String nodeUrl, String imgFormat) {
        List<Term> terms = new ArrayList<Term>();
        terms.add(term);
        return dumpPathsToRoot(terms, edges, maxLineLen, nodeUrl, imgFormat);
    }

    StringBuffer dumpPathsToRoot(List<Term> terms, List<TermDagEdge> edges, int maxLineLen, String nodeUrl, String imgFormat) {
        StringBuffer dot = new StringBuffer();

        // dump nodes
        //
        // dump node of the term in question
        boolean isBold = true;
        Set<String> nodes = new HashSet<String>(); // set of all acc ids for parent nodes
        for (Term term : terms) {
            dumpNode(dot, term.getAccId(), term.getTerm(), maxLineLen, isBold, nodeUrl, imgFormat);
            nodes.add(term.getAccId());
        }

        // are there any edges at all?
        if( edges==null )
            return dot;

        // dump nodes for parent terms
        isBold = false;
        for( TermDagEdge edge: edges ) {
            if( nodes.add(edge.getParentTermAcc()) ) {
                // new node: generate dot code
                dumpNode(dot, edge.getParentTermAcc(), edge.getParentTermName(), maxLineLen, isBold, nodeUrl, imgFormat);
            }
        }

        // dump relations for edges
        for( TermDagEdge edge: edges ) {
            dot.append(" ").append(stripColon(edge.getChildTermAcc())).append("->").append(stripColon(edge.getParentTermAcc()))
               .append(" [ label = \"").append(edge.getRel()).append("\"");
            // is-a edges are shown in default style
            // edges for other relations are shown dotted
            if( !edge.getRel().toString().equals("is-a") ) {
                dot.append(", color=blue, fontcolor=blue");
            }
            dot.append(" ];\n");
        }

        return dot;
    }

    private void dumpNode(StringBuffer dot, String termAcc, String termName, String nodeUrl) {
        dot.append(" ").append(stripColon(termAcc));
        dot.append(" [ URL=\"").append(nodeUrl).append(termAcc).append("\", ")
        .append("label = \"").append(termName.replaceAll(" ", "\\\\n")).append("\\n").append(termAcc).append("\" ];\n");
    }

    private void dumpNode(StringBuffer dot, String termAcc, String termName, int maxLineLen, boolean isBold, String nodeUrl, String imgFormat) {

        if( maxLineLen<=0 ) {
            dumpNode(dot, termAcc, termName, nodeUrl);
            return;
        }

        dot.append(" ").append(stripColon(termAcc));
        dot.append(" [ URL=\"").append(nodeUrl).append(termAcc).append("\", ");
        if (imgFormat.equals("svg")) dot.append("target=\"_blank\", ");
        if( isBold ) {
            dot.append("fontsize=9, fillcolor=gold, ");
        }
        dot.append("label = \"");

        // build node text inserting a new line whenever the text will exceed max line length
        // f.e. text "Four score and seven years ago" with max line length of 10 will be broken into 3 lines:
        //   "Four score \n"
        //   "and seven \n"
        //   "years ago \n"
        int lineLen = 0; // current line length
        StringTokenizer tokenizer = new StringTokenizer(termName);
        boolean emptyLabel = true;
        while( tokenizer.hasMoreTokens() ) {
            String word = tokenizer.nextToken();
            if( lineLen + word.length() > maxLineLen ) {
                // break the current line and start the new line
                dot.append(emptyLabel?"":"\\n").append(word).append(' ');
                lineLen = word.length() + 1;
            }
            else {
                // continue the current line
                dot.append(word).append(' ');
                lineLen += word.length() + 1;
            }
            emptyLabel = false;
        }
        // append term acc in the next line
        dot.append("\\n").append(termAcc)
        // finish the label
        .append("\" ];\n");

    }

    private String stripColon(String str) {
        return str.replace(":", "");
    }

    public String getTmpFileDir() {
        return tmpFileDir;
    }

    public void setTmpFileDir(String tmpFileDir) {
        this.tmpFileDir = tmpFileDir;
    }
}
