<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %><%@ page import="java.util.List" %><%@ page import="edu.mcw.rgd.dao.impl.variants.VariantDAO" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.datamodel.Map" %><%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    response.setHeader("Content-disposition","attachment;filename=\"variants.csv\"");

    VariantDAO vdao = new VariantDAO();
    MapDAO mapDAO = new MapDAO();

    String chr = request.getParameter("chr");
    int start = Integer.parseInt(request.getParameter("start"));
    int stop = Integer.parseInt(request.getParameter("stopPos"));
    int mapKey = Integer.parseInt(request.getParameter("mapKey"));
    String symbol = request.getParameter("symbol");

    List<VariantMapData> vars = vdao.getVariantsWithGeneLocation(mapKey,chr,start,stop);
    Map map = mapDAO.getMap(mapKey);

    out.print(symbol);
    out.println(map.getName());

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
    out.println("RGD ID");


    for (VariantMapData v : vars){
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
        out.print(v.getReferenceNucleotide());
        out.print(",");
        out.print(v.getVariantNucleotide());
        out.print(",");
        out.println(v.getId());
    }%>