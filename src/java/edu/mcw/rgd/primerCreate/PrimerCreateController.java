package edu.mcw.rgd.primerCreate;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MapData;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.process.primerCreate.CreatePrimer;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: Apr 4, 2011
 * Time: 9:31:06 AM
 */
public class PrimerCreateController implements Controller {
    String species;
    private String primerDir;
    private String primerInpDir;

    XdbIdDAO xdao = new XdbIdDAO();
    GeneDAO gdao = new GeneDAO();

    int mapKey;

    protected final Log logger = LogFactory.getLog(getClass());

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {


        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        try {

            if (request.getParameter("assembly") == null) {
               return new ModelAndView("/WEB-INF/jsp/primer/home.jsp");
            }

            species = req.getParameter("Species");
            mapKey = Integer.parseInt(request.getParameter("assembly"));

            String geneTarget = req.getParameter("gene_ens_id");
            if (geneTarget.isEmpty()) {
                throw new Exception("Gene Target is required.");
            }

            String chr = req.getParameter("chr");
            String start = req.getParameter("start");
            String stop = start;

            if (chr.isEmpty()) {
                throw new Exception("Chromosome is required.");
            }

            if (start.isEmpty()) {
                throw new Exception("Start position is required.");
            }

            if (stop.isEmpty()) {
                stop = start;
            }

            String geneRgdId = "0";

            //check to see if we already have an ensemble id
            String ensId = "";
            if (geneTarget.toLowerCase().startsWith("ens")) {
                 ensId = geneTarget;

            } else {

                Gene geneObj = gdao.getGenesBySymbol(geneTarget, Integer.parseInt(species));
                if (geneObj == null) {
                    throw new Exception("Gene symbol " + req.getParameter("gene_ens_id") + " not found");
                }

                MapDAO mdao = new MapDAO();
                List<MapData> mList = mdao.getMapData(geneObj.getRgdId(),mapKey);

                if (mList.size() == 0){
                    throw new Exception("Could not find position for gene " + geneObj.getSymbol());
                }

                if (Integer.parseInt(start) <  mList.get(0).getStartPos()  || Integer.parseInt(stop) > mList.get(0).getStopPos() || !mList.get(0).getChromosome().toLowerCase().equals(chr.toLowerCase())) {
                    throw new Exception("Variant Position is not in gene " + geneObj.getSymbol() + ". " + geneObj.getSymbol() + " is located on chromosome " + mList.get(0).getChromosome() + " from " + mList.get(0).getStartPos() + " to " + mList.get(0).getStopPos());
                }


                List<XdbId> ensIdList = xdao.getXdbIdsByRgdId(XdbId.XDB_KEY_ENSEMBL_GENES, geneObj.getRgdId());
                if(ensIdList.size()>=1){
                    ensId = ensIdList.get(0).getAccId();
                }else{
                    throw new Exception("no ensembl Id for this gene...");
                }

                geneRgdId = geneObj.getRgdId() + "";
            }
            logger.debug(" PrimerCreateController: input parameters validated!");
           //create the primer settings file

            String primerMinSize = req.getParameter("PRIMER_MIN_SIZE");
            String primerOptSize = req.getParameter("PRIMER_OPT_SIZE");
            String primerMaxSize = req.getParameter("PRIMER_MAX_SIZE");
            String primerMinTM = req.getParameter("PRIMER_MIN_TM");
            String primerOptTM = req.getParameter("PRIMER_OPT_TM");
            String primerMaxTM = req.getParameter("PRIMER_MAX_TM");
            String primerProductSizeRange = req.getParameter("PRIMER_PRODUCT_SIZE_RANGE");
            String primerMaxEndStability = req.getParameter("PRIMER_MAX_END_STABILITY");
            String primerMaxSelfAny = req.getParameter("PRIMER_MAX_SELF_ANY");
            String primerMaxSelfEnd = req.getParameter("PRIMER_MAX_SELF_END");
            String primerMaxPolyX = req.getParameter("PRIMER_MAX_POLY_X");
            String primerGCClamp = req.getParameter("PRIMER_GC_CLAMP");

            // by default, use RGD's tuned-up settings set
            String settingsSet = req.getParameter("settings");

            String settingFileName = this.generateFile(settingsSet, geneTarget, primerMinSize, primerOptSize,
                    primerMaxSize, primerMinTM, primerOptTM, primerMaxTM, primerProductSizeRange, primerMaxEndStability,
                    primerMaxSelfAny, primerMaxSelfEnd ,primerMaxPolyX, primerGCClamp);

            logger.debug(" PrimerCreateController: primer3 input file generated "+settingFileName);

            String[] args = {
            "-primerInput:"+primerInpDir+"/primerInp_",
            "-buffer:500",
            "-species:"+species.toUpperCase(),
            "-geneName:"+ensId,
            "-geneSymbol:"+geneTarget,
            "-geneRgdId:"+geneRgdId,
            "-pos:"+chr+"-"+start+"-"+stop,
            "-settings:"+settingFileName};

            response.setBufferSize(0);
            PrintWriter logWriter = new PrintWriter(response.getWriter());
            CreatePrimer cp = new CreatePrimer();
            logger.debug(" PrimerCreateController: starting CreatePrimer...");
            cp.runMain(args, logWriter);
            logger.debug(" PrimerCreateController: finished CreatePrimer...");

            logger.debug(" PrimerCreateController: starting primerprocess.sh script..");

            PrintWriter primer3Log = new PrintWriter(response.getWriter());
            primer3Log.println("<pre>");
            runShellProcess(primer3Log, settingFileName);
            primer3Log.println("</pre>");

            response.getWriter().println("</div></div></td></tr></table></body></html>");

            logger.debug(" PrimerCreateController: OK!");
            return null;

        }catch (Exception e) {
            e.printStackTrace();

            error.add(e.getMessage());

            return new ModelAndView("/WEB-INF/jsp/primer/home.jsp");

        }

    }



