<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %><%@ page import="java.util.List" %><%@ page import="java.util.ArrayList" %><%@ page import="edu.mcw.rgd.datamodel.*" %><%@ page import="edu.mcw.rgd.datamodel.MappedGene" %><%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.QTLDAO" %>
<%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    response.setHeader("Content-disposition","attachment;filename=\"qtl.csv\"");
    //Report report =  (Report)request.getAttribute("report");
    //out.println(report.format(new DelimitedReportStrategy()));
    QTLDAO qdao = new QTLDAO();

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
    out.print("RGD ID");





    List<MappedQTL> qtls = qdao.getActiveMappedQTLsByIds(MapManager.getInstance().getReferenceAssembly(Integer.parseInt(species)).getKey(),idList);




    for (MappedGene g: genes) {
        out.print(g.getChromosome());
        out.print(",");
        out.print(g.getStart());
        out.print(",");
        out.print(g.getStop());
        out.print(",");
        out.print(g.getGene().getSymbol());
        out.print(",");
        out.print(g.getGene().getRgdId());
        out.print(",");
        out.println(g.getGene().getDescription());
    }
%>

