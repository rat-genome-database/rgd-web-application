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
        int mapKey = activeMap.getKey();
        if (obj.getSpeciesTypeKey()==3)
            mapKey=372;
        totalVars = vdao.getVariantsCountWithGeneLocation(mapKey, map.getChromosome(), map.getStartPos(), map.getStopPos());
    }catch (Exception e){
//        System.out.println(e);
    }
%>
<% if (totalVars>0){%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div class="reportTable light-table-border" id="cnVariantsWrapper">
    <div class="sectionHeading" id="cnVariants">Variants</div>

    <%-- The section is one call to action: how many variants this gene has, and the way
         through to them. It used to be a copy of the homepage's "popular tools" tile - a
         layout table holding a 295px card with a hard black border, an absolutely positioned
         title block, and an invisible .headerCardOverlay div (its text content was ".")
         sitting on top to catch the click. Three things follow from that being a link now:
         it is keyboard reachable, it middle-clicks, and it takes its look from the report
         skin rather than from the copy of the homepage's stylesheet that used to sit at the
         foot of this file. The count leads, because that is what a reader comes here for. --%>
    <a class="rgd-variant-cta" href="/rgdweb/report/rsId/main.html?geneId=<%=rgdId.getRgdId()%>">
        <img class="rgd-variant-cta-thumb" src="/rgdweb/common/images/variantPage.png"
             alt="" aria-hidden="true"/>
        <span class="rgd-variant-cta-text">
            <span class="rgd-variant-cta-count"><%=java.text.NumberFormat.getIntegerInstance().format(totalVars)%></span>
            <span class="rgd-variant-cta-label">variants in <%=obj.getSymbol()%></span>
        </span>
        <span class="rgd-action rgd-action-primary rgd-variant-cta-go">
            <i class="fa fa-table" aria-hidden="true"></i> View variant list
        </span>
    </a>
</div>
<%-- there used to be a second </div> here. Nothing in this file opens it - #cnVariantsWrapper
     is closed by the tag above, and sectionHeader/sectionFooter only wrap the include in a
     try/catch - so on any gene with variants it closed #content-wrap instead. Every section
     after this include then sat outside #content-wrap, and reportModernUx.js, which looks for
     "#content-wrap .light-table-border", stopped finding them: no accordion from here down. --%>
<% } %>


<%@ include file="sectionFooter.jsp"%>