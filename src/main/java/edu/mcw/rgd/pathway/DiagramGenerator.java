package edu.mcw.rgd.pathway;

import edu.mcw.rgd.dao.impl.PathwayDAO;
import edu.mcw.rgd.datamodel.Pathway;
import edu.mcw.rgd.process.Utils;
import org.apache.commons.io.FileUtils;
import org.htmlparser.Node;
import org.htmlparser.Parser;
import org.htmlparser.filters.TagNameFilter;

import java.io.*;

/**
 * @author jdepons
 * @since Feb 15, 2008
 * <p>
 * Creates pathway diagrams from pathway studio generated HTML.  The class will replace links created
 * by pathway studio to be links to RGD resources.
 */
public class DiagramGenerator {

    //public static String dataDir = "/rgd/data";
    //public static String wwwDir = "/rgd/www";
    PathwayDAO pwDao = new PathwayDAO();

    private static String uploadingDir;
    private static String dataDir;

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



    public static void main (String[] args) throws Exception {
        PathwayDiagramController pg = new PathwayDiagramController();
        //System.out.println(new DiagramGenerator().getImageMap("glycolysis pathway", pg.getUploadingDir() , pg.getDataDir()));
    }

    /**
     * Looks in the cache for a previously generated diagram of the pathway.  If a cache file
     * is not found, the pathway is created, and a cache file is written.
     *
     * The cache file is currently hard coded to be in /rgd_home/3.0/DATA/pathway/ on the server.
     * This should be made configurable in the future.
     * @param ontTermAcc
     * @param wwwDir
     * @param dataDir
     * @throws Exception
     * @return html image map of the given ontTermAcc
     */
    public String getImageMap(String ontTermAcc, String wwwDir, String dataDir) throws Exception{

        String pw = ontTermAcc.replaceAll("PW", "PW:");
        Pathway ontologyTerm = pwDao.getPathwayInfo(pw);
        if( ontologyTerm==null ) {
            return "unknown pathway id: "+ontTermAcc;
        }

        String name = ontologyTerm.getName();
        if(name.contains("/")){
            name = ontologyTerm.getName().replaceAll("/","-");
        }


        File cache = new File(dataDir+ontTermAcc+"/"+name+".html.cache");
        if (cache.exists()) {
            return Utils.readFileAsString(cache.getAbsolutePath());
        } else {
            File dir = new File(dataDir+ontTermAcc);
            FileUtils fu = new FileUtils();
            fu.forceMkdir(dir);            
            String path = wwwDir+ontTermAcc+"/"+name+".html";

            String newPath = replaceFunnyChar(path);
            if(newPath.equals("")){
                return "";
            }else{
                Parser parser = new Parser(newPath);

                Node mapNode = parser.extractAllNodesThatMatch(new TagNameFilter("body")).elementAt(0);
                PathwayNodeVisitor pv = new PathwayNodeVisitor();
                pv.setAcc_id(ontTermAcc);
                mapNode.accept(pv);
                String html = mapNode.toHtml();

                FileOutputStream fos = new FileOutputStream(dir+"/"+name+".html.cache");

                fos.write(html.getBytes());
                fos.close();
                return html;
            }
        }
    }


    /**
     * Returns a thumbnail size image of the pathway
     *
     * @param ontTermAcc accession id for ontology term
     * @param wwwDir www dir on server where pathway files are found
     * @throws Exception
     */
    public String getSmallImage(String ontTermAcc, String wwwDir) throws Exception{

        return getFile(ontTermAcc, wwwDir, "pwmap.png");
    }


    /**
     * Returns a thumbnail size image of the pathway
     *
     * @param ontTermAcc accession id for ontology term
     * @param wwwDir www dir on server where pathway files are found
     * @throws Exception
     */
    public String getGPPFile(String ontTermAcc, String wwwDir) throws Exception{

        return getFile(ontTermAcc, wwwDir, null);
    }

    /**
     * Returns a file from static pathway files
     *
     * @param ontTermAcc accession id for ontology term
     * @param wwwDir www dir on server where pathway files are found
     * @param fileName file name beeing looked for; if null, '{pathway-name}.gpp' is returned
     * @throws Exception
     */
    public String getFile(String ontTermAcc, String wwwDir, String fileName) throws Exception{
        Pathway pathway = pwDao.getPathwayInfo(ontTermAcc);

        if(ontTermAcc.contains(":")){
            ontTermAcc = ontTermAcc.replaceAll(":", "");
        }

        String name="";
        if( pathway!=null ) {
            name=pathway.getName();
            if(name.contains("/")){
                name = name.replaceAll("/","-");
            }
        }

        if( fileName==null ) {
            fileName = name+".gpp";
        }

        if (pathway!=null && new File(wwwDir+ontTermAcc+"/"+name+"/"+fileName).exists()) {
            String html = "<body>";
            html +=  "/pathway/"+ontTermAcc+"/"+name+"/"+fileName;
            html += "</body>";

            return html;
        }else {
            return "";
        }
    }

    public String replaceFunnyChar(String f) throws Exception{

        File file = new File(f);
        if(file.exists()){
            String oldtext = Utils.readFileAsString(f);

            // replace a word in a file
            String newtext = oldtext.replaceAll("\\%5C", "/");

            FileWriter writer = new FileWriter(f);
            writer.write(newtext);
            writer.close();
            return f;
        }else{
            return "";
        }
    }
}
