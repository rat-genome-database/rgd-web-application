<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.MappedGene" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%
    GeneDAO gdao = new GeneDAO();

    String ids = request.getParameter("ids");

    String[] idArray = ids.split(",");

    List<Integer> idList = new ArrayList();
    for (int i=0; i< idArray.length; i++) {
        idList.add(Integer.parseInt(idArray[i]));
    }

    List<MappedGene> genes = gdao.getActiveMappedGenesByIds(MapManager.getInstance().getReferenceAssembly(3))

    List<Gene> genes = gdao.getGeneByRgdIds(idList);

    for (Gene g: genes) {
%>
<%=g.getSymbol()%>,<%=g.getRgdId()%>,<%=g.getDescription()%>,<%=g.g%>
<%
    }


%>

<%=ids%>