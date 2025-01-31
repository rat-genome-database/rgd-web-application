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
    <br>
    <table>
        <tr>
            <td><div class="headerCard" style="width: 200px;text-align: center;">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/report/rsId/main.html?geneId=<%=rgdId.getRgdId()%>'">.</div>
                <div class="headerCardTitle">Variants in <%=obj.getSymbol()%><br><span class="headerSubTitle"><%=totalVars%> total Variants</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/variantPage.png" height="175" width="270" border="0" /></span>
            </div></td>
            <%--        <td><b><a style="font-size: 20px;" href="/rgdweb/report/rsIds/main.html?geneId=<%=rgdId.getRgdId()%>">View <%=totalVars%> variants for <%=obj.getSymbol()%></a></b></td>--%>
            <%--        <td><a  href="/rgdweb/report/rsIds/main.html?geneId=<%=rgdId.getRgdId()%>" ><input type="image" style="cursor: pointer;"  src="/rgdweb/common/images/variantPage.png"></a></td> &lt;%&ndash; title="View variants in Variant Visualizer" href="/rgdweb/front/select.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=<%=obj.getSymbol()%>&mapKey=<%=activeMap.getKey()%>" &ndash;%&gt;--%>
        </tr>
    </table>
</div>
</div>
<% } %>
<style>
    .headerCardTitle {
        text-align:left;
        position:absolute;
        top:0; left:0;
        margin:0px;
        padding:5px;
        order-radius:10px;
        opacity:1;
        font-weight: bold;
        background-color:#eff3fc;
        color: #24609c;
        font-size: 16px;
        order-right:1px solid black;
        order:1px solid black;
        z-index:20;
    }
    .headerSubTitle {
        font-size:12px;
    }
    .headerCardOverlay {
        position:absolute;
        background-color:#2865a3;
        minWidth:263px;
        width:293px;
        height:195px;
        z-index:30;
        opacity:0;
    }
    .headerCardOverlay:hover {
        opacity:.5;
        cursor:pointer;
    }
    .headerCardImage {
        margin:10px;
        border:1px solid black;
        z-index:15;
    }
    .headerCard {
        position:relative;
        width:295px;
        min-width:295px;
        border: 1px solid black;
        border: 1px solid rgba(0,0,0,.125);
        margin:5px;
    }
</style>

<%@ include file="sectionFooter.jsp"%>