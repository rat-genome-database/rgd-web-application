package edu.mcw.rgd.vv;


import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.*;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author jdepons
 * @since 10/25/11
 */
public class DownloadController extends VariantController {

    VVService service=new VVService();
    GeneDAO gdao = new GeneDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        /*
         a - strain name
         b - analysis description
         c - chromosome
         d - start
         e - stop
         f - reference nuc
         g - variant nucleotide
         h - conservation score

         */

        HttpRequestFacade req = new HttpRequestFacade(request);
        String geneList = java.net.URLDecoder.decode(req.getParameter("geneList"), "UTF-8");
        VariantSearchBean vsb = this.fillBean(req);
        String index=new String();
        String species= SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey()));
        index= RgdContext.getESVariantIndexName("variants_"+species.toLowerCase().replace(" ", "")+vsb.getMapKey());
        VVService.setVariantIndex(index);
        if ((vsb.getStopPosition() - vsb.getStartPosition()) > 30000000) {
            long region = (vsb.getStopPosition() - vsb.getStartPosition()) / 1000000;

            throw new Exception("Maximum Region size is 30MB. Current region is " + region + "MB.");
        }

        boolean isHuman = req.getParameter("mapKey").equals("38") || req.getParameter("mapKey").equals("17");

        List<MappedGene> mappedGenes=new ArrayList<>();

        if (request.getParameter("download") != null && request.getParameter("download").equals("1")) {

            response.setHeader("content-type", "text/plain");
            response.setHeader("Content-disposition", "attachment;filename=\"rgd_strain_snv.tab\"");
            PrintWriter out = response.getWriter();

            // handle single gene, or multiple genes in gene list parameter
            boolean multipleGeneSymbols = false;
            List<String> geneSymbols = null;
            if (!geneList.equals("") && !geneList.contains("|") && !geneList.contains("*")) {
                geneSymbols = Utils.symbolSplit(geneList);
                vsb.setGenes(geneSymbols.stream().map(String::toLowerCase).collect(Collectors.toList()));
                multipleGeneSymbols = geneSymbols.size()>1;
            }
//            if( !multipleGeneSymbols ) {
//                mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
//                generateReport(vsb, mappedGenes, request, out, true, isHuman);
//            } else {
              /*  for(int i=0; i<geneSymbols.size(); i++ ) {
                    String geneSymbol = geneSymbols.get(i);
                    System.out.println(geneSymbol);
                    Position p = this.getPosition(geneSymbol, req.getParameter("geneStart"), req.getParameter("geneStop"), vsb.getMapKey());
                    vsb.setPosition(p.getChromosome(), p.getStart() + "", p.getStop() + "");
                    mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
                 */   generateReport(vsb, null, request, out, true, isHuman);
                // }
//            }
            return null;
        }
        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/vv/download.jsp");
        mv.addObject("isHuman", isHuman);
        mv.addObject("vsb", vsb);
        return mv;
    }

    void generateReport(VariantSearchBean vsb, List<MappedGene> mappedGenes, HttpServletRequest request, PrintWriter out,
                        boolean printHeader, boolean isHuman) throws Exception {

System.out.println("GENERATING REPORT....");
        SampleDAO sdao = new SampleDAO();
        sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        List<Sample> samples = new ArrayList<>();
        LinkedHashMap<String,String> varNuc = new LinkedHashMap<>();
        for( int sampleId: vsb.sampleIds ) {
            //    varNuc.put(Integer.toString(sampleId), null);
            samples.add(sdao.getSampleBySampleId(sampleId));
        }
        String delim = "\t";
        HttpRequestFacade req = new HttpRequestFacade(request);

        if( printHeader ) {
            printHeader(req,out,delim,samples,isHuman);
        }
        String assembly= MapManager.getInstance().getMap(vsb.getMapKey()).getDescription();
        String species= SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey()));

        long start = vsb.getStartPosition();
        long stop = vsb.getStopPosition();
        long mark =0;

        long limit = 500000000;

        if (vsb.getStopPosition() - vsb.getStartPosition() > limit) {
            mark = start + limit;
        }else {
            mark=vsb.getStopPosition();
        }
        if (mappedGenes!=null && mappedGenes.size() > 0) {
            vsb.setMappedGenes(mappedGenes);

            for (MappedGene mg: vsb.getMappedGenes()) {
                vsb.genes.add(mg.getGene().getSymbol().toLowerCase());
            }
        }

        //     while (mark <= stop) {

        vsb.setPosition(vsb.getChromosome(),start + "",mark + "");
        List<VariantResult> variantResults = getVariantResults(vsb, req, true);
        if(variantResults==null){
            throw new VVException("0 Results found. Try update search query parameters");
        }
        //  start=mark;
        //  mark= Math.min(mark + limit, stop);
        TreeMap<String, List<VariantResult>> vrsMap=new TreeMap<>();
        for (VariantResult vr : variantResults) {
            String key=vr.getVariant().getChromosome()+"-"+ vr.getVariant().getStartPos()+"-"+vr.getVariant().getVariantNucleotide();

            List<VariantResult> vrs=new ArrayList<>();
            if(vrsMap.get(key)!=null){
                vrs.addAll(vrsMap.get(key));
            }
            vrs.add(vr);
            vrsMap.put(key, vrs);


        }
        for(Map.Entry e: vrsMap.entrySet()) {
            for( int sampleId: vsb.sampleIds ) {
                varNuc.put(Integer.toString(sampleId), null);
            }
            List<VariantResult> vResults= (List<VariantResult>) e.getValue();
            long rgdId=0;
            String rsId="";
            String chr = new String();
            long pos = -1;
            String score = "";
            String gene = null;
            String strand = null;
            String ref = null;
            String zygosity="";
            String genicStatu="";

            Set<String> location=new HashSet<>();
            Set<String > aaChangeMap=new HashSet<>();
            Set<Integer > aaChangePos=new HashSet<>();
            Set<String> transcriptMap=new HashSet<>();
            Set<String> varAAMap=new HashSet<>();
            Set<String> refAA=new HashSet<>();
            Set<String> polyMap=new HashSet<>();
            boolean first = true;

            for (VariantResult vr :vResults) {
                String samp = vr.getVariant().getSampleId() + "";
                chr = Objects.requireNonNull(vr.getVariant()).getChromosome();
                pos = vr.getVariant().getStartPos();
                rgdId = vr.getVariant().getId();
                if(vr.getVariant().getRsId()!=null)
                rsId=vr.getVariant().getRsId();
                gene = "";
                strand = "";
                if (varNuc.get(samp) != null) {

                    String v = varNuc.get(samp);
                    String[] vs = v.split("/");

                    boolean found=false;

                    for (int i=0; i< vs.length; i++) {
                        if (vs[i]!=null && vr.getVariant().getVariantNucleotide()!=null && vs[i].trim().equals(vr.getVariant().getVariantNucleotide().trim())) {
                            found=true;
                        }
                    }

                    if (!found) {
                        varNuc.put(samp, varNuc.get(samp) + "/" + vr.getVariant().getVariantNucleotide());
                    }

                }else {
                    varNuc.put(samp, vr.getVariant().getVariantNucleotide() +" ("+ vr.getVariant().getZygosityStatus()+")");
                }
                if(mappedGenes!=null) {
                    for (MappedGene mg : mappedGenes) {
                        if (pos >= mg.getStart() && pos <= mg.getStop()) {
                            if (!gene.equals("")) {
                                gene += "|";
                                strand += "|";
                            }

                            gene += mg.getGene().getSymbol();
                            strand += mg.getStrand();
                        }
                    }
                }else {
                    if(vr.getVariant().getRegionName()!=null)
                        gene+=vr.getVariant().getRegionName().replace("[","").replace("]","");
                }


                ref = vr.getVariant().getReferenceNucleotide();

                if (vr.getVariant() != null && vr.getVariant().getConservationScore() != null && vr.getVariant().getConservationScore().size() > 0) {
                    if (vr.getVariant().getConservationScore().get(0).getScore() != null && !Objects.equals(vr.getVariant().getConservationScore().get(0).getScore().toString(), "-1"))
                        score = vr.getVariant().getConservationScore().get(0).getScore().toString();
                }
                genicStatu=vr.getVariant().getGenicStatus();

                if(first) {


                    if(rgdId!=0)out.print(rgdId +delim);
                    out.print(rsId +delim);
                    out.print(species +delim);
                    out.print(assembly +delim);
                    if (!req.getParameter("c").equals("")) out.print(chr + delim);
                    if (!req.getParameter("p").equals("")) out.print(pos + delim);
                    if (!req.getParameter("cs").equals("")) out.print(score + delim);
                    if (!req.getParameter("gs").equals("")) out.print(gene + delim);
                    if (!req.getParameter("st").equals("")) out.print(strand + delim);
                    if (!req.getParameter("rn").equals("")) out.print(ref + delim);
                    first=false;
                }
                if(vr.getTranscriptResults()!=null && vr.getTranscriptResults().size()>0){

                    Set<String>  locationSet=vr.getTranscriptResults().stream()
                            .map(TranscriptResult::getAminoAcidVariant)
                            .filter(Objects::nonNull)
                            .map(AminoAcidVariant::getLocation)
                            .collect(Collectors.toSet());
                    location.addAll(locationSet);
                    Set<String> aaChange=   vr.getTranscriptResults().stream()
                            .filter(t->t.getAminoAcidVariant()!=null && t.getAminoAcidVariant().getSynonymousFlag()!=null)
                            .filter(t->!t.getAminoAcidVariant().getSynonymousFlag().equals(""))
                            .map(t->t.getAminoAcidVariant().getSynonymousFlag())
                            .collect(Collectors.toSet());
                    aaChangeMap.addAll(aaChange);
                    Set<Integer> aaPos=   vr.getTranscriptResults().stream()
                            .filter(t->t.getAminoAcidVariant().getAaPosition()!=0 && t.getAminoAcidVariant().getAaPosition()!=-1 && t.getAminoAcidVariant().getSynonymousFlag()!=null)
                            .filter(t->!t.getAminoAcidVariant().getSynonymousFlag().equals(""))
                            .map(t->t.getAminoAcidVariant().getAaPosition())
                            .collect(Collectors.toSet());
                    aaChangePos.addAll(aaPos);
                    Set<String> transcripts= ( vr.getTranscriptResults().stream()
                            .filter(t -> t.getAminoAcidVariant() != null)
                            .filter(t -> t.getAminoAcidVariant().getTranscriptSymbol() != null && !t.getAminoAcidVariant().getTranscriptSymbol().equals(""))
                            .map(t -> t.getAminoAcidVariant().getTranscriptSymbol()).collect(Collectors.toSet()));
                    transcriptMap.addAll(transcripts);
                    Set<String> poly=  vr.getTranscriptResults().stream()
                            .filter(t->t.getPolyPhenPrediction()!=null)
                            .map(t->t.getPolyPhenPrediction().stream()
                                    .map(PolyPhenPrediction::getPrediction))
                            .flatMap(Stream::distinct)
                            .collect(Collectors.toSet());
                    if (vr.getClinvarInfo() != null) {
                        String clinicalSignificance = vr.getClinvarInfo().getClinicalSignificance();
                        if (!Utils.isStringEmpty(clinicalSignificance)) {
                            poly.add(clinicalSignificance);
                        }
                    }
                    polyMap.addAll(poly);
                    Set<String>  varAA=vr.getTranscriptResults().stream()
                            .filter(t->t.getAminoAcidVariant()!=null)
                            .filter(t->t.getAminoAcidVariant().getVariantAminoAcid()!=null && !t.getAminoAcidVariant().getVariantAminoAcid().equals("") )
                            .map(t->t.getAminoAcidVariant().getVariantAminoAcid()).collect(Collectors.toSet());
                    varAAMap.addAll(varAA);

                    Set<String>  refAAset=(vr.getTranscriptResults().stream()
                            .map(t->t.getAminoAcidVariant().getReferenceAminoAcid())
                            .collect(Collectors.toSet()));
                    refAA.addAll(refAAset);

                }
                //       varNuc.put(samp, vr.getVariant().getVariantNucleotide());

            }
            if (!req.getParameter("sn").equals("")) {
                for (String k : varNuc.keySet()) {
                    if ((varNuc.get(k) != null && !varNuc.get(k).equals(ref)))
                        out.print(varNuc.get(k));
                    out.print(delim);
                }

            }
            out.print(genicStatu);
            out.print(delim);
//            out.print(zygosity);
//            out.print(delim);
            if (!req.getParameter("vl").equals("")) {
                out.print(location.stream()
                        .filter(StringUtils::isNotEmpty)
                        .collect(Collectors.joining("|")));
                out.print(delim);
            }

            if (!req.getParameter("aac").equals("")) {
                out.print(aaChangeMap.stream()
                        .filter(StringUtils::isNotEmpty)
                        .collect(Collectors.joining("|")));
                out.print(delim);
                out.print(aaChangePos.stream().filter(position->position!=0)
                                .map(String::valueOf)
                        .collect(Collectors.joining("|")));
                out.print(delim);
            }

            if (!req.getParameter("tai").equals("")) {
                out.print(transcriptMap.stream()
                        .filter(StringUtils::isNotEmpty)
                        .collect(Collectors.joining("|")));
                out.print(delim);
            }

            if (!req.getParameter("raa").equals("")) {
                out.print(refAA.stream()
                        .filter(StringUtils::isNotEmpty)
                        .collect(Collectors.joining("|")));
                out.print(delim);
            }


            if (!req.getParameter("vaa").equals("")) {
                out.print(varAAMap.stream()
                        .filter(StringUtils::isNotEmpty)
                        .collect(Collectors.joining("|")));
                out.print(delim);
            }
            if (!req.getParameter("pp").equals("")) {
                out.print(polyMap.stream()
                        .filter(StringUtils::isNotEmpty)
                        .collect(Collectors.joining("|")));

            }


            //      varNuc.put(samp, vr.getVariant().getVariantNucleotide());

            out.print(delim);
            out.print("\n");
        }
         /*   if (stop==mark) {
                break;
            }
        }*/
    }
    public void printHeader(HttpRequestFacade req,PrintWriter out, String delim, List<Sample> samples, boolean isHuman){
        if (!req.getParameter("c").equals(""))
            out.print("RGD_ID" + delim);
       // if (!req.getParameter("rsId").equals(""))
            out.print("RS_ID" + delim);
            out.print("SPECIES" + delim);
            out.print("ASSEMBLY" + delim);
        if (!req.getParameter("c").equals("")) out.print("Chromosome" + delim);
        if (!req.getParameter("p").equals("")) out.print("Position" + delim);
        if (!req.getParameter("cs").equals("")) out.print("Conservation Score" + delim);
        if (!req.getParameter("gs").equals("")) out.print("Gene Symbol" + delim);
        if (!req.getParameter("st").equals("")) out.print("Gene Strand" + delim);
        if (!req.getParameter("rn").equals("")) out.print("Reference" + delim);

        if (!req.getParameter("sn").equals("")) {
            for (Sample s : samples) {
                out.print(s.getAnalysisName() + " - Variant" + delim);
            }
        }
        out.print("Genic Status" + delim);
//        out.print("Zygosity" + delim);
        if (!req.getParameter("vl").equals("")) out.print("Variant Location" + delim);
        if (!req.getParameter("aac").equals("")) out.print("Amino Acid Change" + delim);
//        if (!req.getParameter("aap").equals(""))
            out.print("Amino Acid Position" + delim);
        if (!req.getParameter("tai").equals("")) out.print("Transcript Accession IDs" + delim);
        if (!req.getParameter("raa").equals("")) out.print("Reference Amino Acid" + delim);
        if (!req.getParameter("vaa").equals("")) out.print("Variant Amino Acid" + delim);
        if (!req.getParameter("pp").equals("")) {
            if( isHuman ) {
                out.print("Clinical Significance" + delim);
            } else {
                out.print("Polyphen Prediction" + delim);
            }
        }

        out.print("\n");
    }
}
