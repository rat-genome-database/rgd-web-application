<%@ page import="java.util.List" %><%@ page import="java.util.ArrayList" %><%@ page import="edu.mcw.rgd.datamodel.*" %><%@ page import="edu.mcw.rgd.datamodel.MappedGene" %><%@ page import="edu.mcw.rgd.process.mapping.MapManager" %><%@ page import="edu.mcw.rgd.dao.impl.QTLDAO" %><%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    response.setHeader("Content-disposition","attachment;filename=\"qtl.csv\"");
    //Report report =  (Report)request.getAttribute("report");
    //out.println(report.format(new DelimitedReportStrategy()));
    QTLDAO qdao = new QTLDAO();
    MapDAO mdao = new MapDAO();
    String ids = request.getParameter("ids");
    String species= request.getParameter("species");


    String[] idArray = ids.split(",");

    List<Integer> idList = new ArrayList();
    for (int i=0; i< idArray.length; i++) {
        idList.add(Integer.parseInt(idArray[i]));
    }


    out.print("Chromosome");
    out.print(",");
    out.print("Start");
    out.print(",");
    out.print("Stop");
    out.print(",");
    out.print("QTL Symbol");
    out.print(",");
    out.println("RGD ID");


    for (Integer rgdId: idList) {

        QTL q = qdao.getQTL(rgdId);
        List<MapData> mdList = mdao.getMapData(q.getRgdId(),MapManager.getInstance().getReferenceAssembly(Integer.parseInt(species)).getKey());

        if (mdList.size() > 0) {
            MapData g = mdList.get(0);

            out.print(g.getChromosome());
            out.print(",");
            out.print(g.getStartPos());
            out.print(",");
            out.print(g.getStopPos());
        }else {
            out.print("");
            out.print(",");
            out.print("");
            out.print(",");
            out.print("");

        }

        out.print(",");
        out.print(q.getSymbol());
        out.print(",");
        out.println(q.getRgdId());

    }
%>

