package edu.mcw.rgd.webservice;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.TranscriptDAO;
import edu.mcw.rgd.datamodel.MappedGene;

import org.apache.xerces.impl.dv.util.Base64;
import org.json.JSONArray;
import org.json.JSONObject;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import org.w3c.dom.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.swing.plaf.basic.BasicInternalFrameTitlePane;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.lang.reflect.Method;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/26/13
 * Time: 12:49 PM
 * To change this template use File | Settings | File Templates.
 */
public class GeneServiceController implements Controller {

    HttpServletRequest request = null;
    HttpServletResponse response = null;

    String localChr = "2";


    String outputDirectory = "c:/home/genomeLocker";


    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        this.request = httpServletRequest;
        this.response=httpServletResponse;

        //String method = request.getParameter("method");

        //System.out.println(this.getClass());

        System.out.println(request.getParameter("method"));


        Method method = this.getClass().getMethod(request.getParameter("method"));
        method.invoke(this);

        return null;

    }

    public void getUserGenome() throws Exception {

        System.out.println("in get user genome");

        final String authorization = request.getHeader("Authorization");
        System.out.println("auth = " + authorization);
        if (authorization != null && authorization.startsWith("Basic")) {
            // Authorization: Basic base64credentials
            String base64Credentials = authorization.substring("Basic".length()).trim();
            String credentials = new String(Base64.decode(base64Credentials), Charset.forName("UTF-8"));
            final String[] values = credentials.split(":",2);
            String username = values[0];
            String password = values[1];

           try {
            if (username.equals("hjacob")) {
                //check password

                File f = new File("/rgd/www/app/userdb/" + username + "/variantDB.sqlite");

                response.setContentType("application/octet-stream");
                response.setContentLength((int) f.length());

                FileInputStream fis = new FileInputStream(f);

                byte[] outputByte = new byte[4096];
                //copy binary contect to output stream
                while(fis.read(outputByte, 0, 4096) != -1){
                    response.getOutputStream().write(outputByte, 0, 4096);
                }
                fis.close();
                response.getWriter().flush();
            }
           }catch (Exception e) {
               e.printStackTrace();
               throw e;
           }
        }


    }





    public void getUser() throws Exception {

         try {

             System.out.println("in get user for user id " + this.request.getParameter("userId"));
             JSONArray ja= new JSONArray();

             JSONObject json = new JSONObject();

             json.put("userId", "1000001");
             json.put("name", "Howard J Jacob");
             json.put("dob", "06/14/1961");
             ja.put(json);


             this.response.getWriter().print(ja.toString());

         }catch (Exception e)  {
             this.response.getWriter().println(e.getMessage());
         }

     }




    public void getAllActiveMappedGenes() throws Exception {

         try {

             System.out.println("in get all active mapped genes");
             GeneDAO gdao = new GeneDAO();
             List<MappedGene> genes = gdao.getActiveMappedGenes(Integer.parseInt(this.request.getParameter("mapKey")));

             int count=0;
             JSONArray ja= new JSONArray();
             for (MappedGene mg: genes) {

                 JSONObject json = new JSONObject();
                 json.put("symbol", mg.getGene().getSymbol());
                 json.put("name", mg.getGene().getName());
                 json.put("chr", mg.getChromosome());
                 json.put("start",mg.getStart());
                 json.put("stop",mg.getStop());
                 json.put("type",mg.getGene().getType());
                 json.put("strand",mg.getStrand());
                 ja.put(json);

             }
             this.response.getWriter().print(ja.toString());

         }catch (Exception e)  {
             this.response.getWriter().println(e.getMessage());
         }

     }


    private String makeLength(String value, int length) {

        if (value.length() < length) {

            int spaceToAdd = length-value.length();

            for (int i=0; i< spaceToAdd; i++) {
                value = value + " ";

            }
            return value;
        }
        return value;
    }

