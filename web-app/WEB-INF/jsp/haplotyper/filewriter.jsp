<%@ page import="edu.mcw.rgd.datamodel.VariantSearchBean" %><%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %><%@ page import="edu.mcw.rgd.dao.impl.VariantDAO" %><%@ page import="edu.mcw.rgd.datamodel.VariantResult" %><%@ page import="edu.mcw.rgd.datamodel.MappedGene" %><%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %><%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.File" %><%

 try {
    PrintWriter pw = new PrintWriter(new File("c:/home/flister/snps.txt"));

    if (request.getParameter("download") != null && request.getParameter("download").equals("1")) {

        //response.setHeader("content-type", "text/plain");
        //response.setHeader("Content-disposition", "attachment;filename=\"rgd_strain_snv.tab\"");

        VariantSearchBean vsb = (VariantSearchBean) request.getAttribute("vsb");
        List<MappedGene> mappedGenes = (List<MappedGene>) request.getAttribute("mappedGenes");

        VariantDAO vdao = new VariantDAO();
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        SampleDAO sdao = new SampleDAO();
        sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        int sampleCounter = 1;
        String sampleId = request.getParameter("sample1");

        LinkedHashMap varNuc = new LinkedHashMap();
        while (sampleId != null) {
            varNuc.put(request.getParameter("sample" + sampleCounter), null);
            sampleCounter++;
            sampleId = request.getParameter("sample" + sampleCounter);
        }


        List samples = new ArrayList();
        Iterator it = varNuc.keySet().iterator();
        while (it.hasNext()) {
            samples.add(sdao.getSampleBySampleId(Integer.parseInt((String) it.next())));
        }


        String delim = "\t";


        HttpRequestFacade req = new HttpRequestFacade(request);

        if (!req.getParameter("c").equals("")) pw.print("Chromosome" + delim);
        if (!req.getParameter("p").equals("")) pw.print("Position" + delim);
        if (!req.getParameter("cs").equals("")) pw.print("Conservation Score" + delim);
        if (!req.getParameter("gs").equals("")) pw.print("Gene Symbol" + delim);
        if (!req.getParameter("st").equals("")) pw.print("Gene Strand" + delim);
        if (!req.getParameter("rn").equals("")) pw.print("Reference Nucleotide" + delim);

        if (!req.getParameter("sn").equals("")) {

        it = samples.iterator();
            while (it.hasNext()) {
                Sample s = (Sample) it.next();
                pw.print(s.getAnalysisName() + delim);
            }
        }

        if (!req.getParameter("vl").equals("")) pw.print("Variant Location" + delim);
        if (!req.getParameter("aac").equals("")) pw.print("Amino Acid Change" + delim);
        if (!req.getParameter("tai").equals("")) pw.print("Transcript Accession IDs" + delim);
        if (!req.getParameter("raa").equals("")) pw.print("Referance Amino Acid" + delim);
        if (!req.getParameter("vaa").equals("")) pw.print("Variant Amino Acid" + delim);
        if (!req.getParameter("pp").equals("")) pw.print("Polyphen Prediction" + delim);

        pw.print("\n");

        long start = vsb.getStartPosition();
        long stop = vsb.getStopPosition();
        long mark =0;

        long limit = 20000000;

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
            String score = null;
            String gene = null;
            String strand = null;
            String cons = null;
            String ref = null;
            String samp = "0";
            String refAA = "";
            String var = "";



            long lastPosition = 0;
            long nextPosition = -1;

            boolean first = true;

            LinkedHashMap locationMap = new LinkedHashMap();
            LinkedHashMap varAAMap = new LinkedHashMap();
            LinkedHashMap polyMap = new LinkedHashMap();
            LinkedHashMap transcriptMap = new LinkedHashMap();
            LinkedHashMap aaChangeMap = new LinkedHashMap();




            for (VariantResult vr : variantResults) {

                samp = vr.getVariant().getSampleId() + "";
                nextPosition = vr.getVariant().getStartPos();

                if (lastPosition == nextPosition) {
                    varNuc.put(samp, vr.getVariant().getVariantNucleotide());

                    if (vr.getTranscriptResults().size() > 0) {

                        refAA = "";

                        for (int tcount = 0; tcount < vr.getTranscriptResults().size(); tcount++) {

                            locationMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getLocation().toLowerCase(), null);

                            if (vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getSynonymousFlag() != null) {
                                aaChangeMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getSynonymousFlag(), null);
                            }

                            transcriptMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getTranscriptSymbol(), null);


                            if (vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getReferenceAminoAcid() != null) {
                                refAA = vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getReferenceAminoAcid();
                                varAAMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getVariantAminoAcid(), null);

                                if (vr.getTranscriptResults().get(tcount).getPolyPhenPrediction().size() > 0) {
                                    polyMap.put(vr.getTranscriptResults().get(tcount).getPolyPhenPrediction().get(0).getPrediction(), null);
                                }
                            }
                        }

                    } else {
                        refAA = "";
                    }

                } else {

                    if (!first) {
                        if (!req.getParameter("c").equals(""))  pw.print(chr + delim);
                        if (!req.getParameter("p").equals("")) pw.print(pos + delim);
                        if (!req.getParameter("cs").equals("")) pw.print(score + delim);
                        if (!req.getParameter("gs").equals("")) pw.print(gene + delim);
                        if (!req.getParameter("st").equals("")) pw.print(strand + delim);
                        if (!req.getParameter("rn").equals("")) pw.print(ref + delim);

                        if (!req.getParameter("sn").equals(""))  {
                        it = varNuc.keySet().iterator();
                            while (it.hasNext()) {
                                var = (String) varNuc.get(it.next());
                                if (var == null) {
                                    pw.print(delim);
                                } else {
                                    pw.print(var + delim);
                                }
                            }
                        }

                        if (!req.getParameter("vl").equals("")) {
                            it = locationMap.keySet().iterator();
                            while (it.hasNext()) {
                                pw.print((String) it.next());
                                if (it.hasNext()) {
                                    pw.print("|");
                                }
                            }
                            pw.print(delim);
                        }

                        if (!req.getParameter("aac").equals("")){
                            it = aaChangeMap.keySet().iterator();
                            while (it.hasNext()) {
                                pw.print((String) it.next());
                                if (it.hasNext()) {
                                    pw.print("|");
                                }
                            }
                            pw.print(delim);
                        }

                        if (!req.getParameter("tai").equals("")) {
                            it = transcriptMap.keySet().iterator();
                            while (it.hasNext()) {
                                pw.print((String) it.next());
                                if (it.hasNext()) {
                                    pw.print("|");
                                }
                            }
                            pw.print(delim);
                        }

                        if (!req.getParameter("vaa").equals("")) {
                            it = varAAMap.keySet().iterator();
                            while (it.hasNext()) {
                                pw.print((String) it.next());
                                if (it.hasNext()) {
                                    pw.print("|");
                                }
                            }
                            pw.print(delim);
                        }

                        if (!req.getParameter("raa").equals("")) pw.print(refAA + delim);

                        if (!req.getParameter("pp").equals("")) {
                            it = polyMap.keySet().iterator();
                            while (it.hasNext()) {
                                pw.print((String) it.next());
                                if (it.hasNext()) {
                                    pw.print("|");
                                }
                            }
                        }

                        pw.print("\n");

                        Iterator vit = varNuc.keySet().iterator();
                        while (vit.hasNext()) {
                            String vkey = (String) vit.next();
                            varNuc.put(vkey, null);

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


                    if (vr.getTranscriptResults().size() > 0) {

                        refAA = "";

                        for (int tcount = 0; tcount < vr.getTranscriptResults().size(); tcount++) {

                            locationMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getLocation().toLowerCase(), null);

                            if (vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getSynonymousFlag() != null) {
                                aaChangeMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getSynonymousFlag(), null);
                            }

                            transcriptMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getTranscriptSymbol(), null);


                            if (vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getReferenceAminoAcid() != null) {
                                refAA = vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getReferenceAminoAcid();
                                varAAMap.put(vr.getTranscriptResults().get(tcount).getAminoAcidVariant().getVariantAminoAcid(), null);

                                if (vr.getTranscriptResults().get(tcount).getPolyPhenPrediction().size() > 0) {
                                    polyMap.put(vr.getTranscriptResults().get(tcount).getPolyPhenPrediction().get(0).getPrediction(), null);
                                }
                            }
                        }

                    } else {
                        refAA = "";
                    }


                }

                lastPosition = nextPosition;
            }

            if (stop==mark) {
                break;
            }
        }
        pw.close();
        return;
    }

}catch (Exception e) {
     e.printStackTrace();
 }
