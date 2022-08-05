<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %><%@ page import="java.util.List" %><%@ page import="edu.mcw.rgd.dao.impl.variants.VariantDAO" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.datamodel.Map" %><%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %><%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %><%@ page import="edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction" %><%@ page import="edu.mcw.rgd.datamodel.variants.VariantTranscript" %><%@ page import="edu.mcw.rgd.dao.impl.variants.PolyphenDAO" %><%@ page import="edu.mcw.rgd.dao.impl.variants.VariantTranscriptDao" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    response.setHeader("Content-disposition","attachment;filename=\"variants.csv\"");

    VariantDAO vdao = new VariantDAO();
    MapDAO mapDAO = new MapDAO();
    VariantTranscriptDao vtdao = new VariantTranscriptDao();
    PolyphenDAO polydao = new PolyphenDAO();

    String chr = request.getAttribute("chr").toString();
    int start = Integer.parseInt(request.getAttribute("start").toString());
    int stop = Integer.parseInt(request.getAttribute("stopPos").toString());
    int mapKey = Integer.parseInt(request.getAttribute("mapKey").toString());
    String symbol = request.getAttribute("symbol").toString();

    List<VariantMapData> vars = vdao.getVariantsWithGeneLocation(mapKey,chr,start,stop);
    Map map = mapDAO.getMap(mapKey);


    out.print(symbol);
    out.print(",");
    out.print(map.getName());
    out.print(",");
    out.println(SpeciesType.getCommonName(map.getSpeciesTypeKey()));

    out.print("rs ID");
    out.print(",");
    out.print("Chromosome");
    out.print(",");
    out.print("Start");
    out.print(",");
    out.print("Stop");
    out.print(",");
    out.print("Type");
    out.print(",");
    out.print("Reference Nucleotide");
    out.print(",");
    out.print("Variant Nucleotide");
    out.print(",");
    out.print("Location Type");
    out.print(",");
    out.print("PolyPhen Prediction");
    out.print(",");
    out.println("RGD ID");


    for (VariantMapData v : vars){
        List<VariantTranscript> vts = vtdao.getVariantTranscripts(v.getId(),mapKey);
        List<PolyPhenPrediction> p = null;
        String locType = "-";
        if (vts !=null && !vts.isEmpty()) {
            p = polydao.getPloyphenDataByVariantId((int) v.getId(), vts.get(0).getTranscriptRgdId());
            locType = vts.get(0).getLocationName().replace(",", "|");
        }
        if (Utils.isStringEmpty(v.getRsId()) || v.getRsId().equals(".")){
            out.print("-");
        }
        else
            out.print(v.getRsId());
        out.print(",");
        out.print(v.getChromosome());
        out.print(",");
        out.print(v.getStartPos());
        out.print(",");
        out.print(v.getEndPos());
        out.print(",");
        out.print(v.getVariantType());
        out.print(",");
        if (Utils.isStringEmpty(v.getReferenceNucleotide()))
            out.print("-");
        else
            out.print(v.getReferenceNucleotide());
        out.print(",");
        if (Utils.isStringEmpty(v.getVariantNucleotide()))
            out.print("-");
        else
            out.print(v.getVariantNucleotide());
        out.print(",");
        out.print(locType);
        out.print(",");
        if (p != null && !p.isEmpty()) {
            out.print(p.get(0).getPrediction());
        }
        else
            out.print("-");
        out.print(",");
        out.println(v.getId());
    }
%>