    public void runShellProcess(PrintWriter primer3Log, String settingsFileName) throws Exception{
        ProcessBuilder pb = new ProcessBuilder(primerDir+"PrimerProcess.sh");
        //System.out.println( "environment before addition:"+pb.environment());
        Map<String, String> env = pb.environment();
        env.put("SHELL", "/bin/bash");
        String path = env.get("PATH");
        path += ":/usr/local/primer3";
        path += ":/usr/local/blat";
        env.put("PATH", path);
        env.put("SETTINGS",settingsFileName);

        pb.directory(new File(primerDir));
        pb.redirectErrorStream(true);
        System.out.println(pb.directory());
        //System.out.println(pb.command());
        System.out.println(pb.environment());

        //System.out.println("should've initiated the primerProcess.sh..");
        try{
            Process p = pb.start();
            BufferedReader bErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
            StringBuilder errsb = new StringBuilder();
            String errline;
            while ((errline = bErr.readLine()) != null) {
              errsb.append(errline).append("\n");
            }
            String erranswer = errsb.toString();
            primer3Log.println(erranswer);


            BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append("\n");
            }
            String answer = sb.toString();
            primer3Log.println(answer);
        }catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }


    public String getPrimerDir() {
        return primerDir;
    }

    public void setPrimerDir(String primerDir) {
        this.primerDir = primerDir;
    }

    public String getPrimerInpDir() {
        return primerInpDir;
    }

    public void setPrimerInpDir(String primerInpDir) {
        this.primerInpDir = primerInpDir;
    }

    public String generateFile(String settingsSet, String geneTarget, String primerMinSize, String primerOptSize,
            String primerMaxSize, String primerMinTM, String primerOptTM, String primerMaxTM, String primerProductSizeRange,
            String primerMaxEndStability, String primerMaxSelfAny, String primerMaxSelfEnd,
            String primerMaxPolyX, String primerGCClamp) throws Exception {

        boolean usePrimer3Defaults = settingsSet.equals("default");

        String fileName =  geneTarget + "_" + new Date().getTime();

        BufferedWriter fw = new BufferedWriter(new FileWriter("/rgd/data/primer3/settings/" + fileName));

        fw.write("Primer3 File - http://primer3.sourceforge.net\n");
        fw.write("P3_FILE_TYPE=settings\n");
        fw.write("\n");
        if(usePrimer3Defaults) {
            fw.write("PRIMER_EXPLAIN_FLAG=1\n");
            fw.write("PRIMER_FIRST_BASE_INDEX=1\n");
            fw.write("PRIMER_LIBERAL_BASE=1\n");
            fw.write("PRIMER_MAX_HAIRPIN_TH=47.0\n");
            fw.write("PRIMER_MAX_SELF_ANY_TH=47.0\n");
            fw.write("PRIMER_MAX_SELF_END_TH=47.0\n");
            fw.write("PRIMER_MAX_LIBRARY_MISPRIMING=-1.00\n");
            fw.write("PRIMER_MAX_TEMPLATE_MISPRIMING_TH=-1.00\n");
            fw.write("PRIMER_MIN_LEFT_THREE_PRIME_DISTANCE=-1\n");
            fw.write("PRIMER_MIN_RIGHT_THREE_PRIME_DISTANCE=-1\n");
            fw.write("PRIMER_MISPRIMING_LIBRARY=\n");
            fw.write("PRIMER_PAIR_MAX_COMPL_ANY_TH=47.0\n");
            fw.write("PRIMER_PAIR_MAX_COMPL_END_TH=47.0\n");
            fw.write("PRIMER_PAIR_MAX_LIBRARY_MISPRIMING=24.00\n");
            fw.write("PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=-1.00\n");
            fw.write("PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=-1.00\n");
            fw.write("PRIMER_PICK_ANYWAY=0\n");
            fw.write("PRIMER_WT_POS_PENALTY=1.0\n");
        } else { // custom settings after tune-up
            fw.write("PRIMER_EXPLAIN_FLAG=1\n");
            fw.write("PRIMER_FIRST_BASE_INDEX=1\n");
            fw.write("PRIMER_LIBERAL_BASE=1\n");
            fw.write("PRIMER_MAX_HAIRPIN_TH=24.0\n");
            fw.write("PRIMER_MAX_SELF_ANY_TH=45.0\n");
            fw.write("PRIMER_MAX_SELF_END_TH=35.0\n");
            fw.write("PRIMER_MAX_LIBRARY_MISPRIMING=12.00\n");
            fw.write("PRIMER_MAX_TEMPLATE_MISPRIMING_TH=40.00\n");
            fw.write("PRIMER_MIN_LEFT_THREE_PRIME_DISTANCE=3\n");
            fw.write("PRIMER_MIN_RIGHT_THREE_PRIME_DISTANCE=3\n");
            fw.write("PRIMER_MISPRIMING_LIBRARY=primer3-mispriming_human_lib\n");
            fw.write("PRIMER_PAIR_MAX_COMPL_ANY_TH=45.0\n");
            fw.write("PRIMER_PAIR_MAX_COMPL_END_TH=35.0\n");
            fw.write("PRIMER_PAIR_MAX_LIBRARY_MISPRIMING=20.00\n");
            fw.write("PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=24.00\n");
            fw.write("PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=70.00\n");
            fw.write("PRIMER_PICK_ANYWAY=1\n");
            fw.write("PRIMER_WT_POS_PENALTY=0.0\n");
        }
        fw.write("PRIMER_THERMODYNAMIC_OLIGO_ALIGNMENT=1\n");
        fw.write("PRIMER_THERMODYNAMIC_TEMPLATE_ALIGNMENT=0\n");
        fw.write("PRIMER_PICK_LEFT_PRIMER=1\n");
        fw.write("PRIMER_PICK_INTERNAL_OLIGO=0\n");
        fw.write("PRIMER_PICK_RIGHT_PRIMER=1\n");
        fw.write("PRIMER_LIB_AMBIGUITY_CODES_CONSENSUS=0\n");
        fw.write("PRIMER_LOWERCASE_MASKING=0\n");
        fw.write("PRIMER_TASK=generic\n");
        fw.write("PRIMER_MIN_QUALITY=0\n");
        fw.write("PRIMER_MIN_END_QUALITY=0\n");
        fw.write("PRIMER_QUALITY_RANGE_MIN=0\n");
        fw.write("PRIMER_QUALITY_RANGE_MAX=100\n");
        fw.write("PRIMER_MIN_SIZE=" + primerMinSize.trim() + "\n");
        fw.write("PRIMER_OPT_SIZE=" + primerOptSize.trim() + "\n");
        fw.write("PRIMER_MAX_SIZE=" + primerMaxSize.trim() + "\n");
        fw.write("PRIMER_MIN_TM=" + primerMinTM.trim() + "\n");
        fw.write("PRIMER_OPT_TM=" + primerOptTM.trim() + "\n");
        fw.write("PRIMER_MAX_TM=" + primerMaxTM.trim() + "\n");
        fw.write("PRIMER_PAIR_MAX_DIFF_TM=100.0\n");
        fw.write("PRIMER_TM_FORMULA=1\n");
        fw.write("PRIMER_PRODUCT_MIN_TM=-1000000.0\n");
        fw.write("PRIMER_PRODUCT_OPT_TM=0.0\n");
        fw.write("PRIMER_PRODUCT_MAX_TM=1000000.0\n");
        fw.write("PRIMER_MIN_GC=20.0\n");
        fw.write("PRIMER_OPT_GC_PERCENT=50.0\n");
        fw.write("PRIMER_MAX_GC=80.0\n");
        fw.write("PRIMER_PRODUCT_SIZE_RANGE=" + primerProductSizeRange.trim() + "\n");
        fw.write("PRIMER_NUM_RETURN=5\n");
        fw.write("PRIMER_MAX_END_STABILITY=" + primerMaxEndStability.trim() + "\n");
        fw.write("PRIMER_MAX_TEMPLATE_MISPRIMING=12.00\n");
        fw.write("PRIMER_MAX_SELF_ANY=" + primerMaxSelfAny.trim() + "\n");
        fw.write("PRIMER_MAX_SELF_END=" + primerMaxSelfEnd.trim() + "\n");
        fw.write("PRIMER_PAIR_MAX_COMPL_ANY=8.00\n");
        fw.write("PRIMER_PAIR_MAX_COMPL_END=3.00\n");
        fw.write("PRIMER_MAX_NS_ACCEPTED=0\n");
        fw.write("PRIMER_MAX_POLY_X=" + primerMaxPolyX.trim() + "\n");
        fw.write("PRIMER_INSIDE_PENALTY=-1.0\n");
        fw.write("PRIMER_OUTSIDE_PENALTY=0\n");
        fw.write("PRIMER_GC_CLAMP=" + primerGCClamp.trim() + "\n");
        fw.write("PRIMER_MAX_END_GC=5\n");
        fw.write("PRIMER_MIN_5_PRIME_OVERLAP_OF_JUNCTION=7\n");
        fw.write("PRIMER_MIN_3_PRIME_OVERLAP_OF_JUNCTION=4\n");
        fw.write("PRIMER_SALT_MONOVALENT=50.0\n");
        fw.write("PRIMER_SALT_CORRECTIONS=1\n");
        fw.write("PRIMER_SALT_DIVALENT=1.5\n");
        fw.write("PRIMER_DNTP_CONC=0.6\n");
        fw.write("PRIMER_DNA_CONC=50.0\n");
        fw.write("PRIMER_SEQUENCING_SPACING=500\n");
        fw.write("PRIMER_SEQUENCING_INTERVAL=250\n");
        fw.write("PRIMER_SEQUENCING_LEAD=50\n");
        fw.write("PRIMER_SEQUENCING_ACCURACY=20\n");
        fw.write("PRIMER_WT_SIZE_LT=1.0\n");
        fw.write("PRIMER_WT_SIZE_GT=1.0\n");
        fw.write("PRIMER_WT_TM_LT=1.0\n");
        fw.write("PRIMER_WT_TM_GT=1.0\n");
        fw.write("PRIMER_WT_GC_PERCENT_LT=0.0\n");
        fw.write("PRIMER_WT_GC_PERCENT_GT=0.0\n");
        fw.write("PRIMER_WT_SELF_ANY_TH=0.0\n");
        fw.write("PRIMER_WT_SELF_END_TH=0.0\n");
        fw.write("PRIMER_WT_HAIRPIN_TH=0.0\n");
        fw.write("PRIMER_WT_TEMPLATE_MISPRIMING_TH=0.0\n");
        fw.write("PRIMER_WT_SELF_ANY=0.0\n");
        fw.write("PRIMER_WT_SELF_END=0.0\n");
        fw.write("PRIMER_WT_TEMPLATE_MISPRIMING=0.0\n");
        fw.write("PRIMER_WT_NUM_NS=0.0\n");
        fw.write("PRIMER_WT_LIBRARY_MISPRIMING=0.0\n");
        fw.write("PRIMER_WT_SEQ_QUAL=0.0\n");
        fw.write("PRIMER_WT_END_QUAL=0.0\n");
        fw.write("PRIMER_WT_END_STABILITY=0.0\n");
        fw.write("PRIMER_PAIR_WT_PRODUCT_SIZE_LT=0.0\n");
        fw.write("PRIMER_PAIR_WT_PRODUCT_SIZE_GT=0.0\n");
        fw.write("PRIMER_PAIR_WT_PRODUCT_TM_LT=0.0\n");
        fw.write("PRIMER_PAIR_WT_PRODUCT_TM_GT=0.0\n");
        fw.write("PRIMER_PAIR_WT_COMPL_ANY_TH=0.0\n");
        fw.write("PRIMER_PAIR_WT_COMPL_END_TH=0.0\n");
        fw.write("PRIMER_PAIR_WT_TEMPLATE_MISPRIMING_TH=0.0\n");
        fw.write("PRIMER_PAIR_WT_COMPL_ANY=0.0\n");
        fw.write("PRIMER_PAIR_WT_COMPL_END=0.0\n");
        fw.write("PRIMER_PAIR_WT_TEMPLATE_MISPRIMING=0.0\n");
        fw.write("PRIMER_PAIR_WT_DIFF_TM=0.0\n");
        fw.write("PRIMER_PAIR_WT_LIBRARY_MISPRIMING=0.0\n");
        fw.write("PRIMER_PAIR_WT_PR_PENALTY=1.0\n");
        fw.write("PRIMER_PAIR_WT_IO_PENALTY=0.0\n");
        fw.write("PRIMER_INTERNAL_MIN_SIZE=18\n");
        fw.write("PRIMER_INTERNAL_OPT_SIZE=20\n");
        fw.write("PRIMER_INTERNAL_MAX_SIZE=27\n");
        fw.write("PRIMER_INTERNAL_MIN_TM=57.0\n");
        fw.write("PRIMER_INTERNAL_OPT_TM=60.0\n");
        fw.write("PRIMER_INTERNAL_MAX_TM=63.0\n");
        fw.write("PRIMER_INTERNAL_MIN_GC=20.0\n");
        fw.write("PRIMER_INTERNAL_OPT_GC_PERCENT=50.0\n");
        fw.write("PRIMER_INTERNAL_MAX_GC=80.0\n");
        fw.write("PRIMER_INTERNAL_MAX_SELF_ANY_TH=47.00\n");
        fw.write("PRIMER_INTERNAL_MAX_SELF_END_TH=47.00\n");
        fw.write("PRIMER_INTERNAL_MAX_HAIRPIN_TH=47.00\n");
        fw.write("PRIMER_INTERNAL_MAX_SELF_ANY=12.00\n");
        fw.write("PRIMER_INTERNAL_MAX_SELF_END=12.00\n");
        fw.write("PRIMER_INTERNAL_MIN_QUALITY=0\n");
        fw.write("PRIMER_INTERNAL_MAX_NS_ACCEPTED=0\n");
        fw.write("PRIMER_INTERNAL_MAX_POLY_X=5\n");
        fw.write("PRIMER_INTERNAL_MAX_LIBRARY_MISHYB=12.00\n");
        fw.write("PRIMER_INTERNAL_SALT_MONOVALENT=50.0\n");
        fw.write("PRIMER_INTERNAL_DNA_CONC=50.0\n");
        fw.write("PRIMER_INTERNAL_SALT_DIVALENT=1.5\n");
        fw.write("PRIMER_INTERNAL_DNTP_CONC=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_SIZE_LT=1.0\n");
        fw.write("PRIMER_INTERNAL_WT_SIZE_GT=1.0\n");
        fw.write("PRIMER_INTERNAL_WT_TM_LT=1.0\n");
        fw.write("PRIMER_INTERNAL_WT_TM_GT=1.0\n");
        fw.write("PRIMER_INTERNAL_WT_GC_PERCENT_LT=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_GC_PERCENT_GT=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_SELF_ANY_TH=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_SELF_END_TH=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_HAIRPIN_TH=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_SELF_ANY=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_SELF_END=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_NUM_NS=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_LIBRARY_MISHYB=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_SEQ_QUAL=0.0\n");
        fw.write("PRIMER_INTERNAL_WT_END_QUAL=0.0\n");
        fw.write("=");

        fw.close();

        return fileName;
    }
}
