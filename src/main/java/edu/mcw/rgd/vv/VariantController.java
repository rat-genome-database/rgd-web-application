package edu.mcw.rgd.vv;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.dao.impl.variants.PolyphenDAO;
import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.dao.impl.variants.VariantTranscriptDao;
import edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction;
import edu.mcw.rgd.datamodel.variants.VariantTranscript;
import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.common.recycler.Recycler;
import org.elasticsearch.search.SearchHit;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.util.*;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/25/11
 * Time: 10:32 AM
 */
public class VariantController extends HaplotyperController {

    GeneDAO gdao = new GeneDAO();
    Gson gson=new Gson();
    TranscriptDAO tdao=new TranscriptDAO();

    VariantTranscriptDao dao=new VariantTranscriptDao();
    HashMap<Integer, List<PolyPhenPrediction>> polyphenPredictionCache=new HashMap<>();
    HashMap<Integer, String> transcriptSymbolCache=new HashMap<>();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {

            HttpRequestFacade req = new HttpRequestFacade(request);
            String geneList=req.getParameter("geneList");

            String searchType="";

            if (!geneList.equals("")) {
                if (!geneList.contains("|") && !geneList.contains("*") && Utils.symbolSplit(geneList).size()>1 ) {
                    return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
                }else {
                    searchType="GENE";
                }
            }
           /* if (geneList.equals("") ) {
               return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }*/

            VariantSearchBean vsb = this.fillBean(req);
            if(!geneList.contains("|"))
                vsb.genes=Utils.symbolSplit(geneList).stream().map(g->g.toLowerCase()).collect(Collectors.toList());
            else
                vsb.genes= Collections.singletonList(geneList.toLowerCase());
            String index=new String();
            String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey())).replace(" ","");
            index= RgdContext.getESVariantIndexName("variants_"+species.toLowerCase()+vsb.getMapKey());
            VVService.setVariantIndex(index);
            if ((vsb.getStopPosition() - vsb.getStartPosition()) > 30000000) {
                long region = (vsb.getStopPosition() - vsb.getStartPosition()) / 1000000;
                throw new Exception("Maximum Region size is 30MB. Current region is " + region + "MB.");
            }else if ((vsb.getStopPosition() - vsb.getStartPosition()) > 20000000) {
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }
            List<VariantResult> variantResults = this.getVariantResults(vsb, req, false);
            long count=variantResults.size();
            if (count < 2000 || searchType.equals("GENE")) {
                SNPlotyper snplotyper = new SNPlotyper();

                snplotyper.addSampleIds(vsb.sampleIds);


                for (VariantResult vr: variantResults) {
                    if (vr.getVariant() != null ) {
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
                if (mappedGenes.size() > 0) {
                    vsb.setMappedGenes(mappedGenes);

                    String geneListStr=   mappedGenes.stream().
                            map(mg->mg.getGene().getSymbol()).collect(Collectors.joining("+"));
                    request.setAttribute("geneListStr",geneListStr);
                }
                // note: call the methods below to catch 'no-strand' exceptions
                boolean b1 = snplotyper.hasPlusStrandConflict();
                boolean b2 = snplotyper.hasMinusStrandConflict();

                request.setAttribute("mapKey",vsb.getMapKey());
                request.setAttribute("speciesTypeKey", SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey()));
                return new ModelAndView("/WEB-INF/jsp/vv/variants.jsp");
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
            return new ModelAndView("/WEB-INF/jsp/vv/region.jsp");
        }
    }
    public List<MappedGene> getActiveMappedGenes(VariantSearchBean vsb) throws Exception {
        GeneDAO gdao= new GeneDAO();
        List<MappedGene> mappedGenes= gdao.getActiveMappedGenes(vsb.getChromosome(),vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
        return mappedGenes;
    }

    public List<VariantResult> getVariantResults(VariantSearchBean vsb, HttpRequestFacade req, boolean requiredTranscripts) throws Exception {
        Gson gson=new Gson();
        VVService service= new VVService();
        List<SearchHit> hits=service.getVariants(vsb,req);
        List<VariantResult> variantResults=new ArrayList<>();
        //System.out.println("HITS SIZE:" + hits.size());
        Map<Integer, List<TranscriptResult>> transcriptMap=new HashMap<>();
        for (SearchHit h : hits) {
            java.util.Map<String, Object> m = h.getSourceAsMap();
            VariantResult vr = new VariantResult();
            Variant v = new Variant();
            v.setId((Integer) m.get("variant_id"));
            v.setRsId((String) m.get("rsId"));
            v.setChromosome((String) m.get("chromosome"));
            v.setStartPos((int) m.get("startPos"));
            v.setEndPos((int) m.get("endPos"));
            v.setReferenceNucleotide((String) m.get("refNuc"));
            v.setVariantNucleotide((String) m.get("varNuc"));
            v.setGenicStatus((String) m.get("genicStatus"));
            v.setPaddingBase((String) m.get("paddingBase"));
            if(m.get("regionName")!=null)
                v.setRegionName(m.get("regionName").toString());
            v.setVariantType((String) m.get("variantType"));
            v.setSampleId((int) m.get("sampleId"));
            v.setVariantFrequency((int) m.get("varFreq"));
            v.setDepth((Integer) m.get("totalDepth"));
            if(m.get("qualityScore")!=null)
                v.setQualityScore((int) m.get("qualityScore"));
            v.setZygosityStatus((String) m.get("zygosityStatus"));
            v.setZygosityInPseudo((String) m.get("zygosityInPseudo"));
            v.setZygosityNumberAllele((Integer) m.get("zygosityNumAllele"));
            double p= (double) m.get("zygosityPercentRead");
            v.setZygosityPercentRead((int) p);
            v.setZygosityPossibleError((String) m.get("zygosityPossError"));
            v.setZygosityRefAllele((String) m.get("zygosityRefAllele"));
            v.conservationScore.add(mapConservation(m));
            vr.setVariant(v);
            if(requiredTranscripts) {
                List<TranscriptResult> trs = new ArrayList<>();
             //   List<VariantTranscript> transcripts = (List<VariantTranscript>) m.get("variantTranscripts");
             //   System.out.println(gson.toJson(transcripts));
              /*  if(transcriptMap.get(m.get("variant_id"))==null) {
                     trs.addAll(this.getVariantTranscriptResults((Integer) m.get("variant_id"), vsb.getMapKey()));
                     transcriptMap.put((Integer) m.get("variant_id"), transcriptMap.get(m.get("variant_id")));
                }else{
                    trs.addAll(transcriptMap.get(m.get("variant_id")));
                }*/

                if (m.get("variantTranscripts")!=null) {
                    try {
                        trs = getTranscriptResults(m.get("variantTranscripts"), (Integer) m.get("variant_id"));
                    }catch (Exception e){
                        e.printStackTrace();
                    }
                    if(trs!=null && trs.size()>0)
                    vr.setTranscriptResults(trs);
                }
            }

            if(vsb.getMapKey()==38){
                VariantInfo clinvar=getClinvarInfo(v.getId());
//                            System.out.println("CLINVAR: "+ clinvar.getClinicalSignificance()+"\t"+ clinvar.getTraitName());
                vr.setClinvarInfo(clinvar);
            }
            variantResults.add(vr);

        }

        return variantResults;
    }
    VariantInfo getClinvarInfo(long variantRGDId) throws Exception {

        VariantInfoDAO dao= new VariantInfoDAO();
        return dao.getVariant((int) variantRGDId);

    }
    List<TranscriptResult> getTranscriptResults(Object object, int variantId) throws IOException {
        List<TranscriptResult> trs=new ArrayList<>();
        List objects= (List) object;
        ObjectMapper objectMapper=new ObjectMapper();
        for(Object o:objects) {
            VariantTranscript t=new VariantTranscript();
             if(o!=null){
                t= objectMapper.readValue(gson.toJson(o),VariantTranscript.class);
             }
          //  for (VariantTranscript t : transcripts) {
                if (t != null && t.getTranscriptRgdId() != 0) {
                    TranscriptResult tr = new TranscriptResult();
                    AminoAcidVariant aa = new AminoAcidVariant();
                    if (t.getTripletError() != null)
                        aa.setTripletError(t.getTripletError());
                    if (t.getSynStatus() != null)
                        aa.setSynonymousFlag(t.getSynStatus());
                    if (t.getPolyphenStatus() != null)
                        aa.setPolyPhenStatus(t.getPolyphenStatus());
                    if (t.getNearSpliceSite() != null)
                        aa.setNearSpliceSite(t.getNearSpliceSite());

                    // tr.set.setFrameShift((String) source.get("frameShift"));
                    if (t.getTranscriptRgdId() != 0)
                        tr.setTranscriptId(String.valueOf(t.getTranscriptRgdId()));
                    if (t.getLocationName() != null)
                        aa.setLocation(t.getLocationName());
                    if (t.getRefAA() != null)
                        aa.setReferenceAminoAcid(t.getRefAA());
                    if (t.getVarAA() != null)
                        aa.setVariantAminoAcid(t.getVarAA());
       /*  if (source.get("fullRefAA") != null)
             aa.setAASequence(source.get("fullRefAA").toString());
         if (source.get("fullRefNuc") != null)
             aa.setDNASequence(source.get("fullRefNuc").toString());*/
                    if (t.getFullRefAASeqKey() != 0) {
                        aa.setAASequence(getSequence(t.getFullRefAASeqKey()));
                    }
                    if (t.getFullRefNucSeqKey() != 0) {
                        aa.setDNASequence(getSequence(t.getFullRefNucSeqKey()));
                    }
                    if (t.getFullRefAAPos() != null) {
                        //    System.out.println("FULL REF AA PSOTION:" + t.getFullRefAAPos());
                        aa.setAaPosition(t.getFullRefAAPos());
                    }
                    if (t.getFullRefNucPos() != null) {
                        //    System.out.println("FULL REF AA PSOTION:" + t.getFullRefNucPos());
                        aa.setDnaPosition(t.getFullRefNucPos());
                    }
                    if (tr.getTranscriptId() != null && !tr.getTranscriptId().equals("0")) {
                        String trSymbol = transcriptSymbolCache.get(Integer.parseInt(tr.getTranscriptId()));
                        if(trSymbol!=null){
                           trSymbol= transcriptSymbolCache.get(Integer.parseInt(tr.getTranscriptId()));
                        }else{
                         trSymbol=   getTranscriptSymbol(tr.getTranscriptId());
                         transcriptSymbolCache.put(Integer.parseInt(tr.getTranscriptId()), trSymbol);
                        }
                        if (trSymbol != null)
                            aa.setTranscriptSymbol(trSymbol);
                    }
                    tr.setAminoAcidVariant(aa);
                    //********************************************Polyphenprediction********//
                    List<PolyPhenPrediction> polyPhenPredictions=new ArrayList<>();
                    if(polyphenPredictionCache.get(variantId)!=null){
                        polyPhenPredictions.addAll(polyphenPredictionCache.get(variantId));
                    }else {

                         List<PolyPhenPrediction> predictions=getPolphenPredictionByVariantId(variantId, t.getTranscriptRgdId());
                        polyPhenPredictions.addAll(predictions);
                        polyphenPredictionCache.put(variantId, predictions);
                    }
                    if ( polyPhenPredictions.size() > 0)
                        tr.setPolyPhenPrediction(polyPhenPredictions);
                    trs.add(tr);
                }
           // }
        }
        return  trs;
    }
   public List<TranscriptResult> getVariantTranscriptResults(int variantId, int mapKey) throws IOException {
        List<TranscriptResult> trs=new ArrayList<>();
        List<VariantTranscript> transcripts=new ArrayList<>();
        try {
            transcripts= dao.getVariantTranscripts(variantId,mapKey);
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            for(VariantTranscript t:transcripts ){

                TranscriptResult tr = new TranscriptResult();
                AminoAcidVariant aa = new AminoAcidVariant();
                aa.setTripletError(t.getTripletError());
                aa.setSynonymousFlag(t.getSynStatus());
                aa.setPolyPhenStatus(t.getPolyphenStatus());
                aa.setNearSpliceSite(t.getNearSpliceSite());

                // tr.set.setFrameShift((String) source.get("frameShift"));
                tr.setTranscriptId(String.valueOf(t.getTranscriptRgdId()));
                aa.setLocation(t.getLocationName());
                aa.setReferenceAminoAcid(t.getRefAA());
                aa.setVariantAminoAcid(t.getVarAA());
           /*  if (source.get("fullRefAA") != null)
                 aa.setAASequence(source.get("fullRefAA").toString());
             if (source.get("fullRefNuc") != null)
                 aa.setDNASequence(source.get("fullRefNuc").toString());*/
                if (t.getFullRefAASeqKey() != 0) {
                    aa.setAASequence(getSequence(t.getFullRefAASeqKey()));
                }
                if (t.getFullRefNucSeqKey() != 0) {
                    aa.setDNASequence(getSequence(t.getFullRefNucSeqKey()));
                }
                if (t.getFullRefAAPos() != null) {
                    //    System.out.println("FULL REF AA PSOTION:" + t.getFullRefAAPos());
                    aa.setAaPosition(t.getFullRefAAPos());
                }
                if (t.getFullRefNucPos() != null) {
                    //    System.out.println("FULL REF AA PSOTION:" + t.getFullRefNucPos());
                    aa.setDnaPosition(t.getFullRefNucPos());
                }
                String trSymbol = getTranscriptSymbol(tr.getTranscriptId());
                if (trSymbol != null)
                    aa.setTranscriptSymbol(trSymbol);
                tr.setAminoAcidVariant(aa);
                //********************************************Polyphenprediction********//
                List<PolyPhenPrediction> polyPhenPredictions = getPolphenPredictionByVariantId(variantId,t.getTranscriptRgdId());
                if (polyPhenPredictions != null && polyPhenPredictions.size() > 0)
                    tr.setPolyPhenPrediction(polyPhenPredictions);
                trs.add(tr);
            }

        } catch (Exception exception) {
            exception.printStackTrace();
        }
        return  trs;
    }
    public List<PolyPhenPrediction> getPolphenPredictionByVariantId(int variantId, int transcriptId)
    {
        PolyphenDAO pdao=new PolyphenDAO();

        try {
            //   return pdao.getPloyphenDataByVariantId(86880133);
            return pdao.getPloyphenDataByVariantId(variantId, transcriptId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    public String getSequence(int seqKey){
        SequenceDAO sequenceDAO=new SequenceDAO();
        List<Sequence>  sequences=new ArrayList<>();
        try {
            sequences= sequenceDAO.getObjectSequencesBySeqKey(seqKey);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(sequences!=null){
            return sequences.get(0).getSeqData();
        }
        return null;
    }
    public String getTranscriptSymbol(String transcriptId){
        Transcript tr= null;
        try {
            tr = tdao.getTranscript(Integer.parseInt(transcriptId));
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(tr!=null)
            return tr.getAccId();
        return null;
    }
    public ConservationScore mapConservation(java.util.Map m)  {
        List conScores= (List) m.get("conScores");
//        System.out.println(conScores.toString());
        ConservationScore  cs = new ConservationScore();

        try{
            if(conScores!=null && conScores.size()>=1 ) {
                if(conScores.get(0) instanceof Integer){
                    BigDecimal score=  BigDecimal.valueOf((Integer) conScores.get(0));
                    cs.setScore(score);
                    cs.setChromosome((String) m.get("chromosome"));
                    cs.setPosition((Integer) m.get("startPos"));
                    cs.setNuc((String) m.get("refNuc"));
                }else{
                    if(conScores.get(0) instanceof Double){
                        BigDecimal score= BigDecimal.valueOf((Double) conScores.get(0));
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
                            if(conScores.get(0) instanceof String){
                                cs.setScore(BigDecimal.valueOf(Double.parseDouble((String) conScores.get(0))));
                                cs.setChromosome((String) m.get("chromosome"));
                                cs.setPosition((Integer) m.get("startPos"));
                                cs.setNuc((String) m.get("refNuc"));
                            }

                        }
                    }
                }
            }else{

                cs.setScore(BigDecimal.valueOf(-1));
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