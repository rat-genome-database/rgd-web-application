package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.carpenovo.vvservice.VVService;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.dao.impl.TranscriptDAO;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.elasticsearch.search.SearchHit;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/25/11
 * Time: 10:32 AM
 */
public class VariantController extends HaplotyperController {

    VVService service= new VVService();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {

            HttpRequestFacade req = new HttpRequestFacade(request);
            String geneList=req.getParameter("geneList");
            ModelMap model=new ModelMap();

            String searchType="";

            if (!geneList.equals("")) {
                if (!geneList.contains("|") && !geneList.contains("*") && Utils.symbolSplit(geneList).size()>1 ) {
                   return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
                }else {
                    searchType="GENE";
                }
            }
            if (geneList.equals("") && !req.getParameter("rdo_term").equals("")) {
               return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }

            GeneDAO gdao = new GeneDAO();

            VariantSearchBean vsb = this.fillBean(req);

            String index=new String();
            if(vsb.getMapKey()==17 ) {
                if ((vsb.getChromosome() == null && vsb.getChromosome().equals(""))){
                    index = "variants_human_*_dev";
                }else{

                    index="variants_human_chr"+vsb.getChromosome().toLowerCase()+"_dev";
                }
            }
            //   index= RgdContext.getESIndexName("variant_"+SpeciesType.getCommonName(speciesTypeKey).toLowerCase());
          /*  if(mapKey==360 || mapKey==70 || mapKey==60)
                index= "variant_rat_index_dev1";
            if(mapKey==631 || mapKey==600 )
                index= "variant_dog_index_dev2";*/
            service.setVariantIndex(index);
            if ((vsb.getStopPosition() - vsb.getStartPosition()) > 30000000) {
                long region = (vsb.getStopPosition() - vsb.getStartPosition()) / 1000000;
                throw new Exception("Maximum Region size is 30MB. Current region is " + region + "MB.");
            }else if ((vsb.getStopPosition() - vsb.getStartPosition()) > 20000000) {
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }

      /*  if ((vsb.getStopPosition() - vsb.getStartPosition()) > 250000) {
            count = vdao.getPositionCount(vsb);
            System.out.println("position count = " + count);
        }*/

     //     if (count < 2000 || searchType.equals("GENE")) {
            if (searchType.equals("GENE")) {

                SNPlotyper snplotyper = new SNPlotyper();

                snplotyper.addSampleIds(vsb.sampleIds);

                //         List<VariantResult> variantResults = vdao.getVariantAndConservation(vsb);
                List<VariantResult> variantResults = this.getVariantResults(vsb, req);

                //    System.out.println(variantResults.size());

                for (VariantResult vr: variantResults) {
                    if (vr.getVariant() != null) {
                        snplotyper.add(vr);
                    }
                }

                List<MappedGene> mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
                snplotyper.addGeneMappings(mappedGenes);
                TranscriptDAO tdao = new TranscriptDAO();
                List<MapData> mapData = tdao.getFeaturesByGenomicPos(vsb.getMapKey(),vsb.getChromosome(), (int) (long) vsb.getStartPosition(), (int) (long) vsb.getStopPosition(),15);
                snplotyper.addExons(mapData);

                request.setAttribute("snplotyper",snplotyper);
                request.setAttribute("vsb",vsb);

                // note: call the methods below to catch 'no-strand' exceptions
                boolean b1 = snplotyper.hasPlusStrandConflict();
                boolean b2 = snplotyper.hasMinusStrandConflict();

                return new ModelAndView("/WEB-INF/jsp/haplotyper/variants.jsp");
            }else {
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }

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
    public List<MappedGene> getActiveMappedGenes(VariantSearchBean vsb) throws Exception {
        GeneDAO gdao= new GeneDAO();
        List<MappedGene> mappedGenes= gdao.getActiveMappedGenes(vsb.getChromosome(),vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
        return mappedGenes;
    }

    public List<VariantResult> getVariantResults(VariantSearchBean vsb, HttpRequestFacade req) throws Exception {
        VVService service= new VVService();
        List<SearchHit> hits=service.getVariants(vsb,req);
        List<VariantResult> variantResults=new ArrayList<>();
        for(SearchHit h:hits){
            java.util.Map<String, Object> m=h.getSourceAsMap();
            VariantResult vr= new VariantResult();
            Variant v= mapVariant(m);
            v.conservationScore.add(mapConservation(m));
            vr.setVariant(v);
            variantResults.add(vr);

        }

        return variantResults;
    }

    public Variant mapVariant(java.util.Map m){

        Variant v = new Variant();
        v.setId((Integer) m.get("variant_id"));
        v.setChromosome((String) m.get("chromosome"));
        v.setSampleId((Integer) m.get("sampleId"));
        v.setStartPos((Integer) m.get("startPos"));
        v.setEndPos((Integer) m.get("endPos"));
        v.setVariantFrequency((Integer) m.get("varFreq"));
        v.setDepth((Integer) m.get("totalDepth"));
        v.setQualityScore((Integer) m.get("qualityScore"));
        v.setReferenceNucleotide((String) m.get("refNuc"));
        v.setVariantNucleotide((String) m.get("varNuc"));
        v.setZygosityStatus((String) m.get("zygosityStatus"));
        v.setZygosityInPseudo((String) m.get("zygosityInPseudo"));
        v.setZygosityNumberAllele((Integer) m.get("zygosityNumAllele"));
        v.setZygosityPercentRead(100);
        v.setZygosityPossibleError((String) m.get("zygosityPossError"));
        v.setZygosityRefAllele((String) m.get("zygosityRefAllele"));
        v.setGenicStatus((String) m.get("genicStatus"));
        v.setHgvsName((String) m.get("hgvsName"));
        v.setRgdId((Integer) m.get("rgdId"));
        v.setVariantType((String) m.get("variantType"));
        v.setPaddingBase((String) m.get("paddingBase"));
        List<String> geneSymbols= (List<String>) m.get("geneSymbols");
        if(geneSymbols!=null){
            if(geneSymbols.size()>0) {
                String geneSymbol = (geneSymbols).get(0);
                v.setRegionName(geneSymbol);
            }}
        return v;
    }
    public ConservationScore mapConservation(java.util.Map m)  {
        List conScores= (List) m.get("conScores");
        ConservationScore  cs = new ConservationScore();

        try{
            if(conScores!=null && conScores.size()>=1 ) {
                if(conScores.get(0) instanceof Integer){
                    BigDecimal score= new BigDecimal((Integer) conScores.get(0));
                    cs.setScore(score);
                    cs.setChromosome((String) m.get("chromosome"));
                    cs.setPosition((Integer) m.get("startPos"));
                    cs.setNuc((String) m.get("refNuc"));
                }else{
                    if(conScores.get(0) instanceof Double){
                        BigDecimal score= new BigDecimal((Double) conScores.get(0));
                        cs.setScore(score);
                        cs.setChromosome((String) m.get("chromosome"));
                        cs.setPosition((Integer) m.get("startPos"));
                        cs.setNuc((String) m.get("refNuc"));
                    }else{
                        if(conScores.get(0) instanceof BigDecimal){
                            BigDecimal score= (BigDecimal) conScores.get(0);
                            cs.setScore(score);
                            cs.setChromosome((String) m.get("chromosome"));
                            cs.setPosition((Integer) m.get("startPos"));
                            cs.setNuc((String) m.get("refNuc"));
                        }else{
                            if(conScores.get(0) ==null){
                                cs.setScore(BigDecimal.ZERO);
                                cs.setChromosome((String) m.get("chromosome"));
                                cs.setPosition((Integer) m.get("startPos"));
                                cs.setNuc((String) m.get("refNuc"));
                            }
                        }
                    }
                }
            }else{

                cs.setScore(BigDecimal.ZERO);
                cs.setChromosome((String) m.get("chromosome"));
                cs.setPosition((Integer) m.get("startPos"));
                cs.setNuc((String) m.get("refNuc"));

            }
        }catch (Exception e){
            System.out.println("CONSCORE:"+conScores.get(0));
            e.printStackTrace();
        }

        return cs;



    }
    private Object getLast(List list) {
        return list.size() > 0?list.get(list.size() - 1):null;
    }
    protected VariantSearchBean fillBeanNew(HttpRequestFacade req) throws Exception {

        VariantSearchBean vsb = new VariantSearchBean(0);

        if (req.getParameter("sample1").equals("all") && req.getParameter("sample").equals("")) {
            //get all the samples

            SampleDAO sdao = new SampleDAO();
            sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
            int mapKey = Integer.parseInt(req.getParameter("mapKey"));
            List<Sample> samples =new ArrayList<>();
            if(mapKey==17){
                String population="FIN";
               samples= sdao.getSamplesByMapKey(mapKey, population);
            }else
                samples=    sdao.getSamplesByMapKey(mapKey);

            vsb.setMapKey(mapKey);

            for (Sample s : samples) {
                vsb.sampleIds.add(s.getId());
            }

        } else {
            if(req.getParameter("sample")==null || Objects.equals(req.getParameter("sample"), "")){
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

                            } else {
                                // assembly mixup, ignore the sample
                                System.out.println("ERROR: assembly mixup");
                            }
                        }
                    }
                }

            }else{
                int sampleId= Integer.parseInt(req.getParameter("sample"));
                vsb.sampleIds.add(sampleId);
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
         /*   Position p = this.getPosition(req.getParameter("geneList"), req.getParameter("geneStart"), req.getParameter("geneStop"), mapKey);
            chromosome = p.getChromosome();
            start = p.getStart() + "";
            stop = p.getStop() + "";*/

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