package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.carpenovo.dao.VariantSearchBeanNew;
import edu.mcw.rgd.carpenovo.vvservice.VVService;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Sample;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by jthota on 7/2/2019.
 */
public class VariantControllerNew  extends HaplotyperController {
    Log log = LogFactory.getLog(VariantController.class);

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {

            HttpRequestFacade req = new HttpRequestFacade(request);
            String geneList=req.getParameter("geneList");

            String searchType="";

            if (!req.getParameter("chr").equals("") && !req.getParameter("start").equals("") && !req.getParameter("stop").equals("")) {
                searchType="CHR";

            }else if (!req.getParameter("geneStart").equals("") && !req.getParameter("geneStop").equals("")) {
                searchType="REGION";
            }else if (!geneList.equals("")) {
                if (!geneList.contains("|") && !geneList.contains("*") && Utils.symbolSplit(geneList).size()>1 ) {
                    //searchType="LIST";
                    return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
                }else {
                    searchType="GENE";
                }
            }

            if (!geneList.equals("") && !geneList.contains("|") && !geneList.contains("*")) {
                if (Utils.symbolSplit(geneList).size()>1) {
                    return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
                }
            }

            if (geneList.equals("") && !req.getParameter("rdo_term").equals("")) {
                //if (Utils.symbolSplit(geneList).size()>1) {
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
                //}
            }

            VariantSearchBeanNew vsb = fillBeanNew(req);
            VVService service= new VVService();
            SearchResponse sr=service.getVariants(vsb);
            System.out.println("SEARCH HITS: "+ sr.getHits().getTotalHits());
            SearchHit[] hits= sr.getHits().getHits();
     /*   for(int i=0;i<hits.length;i++){
            SearchHit h=hits[i];
            System.out.println(h.getId()+"\n=============================");
            for(Map.Entry e:h.getSourceAsMap().entrySet()){
             System.out.println(e.getKey()+ "\t"+ e.getValue());
            }
        }*/
            request.setAttribute("sr", sr);
            ModelMap model= new ModelMap();
            model.addAttribute("hitsArray", hits);
            return new ModelAndView("/WEB-INF/jsp/haplotyper/variantsNew.jsp", "model", model);


        }catch (Exception e) {

            // do not print stack trace for Exceptions that are 'expected' by us
            if( !(e instanceof VVException) ) {
                e.printStackTrace();
            }

            ArrayList errors = new ArrayList();
            errors.add(e.getMessage());
            request.setAttribute("error", errors);
            return new ModelAndView("/WEB-INF/jsp/haplotyper/region.jsp");
        }

    }
    /**
     * initializes a VariantSearchBean based on data supplied in the HTTP Request object
     *
     * @param req
     * @return
     * @throws Exception
     */
    protected VariantSearchBeanNew fillBeanNew(HttpRequestFacade req) throws Exception {

        VariantSearchBeanNew vsb = new VariantSearchBeanNew(0);

        if (req.getParameter("sample1").equals("all")) {
            //get all the samples

            SampleDAO sdao = new SampleDAO();
            sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
            int mapKey = Integer.parseInt(req.getParameter("mapKey"));
            List<Sample> samples = sdao.getSamplesByMapKey(mapKey);

            vsb.setMapKey(mapKey);

            for (Sample s : samples) {
                vsb.sampleIds.add(s.getId());
            }

        } else {

            // determine mapKey from samples
            for (int i = 0; i < 100; i++) {
                String sample = req.getParameter("sample" + i);
                if (!sample.isEmpty()) {
                    int sampleId = Integer.parseInt(sample);
                    Sample sampleObj = SampleManager.getInstance().getSampleName(sampleId);

                    // if bean map key not set, derive it from sample
                    if (vsb.getMapKey() == 0) {
                        vsb.setMapKey(sampleObj.getMapKey());
                        vsb.sampleIds.add(sampleId);
                    } else {
                        // bean map key already set -- validate it
                        if (sampleObj.getMapKey() == vsb.getMapKey()) {
                            vsb.sampleIds.add(sampleId);
                        } else {
                            // assembly mixup, ignore the sample
                            System.out.println("ERROR: assembly mixup");
                        }
                    }
                }
            }

        }
        // if map key was not explicitly given, set the map key to value determined from sample ids
        int mapKey = vsb.getMapKey();
        if (vsb.getMapKey() == 0) {
            String mapKeyString = req.getParameter("mapKey");
            if (!mapKeyString.isEmpty()) {
                mapKey = Integer.parseInt(mapKeyString);
            }
            // if map key still not determined, set it to map key of primary reference assembly
            if (mapKey == 0) {
                mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
            }
            vsb.setMapKey(mapKey);
        }


        String chromosome = req.getParameter("chr");
        String start = URLDecoder.decode(req.getParameter("start"), "UTF-8").replaceAll(",", "");
        String stop = URLDecoder.decode(req.getParameter("stop"), "UTF-8").replaceAll(",", "");

        if (chromosome.equals("") || start.equals("") || stop.equals("")) {

            // class logger
            Position p = this.getPosition(req.getParameter("geneList"), req.getParameter("geneStart"), req.getParameter("geneStop"), mapKey);
            chromosome = p.getChromosome();
            start = p.getStart() + "";
            stop = p.getStop() + "";

        } else {
            try {
                Integer.parseInt(start);
            } catch (Exception e) {
                throw new VVException("Start value must be numeric");
            }

            try {
                Integer.parseInt(stop);
            } catch (Exception e) {
                throw new VVException("Stop value must be numeric");
            }
        }

        float conLow = -1;
        float conHigh = -1;
        switch (req.getParameter("con")) {
            case "n":
                conLow = 0;
                conHigh = 0;
                break;
            case "l":
                conLow = .01f;
                conHigh = .49f;
                break;
            case "m":
                conLow = .5f;
                conHigh = .749f;
                break;
            case "h":
                conLow = .75f;
                conHigh = 1f;
                break;
        }

        vsb.setPosition(chromosome, start, stop);
        vsb.setAAChange(req.getParameter("synonymous"), req.getParameter("nonSynonymous"));
        vsb.setGenicStatus(req.getParameter("genic"), req.getParameter("intergenic"));
        vsb.setIsPrematureStop(req.getParameter("prematureStopCodon"));
        vsb.setShowDifferences(Boolean.parseBoolean(req.getParameter("showDifferences")));
        vsb.setIsReadthrough(req.getParameter("readthroughMutation"));
        vsb.setConScore(conLow, conHigh);
        vsb.setDepth(req.getParameter("depthLowBound"), req.getParameter("depthHighBound"));
        vsb.setNearSpliceSite(req.getParameter("nearSpliceSite"));
        vsb.setZygosity(req.getParameter("het"), req.getParameter("hom"), req.getParameter("possiblyHom"), req.getParameter("hemi"), req.getParameter("probablyHemi"), req.getParameter("possiblyHemi"), req.getParameter("excludePossibleError"), req.getParameter("hetDiffFromRef"));
        vsb.setScore(req.getParameter("scoreLowBound"), req.getParameter("scoreHighBound"));
        vsb.setDBSNPNovel(req.getParameter("notDBSNP"), req.getParameter("foundDBSNP"));
        vsb.setLocation(req.getParameter("intron"), req.getParameter("3prime"), req.getParameter("5prime"), req.getParameter("proteinCoding"));
        vsb.setPseudoautosomal(req.getParameter("excludePsudoautosomal"), req.getParameter("onlyPsudoautosomal"));
        vsb.setAlleleCount(req.getParameter("alleleCount1"), req.getParameter("alleleCount2"), req.getParameter("alleleCount3"), req.getParameter("alleleCount4"));
        vsb.setVariantType(req.getParameter("snv"), req.getParameter("ins"), req.getParameter("del"));
        vsb.setIsFrameshift(req.getParameter("frameshift"));
        vsb.setPolyphen(req.getParameter("benign"), req.getParameter("possibly"), req.getParameter("probably"));
        vsb.setClinicalSignificance(req.getParameter("cs_pathogenic"), req.getParameter("cs_benign"), req.getParameter("cs_other"));
        return vsb;
    }
}
