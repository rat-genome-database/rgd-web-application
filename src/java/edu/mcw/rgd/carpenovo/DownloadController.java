package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

/**
 * @author jdepons
 * @since 10/25/11
 */
public class DownloadController extends HaplotyperController {


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

        if ((vsb.getStopPosition() - vsb.getStartPosition()) > 30000000) {
            long region = (vsb.getStopPosition() - vsb.getStartPosition()) / 1000000;

            throw new Exception("Maximum Region size is 30MB. Current region is " + region + "MB.");
        }

        boolean isHuman = req.getParameter("mapKey").equals("38") || req.getParameter("mapKey").equals("17");

        GeneDAO gdao = new GeneDAO();
        List<MappedGene> mappedGenes;

        if (request.getParameter("download") != null && request.getParameter("download").equals("1")) {

            response.setHeader("content-type", "text/plain");
            response.setHeader("Content-disposition", "attachment;filename=\"rgd_strain_snv.tab\"");
            PrintWriter out = response.getWriter();

            // handle single gene, or multiple genes in gene list parameter
            boolean multipleGeneSymbols = false;
            List<String> geneSymbols = null;
            if (!geneList.equals("") && !geneList.contains("|") && !geneList.contains("*")) {
                geneSymbols = Utils.symbolSplit(geneList);
                multipleGeneSymbols = geneSymbols.size()>1;
            }
            if( !multipleGeneSymbols ) {
                mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
                generateReport(vsb, mappedGenes, request, out, true, isHuman);
            } else {
                for(int i=0; i<geneSymbols.size(); i++ ) {
                    String geneSymbol = geneSymbols.get(i);
                    Position p = this.getPosition(geneSymbol, req.getParameter("geneStart"), req.getParameter("geneStop"), vsb.getMapKey());
                    vsb.setPosition(p.getChromosome(), p.getStart() + "", p.getStop() + "");
                    mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
                    generateReport(vsb, mappedGenes, request, out, i==0, isHuman);
                }
            }
            return null;
        }
        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/haplotyper/download.jsp");
        mv.addObject("isHuman", isHuman);
        return mv;
    }

    void generateReport(VariantSearchBean vsb, List<MappedGene> mappedGenes, HttpServletRequest request, PrintWriter out,
                        boolean printHeader, boolean isHuman) throws Exception {

        VariantDAO vdao = new VariantDAO();
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        SampleDAO sdao = new SampleDAO();
        sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        List<Sample> samples = new ArrayList<>();
        LinkedHashMap<String,String> varNuc = new LinkedHashMap<>();
        for( int sampleId: vsb.sampleIds ) {
            varNuc.put(Integer.toString(sampleId), null);
            samples.add(sdao.getSampleBySampleId(sampleId));
        }


        String delim = "\t";


        HttpRequestFacade req = new HttpRequestFacade(request);

        if( printHeader ) {
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

            if (!req.getParameter("vl").equals("")) out.print("Variant Location" + delim);
            if (!req.getParameter("aac").equals("")) out.print("Amino Acid Change" + delim);
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

        long start = vsb.getStartPosition();
        long stop = vsb.getStopPosition();
        long mark =0;

        long limit = 500000000;

        if (vsb.getStopPosition() - vsb.getStartPosition() > limit) {
            mark = start + limit;
        }else {
            mark=vsb.getStopPosition();
        }


        while (mark <= stop) {

            vsb.setPosition(vsb.getChromosome(),start + "",mark + "");

            List<VariantResult> variantResults = vdao.getVariantResults(vsb);

            start=mark;

            if (mark + limit > stop) {
                mark = stop;
            }else {
                mark = mark + limit;
            }


            String chr = null;
            long pos = -1;
            String score = "";
            String gene = null;
            String strand = null;
            String ref = null;
            String refAA = "";

            long lastPosition = 0;
            long nextPosition = -1;

            boolean first = true;
            Iterator it;

            LinkedHashMap locationMap = new LinkedHashMap();
            LinkedHashMap varAAMap = new LinkedHashMap();
            LinkedHashMap polyMap = new LinkedHashMap();
            LinkedHashMap transcriptMap = new LinkedHashMap();
            LinkedHashMap aaChangeMap = new LinkedHashMap();


            //hack to ensure the last one is printed.
            VariantResult dummy = new VariantResult();
            Variant varDummy = new Variant();
            varDummy.setStartPos(0);
            dummy.setVariant(varDummy);
            variantResults.add(dummy);


            for (VariantResult vr : variantResults) {
                String samp = vr.getVariant().getSampleId() + "";
                nextPosition = vr.getVariant().getStartPos();

                if (lastPosition == nextPosition ) {

                    if (varNuc.get(samp) != null) {

                        String v = varNuc.get(samp);
                        String[] vs = v.split("/");

                        boolean found=false;

                        for (int i=0; i< vs.length; i++) {
                            if (vs[i].trim().equals(vr.getVariant().getVariantNucleotide().trim())) {
                                found=true;
                            }
                        }

                        if (!found) {
                            varNuc.put(samp, varNuc.get(samp) + "/" + vr.getVariant().getVariantNucleotide());
                        }

                    }else {
                        varNuc.put(samp, vr.getVariant().getVariantNucleotide());
                    }

                    refAA = "";
                    if (vr.getTranscriptResults().size() > 0) {

                        for( TranscriptResult trr: vr.getTranscriptResults() ) {
                            locationMap.put(trr.getAminoAcidVariant().getLocation().toLowerCase(), null);

                            if (trr.getAminoAcidVariant().getSynonymousFlag() != null) {
                                aaChangeMap.put(trr.getAminoAcidVariant().getSynonymousFlag(), null);
                            }

                            transcriptMap.put(trr.getAminoAcidVariant().getTranscriptSymbol(), null);


                            if (trr.getAminoAcidVariant().getReferenceAminoAcid() != null) {
                                refAA = trr.getAminoAcidVariant().getReferenceAminoAcid();
                                varAAMap.put(trr.getAminoAcidVariant().getVariantAminoAcid(), null);

                                if (trr.getPolyPhenPrediction().size() > 0) {
                                    polyMap.put(trr.getPolyPhenPrediction().get(0).getPrediction(), null);
                                }
                            }
                        }
                    }
                    if( vr.getClinvarInfo()!=null ) {
                        String clinicalSignificance = vr.getClinvarInfo().getClinicalSignificance();
                        if( !Utils.isStringEmpty(clinicalSignificance) ) {
                            polyMap.put(clinicalSignificance, null);
                        }
                    }

                } else {
                    if (!first ) {
                        if (!req.getParameter("c").equals(""))  out.print(chr + delim);
                        if (!req.getParameter("p").equals("")) out.print(pos + delim);
                        if (!req.getParameter("cs").equals("")) out.print(score + delim);
                        if (!req.getParameter("gs").equals("")) out.print(gene + delim);
                        if (!req.getParameter("st").equals("")) out.print(strand + delim);
                        if (!req.getParameter("rn").equals("")) out.print(ref + delim);

                        if (!req.getParameter("sn").equals(""))  {
                            for( String sampleId: varNuc.keySet() ) {
                                String v = varNuc.get(sampleId);
                                out.print(v!=null ? v : "");
                                out.print(delim);
                            }
                        }

                        if (!req.getParameter("vl").equals("")) {
                            it = locationMap.keySet().iterator();
                            while (it.hasNext()) {
                                out.print((String) it.next());
                                if (it.hasNext()) {
                                    out.print("|");
                                }
                            }
                            out.print(delim);
                        }

                        if (!req.getParameter("aac").equals("")){
                            it = aaChangeMap.keySet().iterator();
                            while (it.hasNext()) {
                                out.print((String) it.next());
                                if (it.hasNext()) {
                                    out.print("|");
                                }
                            }
                            out.print(delim);
                        }

                        if (!req.getParameter("tai").equals("")) {
                            it = transcriptMap.keySet().iterator();
                            while (it.hasNext()) {
                                out.print((String) it.next());
                                if (it.hasNext()) {
                                    out.print("|");
                                }
                            }
                            out.print(delim);
                        }

                        if (!req.getParameter("raa").equals("")) out.print(refAA + delim);

                        if (!req.getParameter("vaa").equals("")) {
                            it = varAAMap.keySet().iterator();
                            while (it.hasNext()) {
                                out.print((String) it.next());
                                if (it.hasNext()) {
                                    out.print("|");
                                }
                            }
                            out.print(delim);
                        }


                        if (!req.getParameter("pp").equals("")) {
                            it = polyMap.keySet().iterator();
                            while (it.hasNext()) {
                                out.print((String) it.next());
                                if (it.hasNext()) {
                                    out.print("|");
                                }
                            }
                        }

                        out.print("\n");

                        // init variables for next iteration
                        for (String sampleId: varNuc.keySet()) {
                            varNuc.put(sampleId, null);
                        }
                        locationMap = new LinkedHashMap();
                        varAAMap = new LinkedHashMap();
                        polyMap = new LinkedHashMap();
                        transcriptMap = new LinkedHashMap();
                        aaChangeMap = new LinkedHashMap();
                    }

                    first = false;

                    chr = vr.getVariant().getChromosome();
                    pos = vr.getVariant().getStartPos();

                    if (vr.getVariant().getConservationScore().size() > 0) {
                        score = vr.getVariant().getConservationScore().get(0).getScore().toString();
                    }


                    gene = "";
                    strand = "";

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


                    ref = vr.getVariant().getReferenceNucleotide();

                    varNuc.put(samp, vr.getVariant().getVariantNucleotide());

                    refAA = "";
                    if (vr.getTranscriptResults().size() > 0) {

                        for (TranscriptResult trr: vr.getTranscriptResults() ) {

                            locationMap.put(trr.getAminoAcidVariant().getLocation().toLowerCase(), null);

                            if (trr.getAminoAcidVariant().getSynonymousFlag() != null) {
                                aaChangeMap.put(trr.getAminoAcidVariant().getSynonymousFlag(), null);
                            }

                            transcriptMap.put(trr.getAminoAcidVariant().getTranscriptSymbol(), null);


                            if (trr.getAminoAcidVariant().getReferenceAminoAcid() != null) {
                                refAA = trr.getAminoAcidVariant().getReferenceAminoAcid();
                                varAAMap.put(trr.getAminoAcidVariant().getVariantAminoAcid(), null);

                                if (trr.getPolyPhenPrediction().size() > 0) {
                                    polyMap.put(trr.getPolyPhenPrediction().get(0).getPrediction(), null);
                                }
                            }
                        }
                    }
                    if( vr.getClinvarInfo()!=null ) {
                        String clinicalSignificance = vr.getClinvarInfo().getClinicalSignificance();
                        if( !Utils.isStringEmpty(clinicalSignificance) ) {
                            polyMap.put(clinicalSignificance, null);
                        }
                    }
                }

                lastPosition = nextPosition;
            }

            if (stop==mark) {
                break;
            }
        }
    }
}