public void getAllAnnotations() throws Exception{

        System.out.println("in get all annotations");

        String fileName="annotations.csv";

        FileOutputStream fos = new FileOutputStream("c:/home/howardGenome/" + fileName);
        PrintWriter pw = new PrintWriter(fos);

        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream("c:/home/svn/rgd/dev/ios/variantsAll.txt")));
        String line;

        br.readLine();

        char funkyChar = (char) 191;
        //System.out.println("funky = " + funkyChar);

        int count=0;
       String delim = "|";

    HashMap diseaseHash = new HashMap();

        while ((line=br.readLine()) != null) {
            String[] fields = line.split("\t");

            String gene = fields[3];
            String chr = fields[4];

            //only for chr2
            if (!chr.equals("2")) {
                //continue;
            }

            String start = fields[5];
            String stop = fields[6];
            String var = fields[8];

               /*
               String field = fields[i];

                if (field.indexOf("" + funkyChar) != -1) {
                   //System.out.println("found one " + field);
                   field=field.replace(funkyChar,'-');
                   System.out.println(field);
                   //field.replace()
               }
               */

           /*
           if (!fields[35].equals("No HGMD Match")) {
                System.out.println("HGMD Variant Centered Additional Annotations: " + fields[35]);
           }
           */

           /*
           if (!fields[37].equals("0")) {
                //System.out.println("HGMD v2012.2 Gene Level Disease Count: " + fields[37]);
           }
           if (!fields[38].equals("NA")) {
                System.out.println("HGMD v2012.2 Gene Level Disease Terms: " + fields[38]);
           }
           if (!fields[41].equals("NA")) {
                System.out.println("OMIM: " + fields[41]);
           }
           */




          // pw.println();

           count++;
          // break;


        }

    //Iterator it = diseaseHash.keySet().iterator();



    //while (it.hasNext()) {
    //    System.out.println(it.next());
    //}

   // System.out.println("keyset size = " + diseaseHash.keySet().size());


        pw.flush();

        fos.close();

        this.response.getWriter().print("done");


    }




    public void getAllVariants() throws Exception{

        System.out.println("in get all variants");

        String fileName="variants.csv";

        FileOutputStream fos = new FileOutputStream("c:/home/howardGenome/" + fileName);
        PrintWriter pw = new PrintWriter(fos);

       BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream("c:/home/svn/rgd/dev/ios/variantsAll.txt")));
       String line;

       br.readLine();

       char funkyChar = (char) 191;
       System.out.println("funky = " + funkyChar);

       int count=0;
       String delim = "|";

       HashMap aHash = new HashMap();
       HashMap bHash = new HashMap();

       while ((line=br.readLine()) != null) {
           String[] fields = line.split("\t");


           String chr = fields[4];

           //only for chr2
           if (!chr.equals("2")) {
              //continue;
           }



           /*
           if (fields[3].equals("ROGDI")) {
               System.out.print(fields[38]);

               System.out.println(fields[38].indexOf("" + ((char)191)));

               for (int i=0; i< fields[38].length(); i++) {
                   char character = fields[38].charAt(i);
                   System.out.print(character);
                   System.out.println("=" + ((int) character));
               }

             //  continue;
           }
           */

           for (int i=0; i<43; i++) {

               /*
               if (i==0) {
                   if (!fields[i].equals("")) {
                       aHash.put(fields[i],null);
                   }
               }else if (i==1) {
                   if (!fields[i].equals("")) {
                       bHash.put(fields[i],null);
                   }

               }

                */


               //skip these
               if (i==2 || i==16 || i==18 || i==20 || i==34 || i==35 || i==36 || i==37 || i==38 || i==40 || i==41) {
                   continue;
               }




               String field = fields[i];

               if (field.equals("-1")) {
                   field = "";
               }else if (field.equals("Unknown Effect")) {
                   field="";
               }else if (field.equals("Not Found")) {
                   field="";
               //}else if (field.equals("-")) {
               //    field="";
               //}else if (field.startsWith("--")) {
               //    field="";
               }else if (field.equals("NA")) {
                   field="";
               }else if (field.equals("Not Protein Coding")) {
                   field="";
               }else if (field.equals("Not Scored")) {
                   field="";
               }else if (field.equals("-1.00000")) {
                   field="";
               }else if (field.equals("No HGMD Match")) {
                   field="";
               /*}else if (field.equals("Insertion")) {
                   field="I";
               }else if (field.equals("Deletion")) {
                   field="D";
               }else if (field.equals("INTERIOR INTRON")) {
                   field="II";
               }else if (field.equals("5UTR INTRON")) {
                   field="";
               }else if (field.equals("Synonymous")) {
                   field="S";
               }else if (field.equals("Non-Synonymous")) {
                   field="N";
               }else if (field.equals("3PRIME CODING EXON")) {
                   field="3CE";
               }else if (field.equals("3UTR NON-CODING EXON")) {
                   field="3NCE";
               */
               }
               else if (field.indexOf("" + funkyChar) != -1) {
                   //System.out.println("found one " + field);
                   field=field.replace(funkyChar,'-');
                   System.out.println(field);
                   //field.replace()
               }

               pw.print(field); //gene symbol
               if (i < 42) {
                pw.print(delim);
               }
           }

           pw.println();

           count++;

    }


        pw.flush();

        fos.close();

       /*
        Iterator ait = aHash.keySet().iterator();
        while (ait.hasNext()) {
            String key = (String) ait.next();
            System.out.println("a - " + key);
        }


        Iterator bit = bHash.keySet().iterator();
        while (bit.hasNext()) {
            String key = (String) bit.next();
            System.out.println("b - " + key);
        }
        */

        this.response.getWriter().print("done");


    }



    public void getAllActiveMappedGenesAndTranscripts() throws Exception {

         try {

             TranscriptDAO tdao = new TranscriptDAO();
             GeneDAO gdao = new GeneDAO();
             //List<MappedGene> genes = gdao.getActiveMappedGenes(Integer.parseInt(this.request.getParameter("mapKey")));

             List<MappedGene> genes = gdao.getActiveMappedGenes("1",0,100000, Integer.parseInt(request.getParameter("mapKey")));

             int count=0;
             JSONArray ja= new JSONArray();
             for (MappedGene mg: genes) {

                 JSONObject json = new JSONObject();
                 json.put("symbol", mg.getGene().getSymbol());
                 json.put("name", mg.getGene().getName());
                 json.put("chr", mg.getChromosome());
                 json.put("start",mg.getStart());
                 json.put("stop",mg.getStop());
                 json.put("type",mg.getGene().getType());
                 json.put("strand",mg.getStrand());

                 /*
                 List<TranscriptFeature> tfList = tdao.getFeaturesForGene(mg.getGene().getRgdId());

                 List<Transcript> tList = tdao.getTranscriptsForGene(mg.getGene().getRgdId());


                 for (Transcript t: tList) {
                     System.out.println(t.);
                 }



                 for (TranscriptFeature tf: tfList) {
                    System.out.println(tf.getFeatureType().name());
                    System.out.println(tf.getMapKey());


                 }
                 */

                 ja.put(json);

             }
             this.response.getWriter().print(ja.toString());

         }catch (Exception e)  {
             this.response.getWriter().println(e.getMessage());
         }

     }


     public void getAllBands() throws Exception {

        try {


            JSONArray bandArray= new JSONArray();


            File fXmlFile = new File("C:\\home\\svn\\rgd\\prod\\web\\java\\rgdweb\\trunk\\web-app\\gviewer\\data\\human_ideo.xml");
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(fXmlFile);

            //optional, but recommended
            //read this - http://stackoverflow.com/questions/13786607/normalization-in-dom-parsing-with-java-how-does-it-work
            doc.getDocumentElement().normalize();

            NodeList nList = doc.getElementsByTagName("chromosome");

            for (int temp = 0; temp < nList.getLength(); temp++) {

                Node nNode = nList.item(temp);


                String chr =nNode.getAttributes().getNamedItem("number").getTextContent();

                //System.out.println("\nChromosome :" + nNode.getAttributes().getNamedItem("number").getTextContent());
                //System.out.println("\nChromosome size :" + nNode.getAttributes().getNamedItem("length").getTextContent());

                //NodeList bands = nNode.getChildNodes();
                NodeList bands = nNode.getChildNodes();

                for (int iband = 0; iband < bands.getLength(); iband++) {

                    Node n = bands.item(iband);


                    if (n.getNodeType() == Node.ELEMENT_NODE) {

                        JSONObject band = new JSONObject();
                        band.put("chr",chr );
                        band.put("name",n.getAttributes().getNamedItem("name").getTextContent());

                        NodeList props = n.getChildNodes();


                        for (int pcount=0; pcount < props.getLength(); pcount++) {

                            Node p = props.item(pcount);

                            if (p.getNodeType() == Node.ELEMENT_NODE) {

                                if (!p.getNodeName().equals("link")) {
                                    band.put(p.getNodeName(),p.getTextContent());

                                }

                            }

                        }

                        bandArray.put(band);
                    }
                    //NodeList bandElements = n.getChildNodes();

                }

        }


        this.response.getWriter().print(bandArray.toString());



        }catch (Exception e) {
            e.printStackTrace();
        }

     }


    public void getAnnotation() throws Exception {

         try {

             System.out.println("in get annotation for user id " + this.request.getParameter("userId"));
             JSONArray ja= new JSONArray();

             JSONObject json = new JSONObject();
             json.put("chr", "11");
             json.put("gene", "ABCC8");
             json.put("ref", "c");
             json.put("var", "t");
             json.put("zygosity", "Heterozygous");
             json.put("start", "17474779");
             json.put("type", "Pathogenic");
             json.put("name", "Hyperinsulinism");
             json.put("interpretation", "The heterozygous C>T variant on chromosome 11 at position 17474779 (dbSNP id: rs145136257 (2)) is predicted to cause a p.ALA355THR change in transcript NM_000352 in ABCC8. Substitution at this highly conserved nucleotide is predicted to result in the conversion of an alanine to threonine. This alanine is conserved in 7 of 7 other placental mammals with an orthologous protein and is predicted to be benign by PolyPhen 2. This variant was found in 0.077% of 10,000 reference alleles (http://evs.gs.washington.edu/EVS/). No other variants predicted to be deleterious to this geneâ€™s function were identified.  Mutations in this gene are associated with familial hyperinsulinism and permanent neonatal diabetes mellitus (1). The clinical presentation of hyperinsulinism deficiency described to date is significantly divergent from this patientâ€™s reported presentation, consequently, the significance of this variant is uncertain. However, the inheritance of the focal form of familial hyperinsulinism is more complex. Most people with this condition inherit one copy of an altered gene from their unaffected father. During embryonic development, a mutation occurs in the other copy of the gene. This second mutation is only found within some cells in the pancreas. As a result, some pancreatic beta cells have impaired insulin secretion, while other beta cells function normally.");
             json.put("desc", "An above normal level of insulin in the blood of a person or animal. Normal insulin secretion and blood levels are closely related to the level of glucose in the blood, so that a given level of insulin can be normal for one blood glucose level but low or high for another. Hyperinsulinism can be associated with several types of medical problems, which can be roughly divided into two broad and largely non-overlapping categories: those tending toward reduced sensitivity to insulin and high blood glucose levels (hyperglycemia), and those tending toward excessive insulin secretion and low glucose levels (hypoglycemia).");
             ja.put(json);

             json = new JSONObject();
             json.put("chr", "3");
             json.put("gene", "BTD");
             json.put("ref", "g");
             json.put("var", "c");
             json.put("zygosity", "Heterozygous");
             json.put("start", "15686693");
             json.put("type", "Pathogenic");
             json.put("name", "Biotindase Deficiency");
             json.put("interpretation", "The heterozygous G>C variant on chromosome 3 at position 15686693 (dbSNP id: rs13078881 (2)) is predicted to cause a p.ASP444HIS change in transcript NM_000060 in BTD. Substitution at this moderately nucleotide is predicted to result in the conversion of an aspartic acid to histidine. This aspartic acid is conserved in 6 of 7 other placental mammals with an orthologous protein and is predicted to be benign by PolyPhen 2.This variant was found in 3.0 % of 10,000 reference alleles (http://evs.gs.washington.edu/EVS/). No other variants predicted to be deleterious to this gene's function were identified.  Mutations in this gene are associated with autosomal recessive biotinidase deficiency (1). This variant was seen in conjunction with p.A171T variant subsequent papers have moved classification to a benign polymorphism (3).");
             json.put("desc", "Biotinidase deficiency is an inherited disorder in which the body is unable to reuse and recycle the vitamin biotin. This disorder is classified as a multiple carboxylase deficiency, a group of disorders characterized by impaired activity of certain enzymes that depend on biotin. The signs and symptoms of biotinidase deficiency typically appear within the first few months of life, but the age of onset varies. Children with profound biotinidase deficiency, the more severe form of the condition, often have seizures, weak muscle tone (hypotonia), breathing problems, and delayed development. If left untreated, the disorder can lead to hearing loss, eye abnormalities and loss of vision, problems with movement and balance (ataxia), skin rashes, hair loss (alopecia), and a fungal infection called candidiasis. Immediate treatment and lifelong management with biotin supplements can prevent many of these complications. Partial biotinidase deficiency is a milder form of this condition. Affected children experience hypotonia, skin rashes, and hair loss, but these problems may appear only during illness, infection, or other times of stress.");
             ja.put(json);


             this.response.getWriter().print(ja.toString());

         }catch (Exception e)  {
             this.response.getWriter().println(e.getMessage());
         }

     }




}
