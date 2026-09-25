<%--
  Created by IntelliJ IDEA.
  User: mtutaj
  Date: Feb 22, 2012
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>


 <% boolean includeMapping = true;
    String title = "Genomic Elements";

    GenomicElement obj = (GenomicElement) request.getAttribute("reportObject");
    String objectType = "genomic element";
    String displayName = obj.getSymbol();

    // What to call this report. Two different "types" live on these records and only one of
    // them is the name of the page:
    //
    //   RgdId.getObjectTypeName()  "Promoter"          - what the object IS, already capitalised
    //   GenomicElement.getObjectType()  "initiation region"  - a finer subtype within that
    //
    // The heading wants the first. The second is real information but it is a detail about the
    // promoter, not a name for the page, so it goes on a chip instead. Named geRgdId rather
    // than rgdId because info.jsp declares an rgdId of its own and static includes share one
    // translation unit.
    RgdId geRgdId = managementDAO.getRgdId2(obj.getRgdId());
    String geTypeLabel = (geRgdId!=null && !Utils.isStringEmpty(geRgdId.getObjectTypeName()))
            ? geRgdId.getObjectTypeName()
            : "Genomic Element";
    String geType = Utils.NVL(obj.getObjectType(), "").trim();

    String pageTitle = obj.getSymbol() + " (" + geTypeLabel + ") - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "Rat Genome Database report page for " + geTypeLabel + " " + obj.getSymbol();

    // position on the reference assembly, for the hero chip. Prefixed names because the
    // includes below bring their own refMap/mapData/md into the same translation unit.
    edu.mcw.rgd.datamodel.Map geRefMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey());
    List geMapDataList = mapDAO.getMapData(obj.getRgdId(), geRefMap.getKey());
    MapData geMd = geMapDataList.isEmpty() ? null : (MapData) geMapDataList.get(0);
%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script>
    let reportTitle = "<%=geTypeLabel.toLowerCase()%>";
</script>

<div id="page-container" class="<%=reportSkinClass%>">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(obj.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">

        <%-- the same hero every other report page carries; this file only says what the
             genomic element puts in it --%>
        <%
            heroEyebrow = geTypeLabel + " Report";
            heroTitle = obj.getSymbol();
            heroSubtitle = Utils.NVL(obj.getName(), "");
            heroSpeciesKey = obj.getSpeciesTypeKey();
            heroRgdId = obj.getRgdId();
            if( !geType.isEmpty() ) {
                heroChips.add("|" + geType);
            }
            if( geMd!=null && geMd.getChromosome()!=null ) {
                heroChips.add("fa-map-marker|chr" + geMd.getChromosome() + ":" + geMd.getStartPos() + "-" + geMd.getStopPos()
                        + "|" + geRefMap.getName());
            }
            if( !Utils.isStringEmpty(obj.getSource()) ) {
                heroChips.add("fa-database|" + obj.getSource() + "|source");
            }
        %>
        <%@ include file="../reportHero.jsp"%>

        <%@ include file="menu.jsp"%>

        <% if (view.equals("3")) { %>

        <% } else if (!obj.getObjectStatus().equals("ACTIVE")) { %>
        <br><br>This object has been <%=obj.getObjectStatus()%>.<br><br>

        <% } else {%>

        <%-- the legacy 95% layout table that wraps every report body; reportModern.css
             neutralises it (transparent, table-layout:fixed) so it only pins the body column.
             Its third column used to hold ../idInfo.jsp, which every other report has already
             dropped - the same identifiers are in the summary card and the hero's RGD chip. --%>
        <table width="95%" border="0">
            <tr>
                <td>
                    <%@ include file="info.jsp"%>

                    <%-- each subTitle carries an id so it reaches the sidebar nav and the
                         collapse-all control, the way the other report pages do --%>
                    <div class="subTitle" id="region">Region</div>
                    <%@ include file="../sequence.jsp"%>
                    <%@ include file="../pubMedReferences.jsp"%>

                    <div class="subTitle" id="sequence">Sequence</div>
                    <%@ include file="../nucleotide.jsp"%>
                    <%@ include file="../proteins.jsp"%>

                    <div class="subTitle" id="additionalInformation">Additional Information</div>
                    <%@ include file="../xdbs.jsp"%>
                </td>
            </tr>
        </table>

        <% } %>
    </div><%-- /#content-wrap --%>
</div><%-- /#page-container --%>

<%--
    #content-wrap and #page-container close outside the view branch on purpose. The other
    report pages close theirs inside the final else, so the retired-object and view=3 paths
    emit tags that never close; keeping them here means every path through this page produces
    a well-formed document.
--%>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>

<script src="/rgdweb/js/reportPages/geneReport.js?v=21"> </script>
<script src="/rgdweb/js/reportPages/reportModernUx.js?v=6"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=5"> </script>
