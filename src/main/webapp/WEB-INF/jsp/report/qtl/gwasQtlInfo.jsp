<%@ page import="edu.mcw.rgd.datamodel.GWASCatalog" %>
<%@ page import="edu.mcw.rgd.dao.impl.GWASCatalogDAO" %>
<%-- get GWAS data directly associated with QTL based on rgd_id --%>
<%@ include file="../sectionHeader.jsp"%>
<%
    GWASCatalogDAO gdao = new GWASCatalogDAO();
    OntologyXDAO odao = new OntologyXDAO();
    GWASCatalog gwasData = gdao.getGwasCatalogByQTLRgdId(obj.getRgdId());
    List<GWASCatalog> gwasList = gdao.getGWASListByRsId(obj.getPeakRsId());
//    boolean isGwas = true;
%>


<%-- related GWAS QTLS, get gwas from rsID and link to qtl --%>
<%@ include file="../cnVariants/gwasData.jsp"%>

<%@ include file="../sectionFooter.jsp"%>