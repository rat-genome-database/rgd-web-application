<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotController" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    OntAnnotBean bean = new OntAnnotBean();

    String accId = request.getAttribute("ontId").toString();
    String species = "Rat";
    String displayDescendants = "1";
    String sortBy = "";
    String sortDesc = "";
    String objectKey = Integer.toString(RgdId.OBJECT_KEY_STRAINS);
    String extView = null; // no extended view
    OntAnnotController.loadAnnotations(bean, ontologyDAO, accId, species, displayDescendants, sortBy, sortDesc, objectKey,
            extView, OntAnnotBean.MAX_ANNOT_COUNT);

    if( bean.getPhenoCmoTerms().size() + bean.getPhenoMmoTerms().size() + bean.getPhenoStrains().size()
            + bean.getPhenoXcoTerms().size() > 0 ) {
%>

<%--<%=ui.dynOpen("phenominerAssociationC", "Phenotype Values via PhenoMiner")%>--%>
<div id="phenominerAssociationCTableDiv" class="light-table-border">
<div class="sectionHeading" id="phenominerAssociationC">Phenotype Values via PhenoMiner
    <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenominerAssociationCTableDiv', 'phenominerAssociationTableWrapper');">Click to see Annotation Detail View</a>
</div>
<%@ include file="../../ontology/phenoTable.jsp"%>
<%--<%=ui.dynClose("phenominerAssociationC")%>--%>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>