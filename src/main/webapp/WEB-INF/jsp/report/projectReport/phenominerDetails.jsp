<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotController" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    OntAnnotBean bean = new OntAnnotBean();

//    int rgdId = obj.getRgdId();
    List<Integer>rgdId=new ProjectDAO().getReferenceRgdIdsForProject(obj.getRgdId());
    String species = "Rat";
    String displayDescendants = "1";
    String sortBy = "";
    String sortDesc = "";
    String objectKey = Integer.toString(RgdId.OBJECT_KEY_REFERENCES);
    boolean divRendered = false;
    String extView = null; // no extended view
%>
<%--<div class="sectionHeading" id="phenominerAssociationC">Phenotype Values <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenominerAssociationCTableDiv', 'phenominerAssociationTableWrapper');">Click to see Annotation Detail View</a></div>--%>
<%
    for(Integer refId:rgdId){
        OntAnnotController.loadAnnotationsForReference(bean, ontologyDAO, refId, species, displayDescendants, sortBy, sortDesc, objectKey,
                extView, OntAnnotBean.MAX_ANNOT_COUNT);

        if( bean.getPhenoCmoTerms().size() + bean.getPhenoMmoTerms().size() + bean.getPhenoStrains().size()
                + bean.getPhenoXcoTerms().size() > 0 ) {
%>
<%if(!divRendered){%>
<div class="sectionHeading" id="phenominerAssociationC">Phenotype Values <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenominerAssociationCTableDiv', 'phenominerAssociationTableWrapper');">Click to see Annotation Detail View</a></div>
<%
        divRendered = true;
    }%>
<div id="phenominerAssociationCTableDiv" class="light-table-border">
    <div>
        <h3>Related Phenotype Data of Reference RGD:<%=refId%></h3>
        <table cellspacing='3px' border='0'>
            <tr>
                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Rat Strains:</div>
                    <ul>
                        <%    for( Term term: bean.getPhenoStrains() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view strain phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
                    </ul>
                </td>

                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Clinical Measurements:</div>
                    <ul>
                        <%   for( Term term: bean.getPhenoCmoTerms() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view clinical measurement phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
                    </ul>
                </td>
                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Experimental Conditions:</div>
                    <ul>
                        <%   for( Term term: bean.getPhenoXcoTerms() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view experimental condition phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
                    </ul>
                </td>
                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Measurement Methods:</div>
                    <ul>
                        <%   for( Term term: bean.getPhenoMmoTerms() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view measurement method phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
                    </ul>
                </td>
            </tr>
        </table>
    </div>
</div>
<% } %>
<% } %>

<%--<div id="phenominerAssociationCTableDiv" class="light-table-border">--%>
<%--    <div class="sectionHeading" id="phenominerAssociationC">Phenotype Values <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenominerAssociationCTableDiv', 'phenominerAssociationTableWrapper');">Click to see Annotation Detail View</a></div>--%>
<%--    <br><h3>Related Phenotype Data For References</h3>--%>
<%--    <table border="0" cellspacing="0" cellpadding="0" style='border-collapse: collapse;'>--%>
<%--        <thead>--%>
<%--        <tr>--%>
<%--            <td style='font-weight: 700;'>Rat Strains:</td>--%>
<%--            <td style='font-weight: 700;'>Clinical Measurements:</td>--%>
<%--            <td style='font-weight: 700;'>Experimental Conditions:</td>--%>
<%--            <td style='font-weight: 700;'>Measurement Methods:</td>--%>
<%--        </tr>--%>
<%--        </thead>--%>
<%--        <tbody>--%>
<%--        <%--%>
<%--            for(Integer refId:rgdId){--%>
<%--                OntAnnotController.loadAnnotationsForReference(bean, ontologyDAO, refId, species, displayDescendants, sortBy, sortDesc, objectKey,--%>
<%--                        extView, OntAnnotBean.MAX_ANNOT_COUNT);--%>

<%--                if( bean.getPhenoCmoTerms().size() + bean.getPhenoMmoTerms().size() + bean.getPhenoStrains().size()--%>
<%--                        + bean.getPhenoXcoTerms().size() > 0 ) {--%>
<%--        %>--%>
<%--        <tr>--%>
<%--            <td valign='top' style='vertical-align: top;'>--%>
<%--                <ul>--%>
<%--                    <% for( Term term: bean.getPhenoStrains() ) { %>--%>
<%--                    <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view strain phenotype data"><%=term.getTerm()%></a></li>--%>
<%--                    <% } %>--%>
<%--                </ul>--%>
<%--            </td>--%>
<%--            <td valign='top' style='vertical-align: top;'>--%>
<%--                <ul>--%>
<%--                    <% for( Term term: bean.getPhenoCmoTerms() ) { %>--%>
<%--                    <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view clinical measurement phenotype data"><%=term.getTerm()%></a></li>--%>
<%--                    <% } %>--%>
<%--                </ul>--%>
<%--            </td>--%>
<%--            <td valign='top' style='vertical-align: top;'>--%>
<%--                <ul>--%>
<%--                    <% for( Term term: bean.getPhenoXcoTerms() ) { %>--%>
<%--                    <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view experimental condition phenotype data"><%=term.getTerm()%></a></li>--%>
<%--                    <% } %>--%>
<%--                </ul>--%>
<%--            </td>--%>
<%--            <td valign='top' style='vertical-align: top;'>--%>
<%--                <ul>--%>
<%--                    <% for( Term term: bean.getPhenoMmoTerms() ) { %>--%>
<%--                    <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=refId%>" title="view measurement method phenotype data"><%=term.getTerm()%></a></li>--%>
<%--                    <% } %>--%>
<%--                </ul>--%>
<%--            </td>--%>
<%--        </tr>--%>
<%--        <%--%>
<%--                }--%>
<%--            }--%>
<%--        %>--%>
<%--        </tbody>--%>

<%--    </table>--%>
<%--</div>--%>


<%@ include file="../sectionFooter.jsp"%>