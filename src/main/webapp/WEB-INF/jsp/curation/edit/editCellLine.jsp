<%
    String pageTitle = "Edit Cell Line";
    String headContent = "";
    String pageDescription = "";
    
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>

<%
    CellLine cellLine = (CellLine) request.getAttribute("editObject");
    int rgdId = cellLine.getRgdId();

    int displayRgdId = rgdId;
%>

<% if( rgdId<=0  ){ %>
<h1>Create Cell Line</h1>
<% } else { %>
<h1>Edit Cell Line: <%=dm.out("symbol", cellLine.getSymbol())%></h1>
<% } %>

<form action="editCellLine.html" method="get">
 <input type="hidden" name="rgdId" value="<%=rgdId%>" />
 <input type="hidden" name="act" value="<%=rgdId<=0?"add":"upd"%>" />
 <input type="hidden" name="speciesType" value="<%=request.getParameter("speciesType")%>" />
 <input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>" />

<table>
    <tr>
        <td valign="top">
            <table >
                <tr>
                    <td class="label">Rgd Id:</td>
                    <td><%=rgdId%></td>
                </tr>
                <tr>
                    <td class="label">Cell Line Type:</td>
                    <td><input type="text" name="object_type" size="15" value="<%=dm.out("object_type",cellLine.getObjectType())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Symbol:</td>
                    <td><input type="text" name="symbol" size="45" value="<%=dm.out("symbol",cellLine.getSymbol())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Full Name:</td>
                    <td><input type="text" name="name" size="45" value="<%=dm.out("name",cellLine.getName())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Origin:</td>
                    <td><textarea name="origin" cols="45" rows="5"><%=dm.out("origin",cellLine.getOrigin())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Gender:</td>
                    <td><input type="text" name="gender" size="15" value="<%=dm.out("gender",cellLine.getGender())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Germline Competent:</td>
                    <td><input type="text" name="germline_competent" size="15" value="<%=dm.out("germline_competent",cellLine.getGermlineCompetent())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Source:</td>
                    <td><input type="text" name="source" size="45" value="<%=dm.out("source",cellLine.getSource())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Research Use:</td>
                    <td><textarea name="research_use" cols="45" rows="5"><%=dm.out("research_use",cellLine.getResearchUse())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Availability:</td>
                    <td><textarea name="availability" cols="45" rows="5"><%=dm.out("availability",cellLine.getAvailability())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Characteristics:</td>
                    <td><textarea name="characteristics" cols="45" rows="5"><%=dm.out("characteristics",cellLine.getCharacteristics())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Phenotype:</td>
                    <td><textarea name="phenotype" cols="45" rows="5"><%=dm.out("phenotype",cellLine.getPhenotype())%></textarea></td>
                </tr>

                <tr>
                    <td class="label">Other:</td>
                    <td><textarea name="description" cols="45" rows="4"><%=dm.out("description",cellLine.getDescription())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Notes:</td>
                    <td><textarea name="notes" cols="45" rows="4"><%=dm.out("notes",cellLine.getNotes())%></textarea></td>
                </tr>


                <tr>
                    <td colspan="2" align="center">
                        <% if( rgdId<=0 ) { %>
                        <input type="submit" value="Create Cell Line" />
                        <% } else { %>
                        <input type="button" value="Update Cell Line" onclick="makePOSTRequest(this.form)"/>
                        <% } %>
                    </td>
                </tr>
            </table>
        </td>
        <td>&nbsp;</td>
        <td valign="top" align="center">
            <%@ include file="idInfo.jsp"%>
        </td>
    </tr>
</table>
</form>

<% if( rgdId>0 ) { %>
<%@ include file="aliasData.jsp" %>
<%
    String notesObjectType = "cell_lines";
%>
<%@ include file="notesData.jsp" %>
<%@ include file="cellLineAssociationData.jsp" %>
<% } %>

<%@ include file="/common/footerarea.jsp"%>

