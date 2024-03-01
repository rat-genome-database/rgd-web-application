<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotController" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    OntAnnotBean bean = new OntAnnotBean();

    int rgdId = obj.getRgdId();
    String species = "Rat";
    String displayDescendants = "1";
    String sortBy = "";
    String sortDesc = "";
    String objectKey = Integer.toString(RgdId.OBJECT_KEY_REFERENCES);
    String extView = null; // no extended view
    OntAnnotController.loadAnnotationsForReference(bean, ontologyDAO, rgdId, species, displayDescendants, sortBy, sortDesc, objectKey,
            extView, OntAnnotBean.MAX_ANNOT_COUNT);

    if( bean.getPhenoCmoTerms().size() + bean.getPhenoMmoTerms().size() + bean.getPhenoStrains().size()
            + bean.getPhenoXcoTerms().size() > 0 ) {
%>



<div id="phenominerAssociationCTableDiv" class="light-table-border">
    <h3>Related Phenotype Data for this Reference</h3>

    <table>
        <tr>
            <td><b>Phenominer Options:&nbsp;</b></td>
            <td><a href="/rgdweb/phenominer/table.html?species=3&refRgdId=<%=obj.getRgdId()%>#ViewChart">View all phenotype data for this reference</a></td>
            <td>&nbsp;|&nbsp;</td>
            <td><a href="/rgdweb/phenominer/table.html?species=3&fmt=3&refRgdId=<%=obj.getRgdId()%>">Download all phenotype data for this reference</a></td>
        </tr>
    </table>
<br>
    Select a value below to view phenotype data for a specific strain, measurment, or condition.
    <br><br>
    <div>

        <table cellspacing='3px' border='0'>
            <tr>
                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Rat Strains:</div>
                    <ul>
<%--                         if( bean.getAccId().startsWith("RS:") ) {--%>
                    <%    for( Term term: bean.getPhenoStrains() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=rgdId%>" title="view strain phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
<%--                        } else {--%>
<%--                            for( Term term: bean.getPhenoStrains() ) { %>--%>
<%--                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view strain phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>--%>
<%--                        <% }--%>
<%--                        }%>--%>
                    </ul>
                </td>

                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Clinical Measurements:</div>
                    <ul>
<%--                        if( bean.getAccId().startsWith("CMO:") ) {--%>
                        <%   for( Term term: bean.getPhenoCmoTerms() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=rgdId%>" title="view clinical measurement phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
<%--                        } else {--%>
<%--                            for( Term term: bean.getPhenoCmoTerms() ) { %>--%>
<%--                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view clinical measurement phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>--%>
<%--                        <% }--%>
<%--                        }%>--%>
                    </ul>
                </td>
                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Experimental Conditions:</div>
                    <ul>
<%--                         if( bean.getAccId().startsWith("XCO:") ) {--%>
                        <%   for( Term term: bean.getPhenoXcoTerms() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=rgdId%>" title="view experimental condition phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
<%--                        } else {--%>
<%--                            for( Term term: bean.getPhenoXcoTerms() ) { %>--%>
<%--                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view experimental condition phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>--%>
<%--                        <% }--%>
<%--                        }%>--%>
                    </ul>
                </td>
                <td valign='top' style='vertical-align: top;'>
                    <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Measurement Methods:</div>
                    <ul>
<%--                         if( bean.getAccId().startsWith("MMO:") ) {--%>
                        <%   for( Term term: bean.getPhenoMmoTerms() ) { %>
                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>&refRgdId=<%=rgdId%>" title="view measurement method phenotype data"><%=term.getTerm()%></a></li>
                        <%    } %>
<%--                        } else {--%>
<%--                            for( Term term: bean.getPhenoMmoTerms() ) { %>--%>
<%--                        <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view measurement method phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>--%>
<%--                        <% }--%>
<%--                        }%>--%>
                    </ul>
                </td>
            </tr>
        </table>
    </div>
</div>

<% } %>
<%@ include file="../sectionFooter.jsp"%>