%>

<%@ include file="carpeHeader.jsp" %>
<%@ include file="menuBar.jsp" %>
<br>
Welcome to the RGD Download pages

Select Fields to include in your download.
<br>
<br>
<form action="download.html">
    <table align="center">
        <tr>
            <td>
                   <table>
                    <tr>
                        <td><input type='checkbox' name="c" checked>Chromosome</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="p" checked>Position</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="cs" checked>Conservation Score</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="gs" checked>Gene Symbol</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="st" checked>Gene Strand</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="rn" checked>Reference Nucleotide</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="sn" checked>Strain Names</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="vl" checked>Variant Location</td>
                    </tr>
                 </table>
            </td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td valign="top">
                   <table>

                    <tr>
                        <td><input type='checkbox' name="aac" checked>Amino Acid Change</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="tai" checked>Transcript Accession IDs</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="raa" checked>Reference Amino Acid</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="vaa" checked>Variant Amino Acid</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="pp" checked>Polyphen Prediction</td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td align="center"><input type='submit' value="Generate File"></td>
                    </tr>
                </table>

            </td>
        </tr>
    </table>



    <input type="hidden" name="download" value="1"/>
    <%


        out.print(fu.buildHiddenFormFieldsFromQueryString(request.getQueryString()));

    %>

</form>


