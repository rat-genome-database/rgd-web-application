<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>

<%
    String pageTitle = "Edit Variant";
    String headContent = "";
    String pageDescription = "";
    try {
%>

<%@ include file="/common/headerarea.jsp" %>
<%@ include file="editHeader.jsp" %>

<%
    RgdVariant variant = (RgdVariant) request.getAttribute("editObject");

    int rgdId = variant.getRgdId();
    int displayRgdId = rgdId;


    if (isClone) {
        RgdVariant clone = (RgdVariant) request.getAttribute("cloneObject");
        variant = clone;
        displayRgdId = variant.getRgdId();
    }
    AssociationDAO associationDAO = new AssociationDAO();
    String references= (String) request.getAttribute("references");
 if( rgdId<=0  ){ %>
<h1>Create Variant</h1>
<% } else { %>
<h1>Edit Variant: <%=dm.out("name", variant.getName())%></h1>
<% } %>

<table>
    <tr>
        <td  valign="top">

            <form action="editVariant.html" >
                <input type="hidden" name="rgdId" value="<%=rgdId + ""%>"/>
                <input type="hidden" name="references" value="<%=references%>"/>
                <% if (isNew) {%>
                <input type="hidden" name="act" value="add"/>
                <% } else { %>
                <input type="hidden" name="act" value="upd"/>
                <% } %>
                <%
                    String species = request.getParameter("speciesType");

                %>
                <input type="hidden" name="speciesType" value="<%=species%>"/>
                <input type="hidden" name="objectType" value="<%=request.getParameter("objectType")%>"/>
                <input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>"/>

                <table border="0" width="600" >

                    <tr>
                        <td class="label">Name:</td>
                        <td><input name="name" type="text" size="65" value="<%=dm.out("name",variant.getName())%>"/></td>
                    </tr>
                    <tr>
                        <td class="label">Description:</td>
<%--                        <td><input name="description" type="text" size="65"--%>
<%--                                   value="<%=dm.out("description",variant.getDescription())%>"/></td>--%>
                        <td><textarea rows="4" cols="70" name="description"><%=dm.out("description",variant.getDescription())%></textarea></td>
                    </tr>
                    <tr>
                    <td class="label">SO ACC ID:</td>
                    <td><input name="type" type="text" size="25" value="<%=dm.out("type",variant.getType())%>"/></td>
                    </tr>

                    <tr>
                        <td class="label">Reference Nucleotide</td>
                        <td><input name="refNuc" type="text" size="80" value="<%=dm.out("refNuc",variant.getRefNuc())%>"/></td>
                    </tr>
                    <tr>
                        <td class="label">Variant Nucleotide</td>
                        <td><input name="varNuc" type="text" size="80" value="<%=dm.out("varNuc",variant.getVarNuc())%>"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="label">Notes</td>
                        <td><textarea rows="4" cols="70" name="notes"><%=dm.out("notes",variant.getNotes())%></textarea></td>
                    </tr>

                    <tr>
                        <td colspan="2" align="center">
                            <% if (isNew) { %>
                            <input type="submit" value="Add Variant" />
                            <% } else {%>
                            <input type="button" value="Update Variant" onclick="makePOSTRequest(this.form)"/>
                            <% } %>
                        </td>
                    </tr>
                </table>
            </form>

        </td>
        <td>&nbsp;&nbsp;</td>
        <td valign="top">
            <%@ include file="idInfo.jsp" %>
            <br>
            <!--%@ include file="mapData.jsp" %>-->
        </td>
    </tr>
</table>
<%@ include file="mapData.jsp" %>
<%@ include file="variant2geneAssociationData.jsp" %>
<%@ include file="curatedReferencesData.jsp" %>
<%@ include file="geneAssociationData.jsp" %>
<%@ include file="aliasData.jsp" %>
<%@ include file="externalLinksData.jsp" %>
<%@ include file="/common/footerarea.jsp" %>

<% } catch (Exception e) {
    e.printStackTrace();
}
%>