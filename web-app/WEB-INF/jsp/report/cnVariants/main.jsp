<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantSampleDetail" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>

<% boolean includeMapping = true;
    String title = "Variant";
    VariantMapData var = (VariantMapData) request.getAttribute("reportObject");
    String objectType="RgdVariant";
    String displayName;
    if (var.getMapKey()==17 || var.getMapKey()==38)
        displayName = Utils.isStringEmpty(var.getClinvarId()) ? "RGD:"+var.getId(): var.getClinvarId();
    else
        displayName = Utils.isStringEmpty(var.getRsId()) ? "RGD:"+var.getId() : var.getRsId();
    boolean isGwas = false;
    RgdId obj = managementDAO.getRgdId2((int)var.getId());
    VariantDAO vdao = new VariantDAO();
    SampleDAO sdao = new SampleDAO();
    sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    List<VariantSampleDetail> sampleDetails = vdao.getVariantSampleDetail(obj.getRgdId());
    Map refMap = mapDAO.getPrimaryRefAssembly(var.getSpeciesTypeKey());
    List mapDataList = mapDAO.getMapData((int)var.getId(), refMap.getKey());
    List<XdbId> ei1 = DaoUtils.getInstance().getExternalDbLinks(obj.getRgdId(), obj.getSpeciesTypeKey());
    MapData md = new MapData();
    if (mapDataList.size() > 0) {
        md = (MapData) mapDataList.get(0);
    }

    String pageTitle = displayName + " " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = pageTitle;

    String ontId = "SO", ontTerm = "SNV";
    switch (var.getVariantType()){
        case "snv":
            ontTerm = "SNV";
            break;
        case "mnv":
            ontTerm = "MNV";
            break;
        case "ins":
            ontTerm = "insertion";
            break;
        case "del":
            ontTerm = "deletion";
            break;
        default:
            ontTerm = var.getVariantType();
            break;
    }
    OntologyXDAO odao = new OntologyXDAO();
    List<Term> ontTerms = new ArrayList<>();
    GWASCatalogDAO gwasDao = new GWASCatalogDAO();
    GWASCatalog gwas = gwasDao.getGWASCatalogByVariantRgdId(obj.getRgdId());
    try {
        String gwasTerms = gwas.getEfoId().replace('_', ':');
        String[] terms = gwasTerms.split(",");
        for (String termAcc : terms){
            if (termAcc.contains("Orphanet") || termAcc.contains("NCIT") )
                continue;
            String trimmed = termAcc.trim();
//                System.out.println(trimmed);
            Term term = odao.getTermByAccId(trimmed);
            ontTerms.add(term);
        }
        isGwas = true;
//            ontTerms = odao.getTermByAccId(terms); // fix by trimming \\s
        Term t = odao.getTermByTermName(ontTerm, ontId);
        ontTerms.add(t);
    }
    catch (Exception e){
        isGwas = false;
        Term t = odao.getTermByTermName(ontTerm, ontId);
        ontTerms.add(t);
    }
    HashMap<String,Boolean> sources = new HashMap<>();
    List<VariantSampleDetail> col = new ArrayList<>();
    List<Sample> samples = new ArrayList<>();
    for (VariantSampleDetail vsd : sampleDetails){
        Sample s = sdao.getSampleBySampleId(vsd.getSampleId());
        if (sources.get(s.getAnalysisName())==null) {
            samples.add(s);
            sources.put(s.getAnalysisName(), true);
            col.add(vsd);
        }
    }
%>

<div id="top" ></div>


<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script>
    let reportTitle = "rgdvariant";
</script>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(var.getSpeciesTypeKey())%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>


    <div id="content-wrap">


<table width="95%" border="0">
    <tr>
        <td>

            <%@ include file="info.jsp"%>
            <br><div class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation');">Click to see Annotation Detail View</a></div><br>

            <div id="associationsCurator" style="display:none;">
                <%@ include file="../associationsCurator.jsp"%>
            </div>
            <div id="associationsStandard" style="display:block;">
                <%@ include file="../associations.jsp"%>
            </div>

            <br><div class="subTitle" id="variantDetails">Variant Details</div>
            <div id="transcripts">
                <%@ include file="transcripts.jsp"%>
            </div>
            <div id="samples">
                <%@ include file="samples.jsp"%>
            </div>
            <div id="pubMed">
                <%@ include file="../pubMedReferences.jsp"%>
                <%@ include file="pubMed.jsp"%>
            </div>
            <%if (!ei1.isEmpty()) {%>
            <br><div  class="subTitle">Additional Information</div>
            <br>
                <%@ include file="../xdbs.jsp"%>
            <% } %>


<%--            <%@ include file="../relatedStrains.jsp"%>--%>
<%--        <%@ include file="../references.jsp"%>--%>
<%--        <%@ include file="../pubMedReferences.jsp"%>--%>

<%--    <br><div  class="subTitle">Additional Information</div>--%>
<%--    <br>--%>
<%--    <%@ include file="../xdbs.jsp"%>--%>
<%--    </td>--%>
<%--    <td>&nbsp;</td>--%>
<%--    <td valign="top">--%>
<%--        <%@ include file="../idInfo.jsp" %>--%>
<%--    </td>--%>
    </tr>
 </table>
    </div>
</div>
<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>