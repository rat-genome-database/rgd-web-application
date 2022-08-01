<%@ include file="sectionHeader.jsp"%>
<link rel="stylesheet" href="/rgdweb/js/javascriptPopUpWindow/GAdhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/rgdweb/js/javascriptPopUpWindow/dhtmlwindow.js">
</script>
<%
    edu.mcw.rgd.dao.impl.variants.VariantDAO vdao = new edu.mcw.rgd.dao.impl.variants.VariantDAO();
    final MapManager mm = MapManager.getInstance();
    Map activeMap = mm.getReferenceAssembly(obj.getSpeciesTypeKey());
    MapData map = null;
    List<MapData> mapData = mapDAO.getMapData(obj.getRgdId());
    for (MapData m : mapData){
        if (m.getMapKey()==activeMap.getKey()) {
            map = m;
        }
    }
    int totalVars = 0;
    try {
         totalVars = vdao.getVariantsCountWithGeneLocation(activeMap.getKey(), map.getChromosome(), map.getStartPos(), map.getStopPos());
    }catch (Exception e){
        System.out.println(e);
    }

%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div class="reportTable light-table-border" id="cnVariantsWrapper">
    <div class="sectionHeading" id="cnVariants">Variants</div>
    <br>
    <div>
        <b><a style="font-size: 14px;" href="/rgdweb/report/rsIds/main.html?geneId=<%=rgdId.getRgdId()%>">View <%=totalVars%> variants for <%=obj.getSymbol()%></a></b>
    </div>
    </div>
</div>
<%@ include file="sectionFooter.jsp"%>