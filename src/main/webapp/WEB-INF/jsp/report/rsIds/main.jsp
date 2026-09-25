<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>
<%
    String title = "Variant";
    List<VariantMapData> vars = (List<VariantMapData>) request.getAttribute("reportObjects");

    int speciesType = Integer.parseInt(request.getAttribute("species").toString());
    int mapKey = Integer.parseInt(request.getAttribute("mapKey").toString());
    String objectType="Variants";
    String displayName = request.getParameter("id");
    String symbol = "";
    String sym;
    try {
        sym = request.getAttribute("symbol").toString();
    }
    catch (Exception ignore){
        sym = "";
    }
    boolean isGene = false;
    if (sym.isEmpty()){
         displayName = request.getParameter("id");
         symbol = displayName;
    }
    else {
        isGene = true;

        symbol = request.getAttribute("symbol").toString();
        displayName = symbol + " Variants";
    }
    String pageTitle = displayName;
    String headContent = "";
    String pageDescription = pageTitle + " Variants";

%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script>
    let reportTitle = "rgdvariant";
</script>

<div id="page-container" class="<%=reportSkinClass%>">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(speciesType)%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">

        <%
            // The object whose variants these are, in front of the noun - "Gene Variants" - so
            // the eyebrow says whose list this is and still matches the Variants section that
            // links here. Not "Variant Report": the single-variant reports that share this
            // controller (cnVariants/main.jsp) keep that label.
            //
            // isGene is set above off the "symbol" request attribute, which only the geneId
            // branch of CNVariantsRsIdController sets. The other branch that reaches this page
            // is a lookup by rs ID, where there is no owning object to name.
            heroEyebrow = isGene ? "Gene Variants" : "Variants";
            heroTitle = displayName;
            heroSpeciesKey = speciesType;
            heroIcon = "fa-dot-circle-o";
            heroWatch = false;
            if( vars!=null && !vars.isEmpty() ) {
                heroChips.add("fa-list|" + vars.size() + (vars.size()==1 ? " variant" : " variants"));
            }
            // The stretch of genome these variants were pulled from, written the way the gene
            // report writes it so the two pages read alike - position in the chip, assembly in
            // its tooltip. Only the gene-scoped request has a single span to name: the geneId
            // branch of the controller is the one that sets chr/start/stop, and it resolves
            // them against one reference assembly. A lookup by rs id has no such span - the
            // rows it returns can sit on more than one assembly.
            Object varChr   = request.getAttribute("chr");
            Object varStart = request.getAttribute("start");
            Object varStop  = request.getAttribute("stop");
            if( isGene && varChr!=null && varStart!=null && varStop!=null ) {
                Map varMap = mapDAO.getMap(mapKey);
                heroChips.add("fa-map-marker|chr" + varChr + ":" + varStart + "-" + varStop
                        + (varMap!=null ? "|" + varMap.getName() : ""));
            }
        %>
        <%@ include file="../reportHero.jsp"%>

        <table width="95%" border="0">
            <tr>
                <td>

                    <%@ include file="info.jsp"%>

            </tr>
        </table>
    </div>
</div>
<%--<%@ include file="../reportFooter.jsp"%>--%>
<%@ include file="/common/footerarea.jsp"%>
<script src="/rgdweb/js/reportPages/geneReport.js?v=22"> </script>
<script src="/rgdweb/js/reportPages/reportModernUx.js?v=9"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=5"> </script>