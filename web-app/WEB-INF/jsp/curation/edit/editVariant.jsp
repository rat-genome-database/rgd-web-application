<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String pageTitle = "Edit Variant";
    String headContent = "";
    String pageDescription = "";
    try {
%>

<%@ include file="/common/headerarea.jsp" %>
<%@ include file="editHeader.jsp" %>

<%
    Variants variants = (Variants) request.getAttribute("editObject");

    int rgdId = variants.getRgdId();
    int displayRgdId = rgdId;


    if (isClone) {
        Variants clone = (Variants) request.getAttribute("cloneObject");
        variants = clone;
        displayRgdId = variants.getRgdId();
    }
    AssociationDAO associationDAO = new AssociationDAO();
    String references= (String) request.getAttribute("references");
%>

<h1>Edit Variant: </h1>


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
                        <td><input name="name" type="text" size="45" value="<%=dm.out("name",variants.getName())%>"/></td>
                    </tr>
                    <tr>
                        <td class="label">Description:</td>
                        <td><input name="description" type="text" size="45"
                                   value="<%=dm.out("description",variants.getDescription())%>"/></td>
                    </tr>
                    <tr>
                    <td class="label">SO ACC ID:</td>
                    <td><input name="type" type="text" size="30" value="<%=dm.out("type",variants.getType())%>"/></td>
                    </tr>

                    <tr>
                        <td class="label">Reference Nucleotide</td>
                        <td><input name="refNuc" type="text" size="5" value="<%=dm.out("refNuc",variants.getRef_nuc())%>"/></td>
                    </tr>
                    <tr>
                        <td class="label">Variant Nucleotide</td>
                        <td><input name="varNuc" type="text" size="5" value="<%=dm.out("varNuc",variants.getVar_nuc())%>"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="label">Notes</td>
                        <td><input name="notes" type="text" size="100" value="<%=dm.out("notes",variants.getNotes())%>"/></td>
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
<%@ include file="curatedReferencesData.jsp" %>
<%@ include file="geneAssociationData.jsp" %>
<%@ include file="aliasData.jsp" %>
<%@ include file="externalLinksData.jsp" %>
<%@ include file="/common/footerarea.jsp" %>

<% } catch (Exception e) {
    e.printStackTrace();
}
%>