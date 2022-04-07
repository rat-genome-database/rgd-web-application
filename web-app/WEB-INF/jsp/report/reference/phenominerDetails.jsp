<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotController" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ include file="../sectionHeader.jsp"%>
<%  int j = 1;
    for (int i = 0; i < strains.size(); i++){
    OntAnnotBean bean = new OntAnnotBean();

    String accId = ontologyDAO.getStrainOntIdForRgdId(strains.get(i).getAnnotatedObjectRgdId());
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

<%--<%=ui.dynOpen("phenominerAssociationC", "Phenotype Values via Phenominer")%>--%>
<div id="phenominerAssociationC<%out.print(j);%>TableDiv" class="light-table-border">
<div class="sectionHeading" id="phenominerAssociationC<%out.print(j);%>">Phenominer - <%out.print(strains.get(i).getObjectSymbol());%>
    <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenominerAssociationC<%out.print(j);%>TableDiv', 'phenominerAssociationTable<%out.print(j);%>Wrapper');">Click to see Annotation Detail View</a>
</div>
<%@ include file="../../ontology/phenoTable.jsp"%>
<%--<%=ui.dynClose("phenominerAssociationC")%>--%>
</div>
<% j++;}
}%>
<%@ include file="../sectionFooter.jsp"%>